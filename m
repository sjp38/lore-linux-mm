Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 419466B0254
	for <linux-mm@kvack.org>; Wed, 14 Oct 2015 02:34:05 -0400 (EDT)
Received: by pabws5 with SMTP id ws5so14264706pab.1
        for <linux-mm@kvack.org>; Tue, 13 Oct 2015 23:34:05 -0700 (PDT)
Received: from smtprelay.synopsys.com (us01smtprelay-2.synopsys.com. [198.182.47.9])
        by mx.google.com with ESMTPS id ow7si10795925pbb.237.2015.10.13.23.34.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Oct 2015 23:34:04 -0700 (PDT)
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: Re: pmd_modify() semantics
Date: Wed, 14 Oct 2015 06:33:59 +0000
Message-ID: <C2D7FE5348E1B147BCA15975FBA23075D781CDBF@IN01WEMBXB.internal.synopsys.com>
References: <C2D7FE5348E1B147BCA15975FBA23075D781CC4F@IN01WEMBXB.internal.synopsys.com>
 <20151013160656.GA14071@node>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Minchan Kim <minchan@kernel.org>

On Tuesday 13 October 2015 09:37 PM, Kirill A. Shutemov wrote:=0A=
> On Tue, Oct 13, 2015 at 01:58:39PM +0000, Vineet Gupta wrote:=0A=
>> Hi Kirill,=0A=
>>=0A=
>> I'm running LTP tests on the new ARC THP code and thp03 seems to be trig=
gering mm=0A=
>> spew.=0A=
>>=0A=
>> --------------->8---------------------=0A=
>> [ARCLinux]# ./ltp-thp03-extract=0A=
>> PID 60=0A=
>> bad pmd bf1c4600 be600231=0A=
>> ../mm/pgtable-generic.c:34: bad pgd be600231.=0A=
>> bad pmd bf1c4604 bd800231=0A=
>> ../mm/pgtable-generic.c:34: bad pgd bd800231.=0A=
>> BUG: Bad rss-counter state mm:bf12e900 idx:1 val:512=0A=
>> BUG: non-zero nr_ptes on freeing mm: 2=0A=
>> --------------->8---------------------=0A=
>>=0A=
>> I know what exactly is happening and the likely fix, but would want to g=
et some=0A=
>> thoughts from you if possible.=0A=
>>=0A=
>> background: ARC is software page walked with PGD -> PTE -> page for norm=
al and PMD=0A=
>> -> page for THP case. A vanilla PGD doesn't have any flags - only pointe=
r to PTE=0A=
>>=0A=
>> A reduced version of thp03 allocates a THP, dirties it, followed by=0A=
>> mprotect(PROT_NONE).=0A=
>> At the time of mprotect() -> change_huge_pmd() -> pmd_modify() needs to =
change=0A=
>> some of the bits.=0A=
>>=0A=
>> The issue is ARC implementation of pmd_modify() based on pte variant, wh=
ich=0A=
>> retains the soft pte bits (dirty and accessed).=0A=
>>=0A=
>> static inline pmd_t pmd_modify(pmd_t pmd, pgprot_t newprot)=0A=
>> {=0A=
>>     return pte_pmd(pte_modify(pmd_pte(pmd), newprot));=0A=
>> }=0A=
>>=0A=
>> Obvious fix is to rewrite pmd_modify() so that it clears out all pte typ=
e flags=0A=
>> but that assumes PMD is becoming PGD (a vanilla PGD on ARC doesn't have =
any=0A=
>> flags). Can we have pmd_modify() ever be called for NOT splitting pmd e.=
g.=0A=
>> mprotect Write to Read which won't split the THP like it does now and si=
mply=0A=
>> changes the prot flags. My proposed version of pmd_modify() will loose t=
he dirty bit.=0A=
> Hm? pmd_modify() is nothing to do with splitting. The mprotect() codepath=
=0A=
> you've mentioned above calls pmd_modify() only if the THP is fully in=0A=
> mprotect range.=0A=
=0A=
Indeed my mental picture of this was messed up - specially because behind t=
he=0A=
back, pmd_modify() for ARC (based on pte_modify()) was buggered to clear th=
e huge=0A=
page bit itself :-) So we had a THP PMD which would start failing for=0A=
pmd_trans_huge() and thus treated like a normal PGD. But it had the leftove=
r PMD=0A=
soft bits, which triggered the MM spew.=0A=
=0A=
The localized fix is below, while better fix is to make pte_modify() only c=
lear=0A=
R-W-X bits (currently it clears everything except soft accessed/dirty bits)=
=0A=
=0A=
 static inline pmd_t pmd_modify(pmd_t pmd, pgprot_t newprot)=0A=
 {=0A=
-       return pte_pmd(pte_modify(pmd_pte(pmd), newprot));=0A=
+        /*=0A=
+         * open-coded pte_modify() additionally retaining HW_SZ bit=0A=
+         * otherwise, pmd_trans_huge() checks start failing=0A=
+         */=0A=
+        return __pmd((pmd_val(pmd) & (_PAGE_CHG_MASK | _PAGE_HW_SZ)) |=0A=
pgprot_val(newprot));=0A=
 }=0A=
=0A=
=0A=
>=0A=
>> In short, what are the semantics of pmd_modify() - essentially does it i=
mply pmd=0A=
>> is being split so are free to make it like PGD.=0A=
> No, pmd_modify() cannot make such assumption. That's just not true -- we=
=0A=
> don't split PMD in such codepath. And even if we do, we construct new PMD=
=0A=
> entry from scratch instead of modifying existing one.=0A=
>=0A=
> So the semantics of pmd_modify(): you can assume that the entry is=0A=
> pmd_large(), going to stay this way and you need to touch only=0A=
> protection-related bit.=0A=
=0A=
Thx !=0A=
=0A=
-Vineet=0A=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
