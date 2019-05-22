Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D6C0AC282CE
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 23:36:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4A53D2089E
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 23:36:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="htdxCbNT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4A53D2089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DC3F76B0003; Wed, 22 May 2019 19:36:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D73EF6B0006; Wed, 22 May 2019 19:36:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C634A6B0007; Wed, 22 May 2019 19:36:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id A6B386B0003
	for <linux-mm@kvack.org>; Wed, 22 May 2019 19:36:31 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id 66so3822214qke.20
        for <linux-mm@kvack.org>; Wed, 22 May 2019 16:36:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=+NJHH7AAxaCESoWm3N87HnhYAXOqnHf8DIqecYdr+LY=;
        b=plIu4ath6quZXA83jXOdh2VgbFWAUI0/Vfm9ASRetCcMecN6rORTW/Yg9rn0jDDdEo
         KlwAfqWCgXRFAyEx2eoSFeM8gnywGHOPwtxYUZT2MLWBOpaaN6yv6GxSrDRu2/A1NVBr
         93nESxH8ml0yw/kst4yzpC66Pb7WcTBiRvmi9BPi+d8D/cQA14iJMrTWLvuXJggf9SqE
         QnQCMG81ErjAgS/rl2AqIOecAWEyBzZZj0LsxNIhi4lOZgp1qGO+9ueTztyTpVB4oeMo
         3b3dUFUm4X8EzXF33vIXeKxtE9Hwj9eUMVeHoBJKVGWXTqDwDaFfmfe19K0U0bhxrFIp
         GVdQ==
X-Gm-Message-State: APjAAAXtTyF+Vx85Ab9/2OcgHxXGuHBopZ8c5hB0KGrVTuAHgNmNYqE8
	moXznVbG3GFY5HH0GQ3lFkLGmQBERQicYSGGEuLWUo38UfYf3jhtKuyYyrzThaboNRiRxLRlZiY
	FLPftGaIf1FqoDRjEVQzgrjsV9baVWlS0LwkyfWncvu+cQPWg7Va0MX35+eyl0YMlew==
X-Received: by 2002:ac8:2454:: with SMTP id d20mr64148957qtd.266.1558568191414;
        Wed, 22 May 2019 16:36:31 -0700 (PDT)
X-Received: by 2002:ac8:2454:: with SMTP id d20mr64148842qtd.266.1558568190340;
        Wed, 22 May 2019 16:36:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558568190; cv=none;
        d=google.com; s=arc-20160816;
        b=PWkqkheslk4My54GyyiTcyhF/MHkeRb5F4rzB6IztdOAelfexbDZ3Y6S/egMZlJk22
         KQhjjGT1uaUcjQvg7uujSDMeGBg6jRmOezmxOmb+i12IWoaH0a0Yu9vPZzB7L8Sv44wK
         C972yaFLkMdsPr8UrwAWSYqATODdUUn7LN/PFUr6G2pCdsThCRfif8kLnVxzjK0ukYP3
         CGdoPvnJ3sZq8QGwLzV/QukzSHscqUNijesFFOM6Z2SICiSY3+6rKfOPqrG3gUDWpvhr
         1jRkqE0cT+LN5F3WZogI6/HhkEpj0Jit1tJdmASzmFHN5VO5O7NrMoOFdtoSqRRa/B0C
         +blQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=+NJHH7AAxaCESoWm3N87HnhYAXOqnHf8DIqecYdr+LY=;
        b=wKAa4ogtjalrUiTq5mO2DsBVlAH1LCVb/ACvVdyhwf2EiJ2EcE9vQcYy6ExHjjr/JU
         pb/XG5oUc+O/dmRzT5SKvv5tyXiIJ0TKsdBfkKa0BQgSGJg4qgMXqZPKJBc2dFYWwX3T
         8a2PtOrtgRdGL/5VI3K1EVbFh3NgjByhLmjIme0iFjIIwFHyQrUnlKzs7HkhAr+9w/c0
         dRnqpdAFc8nf48+iBc0Px5Q/XkTjQHmWTa0tYmQvX9unD9JhmB7qD/zRvAXXvj0Vk8EP
         vR7JpPqh0y6yzxxB5Qw9XSzFPCQ+ZQRsnfcnnIunMqR54YCyLgnNB2OjSp/FUjI6reAC
         YESw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=htdxCbNT;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f12sor14295236qkm.1.2019.05.22.16.36.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 May 2019 16:36:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=htdxCbNT;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=+NJHH7AAxaCESoWm3N87HnhYAXOqnHf8DIqecYdr+LY=;
        b=htdxCbNT/oy07kfkDDIccfqzQKf6k1q73DmXAvVV3/iOa/EkF1+dmQ6HwByayAvpvO
         otIdU1WZMVGuw8KeNaoEigiWCb4J0mFJ8xVKqBsc0IzAPufc+qKz6cYURDeIkX2/K2JY
         95+wpElGkMy/PnkfSIT3XipCb+SDJCilWAIAULVsR4BgZwtmEnhzSFx95joC1fZ1BBA6
         6lG1G++UBNcvkia56YJfjXQyOpij8aerPtqQAVmmswLJbBH6BD0O8s2qof3/UCMhZTqF
         2j9TpnQPimj8uOHyS23EWQmvLY6wwtriN2o4UxP1hI0R4l4Pdli0XIrjpctAzp/t1Oj8
         D4Xg==
