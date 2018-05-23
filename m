Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 211CB6B0005
	for <linux-mm@kvack.org>; Wed, 23 May 2018 09:46:06 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 70-v6so2524589wmb.2
        for <linux-mm@kvack.org>; Wed, 23 May 2018 06:46:06 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id v23-v6si14544157edr.266.2018.05.23.06.46.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 May 2018 06:46:04 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w4NDdAwo131097
	for <linux-mm@kvack.org>; Wed, 23 May 2018 09:46:03 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2j572e8jxg-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 23 May 2018 09:46:02 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 23 May 2018 14:45:59 +0100
Subject: Re: [PATCH 2/2] mm: do not warn on offline nodes unless the specific
 node is explicitly requested
References: <20180523125555.30039-1-mhocko@kernel.org>
 <20180523125555.30039-3-mhocko@kernel.org>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Wed, 23 May 2018 19:15:51 +0530
MIME-Version: 1.0
In-Reply-To: <20180523125555.30039-3-mhocko@kernel.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <11e26a4e-552e-b1dc-316e-ce3e92973556@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Oscar Salvador <osalvador@techadventures.net>, Vlastimil Babka <vbabka@suse.cz>, Pavel Tatashin <pasha.tatashin@oracle.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>

On 05/23/2018 06:25 PM, Michal Hocko wrote:
> when adding memory to a node that is currently offline.
> 
> The VM_WARN_ON is just too loud without a good reason. In this
> particular case we are doing
> 	alloc_pages_node(node, GFP_KERNEL|__GFP_RETRY_MAYFAIL|__GFP_NOWARN, order)
> 
> so we do not insist on allocating from the given node (it is more a
> hint) so we can fall back to any other populated node and moreover we
> explicitly ask to not warn for the allocation failure.
> 
> Soften the warning only to cases when somebody asks for the given node
> explicitly by __GFP_THISNODE.

node hint passed here eventually goes into __alloc_pages_nodemask()
function which then picks up the applicable zonelist irrespective of
the GFP flag __GFP_THISNODE. Though we can go into zones of other
nodes if the present node (whose zonelist got picked up) does not
have any memory in it's zones. So warning here might not be without
any reason. But yes, if the request has __GFP_NOWARN it makes sense
not to print any warning.
