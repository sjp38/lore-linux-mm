Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id E546E6B0033
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 10:12:08 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id r64so4255779qkc.0
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 07:12:08 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id u14si3214231qtk.265.2017.11.02.07.12.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Nov 2017 07:12:07 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vA2EBn9B006500
	for <linux-mm@kvack.org>; Thu, 2 Nov 2017 10:12:06 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2e03e2x0em-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 02 Nov 2017 10:12:06 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Thu, 2 Nov 2017 14:12:02 -0000
Subject: Re: [v5,22/22] powerpc/mm: Add speculative page fault
References: <1507729966-10660-23-git-send-email-ldufour@linux.vnet.ibm.com>
 <7ca80231-fe02-a3a7-84bc-ce81690ea051@intel.com>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Thu, 2 Nov 2017 15:11:52 +0100
MIME-Version: 1.0
In-Reply-To: <7ca80231-fe02-a3a7-84bc-ce81690ea051@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: fr
Content-Transfer-Encoding: 8bit
Message-Id: <c0b7f172-5d9c-eec6-540d-216b908f005f@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kemi <kemi.wang@intel.com>, paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On 26/10/2017 10:14, kemi wrote:
> Some regression is found by LKP-tools(linux kernel performance) on this patch series
> tested on Intel 2s/4s Skylake platform. 
> The regression result is sorted by the metric will-it-scale.per_process_ops.

Hi Kemi,

Thanks for reporting this, I'll try to address it by turning some features
of the SPF path off when the process is monothreaded.

Laurent.


