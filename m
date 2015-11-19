Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 76FB26B0253
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 08:29:14 -0500 (EST)
Received: by wmec201 with SMTP id c201so117795444wme.1
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 05:29:14 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id pc1si11243594wjb.243.2015.11.19.05.29.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 19 Nov 2015 05:29:13 -0800 (PST)
Subject: Re: hugepage compaction causes performance drop
References: <20151119092920.GA11806@aaronlu.sh.intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <564DCEA6.3000802@suse.cz>
Date: Thu, 19 Nov 2015 14:29:10 +0100
MIME-Version: 1.0
In-Reply-To: <20151119092920.GA11806@aaronlu.sh.intel.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>, linux-mm@kvack.org
Cc: Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, lkp@lists.01.org, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

+CC Andrea, David, Joonsoo

On 11/19/2015 10:29 AM, Aaron Lu wrote:
> Hi,
>
> One vm related test case run by LKP on a Haswell EP with 128GiB memory
> showed that compaction code would cause performance drop about 30%. To
> illustrate the problem, I've simplified the test with a program called
> usemem(see attached). The test goes like this:
> 1 Boot up the server;
> 2 modprobe scsi_debug(a module that could use memory as SCSI device),
>    dev_size set to 4/5 free memory, i.e. about 100GiB. Use it as swap.
> 3 run the usemem test, which use mmap to map a MAP_PRIVATE | MAP_ANON
>    region with the size set to 3/4 of (remaining_free_memory + swap), and
>    then write to that region sequentially to trigger page fault and swap
>    out.
>
> The above test runs with two configs regarding the below two sysfs files:
> /sys/kernel/mm/transparent_hugepage/enabled
> /sys/kernel/mm/transparent_hugepage/defrag
> 1 transparent hugepage and defrag are both set to always, let's call it
>    always-always case;
> 2 transparent hugepage is set to always while defrag is set to never,
>    let's call it always-never case.
>
> The output from the always-always case is:
> Setting up swapspace version 1, size = 104627196 KiB
> no label, UUID=aafa53ae-af9e-46c9-acb9-8b3d4f57f610
> cmdline: /lkp/aaron/src/bin/usemem 99994672128
> 99994672128 transferred in 95 seconds, throughput: 1003 MB/s
>
> And the output from the always-never case is:
> etting up swapspace version 1, size = 104629244 KiB
> no label, UUID=60563c82-d1c6-4d86-b9fa-b52f208097e9
> cmdline: /lkp/aaron/src/bin/usemem 99995965440
> 99995965440 transferred in 67 seconds, throughput: 1423 MB/s

So yeah this is an example of workload that has no benefit from THP's, 
but pays all the cost. Fixing that is non-trivial and I admit I haven't 
pushed my prior efforts there too much lately...
But it's also possible there still are actual compaction bugs making the 
issue worse.

> The vmstat and perf-profile are also attached, please let me know if you
> need any more information, thanks.

Output from vmstat (the tool) isn't much useful here, a periodic "cat 
/proc/vmstat" would be much better.
The perf profiles are somewhat weirdly sorted by children cost (?), but 
I noticed a very high cost (46%) in pageblock_pfn_to_page(). This could 
be due to a very large but sparsely populated zone. Could you provide 
/proc/zoneinfo?
If the compaction scanners behave strangely due to a bug, enabling the 
ftrace compaction tracepoints should help find the cause. That might 
produce a very large output, but maybe it would be enough to see some 
parts of it (i.e. towards beginning, middle, end of the experiment).

Vlastimil

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
