Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 01E756B0038
	for <linux-mm@kvack.org>; Wed, 17 Aug 2016 12:21:27 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id w128so236697616pfd.3
        for <linux-mm@kvack.org>; Wed, 17 Aug 2016 09:21:26 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id n28si38402821pfa.263.2016.08.17.09.21.26
        for <linux-mm@kvack.org>;
        Wed, 17 Aug 2016 09:21:26 -0700 (PDT)
Date: Wed, 17 Aug 2016 10:21:24 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 0/7] re-enable DAX PMD support
Message-ID: <20160817162124.GA16779@linux.intel.com>
References: <20160815190918.20672-1-ross.zwisler@linux.intel.com>
 <CAPcyv4j_eh8Rcozb40JeiPwvbPoMY2sCt+yTewZ-MZzUkBbj-Q@mail.gmail.com>
 <20160815211106.GA31566@linux.intel.com>
 <CAPcyv4i+XHZSN_3T_vcrv+sOkEMQzuTKRo4WBFcPxN=TzSk9iw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4i+XHZSN_3T_vcrv+sOkEMQzuTKRo4WBFcPxN=TzSk9iw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, linux-ext4 <linux-ext4@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>

On Mon, Aug 15, 2016 at 02:14:14PM -0700, Dan Williams wrote:
> On Mon, Aug 15, 2016 at 2:11 PM, Ross Zwisler
> <ross.zwisler@linux.intel.com> wrote:
> > On Mon, Aug 15, 2016 at 01:21:47PM -0700, Dan Williams wrote:
> >> On Mon, Aug 15, 2016 at 12:09 PM, Ross Zwisler
> >> <ross.zwisler@linux.intel.com> wrote:
> >> > DAX PMDs have been disabled since Jan Kara introduced DAX radix tree based
> >> > locking.  This series allows DAX PMDs to participate in the DAX radix tree
> >> > based locking scheme so that they can be re-enabled.
> >>
> >> Looks good to me.
> >>
> >> > This series restores DAX PMD functionality back to what it was before it
> >> > was disabled.  There is still a known issue between DAX PMDs and hole
> >> > punch, which I am currently working on and which I plan to address with a
> >> > separate series.
> >>
> >> Perhaps we should hold off on applying patch 6 and 7 until after the
> >> hole-punch fix is ready?
> >
> > Sure, I'm cool with holding off on patch 7 (the Kconfig change) until after
> > the hole punch fix is ready.
> >
> > I don't see a reason to hold off on patch 6, though?  It stands on it's own,
> > implements the correct locking, and doesn't break anything.
> 
> Whoops, I just meant 7.

Well, it looks like the hole punch case is much improved since I tested it
last!  :)  I used to be able to generate a few different kernel BUGs when hole
punching DAX PMDs, but those have apparently been fixed in the mm layer since
I was last testing, which admittedly was quite a long time ago (February?).

The only issue I was able to find with DAX PMD hole punching was that ext4
wasn't properly doing a writeback before the hole was unmapped and the radix
tree entries were removed.  This issue applies equally to the 4k case, so I've
submitted a bug fix for v4.8:

https://lists.01.org/pipermail/linux-nvdimm/2016-August/006621.html

With that applied, I don't know of any more issues related to DAX PMDs and
hole punch.  I've tested ext4 and XFS (ext2 doesn't support hole punch), and
they both properly do a writeback of all affected PMDs, fully unmap all
affected PMDs, and remove the radix tree entries.  I've tested that new page
faults for addresses previously covered by the old PMDs generate new page
faults, and 4k pages are now faulted in because the block allocator no longer
has 2MiB contiguous allocations.

One question (probably for Jan): should the above ext4 fix be marked for
stable?

Thanks,
- Ross

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
