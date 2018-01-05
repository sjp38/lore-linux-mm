Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id C5BED28026C
	for <linux-mm@kvack.org>; Fri,  5 Jan 2018 12:05:37 -0500 (EST)
Received: by mail-ot0-f200.google.com with SMTP id e6so2577809otd.17
        for <linux-mm@kvack.org>; Fri, 05 Jan 2018 09:05:37 -0800 (PST)
Received: from fieldses.org (fieldses.org. [173.255.197.46])
        by mx.google.com with ESMTP id 7si1731342otr.511.2018.01.05.09.05.36
        for <linux-mm@kvack.org>;
        Fri, 05 Jan 2018 09:05:36 -0800 (PST)
Date: Fri, 5 Jan 2018 12:05:06 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: About the try to remove cross-release feature entirely by Ingo
Message-ID: <20180105170506.GB4032@fieldses.org>
References: <20171229014736.GA10341@X58A-UD3R>
 <20171229035146.GA11757@thunk.org>
 <20171229072851.GA12235@X58A-UD3R>
 <20171230061624.GA27959@bombadil.infradead.org>
 <20171230154041.GB3366@thunk.org>
 <20171230204417.GF27959@bombadil.infradead.org>
 <20171230224028.GC3366@thunk.org>
 <20171230230057.GB12995@thunk.org>
 <20180101101855.GA23567@bombadil.infradead.org>
 <20180105164941.GA4032@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180105164941.GA4032@fieldses.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Theodore Ts'o <tytso@mit.edu>, Byungchul Park <byungchul.park@lge.com>, Byungchul Park <max.byungchul.park@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, david@fromorbit.com, Linus Torvalds <torvalds@linux-foundation.org>, Amir Goldstein <amir73il@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, oleg@redhat.com, kernel-team@lge.com, daniel@ffwll.ch

On Fri, Jan 05, 2018 at 11:49:41AM -0500, bfields wrote:
> On Mon, Jan 01, 2018 at 02:18:55AM -0800, Matthew Wilcox wrote:
> > On Sat, Dec 30, 2017 at 06:00:57PM -0500, Theodore Ts'o wrote:
> > > On Sat, Dec 30, 2017 at 05:40:28PM -0500, Theodore Ts'o wrote:
> > > > On Sat, Dec 30, 2017 at 12:44:17PM -0800, Matthew Wilcox wrote:
> > > > > 
> > > > > I'm not sure I agree with this part.  What if we add a new TCP lock class
> > > > > for connections which are used for filesystems/network block devices/...?
> > > > > Yes, it'll be up to each user to set the lockdep classification correctly,
> > > > > but that's a relatively small number of places to add annotations,
> > > > > and I don't see why it wouldn't work.
> > > > 
> > > > I was exagerrating a bit for effect, I admit.  (but only a bit).
> > 
> > I feel like there's been rather too much of that recently.  Can we stick
> > to facts as far as possible, please?
> > 
> > > > It can probably be for all TCP connections that are used by kernel
> > > > code (as opposed to userspace-only TCP connections).  But it would
> > > > probably have to be each and every device-mapper instance, each and
> > > > every block device, each and every mounted file system, each and every
> > > > bdi object, etc.
> > > 
> > > Clarification: all TCP connections that are used by kernel code would
> > > need to be in their own separate lock class.  All TCP connections used
> > > only by userspace could be in their own shared lock class.  You can't
> > > use a one lock class for all kernel-used TCP connections, because of
> > > the Network Block Device mounted on a local file system which is then
> > > exported via NFS and squirted out yet another TCP connection problem.
> > 
> > So the false positive you're concerned about is write-comes-in-over-NFS
> > (with socket lock held), NFS sends a write request to local filesystem,
> 
> I'm confused, what lock does Ted think the NFS server is holding over
> NFS processing?

Sorry, I meant "over RPC processing".

I'll confess to no understanding of socket locking.  The server RPC code
doesn't take any itself except in a couple places on setup and tear
down of a connection.  We wouldn't actually want any exclusive
per-connection lock held across RPC processing because we want to be
able to handle multiple concurrent RPCs per connection.

We do need a little locking just to make sure multiple server threads
replying to the same client don't accidentally corrupt their replies by
interleaving.  But even there we're using our own lock, held only while
transmitting the reply (after all the work's done and reply encoded).

--b.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
