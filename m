Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id 9A1056B0031
	for <linux-mm@kvack.org>; Thu, 10 Oct 2013 18:50:14 -0400 (EDT)
Received: by mail-pb0-f45.google.com with SMTP id mc17so3274653pbc.18
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 15:50:14 -0700 (PDT)
Message-ID: <52572F1C.8080905@zytor.com>
Date: Thu, 10 Oct 2013 15:50:04 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH] RAID5: Change kmem_cache name string of RAID 4/5/6 stripe
 cache
References: <1379646960-12553-1-git-send-email-jbrassow@redhat.com> <1379646960-12553-2-git-send-email-jbrassow@redhat.com>
In-Reply-To: <1379646960-12553-2-git-send-email-jbrassow@redhat.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Brassow <jbrassow@redhat.com>
Cc: linux-raid@vger.kernel.org, linux-mm@kvack.org, cl@linux.com

On 09/19/2013 08:16 PM, Jonathan Brassow wrote:
> The unique portion of the kmem_cache name used when dm-raid is creating
> a RAID 4/5/6 array is the memory address of it's associated 'mddev'
> structure.  This is not always unique.  The memory associated
> with the 'mddev' structure can be freed and a future 'mddev' structure
> can be allocated from the exact same spot.  This causes an identical
> name to the old cache to be created when kmem_cache_create is called.
> If an old name is still present amoung slab_caches due to cache merging,
> the call will fail.  This is not theoretical, I see this regularly when
> performing device-mapper RAID 4/5/6 tests (although, strangely only on
> Fedora-19).
> 
> Making the unique portion of the kmem_cache name based on jiffies fixes
> this problem.
> 
> Signed-off-by: Jonathan Brassow <jbrassow@redhat.com>
> ---
>  drivers/md/raid5.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/md/raid5.c b/drivers/md/raid5.c
> index 7ff4f25..f731ce9 100644
> --- a/drivers/md/raid5.c
> +++ b/drivers/md/raid5.c
> @@ -1618,7 +1618,7 @@ static int grow_stripes(struct r5conf *conf, int num)
>  			"raid%d-%s", conf->level, mdname(conf->mddev));
>  	else
>  		sprintf(conf->cache_name[0],
> -			"raid%d-%p", conf->level, conf->mddev);
> +			"raid%d-%llu", conf->level, get_jiffies_64());
>  	sprintf(conf->cache_name[1], "%s-alt", conf->cache_name[0]);
>  
>  	conf->active_name = 0;
> 

And it is not possible to create two inside the same jiffy?  Seems
unlikely at best.

Why not just use a simple counter?

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
