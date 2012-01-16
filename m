Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id D6E8A6B005C
	for <linux-mm@kvack.org>; Mon, 16 Jan 2012 06:33:10 -0500 (EST)
Date: Mon, 16 Jan 2012 11:33:04 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 08/11] mm: compaction: Introduce sync-light migration for
 use by compaction
Message-ID: <20120116113304.GB3143@suse.de>
References: <1323877293-15401-1-git-send-email-mgorman@suse.de>
 <1323877293-15401-9-git-send-email-mgorman@suse.de>
 <20120113132540.b2c1b170.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120113132540.b2c1b170.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Dave Jones <davej@redhat.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Nai Xia <nai.xia@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jan 13, 2012 at 01:25:40PM -0800, Andrew Morton wrote:
> On Wed, 14 Dec 2011 15:41:30 +0000
> Mel Gorman <mgorman@suse.de> wrote:
> 
> > This patch adds a lightweight sync migrate operation MIGRATE_SYNC_LIGHT
> > mode that avoids writing back pages to backing storage. Async
> > compaction maps to MIGRATE_ASYNC while sync compaction maps to
> > MIGRATE_SYNC_LIGHT. For other migrate_pages users such as memory
> > hotplug, MIGRATE_SYNC is used.
> > 
> > This avoids sync compaction stalling for an excessive length of time,
> > particularly when copying files to a USB stick where there might be
> > a large number of dirty pages backed by a filesystem that does not
> > support ->writepages.
> >
> > ...
> > 
> > --- a/include/linux/fs.h
> > +++ b/include/linux/fs.h
> > @@ -525,6 +525,7 @@ enum positive_aop_returns {
> >  struct page;
> >  struct address_space;
> >  struct writeback_control;
> > +enum migrate_mode;
> >  
> >  struct iov_iter {
> >  	const struct iovec *iov;
> > @@ -614,7 +615,7 @@ struct address_space_operations {
> >  	 * is false, it must not block.
> >  	 */
> >  	int (*migratepage) (struct address_space *,
> > -			struct page *, struct page *, bool);
> > +			struct page *, struct page *, enum migrate_mode);
> 
> I'm getting a huge warning spew from this with my sparc64 gcc-3.4.5. 
> I'm not sure why, really.
> 

Tetsuo Handa complained about the same thing using gcc 3.3 (added
to cc).

> Forward-declaring an enum in this fashion is problematic because some
> compilers (I'm unsure about gcc) use different sizeofs for enums,
> depending on the enum's value range.  For example, an enum which only
> has values 0...255 can fit into a byte.  (iirc, the compiler actually
> put it in a 16-bit storage).
> 

Ok, I was not aware of this. Thanks for the heads-up.

> So I propose:
> 
> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: mm: fix warnings regarding enum migrate_mode
> 
> sparc64 allmodconfig:
> 
> In file included from include/linux/compat.h:15,
>                  from /usr/src/25/arch/sparc/include/asm/siginfo.h:19,
>                  from include/linux/signal.h:5,
>                  from include/linux/sched.h:73,
>                  from arch/sparc/kernel/asm-offsets.c:13:
> include/linux/fs.h:618: warning: parameter has incomplete type
> 
> It seems that my sparc64 compiler (gcc-3.4.5) doesn't like the forward
> declaration of enums.
> 
> Fix this by moving the "enum migrate_mode" definition into its own header
> file.
> 
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Minchan Kim <minchan.kim@gmail.com>
> Cc: Dave Jones <davej@redhat.com>
> Cc: Jan Kara <jack@suse.cz>
> Cc: Andy Isaacson <adi@hexapodia.org>
> Cc: Nai Xia <nai.xia@gmail.com>
> Cc: Johannes Weiner <jweiner@redhat.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
