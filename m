Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id 550FB6B0031
	for <linux-mm@kvack.org>; Wed, 26 Feb 2014 20:31:35 -0500 (EST)
Received: by mail-pb0-f46.google.com with SMTP id rq2so728247pbb.33
        for <linux-mm@kvack.org>; Wed, 26 Feb 2014 17:31:35 -0800 (PST)
Received: from mail-pb0-x22a.google.com (mail-pb0-x22a.google.com [2607:f8b0:400e:c01::22a])
        by mx.google.com with ESMTPS id wl10si2658201pab.259.2014.02.26.17.31.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 26 Feb 2014 17:31:34 -0800 (PST)
Received: by mail-pb0-f42.google.com with SMTP id rr13so1791906pbb.15
        for <linux-mm@kvack.org>; Wed, 26 Feb 2014 17:31:34 -0800 (PST)
Date: Wed, 26 Feb 2014 17:30:35 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v5 0/10] fs: Introduce new flag(FALLOC_FL_COLLAPSE_RANGE)
 for fallocate
In-Reply-To: <20140227012431.GW13647@dastard>
Message-ID: <alpine.LSU.2.11.1402261729020.29071@eggly.anvils>
References: <1392741436-19995-1-git-send-email-linkinjeon@gmail.com> <20140224005710.GH4317@dastard> <20140225141601.358f6e3df2660d4af44da876@canb.auug.org.au> <20140225041346.GA29907@dastard> <alpine.LSU.2.11.1402251217030.2380@eggly.anvils>
 <20140226011347.GL13647@dastard> <alpine.LSU.2.11.1402251856060.1114@eggly.anvils> <20140226064224.GU13647@dastard> <alpine.LSU.2.11.1402261454270.2808@eggly.anvils> <20140227012431.GW13647@dastard>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Hugh Dickins <hughd@google.com>, Namjae Jeon <linkinjeon@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew@wil.cx>, Theodore Ts'o <tytso@mit.edu>, Stephen Rothwell <sfr@canb.auug.org.au>, viro@zeniv.linux.org.uk, bpm@sgi.com, adilger.kernel@dilger.ca, jack@suse.cz, mtk.manpages@gmail.com, lczerner@redhat.com, linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Namjae Jeon <namjae.jeon@samsung.com>

On Thu, 27 Feb 2014, Dave Chinner wrote:
> On Wed, Feb 26, 2014 at 03:08:58PM -0800, Hugh Dickins wrote:
> > 
> > Thanks for explaining more, I was just about to acknowledge what a good
> > example that is.  Indeed, it seems not unreasonable to be editing the
> > earlier part of a file while the later part of it is still streaming in.
> > 
> > But damn, it now occurs to me that there's still a problem at the
> > streaming end: its file write offset won't be updated to reflect
> > the collapse, so there would be a sparse hole at that end.  And
> > collapse returns -EPERM if IS_APPEND(inode).
> 
> Well, we figure that most applications won't be using append only
> inode flags for files that they know they want to edit at random
> offsets later on. ;)
> 
> However, I can see how DVR apps would use open(O_APPEND) to obtain
> the fd they write to because that sets the write position to the EOF
> on every write() call (i.e. in generic_write_checks()). And collapse
> range should behave sanely with this sort of usage.
> 
> e.g. XFS calls generic_write_checks() after it has taken the IO lock
> to set the current write position to EOF. Hence it will be correctly
> serialised against collapse range calls and so O_APPEND writes will
> not leave sparse holes if collapse range calls are interleaved with
> the write stream....

Right, I was getting confused between O_APPEND and APPEND_Only!
Thanks, I'm back to being convinced by your example.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
