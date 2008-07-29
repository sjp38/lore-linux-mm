From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH] - GRU Driver V3 fixes to resolve code review comments
Date: Tue, 29 Jul 2008 12:02:01 +1000
References: <20080728200559.GA26689@sgi.com>
In-Reply-To: <20080728200559.GA26689@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200807291202.01991.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jack Steiner <steiner@sgi.com>
Cc: akpm@linux-foundation.org, npiggin@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tuesday 29 July 2008 06:05, Jack Steiner wrote:

> Index: linux/drivers/misc/sgi-gru/grutlbpurge.c
> ===================================================================
> --- linux.orig/drivers/misc/sgi-gru/grutlbpurge.c	2008-07-28
> 14:52:26.000000000 -0500 +++
> linux/drivers/misc/sgi-gru/grutlbpurge.c	2008-07-28 14:52:54.000000000
> -0500 @@ -242,7 +242,9 @@ static void gru_invalidate_range_end(str
>  	struct gru_mm_struct *gms = container_of(mn, struct gru_mm_struct,
>  						 ms_notifier);
>
> -	atomic_dec(&gms->ms_range_active);
> +	/* ..._and_test() provides needed barrier */
> +	(void)atomic_dec_and_test(&gms->ms_range_active);
> +
>  	wake_up_all(&gms->ms_wait_queue);

What about

if (atomic_dec_and_test())
    wake_up_all()
?

Also, I would prefer either a comment to say why the increment of
ms_range_active is safe, or an smp_mb__after_atomic_inc() for it too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
