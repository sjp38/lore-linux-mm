Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 6C7CE6B0087
	for <linux-mm@kvack.org>; Fri, 19 Apr 2013 02:54:08 -0400 (EDT)
Received: from /spool/local
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Fri, 19 Apr 2013 16:46:11 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 4FBD22CE804D
	for <linux-mm@kvack.org>; Fri, 19 Apr 2013 16:53:32 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3J6e1gM60227670
	for <linux-mm@kvack.org>; Fri, 19 Apr 2013 16:40:03 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3J6rRTm010542
	for <linux-mm@kvack.org>; Fri, 19 Apr 2013 16:53:29 +1000
Message-ID: <5170E93B.5090902@linux.vnet.ibm.com>
Date: Fri, 19 Apr 2013 12:20:35 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH v2 00/15][Sorted-buddy] mm: Memory Power Management
References: <20130409214443.4500.44168.stgit@srivatsabhat.in.ibm.com> <517028F1.6000002@sr71.net>
In-Reply-To: <517028F1.6000002@sr71.net>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: akpm@linux-foundation.org, mgorman@suse.de, matthew.garrett@nebula.com, rientjes@google.com, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, maxime.coquelin@stericsson.com, loic.pallardy@stericsson.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl, gargankita@gmail.com, paulmck@linux.vnet.ibm.com, amit.kachhap@linaro.org, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, wujianguo@huawei.com, kmpark@infradead.org, thomas.abraham@linaro.org, santosh.shilimkar@ti.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 04/18/2013 10:40 PM, Dave Hansen wrote:
> On 04/09/2013 02:45 PM, Srivatsa S. Bhat wrote:
>> 2. Performance overhead is expected to be low: Since we retain the simplicity
>>    of the algorithm in the page allocation path, page allocation can
>>    potentially remain as fast as it would be without memory regions. The
>>    overhead is pushed to the page-freeing paths which are not that critical.
> 
> Numbers, please.  The problem with pushing the overhead to frees is that
> they, believe it or not, actually average out to the same as the number
> of allocs.  Think kernel compile, or a large dd.  Both of those churn
> through a lot of memory, and both do an awful lot of allocs _and_ frees.
>  We need to know both the overhead on a system that does *no* memory
> power management, and the overhead on a system which is carved and
> actually using this code.
> 
>> Kernbench results didn't show any noticeable performance degradation with
>> this patchset as compared to vanilla 3.9-rc5.
> 
> Surely this code isn't magical and there's overhead _somewhere_, and
> such overhead can be quantified _somehow_.  Have you made an effort to
> find those cases, even with microbenchmarks?
>

Sorry for not posting the numbers explicitly. It really shows no difference in
kernbench, see below.

[For the following run, I reverted patch 14, since it seems to be intermittently
causing kernel-instability at high loads. So the numbers below show the effect
of only the sorted-buddy part of the patchset, and not the compaction part.]

Kernbench was run on a 2 socket 8 core machine (HT disabled) with 128 GB RAM,
with allyesconfig on 3.9-rc5 kernel source. 

Vanilla 3.9-rc5:
---------------
Fri Apr 19 08:30:12 IST 2013
3.9.0-rc5
Average Optimal load -j 16 Run (std deviation):
Elapsed Time 574.66 (2.31846)
User Time 3919.12 (3.71256)
System Time 339.296 (0.73694)
Percent CPU 740.4 (2.50998)
Context Switches 1.2183e+06 (4019.47)
Sleeps 1.61239e+06 (2657.33)

This patchset (minus patch 14): [Region size = 512 MB]
------------------------------
Fri Apr 19 09:42:38 IST 2013
3.9.0-rc5-mpmv2-nowq
Average Optimal load -j 16 Run (std deviation):
Elapsed Time 575.668 (2.01583)
User Time 3916.77 (3.48345)
System Time 337.406 (0.701591)
Percent CPU 738.4 (3.36155)
Context Switches 1.21683e+06 (6980.13)
Sleeps 1.61474e+06 (4906.23)


So, that shows almost no degradation due to the sorted-buddy logic (considering
the elapsed time).
 
> I still also want to see some hard numbers on:
>> However, memory consumes a significant amount of power, potentially upto
>> more than a third of total system power on server systems.
> and
>> It had been demonstrated on a Samsung Exynos board
>> (with 2 GB RAM) that upto 6 percent of total system power can be saved by
>> making the Linux kernel MM subsystem power-aware[4]. 
> 
> That was *NOT* with this code, and it's nearing being two years old.
> What can *this* *patch* do?
> 

Please let me clarify that. My intention behind quoting that 6% power-savings
number was _not_ to trick reviewers into believing that _this_ patchset provides
that much power-savings. It was only to show that this whole effort of doing memory
power management is not worthless, and we do have some valuable/tangible
benefits to gain from it. IOW, it was only meant to show an _estimate_ of how
much we can potentially save and thus justify the effort behind managing memory
power-efficiently.

As I had mentioned in the cover-letter, I don't have the the exact power-savings
number for this particular patchset yet. I'll definitely work towards getting
those numbers soon.

> I think there are three scenarios to look at.  Let's say you have an 8GB
> system with 1GB regions:
> 1. Normal unpatched kernel, booted with  mem=1G...8G (in 1GB increments
>    perhaps) running some benchmark which sees performance scale with
>    the amount of memory present in the system.
> 2. Kernel patched with this set, running the same test, but with single
>    memory regions.
> 3. Kernel patched with this set.  But, instead of using mem=, you run
>    it trying to evacuate equivalent amount of memory to the amounts you
>    removed using mem=.
> 
> That will tell us both what the overhead is, and how effective it is.
> I'd much rather see actual numbers and a description of the test than
> some hand waving that it "didn't show any noticeable performance
> degradation".
> 

Sure, I'll perform more extensive tests to evaluate the performance overhead
more thoroughly. I'll first fix the compaction logic that seems to be buggy
and run benchmarks again.

Thanks a lot for your all invaluable inputs, Dave!

Regards,
Srivatsa S. Bhat

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
