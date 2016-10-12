Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 513566B0261
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 06:39:08 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ry6so39525738pac.1
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 03:39:08 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id o10si8697755pfe.75.2016.10.12.03.39.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Oct 2016 03:39:07 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9CAd5DD126951
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 06:39:07 -0400
Received: from e23smtp04.au.ibm.com (e23smtp04.au.ibm.com [202.81.31.146])
	by mx0a-001b2d01.pphosted.com with ESMTP id 261dxy09qn-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 06:39:06 -0400
Received: from localhost
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 12 Oct 2016 20:38:54 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id CF3FA2CE8056
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 21:38:50 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u9CAcoGs14090256
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 21:38:50 +1100
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u9CAcogq008778
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 21:38:50 +1100
Date: Wed, 12 Oct 2016 16:08:48 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: MPOL_BIND on memory only nodes
References: <57FE0184.6030008@linux.vnet.ibm.com> <20161012094337.GH17128@dhcp22.suse.cz>
In-Reply-To: <20161012094337.GH17128@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <57FE12B8.4050401@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Balbir Singh <bsingharora@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>

On 10/12/2016 03:13 PM, Michal Hocko wrote:
> On Wed 12-10-16 14:55:24, Anshuman Khandual wrote:
>> Hi,
>>
>> We have the following function policy_zonelist() which selects a zonelist
>> during various allocation paths. With this, general user space allocations
>> (IIUC might not have __GFP_THISNODE) fails while trying to get memory from
>> a memory only node without CPUs as the application runs some where else
>> and that node is not part of the nodemask.

My bad. Was playing with some changes to the zonelists rebuild after
a memory node hotplug and the order of various zones in them.

> 
> I am not sure I understand. So you have a task with MPOL_BIND without a
> cpu less node in the mask and you are wondering why the memory is not
> allocated from that node?

In my experiment, there is a MPOL_BIND call with a CPU less node in
the node mask and the memory is not allocated from that CPU less node.
Thats because the zone of the CPU less node was absent from the
FALLBACK zonelist of the local node.

> 
>> Why we insist on __GFP_THISNODE ?
> 
> AFAIU __GFP_THISNODE just overrides the given node to the policy
> nodemask in case the current node is not part of that node mask. In
> other words we are ignoring the given node and use what the policy says. 

Right but provided the gfp flag has __GFP_THISNODE in it. In absence
of __GFP_THISNODE, the node from the nodemask will not be selected. I
still wonder why ? Can we always go to the first node in the nodemask
for MPOL_BIND interface calls ? Just curious to know why preference
is given to the local node and it's FALLBACK zonelist.

> I can see how this can be confusing especially when confronting the
> documentation:
> 
>  * __GFP_THISNODE forces the allocation to be satisified from the requested
>  *   node with no fallbacks or placement policy enforcements.
> 

Yeah, right.

Thanks for your reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
