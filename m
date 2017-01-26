Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 54B346B0253
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 07:09:53 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id jz4so39320746wjb.5
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 04:09:53 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p71si1744133wrc.275.2017.01.26.04.09.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 26 Jan 2017 04:09:51 -0800 (PST)
Date: Thu, 26 Jan 2017 13:09:48 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/6] mm: introduce kv[mz]alloc helpers
Message-ID: <20170126120948.GK6590@dhcp22.suse.cz>
References: <20170112153717.28943-1-mhocko@kernel.org>
 <20170112153717.28943-2-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170112153717.28943-2-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Anatoly Stepanov <astepanov@cloudlinux.com>, Paolo Bonzini <pbonzini@redhat.com>, Mike Snitzer <snitzer@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger@dilger.ca>

On Thu 12-01-17 16:37:12, Michal Hocko wrote:
[...]
> +void *kvmalloc_node(size_t size, gfp_t flags, int node)
> +{
> +	gfp_t kmalloc_flags = flags;
> +	void *ret;
> +
> +	/*
> +	 * vmalloc uses GFP_KERNEL for some internal allocations (e.g page tables)
> +	 * so the given set of flags has to be compatible.
> +	 */
> +	WARN_ON_ONCE((flags & GFP_KERNEL) != GFP_KERNEL);
> +
> +	/*
> +	 * Make sure that larger requests are not too disruptive - no OOM
> +	 * killer and no allocation failure warnings as we have a fallback
> +	 */
> +	if (size > PAGE_SIZE)
> +		kmalloc_flags |= __GFP_NORETRY | __GFP_NOWARN;
> +
> +	ret = kmalloc_node(size, kmalloc_flags, node);
> +
> +	/*
> +	 * It doesn't really make sense to fallback to vmalloc for sub page
> +	 * requests
> +	 */
> +	if (ret || size <= PAGE_SIZE)
> +		return ret;
> +
> +	return __vmalloc_node_flags(size, node, flags);
> +}
> +EXPORT_SYMBOL(kvmalloc_node);

While discussing bpf change I've realized that the vmalloc fallback
doesn't request __GFP_HIGHMEM. So I've updated the patch to do so. All
the current users except for f2fs_kv[zm]alloc which just seemed to
forgot or didn't know about the flag. In the next step, I would like to
check whether we actually have any __vmalloc* user which would strictly
refuse __GFP_HIGHMEM because I do not really see any reason for that and
if there is none then I would simply pull __GFP_HIGHMEM handling into
the vmalloc.

So before I resend the full series again, can I keep acks with the
following?
