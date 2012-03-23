Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 7AF426B0044
	for <linux-mm@kvack.org>; Fri, 23 Mar 2012 07:24:28 -0400 (EDT)
Received: by ggeq1 with SMTP id q1so3302233gge.14
        for <linux-mm@kvack.org>; Fri, 23 Mar 2012 04:24:27 -0700 (PDT)
Date: Fri, 23 Mar 2012 04:23:56 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [RFC]swap: don't do discard if no discard option added
In-Reply-To: <20120320215647.f1268b05.akpm@linux-foundation.org>
Message-ID: <alpine.LSU.2.00.1203230401530.31745@eggly.anvils>
References: <4F68795E.9030304@kernel.org> <alpine.LSU.2.00.1203202019140.1842@eggly.anvils> <CANejiEUyPSNQ7q85ZDz-B3iHikHLgZLBNOF-p4evkxjGo5+M0g@mail.gmail.com> <20120320215647.f1268b05.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Shaohua Li <shli@kernel.org>, Holger Kiehl <Holger.Kiehl@dwd.de>, "Martin K. Petersen" <martin.petersen@oracle.com>, Jason Mattax <jmattax@storytotell.org>, linux-mm@kvack.org

On Tue, 20 Mar 2012, Andrew Morton wrote:
> On Wed, 21 Mar 2012 12:31:47 +0800 Shaohua Li <shli@kernel.org> wrote:
> 
> >  But on
> > the other hand, if user doesn't explictly enable discard, why enable
> > it? Like fs, we didn't do runtime discard and only run trim occasionally
> > since discard is slow.
> 
> This.  Neither the swapon manpage nor the SWAP_FLAG_DISCARD comment nor
> .c code comments nor the 339944663 changelog explain why we do a single
> discard at swapon() time

The 339944663 changelog does explain why it's done at swapon(): "While
discard at swapon still shows as slightly beneficial" - surely I don't
need to justify doing something beneficial?

Discard is a way of informing the drive that we're no longer interested
in the old contents: if the drive can make use of it, that's useful
information when adding a swap area - as it is when doing mkfs.

And the 339944663 changelog explains why we're making the running discard
conditional on a flag: "discarding 1MB swap cluster when allocating is
now disadvantageous" - for more detail see changelog below.

> and then never again.

I don't understand what's so wrong with doing something once, at the
time that it is cheap and effective.  Doing it repeatedly turned out
to be costly, as explained in the changelog.

But now we do find that "cheap" inappropriate on the Vertex2.

> 
> It sure *looks* like a bug.

I can certainly see that a longer name than SWAP_FLAG_DISCARD would have
prevented this confusion - perhaps, SWAP_FLAG_DISCARD_CLUSTER_AFTER_USE,
but that is spelt out in the comment at its definition.

> If it isn't then some explanation is sorely needed.

commit 3399446632739fcd05fd8b272b476a69c6e6d14a
Author: Hugh Dickins <hughd@google.com>
Date:   Thu Sep 9 16:38:11 2010 -0700

    swap: discard while swapping only if SWAP_FLAG_DISCARD
    
    Tests with recent firmware on Intel X25-M 80GB and OCZ Vertex 60GB SSDs
    show a shift since I last tested in December: in part because of firmware
    updates, in part because of the necessary move from barriers to awaiting
    completion at the block layer.  While discard at swapon still shows as
    slightly beneficial on both, discarding 1MB swap cluster when allocating
    is now disadvanteous: adds 25% overhead on Intel, adds 230% on OCZ (YMMV).
    
    Surrender: discard as presently implemented is more hindrance than help
    for swap; but might prove useful on other devices, or with improvements.
    So continue to do the discard at swapon, but make discard while swapping
    conditional on a SWAP_FLAG_DISCARD to sys_swapon() (which has been using
    only the lower 16 bits of int flags).
    
    We can add a --discard or -d to swapon(8), and a "discard" to swap in
    /etc/fstab: matching the mount option for btrfs, ext4, fat, gfs2, nilfs2.
    
    Signed-off-by: Hugh Dickins <hughd@google.com>
    Cc: Christoph Hellwig <hch@lst.de>
    Cc: Nigel Cunningham <nigel@tuxonice.net>
    Cc: Tejun Heo <tj@kernel.org>
    Cc: Jens Axboe <jaxboe@fusionio.com>
    Cc: James Bottomley <James.Bottomley@hansenpartnership.com>
    Cc: "Martin K. Petersen" <martin.petersen@oracle.com>
    Cc: <stable@kernel.org>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>

diff --git a/include/linux/swap.h b/include/linux/swap.h
index bf4eb62..7cdd633 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -19,6 +19,7 @@ struct bio;
 #define SWAP_FLAG_PREFER	0x8000	/* set if swap priority specified */
 #define SWAP_FLAG_PRIO_MASK	0x7fff
 #define SWAP_FLAG_PRIO_SHIFT	0
+#define SWAP_FLAG_DISCARD	0x10000 /* discard swap cluster after use */
 
 static inline int current_is_kswapd(void)
 {
@@ -142,7 +143,7 @@ struct swap_extent {
 enum {
 	SWP_USED	= (1 << 0),	/* is slot in swap_info[] used? */
 	SWP_WRITEOK	= (1 << 1),	/* ok to write to this swap?	*/
-	SWP_DISCARDABLE = (1 << 2),	/* blkdev supports discard */
+	SWP_DISCARDABLE = (1 << 2),	/* swapon+blkdev support discard */
 	SWP_DISCARDING	= (1 << 3),	/* now discarding a free cluster */
 	SWP_SOLIDSTATE	= (1 << 4),	/* blkdev seeks are cheap */
 	SWP_CONTINUED	= (1 << 5),	/* swap_map has count continuation */
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 1894dea..7c703ff 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -2047,7 +2047,7 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 			p->flags |= SWP_SOLIDSTATE;
 			p->cluster_next = 1 + (random32() % p->highest_bit);
 		}
-		if (discard_swap(p) == 0)
+		if (discard_swap(p) == 0 && (swap_flags & SWAP_FLAG_DISCARD))
 			p->flags |= SWP_DISCARDABLE;
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
