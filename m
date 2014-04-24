Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f47.google.com (mail-ee0-f47.google.com [74.125.83.47])
	by kanga.kvack.org (Postfix) with ESMTP id 3F3A76B0037
	for <linux-mm@kvack.org>; Thu, 24 Apr 2014 06:37:33 -0400 (EDT)
Received: by mail-ee0-f47.google.com with SMTP id b15so1681975eek.6
        for <linux-mm@kvack.org>; Thu, 24 Apr 2014 03:37:32 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r9si7692764eew.348.2014.04.24.03.37.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 24 Apr 2014 03:37:31 -0700 (PDT)
Date: Thu, 24 Apr 2014 11:37:27 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 5/6] x86: mm: new tunable for single vs full TLB flush
Message-ID: <20140424103727.GT23991@suse.de>
References: <20140421182418.81CF7519@viggo.jf.intel.com>
 <20140421182426.D6DD1E8F@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140421182426.D6DD1E8F@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, ak@linux.intel.com, riel@redhat.com, alex.shi@linaro.org, dave.hansen@linux.intel.com, "H. Peter Anvin" <hpa@zytor.com>

On Mon, Apr 21, 2014 at 11:24:26AM -0700, Dave Hansen wrote:
> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> Most of the logic here is in the documentation file.  Please take
> a look at it.
> 
> I know we've come full-circle here back to a tunable, but this
> new one is *WAY* simpler.  I challenge anyone to describe in one
> sentence how the old one worked. 

Challenge accepted.

Based on the characteristics of the CPU and a given process, something
semi-random will happen at flush time which may or may not benefit the
workload.

> Here's the way the new one
> works:
> 
> 	If we are flushing more pages than the ceiling, we use
> 	the full flush, otherwise we use per-page flushes.
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> ---
> 
>  b/Documentation/x86/tlb.txt |   72 ++++++++++++++++++++++++++++++++++++++++++++
>  b/arch/x86/mm/tlb.c         |   46 ++++++++++++++++++++++++++++
>  2 files changed, 118 insertions(+)
> 
> diff -puN arch/x86/mm/tlb.c~new-tunable-for-single-vs-full-tlb-flush arch/x86/mm/tlb.c
> --- a/arch/x86/mm/tlb.c~new-tunable-for-single-vs-full-tlb-flush	2014-04-21 11:10:35.901884997 -0700
> +++ b/arch/x86/mm/tlb.c	2014-04-21 11:10:35.905885179 -0700
> @@ -274,3 +274,49 @@ void flush_tlb_kernel_range(unsigned lon
>  		on_each_cpu(do_kernel_range_flush, &info, 1);
>  	}
>  }
> +
> +static ssize_t tlbflush_read_file(struct file *file, char __user *user_buf,
> +			     size_t count, loff_t *ppos)
> +{
> +	char buf[32];
> +	unsigned int len;
> +
> +	len = sprintf(buf, "%ld\n", tlb_single_page_flush_ceiling);
> +	return simple_read_from_buffer(user_buf, count, ppos, buf, len);
> +}
> +
> +static ssize_t tlbflush_write_file(struct file *file,
> +		 const char __user *user_buf, size_t count, loff_t *ppos)
> +{
> +	char buf[32];
> +	ssize_t len;
> +	int ceiling;
> +
> +	len = min(count, sizeof(buf) - 1);
> +	if (copy_from_user(buf, user_buf, len))
> +		return -EFAULT;
> +
> +	buf[len] = '\0';
> +	if (kstrtoint(buf, 0, &ceiling))
> +		return -EINVAL;
> +
> +	if (ceiling < 0)
> +		return -EINVAL;
> +
> +	tlb_single_page_flush_ceiling = ceiling;
> +	return count;
> +}
> +
> +static const struct file_operations fops_tlbflush = {
> +	.read = tlbflush_read_file,
> +	.write = tlbflush_write_file,
> +	.llseek = default_llseek,
> +};
> +
> +static int __init create_tlb_single_page_flush_ceiling(void)
> +{
> +	debugfs_create_file("tlb_single_page_flush_ceiling", S_IRUSR | S_IWUSR,
> +			    arch_debugfs_dir, NULL, &fops_tlbflush);
> +	return 0;
> +}
> +late_initcall(create_tlb_single_page_flush_ceiling);
> diff -puN /dev/null Documentation/x86/tlb.txt
> --- /dev/null	2014-04-10 11:28:14.066815724 -0700
> +++ b/Documentation/x86/tlb.txt	2014-04-21 11:10:35.924886036 -0700
> @@ -0,0 +1,72 @@
> +nWhen the kernel unmaps or modified the attributes of a range of
> +memory, it has two choices:

s/nWhen/When

> + 1. Flush the entire TLB with a two-instruction sequence.  This is
> +    a quick operation, but it causes collateral damage: TLB entries
> +    from areas other than the one we are trying to flush will be
> +    destroyed and must be refilled later, at some cost.
> + 2. Use the invlpg instruction to invalidate a single page at a
> +    time.  This could potentialy cost many more instructions, but
> +    it is a much more precise operation, causing no collateral
> +    damage to other TLB entries.
> +

