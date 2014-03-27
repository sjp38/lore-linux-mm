Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id 11F046B0031
	for <linux-mm@kvack.org>; Thu, 27 Mar 2014 02:20:15 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id rr13so3009878pbb.15
        for <linux-mm@kvack.org>; Wed, 26 Mar 2014 23:20:14 -0700 (PDT)
Received: from e28smtp01.in.ibm.com (e28smtp01.in.ibm.com. [122.248.162.1])
        by mx.google.com with ESMTPS id uh7si688410pbc.512.2014.03.26.23.20.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 26 Mar 2014 23:20:13 -0700 (PDT)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <maddy@linux.vnet.ibm.com>;
	Thu, 27 Mar 2014 11:50:10 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id D80791258054
	for <linux-mm@kvack.org>; Thu, 27 Mar 2014 11:52:32 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s2R6JpRg61669454
	for <linux-mm@kvack.org>; Thu, 27 Mar 2014 11:49:51 +0530
Received: from d28av03.in.ibm.com (localhost [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s2R6K68T026747
	for <linux-mm@kvack.org>; Thu, 27 Mar 2014 11:50:06 +0530
Message-ID: <5333C315.3000405@linux.vnet.ibm.com>
Date: Thu, 27 Mar 2014 11:50:05 +0530
From: Madhavan Srinivasan <maddy@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/1] mm: move FAULT_AROUND_ORDER to arch/
References: <1395730215-11604-1-git-send-email-maddy@linux.vnet.ibm.com> <1395730215-11604-2-git-send-email-maddy@linux.vnet.ibm.com> <20140325173605.GA21411@node.dhcp.inet.fi>
In-Reply-To: <20140325173605.GA21411@node.dhcp.inet.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, benh@kernel.crashing.org, paulus@samba.org, kirill.shutemov@linux.intel.com, rusty@rustcorp.com.au, akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, ak@linux.intel.com, peterz@infradead.org, mingo@kernel.org

On Tuesday 25 March 2014 11:06 PM, Kirill A. Shutemov wrote:
> On Tue, Mar 25, 2014 at 12:20:15PM +0530, Madhavan Srinivasan wrote:
>> Kirill A. Shutemov with the commit 96bacfe542 introduced
>> vm_ops->map_pages() for mapping easy accessible pages around
>> fault address in hope to reduce number of minor page faults.
>> Based on his workload runs, suggested FAULT_AROUND_ORDER
>> (knob to control the numbers of pages to map) is 4.
>>
>> This patch moves the FAULT_AROUND_ORDER macro to arch/ for
>> architecture maintainers to decide on suitable FAULT_AROUND_ORDER
>> value based on performance data for that architecture.
>>
>> Signed-off-by: Madhavan Srinivasan <maddy@linux.vnet.ibm.com>
>> ---
>>  arch/powerpc/include/asm/pgtable.h |    6 ++++++
>>  arch/x86/include/asm/pgtable.h     |    5 +++++
>>  include/asm-generic/pgtable.h      |   10 ++++++++++
>>  mm/memory.c                        |    2 --
>>  4 files changed, 21 insertions(+), 2 deletions(-)
>>
>> diff --git a/arch/powerpc/include/asm/pgtable.h b/arch/powerpc/include/asm/pgtable.h
>> index 3ebb188..9fcbd48 100644
>> --- a/arch/powerpc/include/asm/pgtable.h
>> +++ b/arch/powerpc/include/asm/pgtable.h
>> @@ -19,6 +19,12 @@ struct mm_struct;
>>  #endif
>>  
>>  /*
>> + * With a few real world workloads that were run,
>> + * the performance data showed that a value of 3 is more advantageous.
>> + */
>> +#define FAULT_AROUND_ORDER	3
>> +
>> +/*
>>   * We save the slot number & secondary bit in the second half of the
>>   * PTE page. We use the 8 bytes per each pte entry.
>>   */
>> diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
>> index 938ef1d..8387a65 100644
>> --- a/arch/x86/include/asm/pgtable.h
>> +++ b/arch/x86/include/asm/pgtable.h
>> @@ -7,6 +7,11 @@
>>  #include <asm/pgtable_types.h>
>>  
>>  /*
>> + * Based on Kirill's test results, fault around order is set to 4
>> + */
>> +#define FAULT_AROUND_ORDER 4
>> +
>> +/*
>>   * Macro to mark a page protection value as UC-
>>   */
>>  #define pgprot_noncached(prot)					\
>> diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
>> index 1ec08c1..62f7f07 100644
>> --- a/include/asm-generic/pgtable.h
>> +++ b/include/asm-generic/pgtable.h
>> @@ -7,6 +7,16 @@
>>  #include <linux/mm_types.h>
>>  #include <linux/bug.h>
>>  
>> +
>> +/*
>> + * Fault around order is a control knob to decide the fault around pages.
>> + * Default value is set to 0UL (disabled), but the arch can override it as
>> + * desired.
>> + */
>> +#ifndef FAULT_AROUND_ORDER
>> +#define FAULT_AROUND_ORDER	0UL
>> +#endif
> 
> FAULT_AROUND_ORDER == 0 case should be handled separately in
> do_read_fault(): no reason to go to do_fault_around() if we are going to
> fault in only one page.
> 

ok agreed. I am thinking of adding FAULT_AROUND_ORDER check with
map_pages check in the do_read_fault. Kindly share your thoughts.

With regards
Maddy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
