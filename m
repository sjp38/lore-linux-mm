Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id 49DE26B0036
	for <linux-mm@kvack.org>; Tue, 13 May 2014 18:29:03 -0400 (EDT)
Received: by mail-pb0-f45.google.com with SMTP id um1so805160pbc.32
        for <linux-mm@kvack.org>; Tue, 13 May 2014 15:29:03 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id iu4si8638545pbc.301.2014.05.13.15.29.02
        for <linux-mm@kvack.org>;
        Tue, 13 May 2014 15:29:02 -0700 (PDT)
Date: Tue, 13 May 2014 15:29:00 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 17/19] fs: buffer: Do not use unnecessary atomic
 operations when discarding buffers
Message-Id: <20140513152900.ea0a58cf4a650fb0b4110e3e@linux-foundation.org>
In-Reply-To: <1399974350-11089-18-git-send-email-mgorman@suse.de>
References: <1399974350-11089-1-git-send-email-mgorman@suse.de>
	<1399974350-11089-18-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

On Tue, 13 May 2014 10:45:48 +0100 Mel Gorman <mgorman@suse.de> wrote:

> Discarding buffers uses a bunch of atomic operations when discarding buffers
> because ...... I can't think of a reason. Use a cmpxchg loop to clear all the
> necessary flags. In most (all?) cases this will be a single atomic operations.
> 
> --- a/fs/buffer.c
> +++ b/fs/buffer.c
> @@ -1485,14 +1485,18 @@ EXPORT_SYMBOL(set_bh_page);
>   */
>  static void discard_buffer(struct buffer_head * bh)
>  {
> +	unsigned long b_state, b_state_old;
> +
>  	lock_buffer(bh);
>  	clear_buffer_dirty(bh);
>  	bh->b_bdev = NULL;
> -	clear_buffer_mapped(bh);
> -	clear_buffer_req(bh);
> -	clear_buffer_new(bh);
> -	clear_buffer_delay(bh);
> -	clear_buffer_unwritten(bh);
> +	b_state = bh->b_state;
> +	for (;;) {
> +		b_state_old = cmpxchg(&bh->b_state, b_state, (b_state & ~BUFFER_FLAGS_DISCARD));
> +		if (b_state_old == b_state)
> +			break;
> +		b_state = b_state_old;
> +	}
>  	unlock_buffer(bh);
>  }
>  
> --- a/include/linux/buffer_head.h
> +++ b/include/linux/buffer_head.h
> @@ -77,6 +77,11 @@ struct buffer_head {
>  	atomic_t b_count;		/* users using this buffer_head */
>  };
>  
> +/* Bits that are cleared during an invalidate */
> +#define BUFFER_FLAGS_DISCARD \
> +	(1 << BH_Mapped | 1 << BH_New | 1 << BH_Req | \
> +	 1 << BH_Delay | 1 << BH_Unwritten)
> +

There isn't much point in having this in the header file is there?

--- a/fs/buffer.c~fs-buffer-do-not-use-unnecessary-atomic-operations-when-discarding-buffers-fix
+++ a/fs/buffer.c
@@ -1483,6 +1483,12 @@ EXPORT_SYMBOL(set_bh_page);
 /*
  * Called when truncating a buffer on a page completely.
  */
+
+/* Bits that are cleared during an invalidate */
+#define BUFFER_FLAGS_DISCARD \
+	(1 << BH_Mapped | 1 << BH_New | 1 << BH_Req | \
+	 1 << BH_Delay | 1 << BH_Unwritten)
+
 static void discard_buffer(struct buffer_head * bh)
 {
 	unsigned long b_state, b_state_old;
@@ -1492,7 +1498,8 @@ static void discard_buffer(struct buffer
 	bh->b_bdev = NULL;
 	b_state = bh->b_state;
 	for (;;) {
-		b_state_old = cmpxchg(&bh->b_state, b_state, (b_state & ~BUFFER_FLAGS_DISCARD));
+		b_state_old = cmpxchg(&bh->b_state, b_state,
+				      (b_state & ~BUFFER_FLAGS_DISCARD));
 		if (b_state_old == b_state)
 			break;
 		b_state = b_state_old;
--- a/include/linux/buffer_head.h~fs-buffer-do-not-use-unnecessary-atomic-operations-when-discarding-buffers-fix
+++ a/include/linux/buffer_head.h
@@ -77,11 +77,6 @@ struct buffer_head {
 	atomic_t b_count;		/* users using this buffer_head */
 };
 
-/* Bits that are cleared during an invalidate */
-#define BUFFER_FLAGS_DISCARD \
-	(1 << BH_Mapped | 1 << BH_New | 1 << BH_Req | \
-	 1 << BH_Delay | 1 << BH_Unwritten)
-
 /*
  * macro tricks to expand the set_buffer_foo(), clear_buffer_foo()
  * and buffer_foo() functions.
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
