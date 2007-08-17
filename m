Date: Fri, 17 Aug 2007 12:10:55 -0400
From: Josef Sipek <jsipek@fsl.cs.sunysb.edu>
Subject: Re: [PATCH 11/23] mm: bdi init hooks
Message-ID: <20070817161055.GE24323@filer.fsl.cs.sunysb.edu>
References: <20070816074525.065850000@chello.nl> <20070816074627.235952000@chello.nl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070816074627.235952000@chello.nl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 16, 2007 at 09:45:36AM +0200, Peter Zijlstra wrote:
> provide BDI constructor/destructor hooks
...
> Index: linux-2.6/drivers/block/rd.c
> ===================================================================
> --- linux-2.6.orig/drivers/block/rd.c
> +++ linux-2.6/drivers/block/rd.c
...
> @@ -419,7 +422,19 @@ static void __exit rd_cleanup(void)
>  static int __init rd_init(void)
>  {
>  	int i;
> -	int err = -ENOMEM;
> +	int err;
> +
> +	err = bdi_init(&rd_backing_dev_info);
> +	if (err)
> +		goto out2;
> +
> +	err = bdi_init(&rd_file_backing_dev_info);
> +	if (err) {
> +		bdi_destroy(&rd_backing_dev_info);
> +		goto out2;

How about this...

if (err)
	goto out3;

> +	}
> +
> +	err = -ENOMEM;
>  
>  	if (rd_blocksize > PAGE_SIZE || rd_blocksize < 512 ||
>  			(rd_blocksize & (rd_blocksize-1))) {
> @@ -473,6 +488,9 @@ out:
>  		put_disk(rd_disks[i]);
>  		blk_cleanup_queue(rd_queue[i]);
>  	}
> +	bdi_destroy(&rd_backing_dev_info);
> +	bdi_destroy(&rd_file_backing_dev_info);

	bdi_destroy(&rd_file_backing_dev_info);
out3:
	bdi_destroy(&rd_backing_dev_info);

Sure you might want to switch from numbered labels to something a bit more
descriptive.

> +out2:
>  	return err;
>  }
>  

Josef 'Jeff' Sipek.

-- 
The box said "Windows XP or better required". So I installed Linux.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
