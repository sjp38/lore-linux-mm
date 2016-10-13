Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2A2876B0269
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 06:58:38 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id fn2so74559389pad.7
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 03:58:38 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id n8si13972039pfi.271.2016.10.13.03.58.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Oct 2016 03:58:37 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9DAs1Fe114713
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 06:58:36 -0400
Received: from e23smtp07.au.ibm.com (e23smtp07.au.ibm.com [202.81.31.140])
	by mx0a-001b2d01.pphosted.com with ESMTP id 26264k0tby-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 06:58:36 -0400
Received: from localhost
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 13 Oct 2016 20:58:34 +1000
Received: from d23relay10.au.ibm.com (d23relay10.au.ibm.com [9.190.26.77])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 71E332BB0059
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 21:58:30 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u9DAwUA859703378
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 21:58:30 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u9DAwUOL004882
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 21:58:30 +1100
Date: Thu, 13 Oct 2016 16:28:27 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: MPOL_BIND on memory only nodes
References: <57FE0184.6030008@linux.vnet.ibm.com> <20161012094337.GH17128@dhcp22.suse.cz> <20161012131626.GL17128@dhcp22.suse.cz> <57FF59EE.9050508@linux.vnet.ibm.com> <20161013100708.GI21678@dhcp22.suse.cz>
In-Reply-To: <20161013100708.GI21678@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <57FF68D3.5030507@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Balbir Singh <bsingharora@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>

On 10/13/2016 03:37 PM, Michal Hocko wrote:
> On Thu 13-10-16 15:24:54, Anshuman Khandual wrote:
> [...]
>> Which makes the function look like this. Even with these changes, MPOL_BIND is
>> still going to pick up the local node's zonelist instead of the first node in
>> policy->v.nodes nodemask. It completely ignores policy->v.nodes which it should
>> not.
> 
> Not really. I have tried to explain earlier. We do not ignore policy
> nodemask. This one comes from policy_nodemask. We start with the local
> node but fallback to some of the nodes from the nodemask defined by the
> policy.
> 

Yeah saw your response but did not get that exactly. We dont ignore
policy nodemask while memory allocation, correct. But my point was
we are ignoring policy nodemask while selecting zonelist which will
be used during page allocation. Though the zone contents of both the
zonelists are likely to be same, would not it be better to get the
zone list from the nodemask as well ? Or I am still missing something
here. The following change is what I am trying to propose.

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index ad1c96a..f60ab80 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1685,14 +1685,7 @@ static struct zonelist *policy_zonelist(gfp_t gfp, struct mempolicy *policy,
                        nd = policy->v.preferred_node;
                break;
        case MPOL_BIND:
-               /*
-                * Normally, MPOL_BIND allocations are node-local within the
-                * allowed nodemask.  However, if __GFP_THISNODE is set and the
-                * current node isn't part of the mask, we use the zonelist for
-                * the first node in the mask instead.
-                */
-               if (unlikely(gfp & __GFP_THISNODE) &&
-                               unlikely(!node_isset(nd, policy->v.nodes)))
+               if (unlikely(!node_isset(nd, policy->v.nodes)))
                        nd = first_node(policy->v.nodes);
                break;
        default:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
