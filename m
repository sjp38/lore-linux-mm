Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 0F7795F0001
	for <linux-mm@kvack.org>; Fri, 10 Apr 2009 02:48:23 -0400 (EDT)
Date: Fri, 10 Apr 2009 14:48:45 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH][1/2]page_fault retry with NOPAGE_RETRY
Message-ID: <20090410064845.GA21149@localhost>
References: <604427e00904081302m7b29c538u7781cd8f4dd576f2@mail.gmail.com> <20090409230205.310c68a7.akpm@linux-foundation.org> <604427e00904092332w7e7a3004ne983abc373dd186b@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <604427e00904092332w7e7a3004ne983abc373dd186b@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Ying Han <yinghan@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Mike Waychison <mikew@google.com>, Rohit Seth <rohitseth@google.com>, Hugh Dickins <hugh@veritas.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "H. Peter Anvin" <hpa@zytor.com>, =?utf-8?B?VMO2csO2aw==?= Edwin <edwintorok@gmail.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Fri, Apr 10, 2009 at 02:32:01PM +0800, Ying Han wrote:
> 2009/4/9 Andrew Morton <akpm@linux-foundation.org>:
> >
> >> Subject: [PATCH][1/2]page_fault retry with NOPAGE_RETRY
> >
> > Please give each patch in the series a unique and meaningful title.
> >
> > On Wed, 8 Apr 2009 13:02:35 -0700 Ying Han <yinghan@google.com> wrote:
> >
> >> support for FAULT_FLAG_RETRY with no user change:
> >
> > yup, we'd prefer a complete changelog here please.
> >
> >> Signed-off-by: Ying Han <yinghan@google.com>
> >>              Mike Waychison <mikew@google.com>
> >
> > This form:
> >
> > Signed-off-by: Ying Han <yinghan@google.com>
> > Signed-off-by: Mike Waychison <mikew@google.com>
> 
> Thanks Andrew,  and i need to add Fengguang to Signed-off-by.

Thank you.

> >
> > is conventional.
> >
> >> index 4a853ef..29c2c39 100644
> >> --- a/include/linux/fs.h
> >> +++ b/include/linux/fs.h
> >> @@ -793,7 +793,7 @@ struct file_ra_state {
> >>                                          there are only # of pages ahead */
> >>
> >>       unsigned int ra_pages;          /* Maximum readahead window */
> >> -     int mmap_miss;                  /* Cache miss stat for mmap accesses */
> >> +     unsigned int mmap_miss;         /* Cache miss stat for mmap accesses */
> >
> > This change makes sense, but we're not told the reasons for making it?
> > Did it fix a bug, or is it an unrelated fixlet, or...?
> 
> Fengguang: Could you help making comments on this part? and i will
> make changes elsewhere as Andrew pointed. Thanks

Ah this may deserve a standalone patch:
---
readhead: make mmap_miss an unsigned int

This makes the performance impact of possible mmap_miss wrap around to be
temporary and tolerable: i.e. MMAP_LOTSAMISS=100 extra readarounds.

Otherwise if ever mmap_miss wraps around to negative, it takes INT_MAX
cache misses to bring it back to normal state.  During the time mmap
readaround will be _enabled_ for whatever wild random workload. That's
almost permanent performance impact.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/fs.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- mm.orig/include/linux/fs.h
+++ mm/include/linux/fs.h
@@ -824,7 +824,7 @@ struct file_ra_state {
 					   there are only # of pages ahead */
 
 	unsigned int ra_pages;		/* Maximum readahead window */
-	int mmap_miss;			/* Cache miss stat for mmap accesses */
+	unsigned int mmap_miss;		/* Cache miss stat for mmap accesses */
 	loff_t prev_pos;		/* Cache last read() position */
 };
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
