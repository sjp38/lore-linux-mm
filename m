Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id DD2186B0253
	for <linux-mm@kvack.org>; Tue, 13 Oct 2015 09:58:43 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so22402108pad.1
        for <linux-mm@kvack.org>; Tue, 13 Oct 2015 06:58:43 -0700 (PDT)
Received: from smtprelay.synopsys.com (smtprelay4.synopsys.com. [198.182.47.9])
        by mx.google.com with ESMTPS id wv8si5304934pbc.216.2015.10.13.06.58.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Oct 2015 06:58:43 -0700 (PDT)
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: pmd_modify() semantics
Date: Tue, 13 Oct 2015 13:58:39 +0000
Message-ID: <C2D7FE5348E1B147BCA15975FBA23075D781CC4F@IN01WEMBXB.internal.synopsys.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Minchan Kim <minchan@kernel.org>

Hi Kirill,=0A=
=0A=
I'm running LTP tests on the new ARC THP code and thp03 seems to be trigger=
ing mm=0A=
spew.=0A=
=0A=
--------------->8---------------------=0A=
[ARCLinux]# ./ltp-thp03-extract=0A=
PID 60=0A=
bad pmd bf1c4600 be600231=0A=
../mm/pgtable-generic.c:34: bad pgd be600231.=0A=
bad pmd bf1c4604 bd800231=0A=
../mm/pgtable-generic.c:34: bad pgd bd800231.=0A=
BUG: Bad rss-counter state mm:bf12e900 idx:1 val:512=0A=
BUG: non-zero nr_ptes on freeing mm: 2=0A=
--------------->8---------------------=0A=
=0A=
I know what exactly is happening and the likely fix, but would want to get =
some=0A=
thoughts from you if possible.=0A=
=0A=
background: ARC is software page walked with PGD -> PTE -> page for normal =
and PMD=0A=
-> page for THP case. A vanilla PGD doesn't have any flags - only pointer t=
o PTE=0A=
=0A=
A reduced version of thp03 allocates a THP, dirties it, followed by=0A=
mprotect(PROT_NONE).=0A=
At the time of mprotect() -> change_huge_pmd() -> pmd_modify() needs to cha=
nge=0A=
some of the bits.=0A=
=0A=
The issue is ARC implementation of pmd_modify() based on pte variant, which=
=0A=
retains the soft pte bits (dirty and accessed).=0A=
=0A=
static inline pmd_t pmd_modify(pmd_t pmd, pgprot_t newprot)=0A=
{=0A=
    return pte_pmd(pte_modify(pmd_pte(pmd), newprot));=0A=
}=0A=
=0A=
Obvious fix is to rewrite pmd_modify() so that it clears out all pte type f=
lags=0A=
but that assumes PMD is becoming PGD (a vanilla PGD on ARC doesn't have any=
=0A=
flags). Can we have pmd_modify() ever be called for NOT splitting pmd e.g.=
=0A=
mprotect Write to Read which won't split the THP like it does now and simpl=
y=0A=
changes the prot flags. My proposed version of pmd_modify() will loose the =
dirty bit.=0A=
=0A=
In short, what are the semantics of pmd_modify() - essentially does it impl=
y pmd=0A=
is being split so are free to make it like PGD.=0A=
=0A=
TIA,=0A=
-Vineet=0A=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
