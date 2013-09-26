Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id 22AAF6B0031
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 09:02:44 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id un15so1107940pbc.29
        for <linux-mm@kvack.org>; Thu, 26 Sep 2013 06:02:43 -0700 (PDT)
Received: from /spool/local
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Thu, 26 Sep 2013 18:32:35 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 74CEA1258051
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 18:32:41 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8QD2P0k47710224
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 18:32:26 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r8QD2PnG005297
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 18:32:26 +0530
Message-ID: <52442F6F.5020703@linux.vnet.ibm.com>
Date: Thu, 26 Sep 2013 18:28:23 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [Results] [RFC PATCH v4 00/40] mm: Memory Power Management
References: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com> <52437128.7030402@linux.vnet.ibm.com> <20130925164057.6bbaf23bdc5057c42b2ab010@linux-foundation.org>
In-Reply-To: <20130925164057.6bbaf23bdc5057c42b2ab010@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mgorman@suse.de, dave@sr71.net, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl, gargankita@gmail.com, paulmck@linux.vnet.ibm.com, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, isimatu.yasuaki@jp.fujitsu.com, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, maxime.coquelin@stericsson.com, loic.pallardy@stericsson.com, amit.kachhap@linaro.org, thomas.abraham@linaro.org

On 09/26/2013 05:10 AM, Andrew Morton wrote:
> On Thu, 26 Sep 2013 04:56:32 +0530 "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com> wrote:
> 
>> Experimental Results:
>> ====================
>>
>> Test setup:
>> ----------
>>
>> x86 Sandybridge dual-socket quad core HT-enabled machine, with 128GB RAM.
>> Memory Region size = 512MB.
> 
> Yes, but how much power was saved ;)
> 

I don't have those numbers yet, but I'll be able to get them going forward.

Let me explain the challenge I am facing. A prototype powerpc platform that
I work with has the capability to transition memory banks to content-preserving
low-power states at a per-socket granularity. What that means is that we can
get memory power savings *without* needing to go to full-system-idle, unlike
Intel platforms such as Sandybridge.

So, since we can exploit per-socket memory power-savings irrespective of
whether the system is fully idle or not, using this patchset to shape the
memory references appropriately is definitely going to be beneficial on that
platform.

But the challenge is that I don't have all the pieces in place for demarcating
the actual boundaries of the power-manageable memory chunks of that platform
and exposing it to the Linux kernel. As a result, I was not able to test and
report the overall power-savings from this patchset.

But I'll soon start working on getting the required pieces ready to expose
the memory boundary info of the platform via device-tree and then using
that to construct the Linux MM's view of memory regions (instead of hard-coding
them as I did in this patchset). With that done, I should be able to test and
report the overall power-savings numbers on this prototype powerpc platform.

Until then, in this and previous versions of the patchset, I had used an
Intel Sandybridge system just to evaluate the effectiveness of this patchset
by looking at the statistics (such as /proc/zoneinfo, /proc/pagetypeinfo
etc)., and of course this patchset has the code to export per-memory-region
info in procfs to enable such analyses. Apart from this, I was able to
evaluate the performance overhead of this patchset similarly, without actually
needing to run on a system with true (hardware) memory region boundaries.
Of course, this was a first-level algorithmic/functional testing and evaluation,
and I was able to demonstrate a huge benefit over mainline in terms of
consolidation of allocations. Going forward, I'll work on getting this running
on a setup that can give me the overall power-savings numbers as well.

BTW, it would be really great if somebody who has access to custom BIOSes
(which export memory region/ACPI MPST info) on x86 platforms could try out
this patchset and let me know how well this patchset performs on x86 in terms
of memory power savings. I don't have a custom x86 BIOS to get that info, so
I don't think I'll be able to try that out myself :-(


> Also, the changelogs don't appear to discuss one obvious downside: the
> latency incurred in bringing a bank out of one of the low-power states
> and back into full operation.  Please do discuss and quantify that to
> the best of your knowledge.
> 
> 

As Andi mentioned, the wakeup latency is not expected to be noticeable. And
these power-savings logic is turned on in the hardware by default. So its not
as if this patchset is going to _introduce_ that latency. This patchset only
tries to make the Linux MM _cooperate_ with the (already existing) hardware
power-savings logic and thereby get much better memory power-savings benefits
out of it.

Regards,
Srivatsa S. Bhat

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
