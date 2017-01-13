Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id E8A056B0038
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 09:22:01 -0500 (EST)
Received: by mail-yb0-f200.google.com with SMTP id j82so47938420ybg.0
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 06:22:01 -0800 (PST)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id h65si3682971yba.281.2017.01.13.06.22.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jan 2017 06:22:01 -0800 (PST)
Date: Fri, 13 Jan 2017 09:21:54 -0500
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [LSF/MM TOPIC] I/O error handling and fsync()
Message-ID: <20170113142154.iycjjhjujqt5u2ab@thunk.org>
References: <20170110160224.GC6179@noname.redhat.com>
 <87k2a2ig2c.fsf@notabene.neil.brown.name>
 <20170113110959.GA4981@noname.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170113110959.GA4981@noname.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kevin Wolf <kwolf@redhat.com>
Cc: NeilBrown <neilb@suse.com>, lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@infradead.org>, Ric Wheeler <rwheeler@redhat.com>, Rik van Riel <riel@redhat.com>

On Fri, Jan 13, 2017 at 12:09:59PM +0100, Kevin Wolf wrote:
> Now even if at the moment there were no storage backend where a write
> failure can be temporary (which I find hard to believe, but who knows),
> a single new driver is enough to expose the problem. Are you confident
> enough that no single driver will ever behave this way to make data
> integrity depend on the assumption?

This is really a philosophical question.  It very much simplifiees
things if we can make the assumption that a driver that *does* behave
this way is **broken**.  If the I/O error is temporary, then the
driver should simply not complete the write, and wait.  If it fails,
it should only be because it has timed out on waiting and has assumed
that the problem is permanent.

Otherwise, every single application is going to have to learn how to
deal with temporary errors, and everything that implies (throwing up
dialog boxes to the user, who may not be able to do anything --- this
is why in the dm-thin case, if you think it should be temporary,
dm-thin should be calling out to a usr space program that pages an
system administrator; why do you think the process or the user who
started the process can do anything about it/)

Now, perhaps there ought to be a way for the application to say, "you
know, if you are going to have to wait more than <timeval>, don't
bother".  This might be interesting from a general sense, even for
working hardware, since there are HDD's with media extensions where
you can tell the disk drive not to bother with the I/O operation if
it's going to take more than XX milliseconds, and if there is a way to
reflect that back to userspace, that can be useful for other
applications, such as video or other soft realtime programs.

But forcing every single application to have to deal with retries in
the case of temporary errors?  That way lies madness, and there's no
way we can get to all of the applications to make them do the right
thing.

> Note that I didn't think of a "keep-data-after-write-error" flag,
> neither per-fd nor per-file, because I assumed that everyone would want
> it as long as there is some hope that the data could still be
> successfully written out later.

But not everyone is going to know to do this.  This is why the retry
really should be done by the device driver, and if it fails, everyone
lives will be much simpler if the failure should be a permanent
failure where there is no hope.

Are there use cases you are concerned about where this model wouldn't
suit?

	       	    	      	      	    - Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
