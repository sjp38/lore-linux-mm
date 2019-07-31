Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3FAC7C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 12:39:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C8530206B8
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 12:39:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="QYLt5oLx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C8530206B8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4A48C8E0003; Wed, 31 Jul 2019 08:39:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 454E48E0001; Wed, 31 Jul 2019 08:39:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 31C768E0003; Wed, 31 Jul 2019 08:39:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 100878E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:39:39 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id m25so61229576qtn.18
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 05:39:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=ntHuD78E1C49ZvRvAJ6XgDuP1G4iMkkai3jqPaZStVQ=;
        b=qjFZLgRATqKXxtBkJ/hFQuQXqhervtd603A7cdPhrMc/9yhGldGQ1xfyU6t1yO+GXt
         iNeH+lZ0kf3mqHxDjr6NDi+Qb/I/SEYq8+Sj+WDty57yKPQwzHzE4wcMLC6/1QzxdSyd
         Vd16IvxzOlVEbcpPgSYnH7fqAKVIy4RXOLKh0fpRQWvLO3jIFtGCjCA9duCPPpfDtord
         QvuOmjQhtp+rav6eT2JGElfJcAeAocPENYSlVv365qM7avuZ1Rwt/JBFdFHpFQtLLSpX
         gpsYuYWpq3v4A7Eu/jYgGnM5gjPEtSQRmbDTm6zUnFSD5CeTSemlH8rwYaR/SV/vu401
         phzg==
X-Gm-Message-State: APjAAAX+ENWwKS050oy99QyE0jUkP41tht6QItJcR2g6NssLJ0TGUfXn
	UKb0gNLIwOHaEm81fiDsjChJ9F5pNIdl5nlct7RbuAubCwHCYtgA9y2AKrU9Af3/C2F45oObndr
	6rR1sDShCKm38p4u4QrcTR1jqdAk4tuxeSSyP4UUSS5sgONgWWFhyzA2r55+ZfpamBQ==
X-Received: by 2002:aed:23ef:: with SMTP id k44mr82675638qtc.202.1564576778795;
        Wed, 31 Jul 2019 05:39:38 -0700 (PDT)
X-Received: by 2002:aed:23ef:: with SMTP id k44mr82675578qtc.202.1564576777818;
        Wed, 31 Jul 2019 05:39:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564576777; cv=none;
        d=google.com; s=arc-20160816;
        b=ocB49Jtpgy7JeL44Uf40E+1xWqZmQHvmwcb0k5ZOXQV7Zie9vHlmMFaD+zxxO0FedZ
         ptD7Df7x9BanJZoSWBuW18Sx2Vfn836MVSN9h5fxDL2sh8LqryAL2vUXOpUTpvWFSJgp
         V52FkLxwxOtNm3C+KsBb64L6PPQSVB60/8RmduabKQHgajZUeFTIK/RHUJlrn002Pa+L
         dQJdE4JKoWVAkptv4bac5pXbOxltNrhW//zFFzZTHxDhV76N3jslpZ/45p2VvFlKrxYp
         kVQIyXtdoUXn3WhWNqgr0cq4VoLFvTZiNZ6Y0VBvm8n8eTSSvJZebfLijWIo+jhKrbip
         0FiA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=ntHuD78E1C49ZvRvAJ6XgDuP1G4iMkkai3jqPaZStVQ=;
        b=GzvqgLla7xmYzw3zsBU7EP0iCb7C7+9x6f0NAm4r5a27X8ew3v6JjtZ5OJKmu9iC31
         4S4gV6/3p/Cl1J/TAzeX4tyKYaCiHRiIMglO8Z3x1NIzLeDTYeXwFQnJbBFeZEv2L2YK
         WtPIeSZS0vTRYYQRX2tzgrBq4kyyuN4uSXaqJMb0A+YRrDdJceCQjOy6Jf3fvfGalIia
         4iO/oTL6yZER1jOmBp7uRnZMtZt7u8DhOQHYkE+aaxiynRK2apsUlLVbt5dHPS++23NG
         EGU7ULlpbsVjbmjeS3LC8RigMjLjpq/UvkbC3LBaC8zehssx6Rlxs7MZgL+TayDFG/xd
         m97Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=QYLt5oLx;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w8sor37309118qkf.56.2019.07.31.05.39.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 05:39:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=QYLt5oLx;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=ntHuD78E1C49ZvRvAJ6XgDuP1G4iMkkai3jqPaZStVQ=;
        b=QYLt5oLxRfkO8iVQlcM8CFDLc+4aB1oq1G5gPzD6FWEByB19Sd3Eq075eKqH5NmW7r
         yXUDMxL5fze2A5G71ENrhWbScZuetvwRZCvr7X56doCnXI9uRYUnRWTYeIM3gRLiUeyi
         /eh7SRWLFZtd2zOIxcaSfePSYA3z8PqF8WyX2YtQr70udr1hR6V+9yQyJWWOm0FhCYn3
         RrLimA3hfR0j6oFPuGpOrXLDhZfmxhVa2mCfh5ZGJrV7tIaubv2+pcRGOH8HyUhlMu/X
         gRA+wBoXedUidty3leb/SYk1yPOT9L3tkNi4HVKQb4piuEQsqs8j7Li0axrda17mfn/2
         BcXA==
