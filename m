Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3FE9E6B0033
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 04:47:32 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id r126so13059886wmr.2
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 01:47:32 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h25si3942422wrb.231.2017.01.11.01.47.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 11 Jan 2017 01:47:30 -0800 (PST)
Date: Wed, 11 Jan 2017 10:47:29 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] I/O error handling and fsync()
Message-ID: <20170111094729.GH16116@quack2.suse.cz>
References: <20170110160224.GC6179@noname.redhat.com>
 <20170111050356.ldlx73n66zjdkh6i@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170111050356.ldlx73n66zjdkh6i@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: Kevin Wolf <kwolf@redhat.com>, Rik van Riel <riel@redhat.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, lsf-pc@lists.linux-foundation.org, Ric Wheeler <rwheeler@redhat.com>

On Wed 11-01-17 00:03:56, Ted Tso wrote:
> A couple of thoughts.
> 
> First of all, one of the reasons why this probably hasn't been
> addressed for so long is because programs who really care about issues
> like this tend to use Direct I/O, and don't use the page cache at all.
> And perhaps this is an option open to qemu as well?
> 
> Secondly, one of the reasons why we mark the page clean is because we
> didn't want a failing disk to memory to be trapped with no way of
> releasing the pages.  For example, if a user plugs in a USB
> thumbstick, writes to it, and then rudely yanks it out before all of
> the pages have been writeback, it would be unfortunate if the dirty
> pages can only be released by rebooting the system.
> 
> So an approach that might work is fsync() will keep the pages dirty
> --- but only while the file descriptor is open.  This could either be
> the default behavior, or something that has to be specifically
> requested via fcntl(2).  That way, as soon as the process exits (at
> which point it will be too late for it do anything to save the
> contents of the file) we also release the memory.  And if the process
> gets OOM killed, again, the right thing happens.  But if the process
> wants to take emergency measures to write the file somewhere else, it
> knows that the pages won't get lost until the file gets closed.

Well, as Neil pointed out, the problem is that once the data hits page
cache, we lose the association with a file descriptor. So for example
background writeback or sync(2) can find the dirty data and try to write
it, get EIO, and then you have to do something about it because you don't
know whether fsync(2) is coming or not.

That being said if we'd just keep the pages which failed write out dirty,
the system will eventually block all writers in balance_dirty_pages() and
at that point it is IMO a policy decision (probably per device or per fs)
whether you should just keep things blocked waiting for better times or
whether you just want to start discarding dirty data on a failed write.
Now discarding data that failed to write only when we are close to dirty
limit (or after some timeout or whatever) has a disadvantage that it is
not easy to predict from user POV so I'm not sure if we want to go down
that path. But I can see two options making sense:

1) Just hold onto data and wait indefinitely. Possibly provide a way for
   userspace to forcibly unmount a filesystem in such state.

2) Do what we do now.
 
								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
