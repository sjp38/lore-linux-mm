Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A6513C072B5
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 13:40:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 54A7B2175B
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 13:40:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="TJ1v3fkn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 54A7B2175B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E3D676B0003; Fri, 24 May 2019 09:40:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DEF266B0005; Fri, 24 May 2019 09:40:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CDD976B0006; Fri, 24 May 2019 09:40:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f71.google.com (mail-vs1-f71.google.com [209.85.217.71])
	by kanga.kvack.org (Postfix) with ESMTP id A88AF6B0003
	for <linux-mm@kvack.org>; Fri, 24 May 2019 09:40:38 -0400 (EDT)
Received: by mail-vs1-f71.google.com with SMTP id y70so2073472vsc.6
        for <linux-mm@kvack.org>; Fri, 24 May 2019 06:40:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:subject:message-id
         :references:mime-version:content-disposition:in-reply-to:user-agent;
        bh=jk1Lvx1FvIw772wUrAuBFbuzjdT4riWG2uGTCncDffw=;
        b=CiDZXi1BXG4GppKSfNjA6h8dA45LrXbVR34Heb+jk1WQGQnCd3ouTHh0hY0UCFs7zk
         LF7i/esCIVWvNHpA4R7dcrZGvkokatBRTzGVzmAr5YtcAXL/Lr6JupLYjv5dT4In0+6K
         7UDlp8tGaBmxOGGjBG0L6lVd9T5hlNI1v2n1Tr89O38/vaLJ1et8jnvzVxFiJ1IbDIgk
         /lWKEfVYUrS4GgZ5q1s1l6EEFgAf1tmNox7ZXu54nhVNU8K3uF2YzE/dyRcEyvV7OV3o
         WNbQjgN97LxmvN9jZ3l/BjkHswOeXt29bajufDT5A4zUqPYF65EQof5ShofNh8Lw50+M
         Gwsw==
X-Gm-Message-State: APjAAAWHWsm3mbqynFlMGkPoXe/b9duJGtqc2nu5ILpZWUMLqN5p90Bc
	X3Sj7cR8GpJzzIXTI23gUxdCeYHQimbv4nGPpzUGhOC5wlj6TxeZanHv7ryJDx5sGdNJrdNsV/U
	ipb7TYhewd7vmTBWzH/BOFP7+VSTphEOuaessr/2cU1IxOriS5MV6fxBMSJ72SRgyCQ==
X-Received: by 2002:a67:ed0b:: with SMTP id l11mr8274617vsp.55.1558705238394;
        Fri, 24 May 2019 06:40:38 -0700 (PDT)
X-Received: by 2002:a67:ed0b:: with SMTP id l11mr8274540vsp.55.1558705237709;
        Fri, 24 May 2019 06:40:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558705237; cv=none;
        d=google.com; s=arc-20160816;
        b=o2oPFkq04KVhsGFHNEncooS9jXBh2/fRxzAF9gLLc7kDAsMyHtrdz1pJgcjEa5nDvf
         VQDJ3M73rL8s6X27Y/Lyb0d4+phOG/x+TPQ9d3dhGk/POAxUc6Wr/d/tZcC4PkJcYQZO
         lMLnJSGLrrFdgeDJnMuW59tVH2C1lc225k1xAlOrli+ZEXONhJh0ZG3Bv9lXziNqhXBP
         WUYphBDHoAmeNMjgCV1R48C9Di57TJ+G++VFmISkegtfSC3beRYiyTXooAvGgfPwYVv/
         rPw9yYYaEH10/jNq9nuGIxUgF5pVRcvXrTRxJRL5BfWxri42n6f7uwZ50FMSWnd2Uvto
         9lDg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:to:from:date:dkim-signature;
        bh=jk1Lvx1FvIw772wUrAuBFbuzjdT4riWG2uGTCncDffw=;
        b=SK1qVJwhcdcuY/9cB3TVVAhAF5H8374wvgRO8iRfZ4vL27bx+YToVk41ttlSyIfXt+
         bZeeu+iHGl4uexdcd39C6UiAot+khn4KSePsVHY8zMOPXTIhyxHdlcP5uEf3JUSNHL9r
         fNlCuqlcKSh+rXnAAm2LeUiWuJusAVeas6fqVgvsv5xrwpAiTuhQlo/+aEJ2vhk8oI/S
         PVzAdOwvm8GfHuJ3J6n9dZRnswiRporkQtWrf0IjM0GhSxLFMkmQYNRWLnIolbr/VRq5
         l3TSBx4QfTfscTJo+BrhBjxiQDH20bY9R9ux5AtAr1vj4rCVVM5tLVswZnH10CAosGUb
         BmTg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=TJ1v3fkn;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g7sor1105931vsa.74.2019.05.24.06.40.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 24 May 2019 06:40:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=TJ1v3fkn;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=jk1Lvx1FvIw772wUrAuBFbuzjdT4riWG2uGTCncDffw=;
        b=TJ1v3fknWXI7eBDTfpR4QuLVeyX1otnSWo1H+q2e4OMUI4FDYhMl+gkN9H1i+7mOhO
         7/aDgJCW3ND4tnYxrEw1oB8b8v0vhLGSWJwGFDhhFwdjtmXO1CjA9vX5aIeYCApUY6Oz
         oNA0Bacu6lV9kocnIprEn4BtBq9N0vh25RDNUa7RUM7LzAI70qLEi+L74kbDWi/ebHHq
         EZOI/Y/fhswKPJt/JjMudE0M0zKse16oB9WUlDb4A6Dy36PRO74rbqLaTf0yGGxwJlz6
         DBqTn1hSDKCT3Hdy3NmSOlACj5Q4uQPtcDwQrpx9MluvudT6JLzTdpifJWxlcS0JwkCT
         ZkOA==