X-Google-Smtp-Source: APXvYqx/s09x34m2m60hGEG8oq9rNNiSt1/4j5qtIhV1B9Qgz5W3aPna7RR3oLU+V41Ml5DJ6UJ2Ng==
X-Received: by 2002:a05:620a:1648:: with SMTP id c8mr79693913qko.106.1564576777216;
        Wed, 31 Jul 2019 05:39:37 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id m12sm27127419qkk.123.2019.07.31.05.39.36
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 31 Jul 2019 05:39:36 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hsntH-0006OW-WA; Wed, 31 Jul 2019 09:39:36 -0300
Date: Wed, 31 Jul 2019 09:39:35 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Jason Wang <jasowang@redhat.com>
Cc: mst@redhat.com, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH V2 7/9] vhost: do not use RCU to synchronize MMU notifier
 with worker
Message-ID: <20190731123935.GC3946@ziepe.ca>
References: <20190731084655.7024-1-jasowang@redhat.com>
 <20190731084655.7024-8-jasowang@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190731084655.7024-8-jasowang@redhat.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 31, 2019 at 04:46:53AM -0400, Jason Wang wrote:
> We used to use RCU to synchronize MMU notifier with worker. This leads
> calling synchronize_rcu() in invalidate_range_start(). But on a busy
> system, there would be many factors that may slow down the
> synchronize_rcu() which makes it unsuitable to be called in MMU
> notifier.
> 
> A solution is SRCU but its overhead is obvious with the expensive full
> memory barrier. Another choice is to use seqlock, but it doesn't
> provide a synchronization method between readers and writers. The last
> choice is to use vq mutex, but it need to deal with the worst case
> that MMU notifier must be blocked and wait for the finish of swap in.
> 
> So this patch switches use a counter to track whether or not the map
> was used. The counter was increased when vq try to start or finish
> uses the map. This means, when it was even, we're sure there's no
> readers and MMU notifier is synchronized. When it was odd, it means
> there's a reader we need to wait it to be even again then we are
> synchronized. 

You just described a seqlock.

We've been talking about providing this as some core service from mmu
notifiers because nearly every use of this API needs it.

IMHO this gets the whole thing backwards, the common pattern is to
protect the 'shadow pte' data with a seqlock (usually open coded),
such that the mmu notififer side has the write side of that lock and
the read side is consumed by the thread accessing or updating the SPTE.


