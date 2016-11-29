Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 447A66B025E
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 11:52:10 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id x23so445076155pgx.6
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 08:52:10 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id x1si32107426plb.36.2016.11.29.08.52.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Nov 2016 08:52:09 -0800 (PST)
Subject: Re: [RFC 4/4] mm: Ignore cpuset enforcement when allocation flag has
 __GFP_THISNODE
References: <1479824388-30446-1-git-send-email-khandual@linux.vnet.ibm.com>
 <1479824388-30446-5-git-send-email-khandual@linux.vnet.ibm.com>
 <8216916c-c3f3-bad9-33cb-b0da2508f3d0@intel.com>
 <583D2570.6070109@linux.vnet.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <9a2e3fd7-1955-b347-2447-4b66402c1ce8@intel.com>
Date: Tue, 29 Nov 2016 08:52:08 -0800
MIME-Version: 1.0
In-Reply-To: <583D2570.6070109@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com

On 11/28/2016 10:51 PM, Anshuman Khandual wrote:
> On 11/29/2016 02:42 AM, Dave Hansen wrote:
>> > On 11/22/2016 06:19 AM, Anshuman Khandual wrote:
>>> >> --- a/mm/page_alloc.c
>>> >> +++ b/mm/page_alloc.c
>>> >> @@ -3715,7 +3715,7 @@ struct page *
>>> >>  		.migratetype = gfpflags_to_migratetype(gfp_mask),
>>> >>  	};
>>> >>  
>>> >> -	if (cpusets_enabled()) {
>>> >> +	if (cpusets_enabled() && !(alloc_mask & __GFP_THISNODE)) {
>>> >>  		alloc_mask |= __GFP_HARDWALL;
>>> >>  		alloc_flags |= ALLOC_CPUSET;
>>> >>  		if (!ac.nodemask)
>> > 
>> > This means now that any __GFP_THISNODE allocation can "escape" the
>> > cpuset.  That seems like a pretty major change to how cpusets works.  Do
>> > we know that *ALL* __GFP_THISNODE allocations are truly lacking in a
>> > cpuset context that can be enforced?
> Right, I know its a very blunt change. With the cpuset based isolation
> of coherent device node for the user space tasks leads to a side effect
> that a driver or even kernel cannot allocate memory from the coherent
...

Well, we have __GFP_HARDWALL:

	 * __GFP_HARDWALL enforces the cpuset memory allocation policy.

which you can clear in the places where you want to do an allocation but
want to ignore cpusets.  But, __cpuset_node_allowed() looks like it gets
a little funky if you do that since it would probably be falling back to
the root cpuset that also would not have the new node in mems_allowed.

What exactly are the kernel-internal places that need to allocate from
the coherent device node?  When would this be done out of the context of
an application *asking* for memory in the new node?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
