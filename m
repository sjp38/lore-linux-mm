Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 56BBF6B0072
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 13:34:04 -0500 (EST)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Sat, 17 Nov 2012 00:04:01 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qAGIXnaB4522312
	for <linux-mm@kvack.org>; Sat, 17 Nov 2012 00:03:49 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qAH03T78016670
	for <linux-mm@kvack.org>; Sat, 17 Nov 2012 11:03:30 +1100
Message-ID: <50A686C5.7080103@linux.vnet.ibm.com>
Date: Sat, 17 Nov 2012 00:02:37 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/8][Sorted-buddy] mm: Linux VM Infrastructure to
 support Memory Power Management
References: <20121106195026.6941.24662.stgit@srivatsabhat.in.ibm.com> <20121108180257.GC8218@suse.de> <20121109051247.GA499@dirshya.in.ibm.com> <20121109090052.GF8218@suse.de> <509D185D.8070307@linux.vnet.ibm.com> <509D200F.2000908@linux.vnet.ibm.com> <509D2B9B.4090305@linux.vnet.ibm.com> <509D3088.2060507@linux.vnet.ibm.com> <509D32C2.2090104@linux.vnet.ibm.com> <509D34DA.5090303@linux.vnet.ibm.com>
In-Reply-To: <509D34DA.5090303@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Mel Gorman <mgorman@suse.de>, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, akpm@linux-foundation.org, mjg59@srcf.ucam.org, paulmck@linux.vnet.ibm.com, maxime.coquelin@stericsson.com, loic.pallardy@stericsson.com, arjan@linux.intel.com, kmpark@infradead.org, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl, gargankita@gmail.com, amit.kachhap@linaro.org, thomas.abraham@linaro.org, santosh.shilimkar@ti.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, andi@firstfloor.org, SrinivasPandruvada <srinivas.pandruvada@linux.intel.com>

On 11/09/2012 10:22 PM, Srivatsa S. Bhat wrote:
> On 11/09/2012 10:13 PM, Srivatsa S. Bhat wrote:
>> On 11/09/2012 10:04 PM, Srivatsa S. Bhat wrote:
>>> On 11/09/2012 09:43 PM, Dave Hansen wrote:
>>>> On 11/09/2012 07:23 AM, Srivatsa S. Bhat wrote:
>>>>> FWIW, kernbench is actually (and surprisingly) showing a slight performance
>>>>> *improvement* with this patchset, over vanilla 3.7-rc3, as I mentioned in
>>>>> my other email to Dave.
>>>>>
>>>>> https://lkml.org/lkml/2012/11/7/428
>>>>>
>>>>> I don't think I can dismiss it as an experimental error, because I am seeing
>>>>> those results consistently.. I'm trying to find out what's behind that.
>>>>
>>>> The only numbers in that link are in the date. :)  Let's see the
>>>> numbers, please.
>>>>
>>>
>>> Sure :) The reason I didn't post the numbers very eagerly was that I didn't
>>> want it to look ridiculous if it later turned out to be really an error in the
>>> experiment ;) But since I have seen it happening consistently I think I can
>>> post the numbers here with some non-zero confidence.
>>>
>>>> If you really have performance improvement to the memory allocator (or
>>>> something else) here, then surely it can be pared out of your patches
>>>> and merged quickly by itself.  Those kinds of optimizations are hard to
>>>> come by!
>>>>
>>>
>>> :-)
>>>
>>> Anyway, here it goes:
>>>
>>> Test setup:
>>> ----------
>>> x86 2-socket quad-core machine. (CONFIG_NUMA=n because I figured that my
>>> patchset might not handle NUMA properly). Mem region size = 512 MB.
>>>
>>
>> For CONFIG_NUMA=y on the same machine, the difference between the 2 kernels
>> was much lesser, but nevertheless, this patchset performed better. I wouldn't
>> vouch that my patchset handles NUMA correctly, but here are the numbers from
>> that run anyway (at least to show that I really found the results to be
>> repeatable):
>>

I fixed up the NUMA case (I'll post the updated patch for that soon) and
ran a fresh set of kernbench runs. The difference between mainline and this
patchset is quite tiny; so we can't really say that this patchset shows a
performance improvement over mainline. However, I can safely conclude that
this patchset doesn't show any performance _degradation_ w.r.t mainline
in kernbench.

Results from one of the recent kernbench runs:
---------------------------------------------

Kernbench log for Vanilla 3.7-rc3
=================================
Kernel: 3.7.0-rc3
Average Optimal load -j 32 Run (std deviation):
Elapsed Time 330.39 (0.746257)
User Time 4283.63 (3.39617)
System Time 604.783 (2.72629)
Percent CPU 1479 (3.60555)
Context Switches 845634 (6031.22)
Sleeps 833655 (6652.17)


Kernbench log for Sorted-buddy
==============================
Kernel: 3.7.0-rc3-sorted-buddy
Average Optimal load -j 32 Run (std deviation):
Elapsed Time 329.967 (2.76789)
User Time 4230.02 (2.15324)
System Time 599.793 (1.09988)
Percent CPU 1463.33 (11.3725)
Context Switches 840530 (1646.75)
Sleeps 833732 (2227.68)

Regards,
Srivatsa S. Bhat

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
