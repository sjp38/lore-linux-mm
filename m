Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 25BB16B046C
	for <linux-mm@kvack.org>; Thu, 16 Feb 2017 12:20:38 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id 11so17210368qkl.4
        for <linux-mm@kvack.org>; Thu, 16 Feb 2017 09:20:38 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c41si5657069qtd.180.2017.02.16.09.20.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Feb 2017 09:20:37 -0800 (PST)
Date: Thu, 16 Feb 2017 12:20:34 -0500
From: Brian Foster <bfoster@redhat.com>
Subject: Re: [Bug 192981] New: page allocation stalls
Message-ID: <20170216172034.GC11750@bfoster.bfoster>
References: <bug-192981-27@https.bugzilla.kernel.org/>
 <20170123135111.13ac3e47110de10a4bd503ef@linux-foundation.org>
 <8f450abd-4e05-92d3-2533-72b05fea2012@beget.ru>
 <20170215160538.GA62565@bfoster.bfoster>
 <a055abbf-a471-d111-9491-dc5b00208228@beget.ru>
 <20170215180859.GB62565@bfoster.bfoster>
 <07ee50bc-8220-dda8-07f9-369758603df9@beget.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <07ee50bc-8220-dda8-07f9-369758603df9@beget.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Polakov <apolyakov@beget.ru>
Cc: linux-mm@kvack.org, linux-xfs@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org, Dave Chinner <david@fromorbit.com>

On Thu, Feb 16, 2017 at 01:56:30PM +0300, Alexander Polakov wrote:
> On 02/15/2017 09:09 PM, Brian Foster wrote:
> > Ah, Ok. It sounds like this allows the reclaim thread to carry on into
> > other shrinkers and free up memory that way, perhaps. This sounds kind
> > of similar to the issue brought up previously here[1], but not quite the
> > same in that instead of backing off of locking to allow other shrinkers
> > to progress, we back off of memory allocations required to free up
> > inodes (memory).
> > 
> > In theory, I think something analogous to a trylock for inode to buffer
> > mappings that are no longer cached (or more specifically, cannot
> > currently be allocated) may work around this, but it's not immediately
> > clear to me whether that's a proper fix (it's also probably not a
> > trivial change either). I'm still kind of curious why we end up with
> > dirty inodes with reclaimed buffers. If this problem repeats, is it
> > always with a similar stack (i.e., reclaim -> xfs_iflush() ->
> > xfs_imap_to_bp())?
> 
> Looks like it is.
> 
> > How many independent filesystems are you running this workload against?
> 
> storage9 : ~ [0] # mount|grep storage|grep xfs|wc -l
> 15
> storage9 : ~ [0] # mount|grep storage|grep ext4|wc -l
> 44
> 

So a decent number of fs', more ext4 than XFS. Are the XFS fs' all of
similar size/geometry? If so, can you send representative xfs_info
output for the fs'?

I'm reading back through that reclaim thread[1] and it appears this
indeed is not a straightforward issue. It sounds like the summary is
Chris hit the same general behavior you have and is helped by bypassing
the synchronous nature of the shrinker. This allows other shrinkers to
proceed, but this is not a general solution because other workloads
depend on the synchronous shrinker behavior to throttle direct reclaim.
I can't say I understand all of the details and architecture of how/why
that is the case.

FWIW, it sounds like the first order problem is that we generally don't
want to find/flush dirty inodes from reclaim. A couple things that might
help avoid this situation are more aggressive
/proc/sys/fs/xfs/xfssyncd_centisecs tuning or perhaps considering a
smaller log size would cause more tail pushing pressure on the AIL
instead of pressure originating from memory reclaim. The latter might
not be so convenient if this is an already populated backup server,
though.

Beyond that, there's Chris' patch, another patch that Dave proposed[2],
and obviously your hack here to defer inode reclaim entirely to the
workqueue (I've CC'd Dave since it sounds like he might have been
working on this further..). Unfortunately, it sounds like [1] or your
hack aren't things we can pull into mainline for the time being until
the broader reclaim queueing/throttling mechanism is in place. I suppose
we might be able to revisit [2] if it actually does enough to prevent
this problem...

[1] http://www.spinics.net/lists/linux-xfs/msg01541.html
[2] http://www.spinics.net/lists/linux-xfs/msg02212.html

Brian

> > Can you describe the workload in more detail?
> 
> This is a backup server, we're running rsync. At night our production
> servers rsync their files to this server (a lot of small files).
> 
> > ...
> > > > The bz shows you have non-default vm settings such as
> > > > 'vm.vfs_cache_pressure = 200.' My understanding is that prefers
> > > > aggressive inode reclaim, yet the code workaround here is to bypass XFS
> > > > inode reclaim. Out of curiousity, have you reproduced this problem using
> > > > the default vfs_cache_pressure value (or if so, possibly moving it in
> > > > the other direction)?
> > > 
> > > Yes, we've tried that, it had about 0 influence.
> > > 
> > 
> > Which.. with what values? And by zero influence, do you simply mean the
> > stall still occurred or you have some other measurement of slab sizes or
> > some such that are unaffected?
> 
> Unfortunately I don't have slab statistics at hand. Stalls and following OOM
> situation still occured with this setting at 100.
> 
> -- 
> Alexander Polakov | system software engineer | https://beget.com
> --
> To unsubscribe from this list: send the line "unsubscribe linux-xfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
