Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id D3E2C6B0253
	for <linux-mm@kvack.org>; Fri,  9 Oct 2015 07:31:11 -0400 (EDT)
Received: by igcrk20 with SMTP id rk20so33312316igc.1
        for <linux-mm@kvack.org>; Fri, 09 Oct 2015 04:31:11 -0700 (PDT)
Received: from smtprelay.synopsys.com (smtprelay.synopsys.com. [198.182.60.111])
        by mx.google.com with ESMTPS id z13si2119820igp.64.2015.10.09.04.31.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Oct 2015 04:31:10 -0700 (PDT)
Subject: Re: [PATCH v2 00/12] THP support for ARC
References: <1442918096-17454-1-git-send-email-vgupta@synopsys.com>
 <560CCC73.9080705@synopsys.com> <561789E6.9090800@synopsys.com>
 <20151009101046.GA8081@node>
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Message-ID: <5617A527.9030902@synopsys.com>
Date: Fri, 9 Oct 2015 16:59:43 +0530
MIME-Version: 1.0
In-Reply-To: <20151009101046.GA8081@node>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Matthew
 Wilcox <matthew.r.wilcox@intel.com>, Minchan Kim <minchan@kernel.org>, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Friday 09 October 2015 03:40 PM, Kirill A. Shutemov wrote:
> On Fri, Oct 09, 2015 at 03:03:26PM +0530, Vineet Gupta wrote:
>> On Thursday 01 October 2015 11:32 AM, Vineet Gupta wrote:
>>> On Tuesday 22 September 2015 04:04 PM, Vineet Gupta wrote:
>>>>> Hi,
>>>>>
>>>>> This series brings THP support to ARC. It also introduces an optional new
>>>>> thp hook for arches to possibly optimize the TLB flush in thp regime.
>>>>>
>>>>> Please review !
>>>>>
>>>>> Changes Since v1 [*]
>>>>>    - Rebased against v4.3-rc2
>>>>>    - Switched ARC pgtable_t to pte_t * 		(Kiril)
>>>>>    - Removed stub implementations for		(Andrew)
>>>>> 	pmdp_set_access_flags, pmdp_test_and_clear_young, pmdp_set_wrprotect,
>>>>> 	pmdp_collapse_flush, pmd_same
>>>>>
>>>>> [*] http://lkml.kernel.org/r/1440666194-21478-1-git-send-email-vgupta@synopsys.com
>>>>>
>>>>> Vineet Gupta (12):
>>>>>   ARC: mm: switch pgtable_to to pte_t *
>>>>>   ARC: mm: pte flags comsetic cleanups, comments
>>>>>   ARC: mm: Introduce PTE_SPECIAL
>>>>>   Documentation/features/vm: pte_special now supported by ARC
>>>>>   ARCv2: mm: THP support
>>>>>   ARCv2: mm: THP: boot validation/reporting
>>>>>   Documentation/features/vm: THP now supported by ARC
>>>>>   mm: move some code around
>>>>>   mm,thp: reduce ifdef'ery for THP in generic code
>>>>>   mm,thp: introduce flush_pmd_tlb_range
>>>>>   ARCv2: mm: THP: Implement flush_pmd_tlb_range() optimization
>>>>>   ARCv2: Add a DT which enables THP
>>>>>
>>>>>  Documentation/features/vm/THP/arch-support.txt     |  2 +-
>>>>>  .../features/vm/pte_special/arch-support.txt       |  2 +-
>>>>>  arch/arc/Kconfig                                   |  4 +
>>>>>  arch/arc/boot/dts/hs_thp.dts                       | 59 +++++++++++++
>>>>>  arch/arc/include/asm/hugepage.h                    | 82 ++++++++++++++++++
>>>>>  arch/arc/include/asm/page.h                        |  5 +-
>>>>>  arch/arc/include/asm/pgalloc.h                     |  6 +-
>>>>>  arch/arc/include/asm/pgtable.h                     | 60 +++++++------
>>>>>  arch/arc/mm/tlb.c                                  | 76 ++++++++++++++++-
>>>>>  arch/arc/mm/tlbex.S                                | 21 +++--
>>>>>  include/asm-generic/pgtable.h                      | 49 ++++-------
>>>>>  mm/huge_memory.c                                   |  2 +-
>>>>>  mm/pgtable-generic.c                               | 99 ++++++++++------------
>>>>>  13 files changed, 345 insertions(+), 122 deletions(-)
>>>>>  create mode 100644 arch/arc/boot/dts/hs_thp.dts
>>>>>  create mode 100644 arch/arc/include/asm/hugepage.h
>>> Andrew, Kirill, could you please review/ack the generic mm bits atleast so I can
>>> proceed with moving the stuff into linux-next !
>>
>> Ping 2 !
> 
> Sorry.
> 
>> Can I please get some acks on the generic mm bits. Some of the changes
>> will likely collide Kirill's THP rework !
> 
> Could you check if it acctually collides?

I rebased my changes on top of your v12 branch. As expected I get two merge
conflicts as my patches update code which u have removed. But looks straight
forward to resolve. Meaning we can carry respective patches and give Linus a heads
up abt the merge conflict.

There's also a fixup needed for ARC to remove the pmdp splitting assuming ARC THP
makes it into mainline first.

-Vineet

> 
>> Given people rebase off of mmtomm would it be better if generic patches went thru
>> Andrew and probably included sooner for 4.4 target ?
>>
>> -Vineet
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