It's not stated that there is no range flush instruction for x86 but
anyone who cares about this area should know that.

> +Which method to do depends on a few things:
> + 1. The size of the flush being performed.  A flush of the entire
> +    address space is obviously better performed by flushing the
> +    entire TLB than doing 2^48/PAGE_SIZE individual flushes.
> + 2. The contents of the TLB.  If the TLB is empty, then there will
> +    be no collateral damage caused by doing the global flush, and
> +    all of the individual flush will have ended up being wasted
> +    work.
> + 3. The size of the TLB.  The larger the TLB, the more collateral
> +    damage we do with a full flush.  So, the larger the TLB, the
> +    more attrative an individual flush looks.  Data and
> +    instructions have separate TLBs, as do different page sizes.
> + 4. The microarchitecture.  The TLB has become a multi-level
> +    cache on modern CPUs, and the global flushes have become more
> +    expensive relative to single-page flushes.
> +
> +There is obviously no way the kernel can know all these things,
> +especially the contents of the TLB during a given flush.  The
> +sizes of the flush will vary greatly depending on the workload as
> +well.  There is essentially no "right" point to choose.
> +
> +You may be doing too many individual invalidations if you see the
> +invlpg instruction (or instructions _near_ it) show up high in
> +profiles.  If you believe that individual invalidatoins being
> +called too often, you can lower the tunable:
> +

s/invalidatoins/invalidations/

> +	/sys/debug/kernel/x86/tlb_single_page_flush_ceiling
> +

You do not describe how to use the tracepoints but again anyone investigating
this area should know how to do it already so *shrugs*. Rolling a systemtap
script to display the information would be a short job.

> +This will cause us to do the global flush for more cases.
> +Lowering it to 0 will disable the use of the individual flushes.
> +Setting it to 1 is a very conservative setting and it should
> +never need to be 0 under normal circumstances.
> +
> +Despite the fact that a single individual flush on x86 is
> +guaranteed to flush a full 2MB, hugetlbfs always uses the full
> +flushes.  THP is treated exactly the same as normal memory.
> +

You are the second person that told me this and I felt the manual was
unclear on this subject. I was told that it might be a documentation bug
but because this discussion was in a bar I completely failed to follow up
on it. Specifically this part in 4.10.2.3 caused me problems when I last
looked at the area.

	If the paging structures specify a translation using a page
	larger than 4 KBytes, some processors may choose to cache multiple
	smaller-page TLB entries for that translation. Each such TLB entry
	would be associated with a page number corresponding to the smaller
	page size (e.g., bits 47:12 of a linear address with IA-32e paging),
	even though part of that page number (e.g., bits 20:12) are part
	of the offset with respect to the page specified by the paging
	structures. The upper bits of the physical address in such a TLB
	entry are derived from the physical address in the PDE used to
	create the translation, while the lower bits come from the linear
	address of the access for which the translation is created. There
	is no way for software to be aware that multiple translations for
	smaller pages have been used for a large page.

	If software modifies the paging structures so that the page size
	used for a 4-KByte range of linear addresses changes, the TLBs may
	subsequently contain multiple translations for the address range
	(one for each page size).  A reference to a linear address in the
	address range may use any of these translations. Which translation
	is used may vary from one execution to another, and the choice
	may be implementation-specific.

This was ambiguous to me because of "some processors may choose to cache
multiple smaller-page TLB entries for that translation". The second
paragraph appears to partially contradict that but I could not see an
architectural guarantee that flushing a page address within a huge page
entry was guaranteed to flush all entries.

I understand that there are definite problems around the time of
splitting/collapsing a large page where care has to be taken that old TLB
entries are not present but that's a different case.

> +You might see invlpg inside of flush_tlb_mm_range() show up in
> +profiles, or you can use the trace_tlb_flush() tracepoints. to
> +determine how long the flush operations are taking.
> +
> +Essentially, you are balancing the cycles you spend doing invlpg
> +with the cycles that you spend refilling the TLB later.
> +
> +You can measure how expensive TLB refills are by using
> +performance counters and 'perf stat', like this:
> +
> +perf stat -e
> +	cpu/event=0x8,umask=0x84,name=dtlb_load_misses_walk_duration/,
> +	cpu/event=0x8,umask=0x82,name=dtlb_load_misses_walk_completed/,
> +	cpu/event=0x49,umask=0x4,name=dtlb_store_misses_walk_duration/,
> +	cpu/event=0x49,umask=0x2,name=dtlb_store_misses_walk_completed/,
> +	cpu/event=0x85,umask=0x4,name=itlb_misses_walk_duration/,
> +	cpu/event=0x85,umask=0x2,name=itlb_misses_walk_completed/
> +
> +That works on an IvyBridge-era CPU (i5-3320M).  Different CPUs
> +may have differently-named counters, but they should at least
> +be there in some form.  You can use pmu-tools 'ocperf list'
> +(https://github.com/andikleen/pmu-tools) to find the right
> +counters for a given CPU.
> +

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
