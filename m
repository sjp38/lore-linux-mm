Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 4EA076B0002
	for <linux-mm@kvack.org>; Mon, 22 Apr 2013 20:02:52 -0400 (EDT)
Date: Mon, 22 Apr 2013 20:02:47 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: Excessive stall times on ext4 in 3.9-rc2
Message-ID: <20130423000247.GA17566@thunk.org>
References: <20130410105608.GC1910@suse.de>
 <20130410131245.GC4862@thunk.org>
 <20130411170402.GB11656@suse.de>
 <20130411183512.GA12298@thunk.org>
 <20130411213335.GE9379@quack.suse.cz>
 <20130412025708.GB7445@thunk.org>
 <20130412045042.GA30622@dastard>
 <20130412151952.GA4944@thunk.org>
 <20130422143846.GA2675@suse.de>
 <x49a9oqmblc.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <x49a9oqmblc.fsf@segfault.boston.devel.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, linux-ext4@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>

On Mon, Apr 22, 2013 at 06:42:23PM -0400, Jeff Moyer wrote:
> 
> Jan, if I were to come up with a way of promoting a particular async
> queue to the front of the line, where would I put such a call in the
> ext4/jbd2 code to be effective?

Well, I thought we had discussed trying to bump a pending I/O
automatically when there was an attempt to call lock_buffer() on the
bh?  That would be ideal, because we could keep the async writeback
low priority until someone is trying to wait upon it, at which point
obviously it should no longer be considered an async write call.

Failing that, this is something I've been toying with.... what do you
think?

http://patchwork.ozlabs.org/patch/238192/
http://patchwork.ozlabs.org/patch/238257/

(The first patch in the series just makes sure that allocation bitmap
reads are marked with the META/PRIO flags.  It's not strictly speaking
related to the problem discussed here, but for completeness:
http://patchwork.ozlabs.org/patch/238193/)

						- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
