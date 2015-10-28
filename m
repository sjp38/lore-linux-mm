Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 01B9B82F64
	for <linux-mm@kvack.org>; Wed, 28 Oct 2015 19:23:15 -0400 (EDT)
Received: by wijp11 with SMTP id p11so272395636wij.0
        for <linux-mm@kvack.org>; Wed, 28 Oct 2015 16:23:14 -0700 (PDT)
Received: from mail.anarazel.de (mail.anarazel.de. [217.115.131.40])
        by mx.google.com with ESMTP id bz6si15493567wjb.47.2015.10.28.16.23.13
        for <linux-mm@kvack.org>;
        Wed, 28 Oct 2015 16:23:13 -0700 (PDT)
Date: Thu, 29 Oct 2015 00:23:12 +0100
From: Andres Freund <andres@anarazel.de>
Subject: Re: Triggering non-integrity writeback from userspace
Message-ID: <20151028232312.GL29811@alap3.anarazel.de>
References: <20151022131555.GC4378@alap3.anarazel.de>
 <20151024213912.GE8773@dastard>
 <20151028092752.GF29811@alap3.anarazel.de>
 <20151028204834.GP8773@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151028204834.GP8773@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Hi,

On 2015-10-29 07:48:34 +1100, Dave Chinner wrote:
> > The idea of using SYNC_FILE_RANGE_WRITE beforehand is that
> > the fsync() will only have to do very little work. The language in
> > sync_file_range(2) doesn't inspire enough confidence for using it as an
> > actual integrity operation :/
> 
> So really you're trying to minimise the blocking/latency of fsync()?

The blocking/latency of the fsync doesn't actually matter at all *for
this callsite*. It's called from a dedicated background process - if
it's slowed down by a couple seconds it doesn't matter much.
The problem is that if you have a couple gigabytes of dirty data being
fsync()ed at once, latency for concurrent reads and writes often goes
absolutely apeshit. And those concurrent reads and writes might
actually be latency sensitive.

By calling sync_file_range() over small ranges of pages shortly after
they've been written we make it unlikely (but still possible) that much
data has to be flushed at fsync() time.


Should it interesting: The relevant background process is the
"checkpointer" - it writes back all dirty data from postgres' in-memory
shared buffer cache back to disk, then fyncs all files that have been
touched since the last checkpoint (might have independently been
flushed). After that it then can remove the old write-ahead-log/journal.


> > > You don't want to do writeback from the syscall, right? i.e. you'd
> > > like to expire the inode behind the fd, and schedule background
> > > writeback to run on it immediately?
> > 
> > Yes, that's exactly what we want. Blocking if a process has done too
> > much writes is fine tho.
> 
> OK, so it's really the latency of the fsync() operation that is what
> you are trying to avoid? I've been meaning to get back to a generic
> implementation of an aio fsync operation:
> 
> http://oss.sgi.com/archives/xfs/2014-06/msg00214.html
> 
> Would that be a better approach to solving your need for a
> non-blocking data integrity flush of a file?

So an async fsync() isn't that particularly interesting for the
checkpointer/the issue in this thread. But there's another process in
postgres where I could imagine it being useful. We have a "background"
process that regularly flushes the journal to disk. It currently uses
fdatasync() to do so for subsections of a preallocated/reused file. It
tries to sync the sections that in the near future needs to be flushed
to disk because a transaction commits.

I could imagine that it's good for throughput to issue multiple
asynchronous fsyncs in this background process. Might not be good for
latency sensitive workloads tho.

At the moment using fdatasync() instead of fsync() is a considerable
performance advantage... If I understand the above proposal correctly,
it'd allow specifying ranges, is that right?


There'll be some concern about portability around this - issuing
sync_file_range() every now and then isn't particularly invasive. Using
aio might end up being that, not sure.

Greetings,

Andres Freund

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
