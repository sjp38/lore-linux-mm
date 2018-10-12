Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id C75EE6B0005
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 15:40:12 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id r81-v6so12764173pfk.11
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 12:40:12 -0700 (PDT)
Received: from smtprelay.synopsys.com (smtprelay4.synopsys.com. [198.182.47.9])
        by mx.google.com with ESMTPS id 65-v6si2214009pfd.39.2018.10.12.12.40.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Oct 2018 12:40:11 -0700 (PDT)
From: Vineet Gupta <vineet.gupta1@synopsys.com>
Subject: Re: [PATCH 12/18] arch/tlb: Clean up simple architectures
Date: Fri, 12 Oct 2018 19:40:04 +0000
Message-ID: <C2D7FE5348E1B147BCA15975FBA23075012B0ADA16@US01WEMBX2.internal.synopsys.com>
References: <20180926113623.863696043@infradead.org>
 <20180926114801.146189550@infradead.org>
 <C2D7FE5348E1B147BCA15975FBA23075012B09A59E@us01wembx1.internal.synopsys.com>
 <20181011150406.GL9848@hirez.programming.kicks-ass.net>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "will.deacon@arm.com" <will.deacon@arm.com>, "aneesh.kumar@linux.vnet.ibm.com" <aneesh.kumar@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "npiggin@gmail.com" <npiggin@gmail.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux@armlinux.org.uk" <linux@armlinux.org.uk>, "heiko.carstens@de.ibm.com" <heiko.carstens@de.ibm.com>, "riel@surriel.com" <riel@surriel.com>, Richard
 Henderson <rth@twiddle.net>, Mark Salter <msalter@redhat.com>, Richard Kuo <rkuo@codeaurora.org>, Michal Simek <monstr@monstr.eu>, Paul Burton <paul.burton@mips.com>, Greentime Hu <green.hu@gmail.com>, Ley Foon Tan <lftan@altera.com>, Jonas Bonn <jonas@southpole.se>, Helge Deller <deller@gmx.de>, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@pku.edu.cn>, Max Filippov <jcmvbkbc@gmail.com>, arcml <linux-snps-arc@lists.infradead.org>

On 10/11/2018 08:06 AM, Peter Zijlstra wrote:=0A=
> On Wed, Oct 03, 2018 at 05:03:50PM +0000, Vineet Gupta wrote:=0A=
>> On 09/26/2018 04:56 AM, Peter Zijlstra wrote:=0A=
>>> There are generally two cases:=0A=
>>>=0A=
>>>  1) either the platform has an efficient flush_tlb_range() and=0A=
>>>     asm-generic/tlb.h doesn't need any overrides at all.=0A=
>>>=0A=
>>>  2) or an architecture lacks an efficient flush_tlb_range() and=0A=
>>>     we override tlb_end_vma() and tlb_flush().=0A=
>>>=0A=
>>> Convert all 'simple' architectures to one of these two forms.=0A=
>>>=0A=
>>> --- a/arch/arc/include/asm/tlb.h=0A=
>>> +++ b/arch/arc/include/asm/tlb.h=0A=
>>> @@ -9,29 +9,6 @@=0A=
>>>  #ifndef _ASM_ARC_TLB_H=0A=
>>>  #define _ASM_ARC_TLB_H=0A=
>>>  =0A=
>>> -#define tlb_flush(tlb)				\=0A=
>>> -do {						\=0A=
>>> -	if (tlb->fullmm)			\=0A=
>>> -		flush_tlb_mm((tlb)->mm);	\=0A=
>>> -} while (0)=0A=
>>> -=0A=
>>> -/*=0A=
>>> - * This pair is called at time of munmap/exit to flush cache and TLB e=
ntries=0A=
>>> - * for mappings being torn down.=0A=
>>> - * 1) cache-flush part -implemented via tlb_start_vma( ) for VIPT alia=
sing D$=0A=
>>> - * 2) tlb-flush part - implemted via tlb_end_vma( ) flushes the TLB ra=
nge=0A=
>>> - *=0A=
>>> - * Note, read https://urldefense.proofpoint.com/v2/url?u=3Dhttp-3A__lk=
ml.org_lkml_2004_1_15_6&d=3DDwIBaQ&c=3DDPL6_X_6JkXFx7AXWqB0tg&r=3Dc14YS-cH-=
kdhTOW89KozFhBtBJgs1zXscZojEZQ0THs&m=3D5jiyvgRek4SKK5DUWDBGufVcuLez5G-jJCh3=
K-ndHsg&s=3D7uAzzw_jdAXMfb07B-vGPh3V1vggbTAsB7xL6Kie47A&e=3D=0A=
>>> - */=0A=
>>> -=0A=
>>> -#define tlb_end_vma(tlb, vma)						\=0A=
>>> -do {									\=0A=
>>> -	if (!tlb->fullmm)						\=0A=
>>> -		flush_tlb_range(vma, vma->vm_start, vma->vm_end);	\=0A=
>>> -} while (0)=0A=
>>> -=0A=
>>> -#define __tlb_remove_tlb_entry(tlb, ptep, address)=0A=
>>> -=0A=
>>>  #include <linux/pagemap.h>=0A=
>>>  #include <asm-generic/tlb.h>=0A=
>> LGTM per discussion in an earlier thread. However given that for "simple=
r" arches=0A=
>> the whole series doesn't apply can you please beef up the changelog so I=
 don't go=0A=