> Reported-by: Michael S. Tsirkin <mst@redhat.com>
> Fixes: 7f466032dc9e ("vhost: access vq metadata through kernel virtual address")
> Signed-off-by: Jason Wang <jasowang@redhat.com>
>  drivers/vhost/vhost.c | 145 ++++++++++++++++++++++++++----------------
>  drivers/vhost/vhost.h |   7 +-
>  2 files changed, 94 insertions(+), 58 deletions(-)
> 
> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> index cfc11f9ed9c9..db2c81cb1e90 100644
> +++ b/drivers/vhost/vhost.c
> @@ -324,17 +324,16 @@ static void vhost_uninit_vq_maps(struct vhost_virtqueue *vq)
>  
>  	spin_lock(&vq->mmu_lock);
>  	for (i = 0; i < VHOST_NUM_ADDRS; i++) {
> -		map[i] = rcu_dereference_protected(vq->maps[i],
> -				  lockdep_is_held(&vq->mmu_lock));
> +		map[i] = vq->maps[i];
>  		if (map[i]) {
>  			vhost_set_map_dirty(vq, map[i], i);
> -			rcu_assign_pointer(vq->maps[i], NULL);
> +			vq->maps[i] = NULL;
>  		}
>  	}
>  	spin_unlock(&vq->mmu_lock);
>  
> -	/* No need for synchronize_rcu() or kfree_rcu() since we are
> -	 * serialized with memory accessors (e.g vq mutex held).
> +	/* No need for synchronization since we are serialized with
> +	 * memory accessors (e.g vq mutex held).
>  	 */
>  
>  	for (i = 0; i < VHOST_NUM_ADDRS; i++)
> @@ -362,6 +361,44 @@ static bool vhost_map_range_overlap(struct vhost_uaddr *uaddr,
>  	return !(end < uaddr->uaddr || start > uaddr->uaddr - 1 + uaddr->size);
>  }
>  
> +static void inline vhost_vq_access_map_begin(struct vhost_virtqueue *vq)
> +{
> +	int ref = READ_ONCE(vq->ref);

Is a lock/single threaded supposed to be held for this?

> +
> +	smp_store_release(&vq->ref, ref + 1);
> +	/* Make sure ref counter is visible before accessing the map */
> +	smp_load_acquire(&vq->ref);

release/acquire semantics are intended to protect blocks of related
data, so reading something with acquire and throwing away the result
is nonsense.

> +}
> +
> +static void inline vhost_vq_access_map_end(struct vhost_virtqueue *vq)
> +{
> +	int ref = READ_ONCE(vq->ref);

If the write to vq->ref is not locked this algorithm won't work, if it
is locked the READ_ONCE is not needed.

> +	/* Make sure vq access is done before increasing ref counter */
> +	smp_store_release(&vq->ref, ref + 1);
> +}
> +
> +static void inline vhost_vq_sync_access(struct vhost_virtqueue *vq)
> +{
> +	int ref;
> +
> +	/* Make sure map change was done before checking ref counter */
> +	smp_mb();

This is probably smp_rmb after reading ref, and if you are setting ref
with smp_store_release then this should be smp_load_acquire() without
an explicit mb.

> +	ref = READ_ONCE(vq->ref);
> +	if (ref & 0x1) {
> +		/* When ref change, we are sure no reader can see
> +		 * previous map */
> +		while (READ_ONCE(vq->ref) == ref) {
> +			set_current_state(TASK_RUNNING);
> +			schedule();
> +		}
> +	}

This is basically read_seqcount_begin()' with a schedule instead of
cpu_relax


> +	/* Make sure ref counter was checked before any other
> +	 * operations that was dene on map. */
> +	smp_mb();

should be in a smp_load_acquire()

> +}
> +
>  static void vhost_invalidate_vq_start(struct vhost_virtqueue *vq,
>  				      int index,
>  				      unsigned long start,
> @@ -376,16 +413,15 @@ static void vhost_invalidate_vq_start(struct vhost_virtqueue *vq,
>  	spin_lock(&vq->mmu_lock);
>  	++vq->invalidate_count;
>  
> -	map = rcu_dereference_protected(vq->maps[index],
> -					lockdep_is_held(&vq->mmu_lock));
> +	map = vq->maps[index];
>  	if (map) {
>  		vhost_set_map_dirty(vq, map, index);
> -		rcu_assign_pointer(vq->maps[index], NULL);
> +		vq->maps[index] = NULL;
>  	}
>  	spin_unlock(&vq->mmu_lock);
>  
>  	if (map) {
> -		synchronize_rcu();
> +		vhost_vq_sync_access(vq);

What prevents racing with vhost_vq_access_map_end here?

>  		vhost_map_unprefetch(map);
>  	}
>  }

Overall I don't like it. 

We are trying to get rid of these botique mmu notifier patterns in
drivers. 

Jason

