Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id ED7AF6B0009
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 05:38:41 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id g62so15204246wme.0
        for <linux-mm@kvack.org>; Thu, 11 Feb 2016 02:38:41 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 12si11215572wjy.50.2016.02.11.02.38.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 11 Feb 2016 02:38:40 -0800 (PST)
Date: Thu, 11 Feb 2016 11:38:56 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: Another proposal for DAX fault locking
Message-ID: <20160211103856.GE21760@quack.suse.cz>
References: <20160209172416.GB12245@quack.suse.cz>
 <56BB758D.1000704@plexistor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56BB758D.1000704@plexistor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boaz@plexistor.com>
Cc: Jan Kara <jack@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-nvdimm@lists.01.org, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mgorman@suse.de, linux-fsdevel@vger.kernel.org

On Wed 10-02-16 19:38:21, Boaz Harrosh wrote:
> On 02/09/2016 07:24 PM, Jan Kara wrote:
> > Hello,
> > 
> > I was thinking about current issues with DAX fault locking [1] (data
> > corruption due to racing faults allocating blocks) and also races which
> > currently don't allow us to clear dirty tags in the radix tree due to races
> > between faults and cache flushing [2]. Both of these exist because we don't
> > have an equivalent of page lock available for DAX. While we have a
> > reasonable solution available for problem [1], so far I'm not aware of a
> > decent solution for [2]. After briefly discussing the issue with Mel he had
> > a bright idea that we could used hashed locks to deal with [2] (and I think
> > we can solve [1] with them as well). So my proposal looks as follows:
> > 
> > DAX will have an array of mutexes (the array can be made per device but
> > initially a global one should be OK). We will use mutexes in the array as a
> > replacement for page lock - we will use hashfn(mapping, index) to get
> > particular mutex protecting our offset in the mapping. On fault / page
> > mkwrite, we'll grab the mutex similarly to page lock and release it once we
> > are done updating page tables. This deals with races in [1]. When flushing
> > caches we grab the mutex before clearing writeable bit in page tables
> > and clearing dirty bit in the radix tree and drop it after we have flushed
> > caches for the pfn. This deals with races in [2].
> > 
> > Thoughts?
> > 
> 
> You could also use one of the radix-tree's special-bits as a bit lock.
> So no need for any extra allocations.

Yes and I've suggested that once as well. But since we need sleeping
locks, you need some wait queues somewhere as well. So some allocations are
going to be needed anyway. And mutexes have much better properties than
bit-locks so I prefer mutexes over cramming bit locks into radix tree. Plus
you'd have to be careful so that someone doesn't remove the bit from the
radix tree while you are working with it.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
