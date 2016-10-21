Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8B00F6B025E
	for <linux-mm@kvack.org>; Fri, 21 Oct 2016 08:26:02 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id f129so23141934itc.7
        for <linux-mm@kvack.org>; Fri, 21 Oct 2016 05:26:02 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id c9si2120983pas.21.2016.10.21.05.26.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Oct 2016 05:26:01 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9LCPwtj072675
	for <linux-mm@kvack.org>; Fri, 21 Oct 2016 08:26:01 -0400
Received: from e34.co.us.ibm.com (e34.co.us.ibm.com [32.97.110.152])
	by mx0a-001b2d01.pphosted.com with ESMTP id 267ex9kpkc-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 21 Oct 2016 08:25:59 -0400
Received: from localhost
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 21 Oct 2016 06:25:29 -0600
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm, mempolicy: clean up __GFP_THISNODE confusion in policy_zonelist
In-Reply-To: <c8f66d33-f2e9-c29d-6cfd-9eebb4832ebe@suse.cz>
References: <20161013125958.32155-1-mhocko@kernel.org> <877f92ue91.fsf@linux.vnet.ibm.com> <c8f66d33-f2e9-c29d-6cfd-9eebb4832ebe@suse.cz>
Date: Fri, 21 Oct 2016 17:55:20 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <874m45vqhb.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

Vlastimil Babka <vbabka@suse.cz> writes:

> On 10/21/2016 01:34 PM, Aneesh Kumar K.V wrote:
>> Michal Hocko <mhocko@kernel.org> writes:
>>>
>>
>> For both MPOL_PREFERED and MPOL_INTERLEAVE we pick the zone list from
>> the node other than the current running node. Why don't we do that for
>> MPOL_BIND ?ie, if the current node is not part of the policy node mask
>> why are we not picking the first node from the policy node mask for
>> MPOL_BIND ?
>
> For MPOL_PREFERED and MPOL_INTERLEAVE we got some explicit preference of nodes, 
> so it makes sense that the nodes in the zonelist we pick are ordered by the 
> distance from that node, regardless of current node.
>
> For MPOL_BIND, we don't have preferences but restrictions. If the current cpu is 
> from a node within the restriction, then great. If it's not, finding a node 
> according to distance from current cpu is probably less arbitrary than by 
> distance from the node that happens to have the lowest id in the node mask?

I agree. This is related to the changes we are working in this part of
the kernel. We are looking at adding support for coherent device. By
default we don't want to allocate memory from the coherent device node,
but then we are looking at an user space interface that can be used to
force allocation.

For now, to avoid allocation hitting the coherent device, we build the
zonelist of the nodes such that zones from the coherent device are not
present in any other node's zone list. We looked at use MPOL_BIND as
the user space interface to force allocation from coherent device node.
MPOL_BIND usage breaks with the above detail you mentioned about
MPOL_BIND.

>From what you are suggesting above, I guess the right approach is to add
coherent node's zones to all the node's zone list and make sure the default
node mask used for allocation (N_MEMORY) doesn't have coherent device
node ?

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
