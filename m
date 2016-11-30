Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id AC3606B0253
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 14:43:41 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id p66so44911958pga.4
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 11:43:41 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id z5si65575852pgf.155.2016.11.30.11.43.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Nov 2016 11:43:40 -0800 (PST)
Subject: Re: [RFC 4/4] mm: Ignore cpuset enforcement when allocation flag has
 __GFP_THISNODE
References: <1479824388-30446-1-git-send-email-khandual@linux.vnet.ibm.com>
 <1479824388-30446-5-git-send-email-khandual@linux.vnet.ibm.com>
 <8216916c-c3f3-bad9-33cb-b0da2508f3d0@intel.com>
 <583D2570.6070109@linux.vnet.ibm.com>
 <9a2e3fd7-1955-b347-2447-4b66402c1ce8@intel.com>
 <583EB52D.3080307@linux.vnet.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <facddba2-ab56-0fea-c608-0bae65e32dbd@intel.com>
Date: Wed, 30 Nov 2016 11:43:39 -0800
MIME-Version: 1.0
In-Reply-To: <583EB52D.3080307@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, Li Zefan <lizefan@huawei.com>

On 11/30/2016 03:17 AM, Anshuman Khandual wrote:
> Right but what is the rationale behind this ? This what is in the in-code
> documentation for this function __cpuset_node_allowed().
> 
>  *	GFP_KERNEL   - any node in enclosing hardwalled cpuset ok
>  
> If the allocation has requested GFP_KERNEL, should not it look for the
> entire system for memory ? Does cpuset still has to be enforced ?

Documentation/cgroup-v1/cpusets.txt explains it quite a bit.

>> What exactly are the kernel-internal places that need to allocate from
>> the coherent device node?  When would this be done out of the context of
>> an application *asking* for memory in the new node?
> 
> The primary user right now is a driver who wants to move around mapped
> pages of an application from system RAM to CDM nodes and back. If the
> application has requested for it though an ioctl(), during migration
> the destination pages will be allocated on the CDM *in* the task context.

Side note: uhh, so you're doing migrate_pages() through some kind of new
ioctl()?  Why?

I think you're actually pointing out a hole in how cpusets currently
works, especially about the workqueue.  I'm not quite sure if this is by
design for migrate_pages() (a task doing migrate_pages() can pages for a
task from a cpuset even though that task isn't able to allocate itself).

> The driver could also have scheduled migration chunks in the work queue
> which can execute later on. IIUC those execution and corresponding
> allocation into CDM node will be *out* of context of the task.

Yeah, the current->mems_allowed in __cpuset_node_allowed() does seem
rather wrong for something happening in another task's context.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
