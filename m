Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 702356B0253
	for <linux-mm@kvack.org>; Fri,  9 Oct 2015 05:27:01 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so81954460pad.1
        for <linux-mm@kvack.org>; Fri, 09 Oct 2015 02:27:01 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id fw7si1160306pbd.82.2015.10.09.02.27.00
        for <linux-mm@kvack.org>;
        Fri, 09 Oct 2015 02:27:00 -0700 (PDT)
Subject: Re: [Intel-wired-lan] [Patch V3 5/9] i40e: Use numa_mem_id() to
 better support memoryless node
References: <1439781546-7217-1-git-send-email-jiang.liu@linux.intel.com>
 <1439781546-7217-6-git-send-email-jiang.liu@linux.intel.com>
 <4197C471DCF8714FBA1FE32565271C148FFFF4D3@ORSMSX103.amr.corp.intel.com>
 <alpine.DEB.2.10.1508191717450.30666@chino.kir.corp.google.com>
 <20151008132037.fc3887da0818e7d011cb752f@linux-foundation.org>
 <56175637.50102@linux.intel.com> <56178419.6090503@jp.fujitsu.com>
From: Jiang Liu <jiang.liu@linux.intel.com>
Message-ID: <56178810.8040200@linux.intel.com>
Date: Fri, 9 Oct 2015 17:25:36 +0800
MIME-Version: 1.0
In-Reply-To: <56178419.6090503@jp.fujitsu.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: "Patil, Kiran" <kiran.patil@intel.com>, Mel Gorman <mgorman@suse.de>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Wysocki, Rafael J" <rafael.j.wysocki@intel.com>, Tang Chen <tangchen@cn.fujitsu.com>, Tejun Heo <tj@kernel.org>, "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>, "Brandeburg, Jesse" <jesse.brandeburg@intel.com>, "Nelson, Shannon" <shannon.nelson@intel.com>, "Wyborny, Carolyn" <carolyn.wyborny@intel.com>, "Skidmore, Donald C" <donald.c.skidmore@intel.com>, "Vick, Matthew" <matthew.vick@intel.com>, "Ronciak, John" <john.ronciak@intel.com>, "Williams, Mitch A" <mitch.a.williams@intel.com>, "Luck, Tony" <tony.luck@intel.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "linux-hotplug@vger.kernel.org" <linux-hotplug@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>

On 2015/10/9 17:08, Kamezawa Hiroyuki wrote:
> On 2015/10/09 14:52, Jiang Liu wrote:
>> On 2015/10/9 4:20, Andrew Morton wrote:
>>> On Wed, 19 Aug 2015 17:18:15 -0700 (PDT) David Rientjes
>>> <rientjes@google.com> wrote:
>>>
>>>> On Wed, 19 Aug 2015, Patil, Kiran wrote:
>>>>
>>>>> Acked-by: Kiran Patil <kiran.patil@intel.com>
>>>>
>>>> Where's the call to preempt_disable() to prevent kernels with
>>>> preemption
>>>> from making numa_node_id() invalid during this iteration?
>>>
>>> David asked this question twice, received no answer and now the patch
>>> is in the maintainer tree, destined for mainline.
>>>
>>> If I was asked this question I would respond
>>>
>>>    The use of numa_mem_id() is racy and best-effort.  If the unlikely
>>>    race occurs, the memory allocation will occur on the wrong node, the
>>>    overall result being very slightly suboptimal performance.  The
>>>    existing use of numa_node_id() suffers from the same issue.
>>>
>>> But I'm not the person proposing the patch.  Please don't just ignore
>>> reviewer comments!
>> Hi Andrew,
>>     Apologize for the slow response due to personal reasons!
>> And thanks for answering the question from David. To be honest,
>> I didn't know how to answer this question before. Actually this
>> question has puzzled me for a long time when dealing with memory
>> hot-removal. For normal cases, it only causes sub-optimal memory
>> allocation if schedule event happens between querying NUMA node id
>> and calling alloc_pages_node(). But what happens if system run into
>> following execution sequence?
>> 1) node = numa_mem_id();
>> 2) memory hot-removal event triggers
>> 2.1) remove affected memory
>> 2.2) reset pgdat to zero if node becomes empty after memory removal
> 
> I'm sorry if I misunderstand something.
> After commit b0dc3a342af36f95a68fe229b8f0f73552c5ca08, there is no
> memset().
Hi Kamezawa,
	Thanks for the information. The commit solved the issue what
I was puzzling about. With this change applied, thing should work
as expected. Seems it would be better to enhance __build_all_zonelists()
to handle those offlined empty nodes too, but that really doesn't
make to much difference:)
	Thanks for the info again!
Thanks!
Gerry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
