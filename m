Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 7CC206B0035
	for <linux-mm@kvack.org>; Thu, 24 Apr 2014 12:58:15 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id p10so1779104pdj.4
        for <linux-mm@kvack.org>; Thu, 24 Apr 2014 09:58:15 -0700 (PDT)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id zm10si3032525pbc.404.2014.04.24.09.58.12
        for <linux-mm@kvack.org>;
        Thu, 24 Apr 2014 09:58:13 -0700 (PDT)
Message-ID: <535942A3.3020800@sr71.net>
Date: Thu, 24 Apr 2014 09:58:11 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCH 2/6] x86: mm: rip out complicated, out-of-date, buggy
 TLB flushing
References: <20140421182418.81CF7519@viggo.jf.intel.com> <20140421182421.DFAAD16A@viggo.jf.intel.com> <20140424084552.GQ23991@suse.de>
In-Reply-To: <20140424084552.GQ23991@suse.de>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, ak@linux.intel.com, riel@redhat.com, alex.shi@linaro.org, dave.hansen@linux.intel.com

On 04/24/2014 01:45 AM, Mel Gorman wrote:
>> +/*
>> + * See Documentation/x86/tlb.txt for details.  We choose 33
>> + * because it is large enough to cover the vast majority (at
>> + * least 95%) of allocations, and is small enough that we are
>> + * confident it will not cause too much overhead.  Each single
>> + * flush is about 100 cycles, so this caps the maximum overhead
>> + * at _about_ 3,000 cycles.
>> + */
>> +/* in units of pages */
>> +unsigned long tlb_single_page_flush_ceiling = 1;
>> +
> 
> This comment is premature. The documentation file does not exist yet and
> 33 means nothing yet. Out of curiousity though, how confident are you
> that a TLB flush is generally 100 cycles across different generations
> and manufacturers of CPUs? I'm not suggesting you change it or auto-tune
> it, am just curious.

Yeah, the comment belongs in the later patch where I set it to 33.

I looked at this on the last few generations of Intel CPUs.  "100
cycles" was a very general statement, and not precise at all.  My laptop
averages out to 113 cycles overall, but the flushes of 25 pages averaged
96 cycles/page while the flushes of 2 averaged 219/page.

Those cycles include some costs of from the instrumentation as well.

I did not test on other CPU manufacturers, but this should be pretty
easy to reproduce.  I'm happy to help folks re-run it on other hardware.

I also believe with the modalias stuff we've got in sysfs for the CPU
objects we can do this in the future with udev rules instead of
hard-coding it in the kernel.

>> -	/* In modern CPU, last level tlb used for both data/ins */
>> -	if (vmflag & VM_EXEC)
>> -		tlb_entries = tlb_lli_4k[ENTRIES];
>> -	else
>> -		tlb_entries = tlb_lld_4k[ENTRIES];
>> -
>> -	/* Assume all of TLB entries was occupied by this task */
>> -	act_entries = tlb_entries >> tlb_flushall_shift;
>> -	act_entries = mm->total_vm > act_entries ? act_entries : mm->total_vm;
>> -	nr_base_pages = (end - start) >> PAGE_SHIFT;
>> -
>> -	/* tlb_flushall_shift is on balance point, details in commit log */
>> -	if (nr_base_pages > act_entries) {
>> +	if ((end - start) > tlb_single_page_flush_ceiling * PAGE_SIZE) {
>>  		count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ALL);
>>  		local_flush_tlb();
>>  	} else {
> 
> We lose the different tuning based on whether the flush is for instructions
> or data. However, I cannot think of a good reason for keeping it as I
> expect that flushes of instructions is relatively rare. The benefit, if
> any, will be marginal. Still, if you do another revision it would be
> nice to call this out in the changelog.

Will do.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
