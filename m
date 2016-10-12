Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3D4BC6B0267
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 07:02:01 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id y38so33508576qta.6
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 04:02:01 -0700 (PDT)
Received: from mail-qk0-f180.google.com (mail-qk0-f180.google.com. [209.85.220.180])
        by mx.google.com with ESMTPS id q13si3554554qkl.43.2016.10.12.04.02.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Oct 2016 04:02:00 -0700 (PDT)
Received: by mail-qk0-f180.google.com with SMTP id n189so24038650qke.0
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 04:02:00 -0700 (PDT)
Date: Wed, 12 Oct 2016 13:01:58 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: MPOL_BIND on memory only nodes
Message-ID: <20161012110158.GK17128@dhcp22.suse.cz>
References: <57FE0184.6030008@linux.vnet.ibm.com>
 <20161012094337.GH17128@dhcp22.suse.cz>
 <57FE12B8.4050401@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57FE12B8.4050401@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Balbir Singh <bsingharora@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>

On Wed 12-10-16 16:08:48, Anshuman Khandual wrote:
> On 10/12/2016 03:13 PM, Michal Hocko wrote:
> > On Wed 12-10-16 14:55:24, Anshuman Khandual wrote:
> >> Hi,
> >>
> >> We have the following function policy_zonelist() which selects a zonelist
> >> during various allocation paths. With this, general user space allocations
> >> (IIUC might not have __GFP_THISNODE) fails while trying to get memory from
> >> a memory only node without CPUs as the application runs some where else
> >> and that node is not part of the nodemask.
> 
> My bad. Was playing with some changes to the zonelists rebuild after
> a memory node hotplug and the order of various zones in them.
> 
> > 
> > I am not sure I understand. So you have a task with MPOL_BIND without a
> > cpu less node in the mask and you are wondering why the memory is not
> > allocated from that node?
> 
> In my experiment, there is a MPOL_BIND call with a CPU less node in
> the node mask and the memory is not allocated from that CPU less node.
> Thats because the zone of the CPU less node was absent from the
> FALLBACK zonelist of the local node.

So do I understand this correctly that the issue was caused by
non-upstream changes?

> >> Why we insist on __GFP_THISNODE ?
> > 
> > AFAIU __GFP_THISNODE just overrides the given node to the policy
> > nodemask in case the current node is not part of that node mask. In
> > other words we are ignoring the given node and use what the policy says. 
> 
> Right but provided the gfp flag has __GFP_THISNODE in it. In absence
> of __GFP_THISNODE, the node from the nodemask will not be selected.

In absence of __GFP_THISNODE we will use the zonelist for the given node
and that should contain even memoryless nodes for the fallback. The
nodemask from policy_nodemask() will then make sure that only nodes
relevant to the used policy is used.

> I still wonder why ? Can we always go to the first node in the
> nodemask for MPOL_BIND interface calls ? Just curious to know why
> preference is given to the local node and it's FALLBACK zonelist.

It is not always a local node. Look at how do_huge_pmd_wp_page_fallback
tries to make all the pages into the same node. Also we have
alloc_pages_current() which tries to allocate from the local node which
should not fallback to the firs node in the policy nodemask.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
