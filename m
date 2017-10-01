Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0832E6B0033
	for <linux-mm@kvack.org>; Sun,  1 Oct 2017 17:11:53 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id y29so7637244pff.6
        for <linux-mm@kvack.org>; Sun, 01 Oct 2017 14:11:53 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id v1si6735519plb.50.2017.10.01.14.11.50
        for <linux-mm@kvack.org>;
        Sun, 01 Oct 2017 14:11:51 -0700 (PDT)
Date: Mon, 2 Oct 2017 08:11:47 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v2 0/4] dax: require 'struct page' and other fixups
Message-ID: <20171001211147.GE15067@dastard>
References: <150664806143.36094.11882924009668860273.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20171001075701.GB11554@lst.de>
 <CAPcyv4gKYOdDP_jYJvPaozaOBkuVa-cf8x6TGEbEhzNfxaxhGw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4gKYOdDP_jYJvPaozaOBkuVa-cf8x6TGEbEhzNfxaxhGw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Jan Kara <jack@suse.cz>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Sun, Oct 01, 2017 at 10:58:06AM -0700, Dan Williams wrote:
> On Sun, Oct 1, 2017 at 12:57 AM, Christoph Hellwig <hch@lst.de> wrote:
> > While this looks like a really nice cleanup of the code and removes
> > nasty race conditions I'd like to understand the tradeoffs.
> >
> > This now requires every dax device that is used with a file system
> > to have a struct page backing, which means not only means we'd
> > break existing setups, but also a sharp turn from previous policy.
> >
> > Unless I misremember it was you Intel guys that heavily pushed for
> > the page-less version, so I'd like to understand why you've changed
> > your mind.
> 
> Sure, here's a quick recap of the story so far of how we got here:
> 
> * In support of page-less I/O operations envisioned by Matthew I
> introduced pfn_t as a proposal for converting the block layer and
> other sub-systems to use pfns instead of pages [1]. You helped out on
> that patch set with some work on the DMA api. [2]
> 
> * The DMA api conversion effort came to a halt when it came time to
> touch sparc paths and DaveM said [3]: "Generally speaking, I think
> that all actual physical memory the kernel operates on should have a
> struct page backing it."
> 
> * ZONE_DEVICE was created to solve the DMA problem and in developing /
> testing that discovered plenty of proof for Dave's assertion (no fork,
> no ptrace, etc). We should have made the switch to require struct page
> at that point, but I was persuaded by the argument that changing the
> dax policy may break existing assumptions, and that there were larger
> issues to go solve at the time.
> 
> What changed recently was the discussions around what the dax mount
> option means and the assertion that we can, in general, make some
> policy changes on our way to removing the "experimental" designation
> from filesystem-dax. It is clear that the page-less dax path remains
> experimental with all the way it fails in several kernel paths, and
> there has been no patches for several months to revive the effort.
> Meanwhile the page-less path continues to generate maintenance
> overhead. The recent gymnastics (new ->post_mmap file_operation) to
> make sure ->vm_flags are safely manipulated when dynamically changing
> the dax mode of a file was the final straw for me to pull the trigger
> on this series.
> 
> In terms of what breaks by changing this policy it should be noted
> that we automatically create pages for "legacy" pmem devices, and the
> default for "ndctl create-namespace" is to allocate pages. I have yet
> to see a bug report where someone was surprised by fork failing or
> direct-I/O causing a SIGBUS. So, I think the defaults are working, it
> is unlikely that there are environments dependent on page-less
> behavior.

Does this imply that the hardware vendors won't have
tens of terabytes of pmem in systems in the near to medium term?
That's what we were originally told to expect by 2018-19 timeframe
(i.e. 5 years in), and that's kinda what we've been working towards.
Indeed, supporting systems with a couple of orders of magnitude more
pmem than ram was the big driver for page-less DAX mappings in the
first place. i.e. it was needed to avoid the static RAM overhead of
all the static struct pages for such large amounts of physical
memory.

If we decide that we must have struct pages for pmem, then we're
essentially throwing away the ability to support the very systems
the hardware vendors were telling us we needed to design the pmem
infrastructure for.  If that reality has changed, then I'd suggest
that we need to determine what the long term replacement for
pageless IO on large pmem systems will be before we throw what we
have away.

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
