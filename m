Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 099E56B02A5
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 12:03:26 -0400 (EDT)
Date: Fri, 6 Aug 2010 00:01:24 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 6/6] writeback: merge for_kupdate and !for_kupdate cases
Message-ID: <20100805160124.GA17939@localhost>
References: <20100711020656.340075560@intel.com>
 <20100711021749.303817848@intel.com>
 <20100712020842.GC25335@dastard>
 <20100712155239.GC30222@localhost>
 <20100712152254.2071ba5f.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100712152254.2071ba5f.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Martin Bligh <mbligh@google.com>, Michael Rubin <mrubin@google.com>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jul 13, 2010 at 06:22:54AM +0800, Andrew Morton wrote:
> On Mon, 12 Jul 2010 23:52:39 +0800
> Wu Fengguang <fengguang.wu@intel.com> wrote:
> 
> > > Also, I'd prefer that the
> > > comments remain somewhat more descriptive of the circumstances that
> > > we are operating under. Comments like "retry later to avoid blocking
> > > writeback of other inodes" is far, far better than "retry later"
> > > because it has "why" component that explains the reason for the
> > > logic. You may remember why, but I sure won't in a few months time....
> 
> me2 (of course).  This code is waaaay too complex to be scrimping on comments.
> 
> > Ah yes the comment is too simple. However the redirty_tail() is not to
> > avoid blocking writeback of other inodes, but to avoid eating 100% CPU
> > on busy retrying a dirty inode/page that cannot perform writeback for
> > a while. (In theory redirty_tail() can still busy retry though, when
> > there is only one single dirty inode.) So how about
> > 
> >         /*
> >          * somehow blocked: avoid busy retrying
> >          */
> 
> That's much too short.  Expand on the "somehow" - provide an example,
> describe the common/expected cause.  Fully explain what the "busy"
> retry _is_ and how it can come about.

It was a long story.. This redirty_tail() was introduced when more_io
is introduced. The initial patch for more_io does not have the
redirty_tail(), and when it's merged, several 100% iowait bug reports
arises:

reiserfs:
        http://lkml.org/lkml/2007/10/23/93

jfs:
        commit 29a424f28390752a4ca2349633aaacc6be494db5
        JFS: clear PAGECACHE_TAG_DIRTY for no-write pages

ext2:
        http://www.spinics.net/linux/lists/linux-ext4/msg04762.html

They are all old bugs hidden in various filesystems that become
"obvious" with the more_io patch. At the time, the ext2 bug is thought
to be "trivial", so you didn't merge that fix. Instead the following
patch with redirty_tail() is merged:

http://www.spinics.net/linux/lists/linux-ext4/msg04507.html

This will in general prevent 100% on ext2 and other possibly unknown FS bugs.

I'll take David's comments and note the above in changelog.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