X-Google-Smtp-Source: APXvYqw8mwBk3DO7N2wH6PK1f+AD1sgPGSjHEWIChiWeOIKAMl3omYHQb8VqEw5144BspC8y2H55mg==
X-Received: by 2002:a67:e9cf:: with SMTP id q15mr19361500vso.194.1558705236966;
        Fri, 24 May 2019 06:40:36 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-49-251.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.49.251])
        by smtp.gmail.com with ESMTPSA id 102sm864606uar.11.2019.05.24.06.40.36
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 24 May 2019 06:40:36 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hUAR1-0003QD-Jx; Fri, 24 May 2019 10:40:35 -0300
Date: Fri, 24 May 2019 10:40:35 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>
Subject: Re: [RFC PATCH 05/11] mm/hmm: Improve locking around hmm->dead
Message-ID: <20190524134035.GA12653@ziepe.ca>
References: <20190523153436.19102-1-jgg@ziepe.ca>
 <20190523153436.19102-6-jgg@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190523153436.19102-6-jgg@ziepe.ca>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 23, 2019 at 12:34:30PM -0300, Jason Gunthorpe wrote:
> From: Jason Gunthorpe <jgg@mellanox.com>
> 
> This value is being read without any locking, so it is just an unreliable
> hint, however in many cases we need to have certainty that code is not
> racing with mmput()/hmm_release().
> 
> For the two functions doing find_vma(), document that the caller is
> expected to hold mmap_sem and thus also have a mmget().
> 
> For hmm_range_register acquire a mmget internally as it must not race with
> hmm_release() when it sets valid.
> 
> Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
>  mm/hmm.c | 27 +++++++++++++++++++--------
>  1 file changed, 19 insertions(+), 8 deletions(-)
> 
> diff --git a/mm/hmm.c b/mm/hmm.c
> index ec54be54d81135..d97ec293336ea5 100644
> +++ b/mm/hmm.c
> @@ -909,8 +909,10 @@ int hmm_range_register(struct hmm_range *range,
>  	range->start = start;
>  	range->end = end;
>  
> -	/* Check if hmm_mm_destroy() was call. */
> -	if (mirror->hmm->mm == NULL || mirror->hmm->dead)
> +	/*
> +	 * We cannot set range->value to true if hmm_release has already run.
> +	 */
> +	if (!mmget_not_zero(mirror->hmm->mm))
>  		return -EFAULT;
>  
>  	range->hmm = mirror->hmm;
> @@ -928,6 +930,7 @@ int hmm_range_register(struct hmm_range *range,
>  	if (!range->hmm->notifiers)
>  		range->valid = true;
>  	mutex_unlock(&range->hmm->lock);
> +	mmput(mirror->hmm->mm);

Hi Jerome, when you revised this patch to move the mmput to
hmm_range_unregister() it means hmm_release() cannot run while a range
exists, and thus we can have this futher simplification rolled into
this patch. Can you update your git? Thanks:

diff --git a/mm/hmm.c b/mm/hmm.c
index 2a08b78550b90d..ddd05f2ebe739a 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -128,17 +128,17 @@ static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
 {
 	struct hmm *hmm = container_of(mn, struct hmm, mmu_notifier);
 	struct hmm_mirror *mirror;
-	struct hmm_range *range;
 
 	/* hmm is in progress to free */
 	if (!kref_get_unless_zero(&hmm->kref))
 		return;
 
-	/* Wake-up everyone waiting on any range. */
 	mutex_lock(&hmm->lock);
-	list_for_each_entry(range, &hmm->ranges, list)
-		range->valid = false;
-	wake_up_all(&hmm->wq);
+	/*
+	 * Since hmm_range_register() holds the mmget() lock hmm_release() is
+	 * prevented as long as a range exists.
+	 */
+	WARN_ON(!list_empty(&hmm->ranges));
 	mutex_unlock(&hmm->lock);
 
 	down_write(&hmm->mirrors_sem);
@@ -908,9 +908,7 @@ int hmm_range_register(struct hmm_range *range,
 	range->hmm = mm->hmm;
 	kref_get(&range->hmm->kref);
 
-	/*
-	 * We cannot set range->value to true if hmm_release has already run.
-	 */
+	/* Prevent hmm_release() from running while the range is valid */
 	if (!mmget_not_zero(mm))
 		return -EFAULT;
 