>> scratching my head 2 years down the line. It currently describes the how=
s of=0A=
>> things but not exactly whys: shift_arg_pages missing tlb_start_vma,=0A=
>> move_page_tables look dodgy, yady yadda ?=0A=
> Right you are. Thanks for pointing out the somewhat sparse Changelog;=0A=
> typically I end up kicking myself a few years down the line.=0A=
>=0A=
> I think I will in fact change the implementation a little and provide a=
=0A=
> symbol/Kconfig to switch the default implementation between=0A=
> flush_tlb_vma() and flush_tlb_mm().=0A=
>=0A=
> That avoids some of the repetition. But see here a preview of the new=0A=
> Changelog, does that clarify things enough?=0A=
>=0A=
> ---=0A=
> Subject: arch/tlb: Clean up simple architectures=0A=
> From: Peter Zijlstra <peterz@infradead.org>=0A=
> Date: Tue Sep 4 17:04:07 CEST 2018=0A=
>=0A=
> The generic mmu_gather implementation is geared towards range tracking=0A=
> and provided the architecture provides a fairly efficient=0A=
> flush_tlb_range() implementation (or provides a custom tlb_flush()=0A=
> implementation) things will work well.=0A=
>=0A=
> The one case this doesn't cover well is where there is no (efficient)=0A=
> range invalidate at all. In this case we can select=0A=
> MMU_GATHER_NO_RANGE.=0A=
>=0A=
> So this reduces to two cases:=0A=
>=0A=
>  1) either the platform has an efficient flush_tlb_range() and=0A=
>     asm-generic/tlb.h doesn't need any overrides at all.=0A=
>=0A=
>  2) or an architecture lacks an efficient flush_tlb_range() and=0A=
>     we need to select MMU_GATHER_NO_RANGE.=0A=
>=0A=
> Convert all 'simple' architectures to one of these two forms.=0A=
>=0A=
> alpha:	    has no range invalidate -> 2=0A=
> arc:	    already used flush_tlb_range() -> 1=0A=
> c6x:	    has no range invalidate -> 2=0A=
> hexagon:    has an efficient flush_tlb_range() -> 1=0A=
>             (flush_tlb_mm() is in fact a full range invalidate,=0A=
> 	     so no need to shoot down everything)=0A=
> m68k:	    has inefficient flush_tlb_range() -> 2=0A=
> microblaze: has no flush_tlb_range() -> 2=0A=
> mips:	    has efficient flush_tlb_range() -> 1=0A=
> 	    (even though it currently seems to use flush_tlb_mm())=0A=
> nds32:	    already uses flush_tlb_range() -> 1=0A=
> nios2:	    has inefficient flush_tlb_range() -> 2=0A=
> 	    (no limit on range iteration)=0A=
> openrisc:   has inefficient flush_tlb_range() -> 2=0A=
> 	    (no limit on range iteration)=0A=
> parisc:	    already uses flush_tlb_range() -> 1=0A=
> sparc32:    already uses flush_tlb_range() -> 1=0A=
> unicore32:  has inefficient flush_tlb_range() -> 2=0A=
> 	    (no limit on range iteration)=0A=
> xtensa:	    has efficient flush_tlb_range() -> 1=0A=
>=0A=
> Note this also fixes a bug in the existing code for a number=0A=
> platforms. Those platforms that did:=0A=
>=0A=
>   tlb_end_vma() -> if (!fullmm) flush_tlb_*()=0A=
>   tlb_flush -> if (full_mm) flush_tlb_mm()=0A=
>=0A=
> missed the case of shift_arg_pages(), which doesn't have @fullmm set,=0A=
> nor calls into tlb_*vma(), but still frees page-tables and thus needs=0A=
> an invalidate. The new code handles this by detecting a non-empty=0A=
> range, and either issuing the matching range invalidate or a full=0A=
> invalidate, depending on the capabilities.=0A=
>=0A=
> Cc: Nick Piggin <npiggin@gmail.com>=0A=
> Cc: "David S. Miller" <davem@davemloft.net>=0A=
> Cc: Michal Simek <monstr@monstr.eu>=0A=
> Cc: Helge Deller <deller@gmx.de>=0A=
> Cc: Greentime Hu <green.hu@gmail.com>=0A=
> Cc: Richard Henderson <rth@twiddle.net>=0A=
> Cc: Andrew Morton <akpm@linux-foundation.org>=0A=
> Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>=0A=
> Cc: Will Deacon <will.deacon@arm.com>=0A=
> Cc: Ley Foon Tan <lftan@altera.com>=0A=
> Cc: Jonas Bonn <jonas@southpole.se>=0A=
> Cc: Mark Salter <msalter@redhat.com>=0A=
> Cc: Richard Kuo <rkuo@codeaurora.org=0A=
> Cc: Vineet Gupta <vgupta@synopsys.com>=0A=
> Cc: Paul Burton <paul.burton@mips.com>=0A=
> Cc: Max Filippov <jcmvbkbc@gmail.com>=0A=
> Cc: Guan Xuetao <gxt@pku.edu.cn>=0A=
> Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>=0A=
=0A=
Very nice. Thx for doing this.=0A=
=0A=
Once you have redone this, please point me to a branch so I can give this a=
 spin.=0A=
I've always been interested in tracking down / optimizing the full TLB flus=
hes -=0A=
which ARC implements by simply moving the MMU/process to a new ASID (TLB en=
tries=0A=
tagged with an 8 bit value - unique per process). When I started looking in=
to this=0A=
, a simple ls (fork+execve) would increment the ASID by 13 which I'd optimi=
zed to=0A=
a reasonable 4. Haven't checked that in recent times though so would be fun=
 to=0A=
revive that measurement.=0A=
=0A=
-Vineet=0A=
