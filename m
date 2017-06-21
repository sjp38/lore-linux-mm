Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id C440B6B0279
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 22:20:43 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id l68so27568193pfi.11
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 19:20:43 -0700 (PDT)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id p1si12840598pld.128.2017.06.20.19.20.42
        for <linux-mm@kvack.org>;
        Tue, 20 Jun 2017 19:20:42 -0700 (PDT)
Date: Wed, 21 Jun 2017 12:19:03 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC PATCH 2/2] mm, fs: daxfile, an interface for
 byte-addressable updates to pmem
Message-ID: <20170621021903.GM17542@dastard>
References: <CAPcyv4iPb69e+rE3fJUzm9U_P_dLfhantU9mvYmV-R0oQee4rA@mail.gmail.com>
 <CALCETrVY38h2ajpod2U_2pdHSp8zO4mG2p19h=OnnHmhGTairw@mail.gmail.com>
 <20170619132107.GG11993@dastard>
 <CALCETrUe0igzK0RZTSSondkCY3ApYQti89tOh00f0j_APrf_dQ@mail.gmail.com>
 <20170620004653.GI17542@dastard>
 <CALCETrVuoPDRuuhc9X8eVCYiFUzWLSTRkcjbD6jas_2J2GixNQ@mail.gmail.com>
 <20170620084924.GA9752@lst.de>
 <CAPcyv4jkH6iwDoG4NnCaTNXozwYgVXiJDe2iFSONcE63KvGQoA@mail.gmail.com>
 <20170620235346.GK17542@dastard>
 <20170621012403.GB4730@birch.djwong.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170621012403.GB4730@birch.djwong.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Christoph Hellwig <hch@lst.de>, Andy Lutomirski <luto@kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Rudoff, Andy" <andy.rudoff@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, linux-nvdimm <linux-nvdimm@lists.01.org>, Linux API <linux-api@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, Linux FS Devel <linux-fsdevel@vger.kernel.org>

On Tue, Jun 20, 2017 at 06:24:03PM -0700, Darrick J. Wong wrote:
> On Wed, Jun 21, 2017 at 09:53:46AM +1000, Dave Chinner wrote:
> > On Tue, Jun 20, 2017 at 09:17:36AM -0700, Dan Williams wrote:
> > > An immutable-extent DAX-file and a reflink-capable DAX-file are not
> > > mutually exclusive,
> > 
> > Actually, they are mutually exclusive: when the immutable extent DAX
> > inode is breaking the extent sharing done during the reflink
> > operation, the copy-on-write operation requires allocating and
> > freeing extents on the inode that has immutable extents. Which, if
> > the inode really has immutable extents, cannot be done.
> > 
> > That said, if the extent sharing is broken on the other side of the
> > reflink (i.e. the non-immutable inode created by the reflink) then
> > the extent map of the inode with immutable extents will remain
> > unchanged. i.e. there are two sides to this, and if you only see one
> > side you might come to the wrong conclusion.
> > 
> > However, we cannot guarantee that no writes occur to the inode with
> > immutable extent maps (especially as the whole point is to allow
> > userspace writes and commits without the kernel being involved), so
> > extent sharing on immutable extent maps cannot be allowed...
> 
> Just to play devil's advocate...
> 
> /If/ you have rmap and /if/ you discover that there's only one
> IOMAP_IMMUTABLE file owning this same block and /if/ you're willing to
> relocate every other mapping on the whole filesystem, /then/ you could
> /in theory/ support shared daxfiles.

I figured that nobody apart from experienced filesystem developers
would understand the complexities of rmap and refcounts and how they
could be abused to do this. I also assumed that that people like you
would understand this is possible but completely impractical....

> However, that's so many on-disk metadata lookups to shove into a
> pagefault handler that I don't think anyone in XFSland would entertain
> such an ugly fantasy.  You'd be making a lot of metadata requests, and
> you'd have to lock the rmapbt while grabbing inodes, which is insane.

Exactly. But while I understand this, consider the amount of assumed
filesystem and XFS knowledge in that one simple paragraph. Most
non-experts would have stopped *understanding* at "/If/ you have
rmap" and go away with the wrong ideas in their heads. Hence I now
tend to omit mentioning "possible but impractical" things in mixed
expertise discussions....

> Much easier to have a per-inode flag that says "the block map of this
> file does not change" and put up with the restricted semantics.

In a nutshell.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
