Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7EABD6B0038
	for <linux-mm@kvack.org>; Wed, 16 Sep 2015 19:58:12 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so2359223pac.2
        for <linux-mm@kvack.org>; Wed, 16 Sep 2015 16:58:12 -0700 (PDT)
Received: from smtprelay.synopsys.com (us01smtprelay-2.synopsys.com. [198.182.60.111])
        by mx.google.com with ESMTPS id yv10si748886pab.172.2015.09.16.16.58.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Sep 2015 16:58:11 -0700 (PDT)
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: Re: [PATCH 09/11] mm,thp: introduce flush_pmd_tlb_range
Date: Wed, 16 Sep 2015 23:57:45 +0000
Message-ID: <C2D7FE5348E1B147BCA15975FBA23075D7817CDC@IN01WEMBXB.internal.synopsys.com>
References: <1440666194-21478-1-git-send-email-vgupta@synopsys.com>
 <1440666194-21478-10-git-send-email-vgupta@synopsys.com>
 <20150916152628.32073b37c02550557672092c@linux-foundation.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Matthew
 Wilcox <matthew.r.wilcox@intel.com>, Minchan Kim <minchan@kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "arc-linux-dev@synopsys.com" <arc-linux-dev@synopsys.com>

On Wednesday 16 September 2015 03:26 PM, Andrew Morton wrote:=0A=
> On Thu, 27 Aug 2015 14:33:12 +0530 Vineet Gupta <Vineet.Gupta1@synopsys.c=
om> wrote:=0A=
>=0A=
>> --- a/mm/pgtable-generic.c=0A=
>> +++ b/mm/pgtable-generic.c=0A=
>> @@ -84,6 +84,19 @@ pte_t ptep_clear_flush(struct vm_area_struct *vma, un=
signed long address,=0A=
>>  =0A=
>>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE=0A=
>>  =0A=
>> +#ifndef __HAVE_ARCH_FLUSH_PMD_TLB_RANGE=0A=
>> +=0A=
>> +/*=0A=
>> + * ARCHes with special requirements for evicting THP backing TLB entrie=
s can=0A=
>> + * implement this. Otherwise also, it can help optimizing thp flush ope=
ration.=0A=
>> + * flush_tlb_range() can have optimization to nuke the entire TLB if fl=
ush span=0A=
>> + * is greater than a threashhold, which will likely be true for a singl=
e=0A=
>> + * huge page.=0A=
>> + * e.g. see arch/arc: flush_pmd_tlb_range=0A=
>> + */=0A=
>> +#define flush_pmd_tlb_range(vma, addr, end)	flush_tlb_range(vma, addr, =
end)=0A=
>> +#endif=0A=
> Did you consider using a __weak function here?=0A=
=0A=
IMHO weak doesn't apply here. All arches already have flush_tlb_range() whi=
ch is=0A=
called by normal and THP code to flush the corresponding normal/THP page TL=
B=0A=
entry. What I want to do is differentiate the THP page flush case - bu call=
ing a=0A=
different API (which can be optionally implemented by arch or fall back to =
vanilla=0A=
flush_tlb_page()). So we need to change the call itself here while weak len=
ds=0A=
itself better to keeping the call same but just swapping the implementation=
.=0A=
=0A=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
