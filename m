Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id E71416B0031
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 09:42:00 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id un15so1152424pbc.29
        for <linux-mm@kvack.org>; Thu, 26 Sep 2013 06:42:00 -0700 (PDT)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Thu, 26 Sep 2013 23:41:50 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 5A7A32BB0054
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 23:41:44 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8QDfW7c2556292
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 23:41:33 +1000
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r8QDffII011716
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 23:41:43 +1000
Message-ID: <52443897.7050603@linux.vnet.ibm.com>
Date: Thu, 26 Sep 2013 19:07:27 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [Results] [RFC PATCH v4 00/40] mm: Memory Power Management
References: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com> <52437128.7030402@linux.vnet.ibm.com> <20130925164057.6bbaf23bdc5057c42b2ab010@linux-foundation.org> <20130925234734.GK18242@two.firstfloor.org> <52438AA9.3020809@linux.intel.com> <20130925182129.a7db6a0fd2c7cc3b43fda92d@linux-foundation.org> <20130926015016.GM18242@two.firstfloor.org>
In-Reply-To: <20130926015016.GM18242@two.firstfloor.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Arjan van de Ven <arjan@linux.intel.com>, mgorman@suse.de, dave@sr71.net, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, riel@redhat.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl, gargankita@gmail.com, paulmck@linux.vnet.ibm.com, svaidy@linux.vnet.ibm.com, isimatu.yasuaki@jp.fujitsu.com, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, maxime.coquelin@stericsson.com, loic.pallardy@stericsson.com, thomas.abraham@linaro.org, amit.kachhap@linaro.org

On 09/26/2013 07:20 AM, Andi Kleen wrote:
> On Wed, Sep 25, 2013 at 06:21:29PM -0700, Andrew Morton wrote:
>> On Wed, 25 Sep 2013 18:15:21 -0700 Arjan van de Ven <arjan@linux.intel.com> wrote:
>>
>>> On 9/25/2013 4:47 PM, Andi Kleen wrote:
>>>>> Also, the changelogs don't appear to discuss one obvious downside: the
>>>>> latency incurred in bringing a bank out of one of the low-power states
>>>>> and back into full operation.  Please do discuss and quantify that to
>>>>> the best of your knowledge.
>>>>
>>>> On Sandy Bridge the memry wakeup overhead is really small. It's on by default
>>>> in most setups today.
>>>
>>> btw note that those kind of memory power savings are content-preserving,
>>> so likely a whole chunk of these patches is not actually needed on SNB
>>> (or anything else Intel sells or sold)
>>
>> (head spinning a bit).  Could you please expand on this rather a lot?
> 
> As far as I understand there is a range of aggressiveness. You could
> just group memory a bit better (assuming you can sufficiently predict
> the future or have some interface to let someone tell you about it).
> 
> Or you can actually move memory around later to get as low footprint
> as possible.
> 
> This patchkit seems to do both, with the later parts being on the
> aggressive side (move things around) 
>

Yes, that's correct.

Grouping memory at allocation time is achieved using 2 techniques:
- Sorted-buddy allocator (patches 1-15)
- Split-allocator design or a "Region Allocator" as back-end (patches 16-33)

The aggressive/opportunistic page movement or reclaim is achieved using:
- Targeted region evacuation mechanism (patches 34-40)

Apart from being individually beneficial, the first 2 techniques influence
the Linux MM in such a way that it tremendously improves the yield/benefit
of the targeted compaction as well :-)

[ Its due to the avoidance of fragmentation of allocations pertaining to
_different_ migratetypes within a single memory region. By keeping each memory
region homogeneous with respect to the type of allocation, targeted compaction
becomes much more effective, since for example, we won't have cases where a
stubborn unmovable page will end up disrupting the region-evac attempt of a
region which has mostly movable/reclaimable allocations. ]


> If you had non content preserving memory saving you would 
> need to be aggressive as you couldn't afford any mistakes.
> 
> If you had very slow wakeup you also couldn't afford mistakes,
> as those could cost a lot of time.
> 
> On SandyBridge is not slow and it's preserving, so some mistakes are ok.
> 
> But being aggressive (so move things around) may still help you saving
> more power -- i guess only benchmarks can tell. It's a trade off between
> potential gain and potential worse case performance regression.
> It may also depend on the workload.
>

True, but we get better consolidation ratios than mainline even without
getting too aggressive. For example, the v3 of this patchset didn't have
the targeted compaction logic, and still it was able to show up to around
120 free-regions at the end of test run.

http://article.gmane.org/gmane.linux.kernel.mm/106283

This version of the patchset with the added aggressive logic (targeted
compaction) makes it only better: the free-regions number comes up to 202.
 
> At least right now the numbers seem to be positive.
> 

:-)
 
Regards,
Srivatsa S. Bhat

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
