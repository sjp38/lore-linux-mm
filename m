Date: Sat, 21 Apr 2007 02:55:28 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 09/10] mm: expose BDI statistics in sysfs.
Message-Id: <20070421025528.03105b60.akpm@linux-foundation.org>
In-Reply-To: <20070420155503.473053637@chello.nl>
References: <20070420155154.898600123@chello.nl>
	<20070420155503.473053637@chello.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com
List-ID: <linux-mm.kvack.org>

On Fri, 20 Apr 2007 17:52:03 +0200 Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> Expose the per BDI stats in /sys/block/<dev>/queue/*
> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> ---
>  block/ll_rw_blk.c |   32 ++++++++++++++++++++++++++++++++
>  1 file changed, 32 insertions(+)
> 
> Index: linux-2.6-mm/block/ll_rw_blk.c
> ===================================================================
> --- linux-2.6-mm.orig/block/ll_rw_blk.c
> +++ linux-2.6-mm/block/ll_rw_blk.c
> @@ -3976,6 +3976,15 @@ static ssize_t queue_max_hw_sectors_show
>  	return queue_var_show(max_hw_sectors_kb, (page));
>  }
>  
> +static ssize_t queue_nr_reclaimable_show(struct request_queue *q, char *page)
> +{
> +	return sprintf(page, "%lld\n", bdi_stat(&q->backing_dev_info, BDI_RECLAIMABLE));
> +}

We try to present memory statistics to userspace in bytes or kbytes rather
than number-of-pages.  Because page-size varies between architectures and
between .configs.  Displaying number-of-pages is just inviting people to write
it-broke-when-i-moved-it-to-ia64 applications.

Plus kbytes is a bit more user-friendly, particularly when the user will
want to compare these numbers to /proc/meminfo, for example.

Using %llu might be more appropriate than %lld.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
