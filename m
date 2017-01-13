Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id E018C6B0038
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 11:00:28 -0500 (EST)
Received: by mail-yw0-f199.google.com with SMTP id q71so61056675ywg.1
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 08:00:28 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h6si3759428ybh.172.2017.01.13.08.00.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jan 2017 08:00:26 -0800 (PST)
Date: Fri, 13 Jan 2017 17:00:22 +0100
From: Kevin Wolf <kwolf@redhat.com>
Subject: Re: [LSF/MM TOPIC] I/O error handling and fsync()
Message-ID: <20170113160022.GC4981@noname.redhat.com>
References: <20170110160224.GC6179@noname.redhat.com>
 <87k2a2ig2c.fsf@notabene.neil.brown.name>
 <20170113110959.GA4981@noname.redhat.com>
 <20170113142154.iycjjhjujqt5u2ab@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170113142154.iycjjhjujqt5u2ab@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: NeilBrown <neilb@suse.com>, lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@infradead.org>, Ric Wheeler <rwheeler@redhat.com>, Rik van Riel <riel@redhat.com>

Am 13.01.2017 um 15:21 hat Theodore Ts'o geschrieben:
> On Fri, Jan 13, 2017 at 12:09:59PM +0100, Kevin Wolf wrote:
> > Now even if at the moment there were no storage backend where a write
> > failure can be temporary (which I find hard to believe, but who knows),
> > a single new driver is enough to expose the problem. Are you confident
> > enough that no single driver will ever behave this way to make data
> > integrity depend on the assumption?
> 
> This is really a philosophical question.  It very much simplifiees
> things if we can make the assumption that a driver that *does* behave
> this way is **broken**.  If the I/O error is temporary, then the
> driver should simply not complete the write, and wait.

If we are sure that (at least we make it so that) every error is
permanent, then yes, this simplifies things a bit because it saves you
the retries that we know wouldn't succeed anyway.

In that case, what's possibly left is modifying fsync() so that it
consistently returns an error; or if not, we need to promise this
behaviour to userspace so that on the first fsync() failure it can give
up on the file without doing less for the user than it could do.

> If it fails, it should only be because it has timed out on waiting and
> has assumed that the problem is permanent.

If a manual action is required to restore the functionality, how can you
use a timeout for determining whether a problem is permanent or not?

This is exactly the kind of errors from which we want to recover in
qemu instead of killing the VMs. Assuming that errors are permanent when
they aren't, but just require some action before they can succeed, is
not a solution to the problem, but it's pretty much the description of
the problem that we had before we implemented the retry logic.

So if you say that all errors are permanent, fine; but if some of them
are actually temporary, we're back to square one.

> Otherwise, every single application is going to have to learn how to
> deal with temporary errors, and everything that implies (throwing up
> dialog boxes to the user, who may not be able to do anything

Yes, that's obviously not a realistic option.

> --- this is why in the dm-thin case, if you think it should be
> temporary, dm-thin should be calling out to a usr space program that
> pages an system administrator; why do you think the process or the
> user who started the process can do anything about it/)

In the case of qemu, we can't do anything about it in terms of making
the request work, but we can do something useful with the information:
We limit the damage done, by pausing the VM and preventing it from
seeing a broken hard disk from which it wouldn't recover without a
reboot. So in our case, both the system administrator and the process
want to be informed.

A timeout could serve as a trigger for qemu, but we could possibly do
better for things like the dm-thin case where we know immediately that
we'll have to wait for manual action.

> Now, perhaps there ought to be a way for the application to say, "you
> know, if you are going to have to wait more than <timeval>, don't
> bother".  This might be interesting from a general sense, even for
> working hardware, since there are HDD's with media extensions where
> you can tell the disk drive not to bother with the I/O operation if
> it's going to take more than XX milliseconds, and if there is a way to
> reflect that back to userspace, that can be useful for other
> applications, such as video or other soft realtime programs.
> 
> But forcing every single application to have to deal with retries in
> the case of temporary errors?  That way lies madness, and there's no
> way we can get to all of the applications to make them do the right
> thing.

Agree on both points.

> > Note that I didn't think of a "keep-data-after-write-error" flag,
> > neither per-fd nor per-file, because I assumed that everyone would want
> > it as long as there is some hope that the data could still be
> > successfully written out later.
> 
> But not everyone is going to know to do this.  This is why the retry
> really should be done by the device driver, and if it fails, everyone
> lives will be much simpler if the failure should be a permanent
> failure where there is no hope.
> 
> Are there use cases you are concerned about where this model wouldn't
> suit?

If, and only if, all permanent errors are actually permanent, I think
this works.

Of course, this makes handling hanging requests even more important for
us. We have certain places where we want to get to a clean state with no
pending requests. We could probably use timeouts in userspace, but we
would also want to get the thread doing the syscall unstuck and ideally
be sure that the kernel doesn't still try changing the file behind our
back (maybe the latter part is only thinkable with direct I/O, though).

In other words, we're the only user of a file and we want to cancel
hanging I/O syscalls. I think we once came to the conclusion that this
isn't currently possible, but it's been a while...

Kevin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
