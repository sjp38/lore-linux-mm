Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 570CD6B0070
	for <linux-mm@kvack.org>; Fri, 12 Dec 2014 15:15:14 -0500 (EST)
Received: by mail-pd0-f177.google.com with SMTP id ft15so7730196pdb.22
        for <linux-mm@kvack.org>; Fri, 12 Dec 2014 12:15:14 -0800 (PST)
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com. [209.85.220.51])
        by mx.google.com with ESMTPS id al4si3425055pbc.137.2014.12.12.12.15.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 12 Dec 2014 12:15:12 -0800 (PST)
Received: by mail-pa0-f51.google.com with SMTP id ey11so7829926pad.24
        for <linux-mm@kvack.org>; Fri, 12 Dec 2014 12:15:12 -0800 (PST)
Date: Fri, 12 Dec 2014 12:15:09 -0800
From: Omar Sandoval <osandov@osandov.com>
Subject: Re: [RFC PATCH v3 0/7] btrfs: implement swap file support
Message-ID: <20141212201509.GB20971@mew>
References: <cover.1418173063.git.osandov@osandov.com>
 <20141212103213.GL27601@twin.jikos.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141212103213.GL27601@twin.jikos.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Sterba <dsterba@suse.cz>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, Trond Myklebust <trond.myklebust@primarydata.com>, Christoph Hellwig <hch@infradead.org>, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Dec 12, 2014 at 11:32:13AM +0100, David Sterba wrote:
> On Tue, Dec 09, 2014 at 05:45:41PM -0800, Omar Sandoval wrote:
> > After some discussion on the mailing list, I decided that for simplicity and
> > reliability, it's best to simply disallow COW files and files with shared
> > extents (like files with extents shared with a snapshot). From a user's
> > perspective, this means that a snapshotted subvolume cannot be used for a swap
> > file, but keeping the swap file in a separate subvolume that is never
> > snapshotted seems entirely reasonable to me.
> 
> Well, there are enough special cases how to do things on btrfs and I'd
> like to avoid introducing another one.
> 
> > An alternative suggestion was to
> > allow swap files to be snapshotted and to do an implied COW on swap file
> > activation, which I was ready to implement until I realized that we can't permit
> > snapshotting a subvolume with an active swap file, so this creates a surprising
> > inconsistency for users (in my opinion).
> 
> I still don't see why it's not possible to do the snapshot with an
> active swapfile.
> 
Creating a snapshot of an active swapfile would create shared extents,
so the next time we have to swap out a page, we'd have to do a COW,
which we're already trying pretty hard to avoid. We could allow it, but
it might lead to some unreliable behavior and unhappy emails to the
mailing list. However, I do see your point about wanting to avoid
special cases, so I'd like to get some more input from others on this as
well.

> > As with before, this functionality is tenuously tested in a virtual machine with
> > some artificial workloads, but it "works for me". I'm pretty happy with the
> > results on my end, so please comment away.
> 
> The non-btrfs changes can go independently and do not have to wait until
> we resolve the swap vs snapshot problem.
> 
> I did a simple test and it crashed instantly, lockep complains:
> 
> memory: 2G
> swap file: 1G
> kernel: 3.17 + v3
> 
[snip]

That's my fault for not running with lockdep enabled. The problem here
is that swap-over-NFS is the only caller of nfs_direct_IO, so
nfs_direct_IO doesn't observe the normal direct_IO locking conventions
and neither does swap_writepage. I'll have to shuffle around some code
on the NFS side to fix that.

It looks like the non-btrfs parts of this might get a bit bigger, so
I'll look into getting that in separately.

Thanks!
-- 
Omar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
