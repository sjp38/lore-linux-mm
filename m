Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id AE33E6B006C
	for <linux-mm@kvack.org>; Mon,  2 Feb 2015 03:11:20 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id kx10so79316773pab.11
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 00:11:20 -0800 (PST)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id y4si22811062pdl.50.2015.02.02.00.11.18
        for <linux-mm@kvack.org>;
        Mon, 02 Feb 2015 00:11:19 -0800 (PST)
Date: Mon, 2 Feb 2015 19:11:15 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] gfs2: use __vmalloc GFP_NOFS for fs-related allocations.
Message-ID: <20150202081115.GI4251@dastard>
References: <1422849594-15677-1-git-send-email-green@linuxhacker.ru>
 <20150202053708.GG4251@dastard>
 <E68E8257-1CE5-4833-B751-26478C9818C7@linuxhacker.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E68E8257-1CE5-4833-B751-26478C9818C7@linuxhacker.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Drokin <green@linuxhacker.ru>
Cc: Steven Whitehouse <swhiteho@redhat.com>, cluster-devel@redhat.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Mon, Feb 02, 2015 at 01:57:23AM -0500, Oleg Drokin wrote:
> Hello!
> 
> On Feb 2, 2015, at 12:37 AM, Dave Chinner wrote:
> 
> > On Sun, Feb 01, 2015 at 10:59:54PM -0500, green@linuxhacker.ru wrote:
> >> From: Oleg Drokin <green@linuxhacker.ru>
> >> 
> >> leaf_dealloc uses vzalloc as a fallback to kzalloc(GFP_NOFS), so
> >> it clearly does not want any shrinker activity within the fs itself.
> >> convert vzalloc into __vmalloc(GFP_NOFS|__GFP_ZERO) to better achieve
> >> this goal.
> >> 
> >> Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
> >> ---
> >> fs/gfs2/dir.c | 3 ++-
> >> 1 file changed, 2 insertions(+), 1 deletion(-)
> >> 
> >> diff --git a/fs/gfs2/dir.c b/fs/gfs2/dir.c
> >> index c5a34f0..6371192 100644
> >> --- a/fs/gfs2/dir.c
> >> +++ b/fs/gfs2/dir.c
> >> @@ -1896,7 +1896,8 @@ static int leaf_dealloc(struct gfs2_inode *dip, u32 index, u32 len,
> >> 
> >> 	ht = kzalloc(size, GFP_NOFS | __GFP_NOWARN);
> >> 	if (ht == NULL)
> >> -		ht = vzalloc(size);
> >> +		ht = __vmalloc(size, GFP_NOFS | __GFP_NOWARN | __GFP_ZERO,
> >> +			       PAGE_KERNEL);
> > That, in the end, won't help as vmalloc still uses GFP_KERNEL
> > allocations deep down in the PTE allocation code. See the hacks in
> > the DM and XFS code to work around this. i.e. go look for callers of
> > memalloc_noio_save().  It's ugly and grotesque, but we've got no
> > other way to limit reclaim context because the MM devs won't pass
> > the vmalloc gfp context down the stack to the PTE allocations....
> 
> Hm, interesting.
> So all the other code in the kernel that does this sort of thing (and there's quite a bit
> outside of xfs and ocfs2) would not get the desired effect?

No. I expect, however, that very few people would ever see a
deadlock as a result - it's a pretty rare sort of kernel case to hit
in most cases. XFS does make extensive use of vm_map_ram() in
GFP_NOFS context, however, when large directory block sizes are in
use, and we also have a history of lockdep throwing warnings under
memory pressure. In the end, the memalloc_noio_save() changes were
made to stop the frequent lockdep reports rather than actual
deadlocks.

> So, I did some digging in archives and found this thread from 2010 onward with various
> patches and rants.
> Not sure how I missed that before.
> 
> Should we have another run at this I wonder?

By all means, but I don't think you'll have any more luck than
anyone else in the past. We've still got the problem of attitude
("vmalloc is not for general use") and making it actually work is
seen as "encouraging undesirable behaviour". If you can change
attitudes towards vmalloc first, then you'll be much more likely to
make progress in getting these problems solved....

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
