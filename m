Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id 3236B6B0031
	for <linux-mm@kvack.org>; Tue,  1 Apr 2014 11:58:52 -0400 (EDT)
Received: by mail-pb0-f48.google.com with SMTP id md12so10017617pbc.21
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 08:58:51 -0700 (PDT)
Received: from collaborate-mta1.arm.com (fw-tnat.austin.arm.com. [217.140.110.23])
        by mx.google.com with ESMTP id zt8si11490419pbc.488.2014.04.01.08.58.51
        for <linux-mm@kvack.org>;
        Tue, 01 Apr 2014 08:58:51 -0700 (PDT)
Date: Tue, 1 Apr 2014 16:58:17 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: Recent 3.x kernels: Memory leak causing OOMs
Message-ID: <20140401155815.GF20061@arm.com>
References: <alpine.DEB.2.02.1402161406120.26926@chino.kir.corp.google.com>
 <20140216225000.GO30257@n2100.arm.linux.org.uk>
 <1392670951.24429.10.camel@sakura.staff.proxad.net>
 <20140217210954.GA21483@n2100.arm.linux.org.uk>
 <20140315101952.GT21483@n2100.arm.linux.org.uk>
 <20140317180748.644d30e2@notabene.brown>
 <20140317181813.GA24144@arm.com>
 <20140317193316.GF21483@n2100.arm.linux.org.uk>
 <20140401091959.GA10912@n2100.arm.linux.org.uk>
 <20140401113851.GA15317@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140401113851.GA15317@n2100.arm.linux.org.uk>
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, NeilBrown <neilb@suse.de>, "linux-raid@vger.kernel.org" <linux-raid@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Maxime Bizon <mbizon@freebox.fr>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Tue, Apr 01, 2014 at 12:38:51PM +0100, Russell King - ARM Linux wrote:
> diff --git a/drivers/md/raid1.c b/drivers/md/raid1.c
> index aacf6bf352d8..604bad2fa442 100644
> --- a/drivers/md/raid1.c
> +++ b/drivers/md/raid1.c
> @@ -123,8 +123,14 @@ static void * r1buf_pool_alloc(gfp_t gfp_flags, void *data)
>  		bio = r1_bio->bios[j];
>  		bio->bi_vcnt = RESYNC_PAGES;
>  
> -		if (bio_alloc_pages(bio, gfp_flags))
> -			goto out_free_bio;
> +		if (bio_alloc_pages(bio, gfp_flags)) {
> +			/*
> +			 * Mark this as having no pages - bio_alloc_pages
> +			 * removes any it allocated.
> +			 */
> +			bio->bi_vcnt = 0;
> +			goto out_free_all_bios;
> +		}
>  	}
>  	/* If not user-requests, copy the page pointers to all bios */
>  	if (!test_bit(MD_RECOVERY_REQUESTED, &pi->mddev->recovery)) {
> @@ -138,9 +144,25 @@ static void * r1buf_pool_alloc(gfp_t gfp_flags, void *data)
>  
>  	return r1_bio;
>  
> +out_free_all_bios:
> +	j = -1;
>  out_free_bio:
> -	while (++j < pi->raid_disks)
> -		bio_put(r1_bio->bios[j]);
> +	while (++j < pi->raid_disks) {
> +		bio = r1_bio->bios[j];
> +		if (bio->bi_vcnt) {
> +			struct bio_vec *bv;
> +			int i;
> +			/*
> +			 * Annoyingly, BIO has no way to do this, so we have
> +			 * to do it manually.  Given the trouble here, and
> +			 * the lack of BIO support for cleaning up, I don't
> +			 * care about linux/bio.h's comment about this helper.
> +			 */
> +			bio_for_each_segment_all(bv, bio, i)
> +				__free_page(bv->bv_page);
> +		}

Do you still need the 'if' block here? bio_for_each_segment_all() checks
for bio->bi_vcnt which was set to 0 above.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
