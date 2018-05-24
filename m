Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id BE62E6B026E
	for <linux-mm@kvack.org>; Wed, 23 May 2018 23:22:26 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id f63-v6so293453wmi.4
        for <linux-mm@kvack.org>; Wed, 23 May 2018 20:22:26 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id m7-v6si3554558edm.35.2018.05.23.20.22.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 May 2018 20:22:25 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w4O3JPIu116432
	for <linux-mm@kvack.org>; Wed, 23 May 2018 23:22:24 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2j5gbvj8tm-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 23 May 2018 23:22:23 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 24 May 2018 04:22:22 +0100
Subject: Re: [PATCH 2/2] mm: do not warn on offline nodes unless the specific
 node is explicitly requested
References: <20180523125555.30039-1-mhocko@kernel.org>
 <20180523125555.30039-3-mhocko@kernel.org>
 <11e26a4e-552e-b1dc-316e-ce3e92973556@linux.vnet.ibm.com>
 <20180523140601.GQ20441@dhcp22.suse.cz>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Thu, 24 May 2018 08:52:14 +0530
MIME-Version: 1.0
In-Reply-To: <20180523140601.GQ20441@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <094afec3-5682-f99d-81bb-230319c78d5d@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oscar Salvador <osalvador@techadventures.net>, Vlastimil Babka <vbabka@suse.cz>, Pavel Tatashin <pasha.tatashin@oracle.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On 05/23/2018 07:36 PM, Michal Hocko wrote:
> On Wed 23-05-18 19:15:51, Anshuman Khandual wrote:
>> On 05/23/2018 06:25 PM, Michal Hocko wrote:
>>> when adding memory to a node that is currently offline.
>>>
>>> The VM_WARN_ON is just too loud without a good reason. In this
>>> particular case we are doing
>>> 	alloc_pages_node(node, GFP_KERNEL|__GFP_RETRY_MAYFAIL|__GFP_NOWARN, order)
>>>
>>> so we do not insist on allocating from the given node (it is more a
>>> hint) so we can fall back to any other populated node and moreover we
>>> explicitly ask to not warn for the allocation failure.
>>>
>>> Soften the warning only to cases when somebody asks for the given node
>>> explicitly by __GFP_THISNODE.
>>
>> node hint passed here eventually goes into __alloc_pages_nodemask()
>> function which then picks up the applicable zonelist irrespective of
>> the GFP flag __GFP_THISNODE.
> 
> __GFP_THISNODE should enforce the given node without any fallbacks
> unless something has changed recently.

Right. I was just saying requiring given preferred node to be online
whose zonelist (hence allocation zone fallback order) is getting picked
up during allocation and warning when that is not online still makes
sense. We should only hide the warning if the allocation request has
__GFP_NOWARN.

> 
>> Though we can go into zones of other
>> nodes if the present node (whose zonelist got picked up) does not
>> have any memory in it's zones. So warning here might not be without
>> any reason.
> 
> I am not sure I follow. Are you suggesting a different VM_WARN_ON?

I am just suggesting this instead.

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 036846fc00a6..7f860ea29ec6 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -464,7 +464,7 @@ static inline struct page *
 __alloc_pages_node(int nid, gfp_t gfp_mask, unsigned int order)
 {
 	VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES);
-	VM_WARN_ON(!node_online(nid));
+	VM_WARN_ON(!(gfp_mask & __GFP_NOWARN) && !node_online(nid));
 
 	return __alloc_pages(gfp_mask, order, nid);
 }
