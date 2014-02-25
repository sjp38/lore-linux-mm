Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 9E64E6B0098
	for <linux-mm@kvack.org>; Tue, 25 Feb 2014 18:41:35 -0500 (EST)
Received: by mail-pd0-f172.google.com with SMTP id p10so129490pdj.17
        for <linux-mm@kvack.org>; Tue, 25 Feb 2014 15:41:35 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id tm9si22010869pab.192.2014.02.25.15.41.34
        for <linux-mm@kvack.org>;
        Tue, 25 Feb 2014 15:41:34 -0800 (PST)
Date: Tue, 25 Feb 2014 15:41:28 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v5 0/10] fs: Introduce new
 flag(FALLOC_FL_COLLAPSE_RANGE) for fallocate
Message-Id: <20140225154128.947a2de83a2d0dc21763ccf9@linux-foundation.org>
In-Reply-To: <alpine.LSU.2.11.1402251217030.2380@eggly.anvils>
References: <1392741436-19995-1-git-send-email-linkinjeon@gmail.com>
	<20140224005710.GH4317@dastard>
	<20140225141601.358f6e3df2660d4af44da876@canb.auug.org.au>
	<20140225041346.GA29907@dastard>
	<alpine.LSU.2.11.1402251217030.2380@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Namjae Jeon <linkinjeon@gmail.com>, Matthew Wilcox <matthew@wil.cx>, Theodore Ts'o <tytso@mit.edu>, Dave Chinner <david@fromorbit.com>, Stephen Rothwell <sfr@canb.auug.org.au>, viro@zeniv.linux.org.uk, bpm@sgi.com, adilger.kernel@dilger.ca, jack@suse.cz, mtk.manpages@gmail.com, lczerner@redhat.com, linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Namjae Jeon <namjae.jeon@samsung.com>

On Tue, 25 Feb 2014 15:23:35 -0800 (PST) Hugh Dickins <hughd@google.com> wrote:

> On Tue, 25 Feb 2014, Dave Chinner wrote:
> > On Tue, Feb 25, 2014 at 02:16:01PM +1100, Stephen Rothwell wrote:
> > > On Mon, 24 Feb 2014 11:57:10 +1100 Dave Chinner <david@fromorbit.com> wrote:
> > > >
> > > > > Namjae Jeon (10):
> > > > >   fs: Add new flag(FALLOC_FL_COLLAPSE_RANGE) for fallocate
> > > > >   xfs: Add support FALLOC_FL_COLLAPSE_RANGE for fallocate
> > > > 
> > > > I've pushed these to the following branch:
> > > > 
> > > > 	git://oss.sgi.com/xfs/xfs.git xfs-collapse-range
> > > > 
> > > > And so they'll be in tomorrow's linux-next tree.
> > > > 
> > > > >   ext4: Add support FALLOC_FL_COLLAPSE_RANGE for fallocate
> > > > 
> > > > I've left this one alone for the ext4 guys to sort out.
> > > 
> > > So presumably that xfs tree branch is now completely stable and so Ted
> > > could just merge that branch into the ext4 tree as well and put the ext4
> > > part on top of that in his tree.
> > 
> > Well, for some definition of stable. Right now it's just a topic
> > branch that is merged into the for-next branch, so in theory it is
> > still just a set of pending changes in a branch in a repo that has
> > been pushed to linux-next for testing.
> > 
> > That said, I don't see that branch changing unless we find bugs in
> > the code or a problem with the API needs fixing, at which point I
> > would add more commits to it and rebase the for-next branch that you
> > are pulling into the linux-next tree.
> > 
> > Realistically, I'm waiting for Lukas to repost his other pending
> > fallocate changes (the zero range changes) so I can pull the VFS and
> > XFS bits of that into the XFS tree and I can test them together
> > before I'll call the xfs-collapse-range stable and ready to be
> > merged into some other tree...
>
> ...
>
> Emphasis on "might": I expect it's impossible, given your current
> approach, but something to be on guard against is unmap_mapping_range()
> failing to find and unmap a pte, because the page is mapped at the
> "wrong" place in the vma, resulting in BUG_ON(page_mapped(page))
> in __delete_from_page_cache().

It should be well tested with non-linear mappings please.  It *should*
be OK, but...

>
> ...
>
> FALLOC_FL_COLLAPSE_RANGE: I'm a little sad at the name COLLAPSE,
> but probably seven months too late to object.  It surprises me that
> you're doing all this work to deflate a part of the file, without
> the obvious complementary work to inflate it - presumably all those
> advertisers whose ads you're cutting out, will come back to us soon
> to ask for inflation, so that they have somewhere to reinsert them ;)

Yes, I was wondering that.  Why not simply "move these blocks from here
to there".


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
