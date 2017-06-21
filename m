Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id CF5F66B02B4
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 21:24:16 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id 82so44740112vki.3
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 18:24:16 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id j91si7157690uad.51.2017.06.20.18.24.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Jun 2017 18:24:15 -0700 (PDT)
Date: Tue, 20 Jun 2017 18:24:03 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [RFC PATCH 2/2] mm, fs: daxfile, an interface for
 byte-addressable updates to pmem
Message-ID: <20170621012403.GB4730@birch.djwong.org>
References: <CALCETrUfv26pvmyQ1gOkKbzfSXK2DnmeBG6VmSWjFy1WBhknTw@mail.gmail.com>
 <CAPcyv4iPb69e+rE3fJUzm9U_P_dLfhantU9mvYmV-R0oQee4rA@mail.gmail.com>
 <CALCETrVY38h2ajpod2U_2pdHSp8zO4mG2p19h=OnnHmhGTairw@mail.gmail.com>
 <20170619132107.GG11993@dastard>
 <CALCETrUe0igzK0RZTSSondkCY3ApYQti89tOh00f0j_APrf_dQ@mail.gmail.com>
 <20170620004653.GI17542@dastard>
 <CALCETrVuoPDRuuhc9X8eVCYiFUzWLSTRkcjbD6jas_2J2GixNQ@mail.gmail.com>
 <20170620084924.GA9752@lst.de>
 <CAPcyv4jkH6iwDoG4NnCaTNXozwYgVXiJDe2iFSONcE63KvGQoA@mail.gmail.com>
 <20170620235346.GK17542@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170620235346.GK17542@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Christoph Hellwig <hch@lst.de>, Andy Lutomirski <luto@kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Rudoff, Andy" <andy.rudoff@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, linux-nvdimm <linux-nvdimm@lists.01.org>, Linux API <linux-api@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, Linux FS Devel <linux-fsdevel@vger.kernel.org>

On Wed, Jun 21, 2017 at 09:53:46AM +1000, Dave Chinner wrote:
> On Tue, Jun 20, 2017 at 09:17:36AM -0700, Dan Williams wrote:
> > On Tue, Jun 20, 2017 at 1:49 AM, Christoph Hellwig <hch@lst.de> wrote:
> > > [stripped giant fullquotes]
> > >
> > > On Mon, Jun 19, 2017 at 10:53:12PM -0700, Andy Lutomirski wrote:
> > >> But that's my whole point.  The kernel doesn't really need to prevent
> > >> all these background maintenance operations -- it just needs to block
> > >> .page_mkwrite until they are synced.  I think that whatever new
> > >> mechanism we add for this should be sticky, but I see no reason why
> > >> the filesystem should have to block reflink on a DAX file entirely.
> > >
> > > Agreed - IFF we want to support write through semantics this is the
> > > only somewhat feasible way.  It still has massive downsides of forcing
> > > the full sync machinery to run from the page fauly handler, which
> > > I'm rather scared off, but that's still better than creating a magic
> > > special case that isn't managable at all.
> > 
> > An immutable-extent DAX-file and a reflink-capable DAX-file are not
> > mutually exclusive,
> 
> Actually, they are mutually exclusive: when the immutable extent DAX
> inode is breaking the extent sharing done during the reflink
> operation, the copy-on-write operation requires allocating and
> freeing extents on the inode that has immutable extents. Which, if
> the inode really has immutable extents, cannot be done.
> 
> That said, if the extent sharing is broken on the other side of the
> reflink (i.e. the non-immutable inode created by the reflink) then
> the extent map of the inode with immutable extents will remain
> unchanged. i.e. there are two sides to this, and if you only see one
> side you might come to the wrong conclusion.
> 
> However, we cannot guarantee that no writes occur to the inode with
> immutable extent maps (especially as the whole point is to allow
> userspace writes and commits without the kernel being involved), so
> extent sharing on immutable extent maps cannot be allowed...

Just to play devil's advocate...

/If/ you have rmap and /if/ you discover that there's only one
IOMAP_IMMUTABLE file owning this same block and /if/ you're willing to
relocate every other mapping on the whole filesystem, /then/ you could
/in theory/ support shared daxfiles.

However, that's so many on-disk metadata lookups to shove into a
pagefault handler that I don't think anyone in XFSland would entertain
such an ugly fantasy.  You'd be making a lot of metadata requests, and
you'd have to lock the rmapbt while grabbing inodes, which is insane.

Much easier to have a per-inode flag that says "the block map of this
file does not change" and put up with the restricted semantics.

--D

> 
> Cheers,
> 
> Dave.
> -- 
> Dave Chinner
> david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
