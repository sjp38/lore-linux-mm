Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 69D676B0035
	for <linux-mm@kvack.org>; Wed, 20 Aug 2014 18:10:28 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id rd3so13113176pab.14
        for <linux-mm@kvack.org>; Wed, 20 Aug 2014 15:10:28 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id ia3si33573380pbb.209.2014.08.20.15.10.27
        for <linux-mm@kvack.org>;
        Wed, 20 Aug 2014 15:10:27 -0700 (PDT)
Message-ID: <1408572624.26863.17.camel@rzwisler-mobl1.amr.corp.intel.com>
Subject: Re: [RFC 4/9] SQUASHME: prd: Fixs to getgeo
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Date: Wed, 20 Aug 2014 16:10:24 -0600
In-Reply-To: <53EB568B.2060006@plexistor.com>
References: <53EB5536.8020702@gmail.com> <53EB568B.2060006@plexistor.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boaz@plexistor.com>
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Matthew Wilcox <willy@linux.intel.com>, Sagi Manole <sagi@plexistor.com>, Yigal Korman <yigal@plexistor.com>

On Wed, 2014-08-13 at 15:14 +0300, Boaz Harrosh wrote:
> From: Boaz Harrosh <boaz@plexistor.com>
> 
> With current values fdisk does the wrong thing.
> 
> Setting all values to 1, will make everything nice and easy.
> 
> Note that current code had a BUG with anything bigger than
> 64G because hd_geometry->cylinders is ushort and it would
> overflow at this value. Any way capacity is not calculated
> through getgeo so it does not matter what you put here.
> 
> Signed-off-by: Boaz Harrosh <boaz@plexistor.com>
> ---
>  drivers/block/prd.c | 16 ++++++++++++----
>  1 file changed, 12 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/block/prd.c b/drivers/block/prd.c
> index cc0aabf..62af81e 100644
> --- a/drivers/block/prd.c
> +++ b/drivers/block/prd.c
> @@ -55,10 +55,18 @@ struct prd_device {
>  
>  static int prd_getgeo(struct block_device *bd, struct hd_geometry *geo)
>  {
> -	/* some standard values */
> -	geo->heads = 1 << 6;
> -	geo->sectors = 1 << 5;
> -	geo->cylinders = get_capacity(bd->bd_disk) >> 11;
> +	/* Just tell fdisk to get out of the way. The math here is so
> +	 * convoluted and does not make any sense at all. With all 1s
> +	 * The math just gets out of the way.
> +	 * NOTE: I was trying to get some values that will make fdisk
> +	 * Want to align first sector on 4K (like 8, 16, 20, ... sectors) but
> +	 * nothing worked, I searched the net the math is not your regular
> +	 * simple multiplication at all. If you managed to get these please
> +	 * fix here. For now we use 4k physical sectors for this
> +	 */
> +	geo->heads = 1;
> +	geo->sectors = 1;
> +	geo->cylinders = 1;
>  	return 0;
>  }

I'm okay with this change, but can you let me know in which case fdisk was
previously doing the wrong thing?  I'm just curious because I never saw it
misbehave, and wonder what else I should be testing.

Regarding the note in the comment, is this addressed by the
blk_queue_physical_block_size() and prd->prd_queue->limits.io_min changes in
your patch 5/9, or is it an open issue?  Either way, can we nix the NOTE?

Also, you put "SQUASHME" on this patch.  I'm planning on squashing all of my
patches together into an "initial version" type patch (see
https://github.com/01org/prd).  Based on this, it probably makes sense to keep
it separate so you get credit for the patch?

- Ross


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
