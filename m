Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 31D5D6B0254
	for <linux-mm@kvack.org>; Wed, 10 Feb 2016 07:35:05 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id p63so24485330wmp.1
        for <linux-mm@kvack.org>; Wed, 10 Feb 2016 04:35:05 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f184si5167930wme.20.2016.02.10.04.35.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 10 Feb 2016 04:35:04 -0800 (PST)
Date: Wed, 10 Feb 2016 13:35:18 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: Another proposal for DAX fault locking
Message-ID: <20160210123518.GG12245@quack.suse.cz>
References: <20160209172416.GB12245@quack.suse.cz>
 <87egck4ukx.fsf@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87egck4ukx.fsf@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Monakhov <dmonlist@gmail.com>
Cc: Jan Kara <jack@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-nvdimm@lists.01.org, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mgorman@suse.de, linux-fsdevel@vger.kernel.org

On Wed 10-02-16 15:29:34, Dmitry Monakhov wrote:
> Jan Kara <jack@suse.cz> writes:
> 
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
> Agree, only small note:
> Hash locks has side effect for batch locking due to collision.
> Some times we want to lock several pages/entries (migration/defragmentation)
> So we will endup with deadlock due to hash collision.

Yeah, but at least for the purposes we want the locks for locking just one
'page' is enough. If we ever needed locking more 'pages', we would have to
choose a different locking scheme.

									Honza

-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
