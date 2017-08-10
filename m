Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3A70D6B0292
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 17:20:29 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id 83so18674787pgb.14
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 14:20:29 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id o129si4471543pga.543.2017.08.10.14.20.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Aug 2017 14:20:28 -0700 (PDT)
Date: Thu, 10 Aug 2017 14:20:26 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: How can we share page cache pages for reflinked files?
Message-ID: <20170810212026.GJ31390@bombadil.infradead.org>
References: <20170810042849.GK21024@dastard>
 <20170810161159.GI31390@bombadil.infradead.org>
 <20170810191746.GB24674@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170810191746.GB24674@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Dave Chinner <david@fromorbit.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Thu, Aug 10, 2017 at 03:17:46PM -0400, Vivek Goyal wrote:
> On Thu, Aug 10, 2017 at 09:11:59AM -0700, Matthew Wilcox wrote:
> > On Thu, Aug 10, 2017 at 02:28:49PM +1000, Dave Chinner wrote:
> > > If we scale this up to a container host which is using reflink trees
> > > it's shared root images, there might be hundreds of copies of the
> > > same data held in cache (i.e. one page per container). Given that
> > > the filesystem knows that the underlying data extent is shared when
> > > we go to read it, it's relatively easy to add mechanisms to the
> > > filesystem to return the same page for all attempts to read the
> > > from a shared extent from all inodes that share it.
> > 
> > I agree the problem exists.  Should we try to fix this problem, or
> > should we steer people towards solutions which don't have this problem?
> > The solutions I've been seeing use COW block devices instead of COW
> > filesystems, and DAX to share the common pages between the host and
> > each guest.
> 
> Hi Matthew, 
> 
> This is in the context of clear containers? It would be good to have
> a solution for those who are not launching virt guests.
> 
> overlayfs helps mitigate this page cache sharing issue but xfs reflink
> and dm thin pool continue to face this issue.

Right, this is with clear containers.  But there's no reason it couldn't
be used with other virtualisation solutions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
