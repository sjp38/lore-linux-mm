Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id 44FB36B004D
	for <linux-mm@kvack.org>; Wed, 26 Feb 2014 18:09:56 -0500 (EST)
Received: by mail-pb0-f51.google.com with SMTP id un15so1655196pbc.38
        for <linux-mm@kvack.org>; Wed, 26 Feb 2014 15:09:55 -0800 (PST)
Received: from mail-pb0-x231.google.com (mail-pb0-x231.google.com [2607:f8b0:400e:c01::231])
        by mx.google.com with ESMTPS id gp2si2419112pac.157.2014.02.26.15.09.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 26 Feb 2014 15:09:55 -0800 (PST)
Received: by mail-pb0-f49.google.com with SMTP id jt11so1646404pbb.22
        for <linux-mm@kvack.org>; Wed, 26 Feb 2014 15:09:53 -0800 (PST)
Date: Wed, 26 Feb 2014 15:08:58 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v5 0/10] fs: Introduce new flag(FALLOC_FL_COLLAPSE_RANGE)
 for fallocate
In-Reply-To: <20140226064224.GU13647@dastard>
Message-ID: <alpine.LSU.2.11.1402261454270.2808@eggly.anvils>
References: <1392741436-19995-1-git-send-email-linkinjeon@gmail.com> <20140224005710.GH4317@dastard> <20140225141601.358f6e3df2660d4af44da876@canb.auug.org.au> <20140225041346.GA29907@dastard> <alpine.LSU.2.11.1402251217030.2380@eggly.anvils>
 <20140226011347.GL13647@dastard> <alpine.LSU.2.11.1402251856060.1114@eggly.anvils> <20140226064224.GU13647@dastard>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Hugh Dickins <hughd@google.com>, Namjae Jeon <linkinjeon@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew@wil.cx>, Theodore Ts'o <tytso@mit.edu>, Stephen Rothwell <sfr@canb.auug.org.au>, viro@zeniv.linux.org.uk, bpm@sgi.com, adilger.kernel@dilger.ca, jack@suse.cz, mtk.manpages@gmail.com, lczerner@redhat.com, linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Namjae Jeon <namjae.jeon@samsung.com>

On Wed, 26 Feb 2014, Dave Chinner wrote:
> On Tue, Feb 25, 2014 at 08:45:15PM -0800, Hugh Dickins wrote:
> > On Wed, 26 Feb 2014, Dave Chinner wrote:
> > > On Tue, Feb 25, 2014 at 03:23:35PM -0800, Hugh Dickins wrote:
> > > 
> > > > I should mention that when "we" implemented this thirty years ago,
> > > > we had a strong conviction that the system call should be idempotent:
> > > > that is, the len argument should indicate the final i_size, not the
> > > > amount being removed from it.  Now, I don't remember the grounds for
> > > > that conviction: maybe it was just an idealistic preference for how
> > > > to design a good system call.  I can certainly see that defining it
> > > > that way round would surprise many app programmers.  Just mentioning
> > > > this in case anyone on these lists sees a practical advantage to
> > > > doing it that way instead.
> > > 
> > > I don't see how specifying the end file size as an improvement. What
> > > happens if you are collapse a range in a file that is still being
> > > appended to by the application and so you race with a file size
> > > update? IOWs, with such an API the range to be collapsed is
> > > completely unpredictable, and IMO that's a fundamentally broken API.
> > 
> > That's fine if you don't see the idempotent API as an improvement,
> > I just wanted to put it on the table in case someone does see an
> > advantage to it.  But I think I'm missing something in your race
> > example: I don't see a difference between the two APIs there.
> 
> 
> Userspace can't sample the inode size via stat(2) and then use the value for a
> syscall atomically. i.e. if you specify the offset you want to
> collapse at, and the file size you want to have to define the region
> to collapse, then the length you need to collapse is (current inode
> size - end file size). If "current inode size" can change between
> the stat(2) and fallocate() call (and it can), then the length being
> collapsed is indeterminate....

Thanks for explaining more, I was just about to acknowledge what a good
example that is.  Indeed, it seems not unreasonable to be editing the
earlier part of a file while the later part of it is still streaming in.

But damn, it now occurs to me that there's still a problem at the
streaming end: its file write offset won't be updated to reflect
the collapse, so there would be a sparse hole at that end.  And
collapse returns -EPERM if IS_APPEND(inode).

Never mind, I'm not campaigning for a change of interface anyway.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
