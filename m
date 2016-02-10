Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id C07C96B0259
	for <linux-mm@kvack.org>; Wed, 10 Feb 2016 18:44:18 -0500 (EST)
Received: by mail-pf0-f177.google.com with SMTP id q63so19761836pfb.0
        for <linux-mm@kvack.org>; Wed, 10 Feb 2016 15:44:18 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id uv2si8186538pac.41.2016.02.10.15.44.18
        for <linux-mm@kvack.org>;
        Wed, 10 Feb 2016 15:44:18 -0800 (PST)
Date: Wed, 10 Feb 2016 16:44:06 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: Another proposal for DAX fault locking
Message-ID: <20160210234406.GD30938@linux.intel.com>
References: <20160209172416.GB12245@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160209172416.GB12245@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, Dave Chinner <david@fromorbit.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dan Williams <dan.j.williams@intel.com>, linux-nvdimm@lists.01.org, mgorman@suse.de, Matthew Wilcox <willy@linux.intel.com>

On Tue, Feb 09, 2016 at 06:24:16PM +0100, Jan Kara wrote:
> Hello,
> 
> I was thinking about current issues with DAX fault locking [1] (data
> corruption due to racing faults allocating blocks) and also races which
> currently don't allow us to clear dirty tags in the radix tree due to races
> between faults and cache flushing [2]. Both of these exist because we don't
> have an equivalent of page lock available for DAX. While we have a
> reasonable solution available for problem [1], so far I'm not aware of a
> decent solution for [2]. After briefly discussing the issue with Mel he had
> a bright idea that we could used hashed locks to deal with [2] (and I think
> we can solve [1] with them as well). So my proposal looks as follows:
> 
> DAX will have an array of mutexes (the array can be made per device but
> initially a global one should be OK). We will use mutexes in the array as a
> replacement for page lock - we will use hashfn(mapping, index) to get
> particular mutex protecting our offset in the mapping. On fault / page
> mkwrite, we'll grab the mutex similarly to page lock and release it once we
> are done updating page tables. This deals with races in [1]. When flushing
> caches we grab the mutex before clearing writeable bit in page tables
> and clearing dirty bit in the radix tree and drop it after we have flushed
> caches for the pfn. This deals with races in [2].
> 
> Thoughts?
> 
> 								Honza
> 
> [1] http://oss.sgi.com/archives/xfs/2016-01/msg00575.html
> [2] https://lists.01.org/pipermail/linux-nvdimm/2016-January/004057.html

Overall I think this sounds promising.  I think a potential tie-in with the
radix tree would maybe take us in a good direction.

I had another idea of how to solve race #2 that involved sticking a seqlock
around the DAX radix tree + pte_mkwrite() sequence, and on the flushing side
if you noticed that you've raced against a page fault, just leaving the dirty
page tree entry intact.

I *think* this could work - I'd want to bang on it more - but if we have a
general way of handling DAX locking that we can use instead of solving these
issues one-by-one as they come up, that seems like a much better route.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
