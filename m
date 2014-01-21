Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-gg0-f180.google.com (mail-gg0-f180.google.com [209.85.161.180])
	by kanga.kvack.org (Postfix) with ESMTP id E3DEC6B004D
	for <linux-mm@kvack.org>; Tue, 21 Jan 2014 15:20:50 -0500 (EST)
Received: by mail-gg0-f180.google.com with SMTP id q3so2756492gge.11
        for <linux-mm@kvack.org>; Tue, 21 Jan 2014 12:20:50 -0800 (PST)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [2001:44b8:8060:ff02:300:1:6:4])
        by mx.google.com with ESMTP id k66si7351622yhc.36.2014.01.21.12.20.48
        for <linux-mm@kvack.org>;
        Tue, 21 Jan 2014 12:20:49 -0800 (PST)
Date: Wed, 22 Jan 2014 07:20:43 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] [ATTEND] Persistent memory
Message-ID: <20140121202043.GC13997@dastard>
References: <CALCETrUaotUuzn60-bSt1oUb8+94do2QgiCq_TXhqEHj79DePQ@mail.gmail.com>
 <52D8AEBF.3090803@symas.com>
 <52D982EB.6010507@amacapital.net>
 <52DE23E8.9010608@symas.com>
 <20140121111727.GB13997@dastard>
 <52DE7CBA.8020206@symas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52DE7CBA.8020206@symas.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Howard Chu <hyc@symas.com>
Cc: Linux FS Devel <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, lsf-pc@lists.linux-foundation.org, Andy Lutomirski <luto@amacapital.net>

On Tue, Jan 21, 2014 at 05:57:14AM -0800, Howard Chu wrote:
> Dave Chinner wrote:
> >On Mon, Jan 20, 2014 at 11:38:16PM -0800, Howard Chu wrote:
> >>Andy Lutomirski wrote:
> >>>On 01/16/2014 08:17 PM, Howard Chu wrote:
> >>>>Andy Lutomirski wrote:
> >>>>>I'm interested in a persistent memory track.  There seems to be plenty
> >>>>>of other emails about this, but here's my take:
> >>>>
> >>>>I'm also interested in this track. I'm not up on FS development these
> >>>>days, the last time I wrote filesystem code was nearly 20 years ago. But
> >>>>persistent memory is a topic near and dear to my heart, and of great
> >>>>relevance to my current pet project, the LMDB memory-mapped database.
> >>>>
> >>>>In a previous era I also developed block device drivers for
> >>>>battery-backed external DRAM disks. (My ideal would have been systems
> >>>>where all of RAM was persistent. I suppose we can just about get there
> >>>>with mobile phones and tablets these days.)
> >>>>
> >>>>In the context of database engines, I'm interested in leveraging
> >>>>persistent memory for write-back caching and how user level code can be
> >>>>made aware of it. (If all your cache is persistent and guaranteed to
> >>>>eventually reach stable store then you never need to fsync() a
> >>>>transaction.)
> >
> >I don't think that is true -  your still going to need fsync to get
> >the CPU to flush it's caches and filesystem metadata into the
> >persistent domain....
> >
> >>>Hmm.  Presumably that would work by actually allocating cache pages in
> >>>persistent memory.  I don't think that anything like the current XIP
> >>>interfaces can do that, but it's certainly an interesting thought for
> >>>(complicated) future work.
> >>>
> >>>This might not be pretty in conjunction with something like my
> >>>writethrough mapping idea -- read(2) and write(2) would be fine (well,
> >>>write(2) might need to use streaming loads), but mmap users who weren't
> >>>expecting it might have truly awful performance.  That especially
> >>>includes things like databases that aren't expecting this behavior.
> >>
> >>At the moment all I can suggest is a new mmap() flag, e.g.
> >>MAP_PERSISTENT. Not sure how a user or app should discover that it's
> >>supported though.
> >
> >The point of using the XIP interface with filesystems that are
> >backed by persistent memory is that mmap() gives userspace
> >applications direct acess to the persistent memory directly without
> >needing any modifications.  It's just a really, really fast file...
> 
> OK, I see that now. But that only works well when your persistent
> memory size is >= the size of the file(s) you want to work with.

It assumes that you have a persistent memory block device. If you
have a persistent memory block device, then if you want persistent
caching on top of the filesystem, use dm-cache or bcache to stack
the persistent memory on top of the slow block device. i.e. we
already have solutions to this problem.

> If you use persistent memory for the page cache, then you can use it
> with any filesystem of any arbitrary size.

We don't actually need (or, IMO, want) a the page
cache to have to be aware of persistent memory state. If the page
cache is persistent, then we need to store that persistent state
somewhere so that when the machine crashes and reboots, we can bring
the persistent page cache back up. That involves metadata to hold
state, crash recovery, etc. We've already got all that persistence
management in our filesystem implementations.

IOWs, persistent data and it's state belongs in the filesystem
domain, not the page cache domain.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