X-Google-Smtp-Source: APXvYqyD20aSctQ1Ky7L3IexyMg2V3K58g60hVrurjFoUlG0qnm8teaLuvTADcFGeHUoNv8kRCEiHg==
X-Received: by 2002:a37:404b:: with SMTP id n72mr69771301qka.98.1558568189805;
        Wed, 22 May 2019 16:36:29 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-49-251.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.49.251])
        by smtp.gmail.com with ESMTPSA id f35sm14354378qte.71.2019.05.22.16.36.28
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 22 May 2019 16:36:29 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hTama-0006Dd-Fc; Wed, 22 May 2019 20:36:28 -0300
Date: Wed, 22 May 2019 20:36:28 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: rcampbell@nvidia.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>, Ira Weiny <ira.weiny@intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Matthew Wilcox <willy@infradead.org>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 5/5] mm/hmm: Fix mm stale reference use in hmm_free()
Message-ID: <20190522233628.GA16137@ziepe.ca>
References: <20190506233514.12795-1-rcampbell@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190506233514.12795-1-rcampbell@nvidia.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 06, 2019 at 04:35:14PM -0700, rcampbell@nvidia.com wrote:
> From: Ralph Campbell <rcampbell@nvidia.com>
> 
> The last reference to struct hmm may be released long after the mm_struct
> is destroyed because the struct hmm_mirror memory may be part of a
> device driver open file private data pointer. The file descriptor close
> is usually after the mm_struct is destroyed in do_exit(). This is a good
> reason for making struct hmm a kref_t object [1] since its lifetime spans
> the life time of mm_struct and struct hmm_mirror.

> The fix is to not use hmm->mm in hmm_free() and to clear mm->hmm and
> hmm->mm pointers in hmm_destroy() when the mm_struct is
> destroyed.

I think the right way to fix this is to have the struct hmm hold a
mmgrab() on the mm so its memory cannot go away until all of the hmm
users release the struct hmm, hmm_ranges/etc

Then we can properly use mmget_not_zero() instead of the racy/abnormal
'if (hmm->xmm == NULL || hmm->dead)' pattern (see the other
thread). Actually looking at this, all these tests look very
questionable. If we hold the mmget() for the duration of the range
object, as Jerome suggested, then they all get deleted.

