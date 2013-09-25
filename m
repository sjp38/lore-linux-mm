Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 22F606B00A9
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 19:29:30 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id lf10so478798pab.17
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 16:29:29 -0700 (PDT)
Date: Thu, 26 Sep 2013 09:29:15 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCHv6 00/22] Transparent huge page cache: phase 1, everything
 but mmap()
Message-ID: <20130925232915.GK26872@dastard>
References: <1379937950-8411-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20130924163740.4bc7db61e3e520798220dc4c@linux-foundation.org>
 <20130925095105.06464E0090@blue.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130925095105.06464E0090@blue.fi.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Ning Qu <quning@google.com>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Sep 25, 2013 at 12:51:04PM +0300, Kirill A. Shutemov wrote:
> Andrew Morton wrote:
> > On Mon, 23 Sep 2013 15:05:28 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> > 
> > > It brings thp support for ramfs, but without mmap() -- it will be posted
> > > separately.
> > 
> > We were never going to do this :(
> > 
> > Has anyone reviewed these patches much yet?
> 
> Dave did very good review. Few other people looked to separate patches.
> See Reviewed-by/Acked-by tags in patches.
> 
> It looks like most mm experts are busy with numa balancing nowadays, so
> it's hard to get more review.

Nobody has reviewed it from the filesystem side, though.

The changes that require special code paths for huge pages in the
write_begin/write_end paths are nasty. You're adding conditional
code that depends on the page size and then having to add checks to
ensure that large page operations don't step over small page
boundaries and other such corner cases. It's an extremely fragile
design, IMO.

In general, I don't like all the if (thp) {} else {}; code that this
series introduces - they are code paths that simply won't get tested
with any sort of regularity and make the code more complex for those
that aren't using THP to understand and debug...

Then there is a new per-inode lock that is used in
generic_perform_write() which is held across page faults and calls
to filesystem block mapping callbacks. This inserts into the middle
of an existing locking chain that needs to be strictly ordered, and
as such will lead to the same type of lock inversion problems that
the mmap_sem had.  We do not want to introduce a new lock that has
this same problem just as we are getting rid of that long standing
nastiness from the page fault path...

I also note that you didn't convert invalidate_inode_pages2_range()
to support huge pages which is needed by real filesystems that
support direct IO. There are other truncate/invalidate interfaces
that you didn't convert, either, and some of them will present you
with interesting locking challenges as a result of adding that new
lock...

> The patchset was mostly ignored for few rounds and Dave suggested to split
> to have less scary patch number.

It's still being ignored by filesystem people because you haven't
actually tried to implement support into a real filesystem.....

> > > Please review and consider applying.
> > 
> > It appears rather too immature at this stage.
> 
> More review is always welcome and I'm committed to address issues.

IMO, supporting a real block based filesystem like ext4 or XFS and
demonstrating that everything works is necessary before we go any
further...

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
