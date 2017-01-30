Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 771516B0038
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 12:34:28 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id c73so462054096pfb.7
        for <linux-mm@kvack.org>; Mon, 30 Jan 2017 09:34:28 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id g9si13159578plk.185.2017.01.30.09.34.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jan 2017 09:34:27 -0800 (PST)
Subject: Re: [RFC V2 03/12] mm: Change generic FALLBACK zonelist creation
 process
References: <20170130033602.12275-1-khandual@linux.vnet.ibm.com>
 <20170130033602.12275-4-khandual@linux.vnet.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <07bd439c-6270-b219-227b-4079d36a2788@intel.com>
Date: Mon, 30 Jan 2017 09:34:27 -0800
MIME-Version: 1.0
In-Reply-To: <20170130033602.12275-4-khandual@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dan.j.williams@intel.com

On 01/29/2017 07:35 PM, Anshuman Khandual wrote:
> * CDM node's zones are not part of any other node's FALLBACK zonelist
> * CDM node's FALLBACK list contains it's own memory zones followed by
>   all system RAM zones in regular order as before
> * CDM node's zones are part of it's own NOFALLBACK zonelist

This seems like a sane policy for the system that you're describing.
But, it's still a policy, and it's rather hard-coded into the kernel.
Let's say we had a CDM node with 100x more RAM than the rest of the
system and it was just as fast as the rest of the RAM.  Would we still
want it isolated like this?  Or would we want a different policy?

Why do we need this hard-coded along with the cpuset stuff later in the
series.  Doesn't taking a node out of the cpuset also take it out of the
fallback lists?

>  	while ((node = find_next_best_node(local_node, &used_mask)) >= 0) {
> +#ifdef CONFIG_COHERENT_DEVICE
> +		/*
> +		 * CDM node's own zones should not be part of any other
> +		 * node's fallback zonelist but only it's own fallback
> +		 * zonelist.
> +		 */
> +		if (is_cdm_node(node) && (pgdat->node_id != node))
> +			continue;
> +#endif

On a superficial note: Isn't that #ifdef unnecessary?  is_cdm_node() has
a 'return 0' stub when the config option is off anyway.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