That just leaves mmu_notifier_unregister_no_relase() as the remaining
user of hmm->mm (everyone else is trying to do range->mm) - and it
looks like it currently tries to call
mmu_notifier_unregister_no_release on a NULL hmm->mm and crashes :(

Holding the mmgrab fixes this as we can safely call
mmu_notifier_unregister_no_relase() post exit_mmap on a grab'd mm.

Also we can delete the hmm_mm_destroy() intrustion into fork.c as it
can't be called when the mmgrab is active.

This is the basic pattern we used in ODP when working with mmu
notifiers, I don't know why hmm would need to be different.

> index 2aa75dbed04a..4e42c282d334 100644
> +++ b/mm/hmm.c
> @@ -43,8 +43,10 @@ static inline struct hmm *mm_get_hmm(struct mm_struct *mm)
>  {
>  	struct hmm *hmm = READ_ONCE(mm->hmm);
>  
> -	if (hmm && kref_get_unless_zero(&hmm->kref))
> +	if (hmm && !hmm->dead) {
> +		kref_get(&hmm->kref);
>  		return hmm;
> +	}

hmm->dead and mm->hmm are not being read under lock, so this went from
something almost thread safe to something racy :(

> @@ -53,25 +55,28 @@ static inline struct hmm *mm_get_hmm(struct mm_struct *mm)
>   * hmm_get_or_create - register HMM against an mm (HMM internal)
>   *
>   * @mm: mm struct to attach to
> - * Returns: returns an HMM object, either by referencing the existing
> - *          (per-process) object, or by creating a new one.
> + * Return: an HMM object reference, either by referencing the existing
> + *         (per-process) object, or by creating a new one.
>   *
> - * This is not intended to be used directly by device drivers. If mm already
> - * has an HMM struct then it get a reference on it and returns it. Otherwise
> - * it allocates an HMM struct, initializes it, associate it with the mm and
> - * returns it.
> + * If the mm already has an HMM struct then return a new reference to it.
> + * Otherwise, allocate an HMM struct, initialize it, associate it with the mm,
> + * and return a new reference to it. If the return value is not NULL,
> + * the caller is responsible for calling hmm_put().
>   */
>  static struct hmm *hmm_get_or_create(struct mm_struct *mm)
>  {
> -	struct hmm *hmm = mm_get_hmm(mm);
> -	bool cleanup = false;
> +	struct hmm *hmm = mm->hmm;
>  
> -	if (hmm)
> -		return hmm;
> +	if (hmm) {
> +		if (hmm->dead)
> +			goto error;

Create shouldn't fail just because it is racing with something doing
destroy

The flow should be something like:

spin_lock(&mm->page_table_lock); // or write side mmap_sem if you prefer
if (mm->hmm)
   if (kref_get_unless_zero(mm->hmm))
        return mm->hmm;
   mm->hmm = NULL


> +		goto out;
> +	}
>  
>  	hmm = kmalloc(sizeof(*hmm), GFP_KERNEL);
>  	if (!hmm)
> -		return NULL;
> +		goto error;
> +
>  	init_waitqueue_head(&hmm->wq);
>  	INIT_LIST_HEAD(&hmm->mirrors);
>  	init_rwsem(&hmm->mirrors_sem);
> @@ -83,47 +88,32 @@ static struct hmm *hmm_get_or_create(struct mm_struct *mm)
>  	hmm->dead = false;
>  	hmm->mm = mm;
>  
> -	spin_lock(&mm->page_table_lock);
> -	if (!mm->hmm)
> -		mm->hmm = hmm;
> -	else
> -		cleanup = true;
> -	spin_unlock(&mm->page_table_lock);

BTW, Jerome this needs fixing too, it shouldn't fail the function just
because it lost the race.

More like

spin_lock(&mm->page_table_lock);
if (mm->hmm)
   if (kref_get_unless_zero(mm->hmm)) {
        kfree(hmm);
        return mm->hmm;
   }
mm->hmm = hmm

> -	if (cleanup)
> -		goto error;
> -
>  	/*
> -	 * We should only get here if hold the mmap_sem in write mode ie on
> -	 * registration of first mirror through hmm_mirror_register()
> +	 * The mmap_sem should be held for write so no additional locking

Please let us have proper lockdep assertions for this kind of stuff.

> +	 * is needed. Note that struct_mm holds a reference to hmm.
> +	 * It is cleared in hmm_release().
>  	 */
> +	mm->hmm = hmm;

Actually using the write side the mmap_sem seems sort of same if it is
assured the write side is always held for this call..


Hmm, there is a race with hmm_destroy touching mm->hmm that does
hold the write lock.

> +
>  	hmm->mmu_notifier.ops = &hmm_mmu_notifier_ops;
>  	if (__mmu_notifier_register(&hmm->mmu_notifier, mm))
>  		goto error_mm;

And the error unwind here is problematic as it should do
kref_put. Actually after my patch to use container_of this
mmu_notifier_register should go before the mm->hmm = hmm to avoid
having to do the sketchy error unwind at all.

> +out:
> +	/* Return a separate hmm reference for the caller. */
> +	kref_get(&hmm->kref);
>  	return hmm;
>  
>  error_mm:
> -	spin_lock(&mm->page_table_lock);
> -	if (mm->hmm == hmm)
> -		mm->hmm = NULL;
> -	spin_unlock(&mm->page_table_lock);
> -error:
> +	mm->hmm = NULL;
>  	kfree(hmm);
> +error:
>  	return NULL;
>  }
>  
>  static void hmm_free(struct kref *kref)
>  {
>  	struct hmm *hmm = container_of(kref, struct hmm, kref);
> -	struct mm_struct *mm = hmm->mm;
> -
> -	mmu_notifier_unregister_no_release(&hmm->mmu_notifier, mm);

Where did the unregister go?

> -
> -	spin_lock(&mm->page_table_lock);
> -	if (mm->hmm == hmm)
> -		mm->hmm = NULL;
> -	spin_unlock(&mm->page_table_lock);

Well, we still need to NULL mm->hmm if the hmm was put before the mm
is destroyed.

>  	kfree(hmm);
>  }
> @@ -135,25 +125,18 @@ static inline void hmm_put(struct hmm *hmm)
>  
>  void hmm_mm_destroy(struct mm_struct *mm)
>  {
> -	struct hmm *hmm;
> +	struct hmm *hmm = mm->hmm;
>  
> -	spin_lock(&mm->page_table_lock);
> -	hmm = mm_get_hmm(mm);
> -	mm->hmm = NULL;
>  	if (hmm) {
> +		mm->hmm = NULL;

At this point The kref on mm is 0, so any other thread reading mm->hmm
has a use-after-free bug. Not much point in doing this assignment , it
is just confusing.

>  		hmm->mm = NULL;
> -		hmm->dead = true;
> -		spin_unlock(&mm->page_table_lock);
>  		hmm_put(hmm);
> -		return;
>  	}
> -
> -	spin_unlock(&mm->page_table_lock);
>  }
>  
>  static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
>  {
> -	struct hmm *hmm = mm_get_hmm(mm);
> +	struct hmm *hmm = mm->hmm;

container_of is much safer/better

> @@ -931,20 +909,14 @@ int hmm_range_register(struct hmm_range *range,
>  		return -EINVAL;
>  	if (start >= end)
>  		return -EINVAL;
> +	hmm = mm_get_hmm(mm);
> +	if (!hmm)
> +		return -EFAULT;
>  
>  	range->page_shift = page_shift;
>  	range->start = start;
>  	range->end = end;
> -
> -	range->hmm = mm_get_hmm(mm);
> -	if (!range->hmm)
> -		return -EFAULT;
> -
> -	/* Check if hmm_mm_destroy() was call. */
> -	if (range->hmm->mm == NULL || range->hmm->dead) {

This comment looks bogus too, we can't race with hmm_mm_destroy as the
caller MUST have a mmgrab or mmget on the mm already to call this API
- ie can't be destroyed. 

As discussed in the other thread this should probably be
mmget_not_zero.

Jason