> Branch:Laurent-Dufour/Speculative-page-faults/20171011-213456(V4 patch series)
> Commit id:
>      base:9a4b4dd1d8700dd5771f11dd2c048e4363efb493
>      head:56a4a8962fb32555a42eefdc9a19eeedd3e8c2e6
> Benchmark suite:will-it-scale
> Download link:https://github.com/antonblanchard/will-it-scale/tree/master/tests
> Metrics:
>      will-it-scale.per_process_ops=processes/nr_cpu
>      will-it-scale.per_thread_ops=threads/nr_cpu
> 
> tbox:lkp-skl-4sp1(nr_cpu=192,memory=768G)
> kconfig:CONFIG_TRANSPARENT_HUGEPAGE is not set
> testcase        base            change          head            metric                   
> brk1            2251803         -18.1%          1843535         will-it-scale.per_process_ops
>                 341101          -17.5%          281284          will-it-scale.per_thread_ops
> malloc1         48833           -9.2%           44343           will-it-scale.per_process_ops
>                 31555           +2.9%           32473           will-it-scale.per_thread_ops
> page_fault3     913019          -8.5%           835203          will-it-scale.per_process_ops
>                 233978          -18.1%          191593          will-it-scale.per_thread_ops
> mmap2           95892           -6.6%           89536           will-it-scale.per_process_ops
>                 90180           -13.7%          77803           will-it-scale.per_thread_ops
> mmap1           109586          -4.7%           104414          will-it-scale.per_process_ops
>                 104477          -12.4%          91484           will-it-scale.per_thread_ops
> sched_yield     4964649         -2.1%           4859927         will-it-scale.per_process_ops
>                 4946759         -1.7%           4864924         will-it-scale.per_thread_ops
> write1          1345159         -1.3%           1327719         will-it-scale.per_process_ops
>                 1228754         -2.2%           1201915         will-it-scale.per_thread_ops
> page_fault2     202519          -1.0%           200545          will-it-scale.per_process_ops
>                 96573           -10.4%          86526           will-it-scale.per_thread_ops
> page_fault1     225608          -0.9%           223585          will-it-scale.per_process_ops
>                 105945          +14.4%          121199          will-it-scale.per_thread_ops
> 
> tbox:lkp-skl-4sp1(nr_cpu=192,memory=768G)
> kconfig:CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS=y
> testcase        base            change          head            metric                   
> context_switch1 333780          -23.0%          256927          will-it-scale.per_process_ops
> brk1            2263539         -18.8%          1837462         will-it-scale.per_process_ops
>                 325854          -15.7%          274752          will-it-scale.per_thread_ops
> malloc1         48746           -13.5%          42148           will-it-scale.per_process_ops
> mmap1           106860          -12.4%          93634           will-it-scale.per_process_ops
>                 98082           -18.9%          79506           will-it-scale.per_thread_ops
> mmap2           92468           -11.3%          82059           will-it-scale.per_process_ops
>                 80468           -8.9%           73343           will-it-scale.per_thread_ops
> page_fault3     900709          -9.1%           818851          will-it-scale.per_process_ops
>                 229837          -18.3%          187769          will-it-scale.per_thread_ops
> write1          1327409         -1.7%           1305048         will-it-scale.per_process_ops
>                 1215658         -1.6%           1196479         will-it-scale.per_thread_ops
> writeseek3      300639          -1.6%           295882          will-it-scale.per_process_ops
>                 231118          -2.2%           225929          will-it-scale.per_thread_ops
> signal1         122011          -1.5%           120155          will-it-scale.per_process_ops
> futex1          5123778         -1.2%           5062087         will-it-scale.per_process_ops
> page_fault2     202321          -1.0%           200289          will-it-scale.per_process_ops
>                 93073           -9.8%           83927           will-it-scale.per_thread_ops
> 
> tbox:lkp-skl-2sp2(nr_cpu=112,memory=64G)
> kconfig:CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS=y
> testcase        base            change          head            metric                   
> brk1            2177903         -20.0%          1742054         will-it-scale.per_process_ops
>                 434558          -15.3%          367896          will-it-scale.per_thread_ops
> malloc1         64871           -10.3%          58174           will-it-scale.per_process_ops
> page_fault3     882435          -9.0%           802892          will-it-scale.per_process_ops
>                 299176          -15.7%          252170          will-it-scale.per_thread_ops
> mmap2           124567          -8.3%           114214          will-it-scale.per_process_ops
>                 110674          -12.1%          97272           will-it-scale.per_thread_ops
> mmap1           137205          -7.8%           126440          will-it-scale.per_process_ops
>                 128973          -15.1%          109560          will-it-scale.per_thread_ops
> context_switch1 343790          -7.2%           319209          will-it-scale.per_process_ops
> page_fault2     161891          -2.1%           158458          will-it-scale.per_process_ops
>                 123278          -5.4%           116629          will-it-scale.per_thread_ops
> malloc2         14354856        -1.8%           14096856        will-it-scale.per_process_ops
> read2           1204838         -1.7%           1183993         will-it-scale.per_process_ops
> futex1          5017718         -1.6%           4938677         will-it-scale.per_process_ops
>                 1408250         -1.0%           1394022         will-it-scale.per_thread_ops
> writeseek3      399651          -1.4%           393935          will-it-scale.per_process_ops
> signal1         157952          -1.0%           156302          will-it-scale.per_process_ops
> 
> On 2017a1'10ae??11ae?JPY 21:52, Laurent Dufour wrote:
>> This patch enable the speculative page fault on the PowerPC
>> architecture.
>>
>> This will try a speculative page fault without holding the mmap_sem,
>> if it returns with VM_FAULT_RETRY, the mmap_sem is acquired and the
>> traditional page fault processing is done.
>>
>> Build on if CONFIG_SPF is defined (currently for BOOK3S_64 && SMP).
>>
>> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
>> ---
>>  arch/powerpc/mm/fault.c | 17 +++++++++++++++++
>>  1 file changed, 17 insertions(+)
>>
>> diff --git a/arch/powerpc/mm/fault.c b/arch/powerpc/mm/fault.c
>> index 4797d08581ce..c018c2554cc8 100644
>> --- a/arch/powerpc/mm/fault.c
>> +++ b/arch/powerpc/mm/fault.c
>> @@ -442,6 +442,20 @@ static int __do_page_fault(struct pt_regs *regs, unsigned long address,
>>  	if (is_exec)
>>  		flags |= FAULT_FLAG_INSTRUCTION;
>>  
>> +#ifdef CONFIG_SPF
>> +	if (is_user) {
>> +		/* let's try a speculative page fault without grabbing the
>> +		 * mmap_sem.
>> +		 */
>> +		fault = handle_speculative_fault(mm, address, flags);
>> +		if (!(fault & VM_FAULT_RETRY)) {
>> +			perf_sw_event(PERF_COUNT_SW_SPF, 1,
>> +				      regs, address);
>> +			goto done;
>> +		}
>> +	}
>> +#endif /* CONFIG_SPF */
>> +
>>  	/* When running in the kernel we expect faults to occur only to
>>  	 * addresses in user space.  All other faults represent errors in the
>>  	 * kernel and should generate an OOPS.  Unfortunately, in the case of an
>> @@ -526,6 +540,9 @@ static int __do_page_fault(struct pt_regs *regs, unsigned long address,
>>  
>>  	up_read(&current->mm->mmap_sem);
>>  
>> +#ifdef CONFIG_SPF
>> +done:
>> +#endif
>>  	if (unlikely(fault & VM_FAULT_ERROR))
>>  		return mm_fault_error(regs, address, fault);
>>  
>>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
