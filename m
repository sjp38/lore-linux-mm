Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 747DBC32754
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 12:07:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1D8E621E6C
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 12:07:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="FwqxEndr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1D8E621E6C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5923A6B0003; Wed,  7 Aug 2019 08:07:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5439E6B0006; Wed,  7 Aug 2019 08:07:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 40A2F6B0007; Wed,  7 Aug 2019 08:07:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 236A86B0003
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 08:07:41 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id d26so82126106qte.19
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 05:07:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=v26ljGQm8kb1b/B+MgY9iqkRnu2IlPlITotoyjOaRLE=;
        b=aYWB5KK0/Uh9dkeMnDkGSuzqrBXNSNELnK3piWedvSN6BBz/y+6W5lGUKCwjN5ZKPO
         dcam4QOm8omBpWtjcS6CR6mtwrGIlQG51g+zedQ4+yl3CpP8172Gsg2oA4GRyNTINCKe
         U7yaLZZOPCq4h1ODWj8cdqSg5QvIghXnFngqH1q0DH1p67o9RZyZCpPUqEzluLJrztDF
         JjTlZCVd2fftRYd1wOcrxWtZD7/P73uhDBdkDbZTReKBEGbpFZdkcO7yO398FgE+em07
         fIQ6aY5YHmKkupUJRg/BOD4UTq/L+BHlrtMcAVlHnzf7sxx6699IBDRxBszOcEZgc/fN
         jnUw==
X-Gm-Message-State: APjAAAXnQuMtyayH+znZCLF7NFfVq6sTEmFLrD0thS7q9dsc7INbA/g1
	UFJsl+riAFIjvgXR5b+u5bd4Ghu5Nb4gwJs4zZvhNpzV10cBuF3Wpv9c8fsz3mylBXrBlZIvoK8
	KJhDIWlbqjD2RWu43ZaPvuUwpZ/Ee4CpVnQub3FrZ8MA6tiOIamCn2DIw1ArQtQ/fbA==
X-Received: by 2002:aed:37e7:: with SMTP id j94mr7534184qtb.75.1565179660823;
        Wed, 07 Aug 2019 05:07:40 -0700 (PDT)
X-Received: by 2002:aed:37e7:: with SMTP id j94mr7534120qtb.75.1565179660111;
        Wed, 07 Aug 2019 05:07:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565179660; cv=none;
        d=google.com; s=arc-20160816;
        b=qeM8wbYEI08lXuCYW58vbkDtNIonc39HdtCqcq6EW2wCRQzwaqNGU+Mqjiw0vs449R
         KT8SNfdRwP2W8bv1AsrFujJKRKNCgIUiEK+E+9EXd0WXbRgk8uV+lYXR684mI25ltExH
         vSgpgozFjUTyz+yUqf3hR81Y5HR5NNc3F/BmFSwK431rMd+K3hTO4Kwh7cEgRdRlB2dI
         CKJCRmrA+5hBvYaz1kJRusRtI8GjGUIgyWwbxPKjk5LkDv0C4fYVs2w+sLBH2+WovUBQ
         mtWPCD5VSd/bGgweAihKroBGknsq0wfjxkiKXPlVhzTr+QLFcxR1jjzcBIxXZ9w7KE6U
         t+lg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=v26ljGQm8kb1b/B+MgY9iqkRnu2IlPlITotoyjOaRLE=;
        b=PIvOdnNjMz6QYobUgVVknXAFL6EqGbuwl+0Dp2jMuxcSRk+4HvbhaGSScgk/jD1rT2
         pBTh6hTXxZtFQ3K6mhj1BQulOeV8MdWi0jlqwIN//QfH313OEXwuYU2Dy+al16tWuy36
         /yJir4K+P9bTZpv/cV/O7w00KJThB3Pzht/7JMPgeFEJt6BA8/ltRXJXD1QQJVvAkdj6
         m2SKM79W/1gVIUCJfbLUYacdZAcGfngHUets34qBq0oWCUSCKDbOnHOLEgNNFIXoGfEt
         gu4vGtxPoLcVZRF/OzRKft2iQw16fpLlM7FmtX3pwluEI86n5U5Wj/d6XTv308r+6fQL
         Ba+g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=FwqxEndr;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 4sor330835qvr.47.2019.08.07.05.07.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Aug 2019 05:07:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=FwqxEndr;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=v26ljGQm8kb1b/B+MgY9iqkRnu2IlPlITotoyjOaRLE=;
        b=FwqxEndrrseDTfa7IA+ahMyXJcw275sq/ogyK1cE9Brfp/+cA5dthaNKeo43mipwCW
         6M3TrldZWv7JXH9KLIINp0G6YhemLDU3zOb98Y6ixjqND8Edt4vtD4dtABJZtPFOlNWQ
         7o+i/B+d4dsypsLc9FAuuiUZqdV3+cuQPd1u7fGeYNEYgtw4WFPR67fjUunxQzqjk+D+
         m/Hrc+kRzSQLc/Y4MNwDwO+mVI0ImT4tvNWKY8DSYiKFsYOn0c9EH2FZcaFik8oOhgro
         wCckNCtxQRpeA/pGd5OtN/Hmf4FSEtEBQR4gGNGlbagAyW+no63yQWaSBO4AtHGy6HOL
         lRNA==
X-Google-Smtp-Source: APXvYqwdlTEXDfbCbN8MO6nqW9FtHXr3xg/qpTMHDicPu2B1XqjJOXbR74uxCwKcBjwiEflnXc1c9w==
X-Received: by 2002:a0c:e790:: with SMTP id x16mr7775534qvn.120.1565179659437;
        Wed, 07 Aug 2019 05:07:39 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id p32sm45431550qtb.67.2019.08.07.05.07.38
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 07 Aug 2019 05:07:38 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hvKjC-0000z1-4M; Wed, 07 Aug 2019 09:07:38 -0300
Date: Wed, 7 Aug 2019 09:07:38 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Jason Wang <jasowang@redhat.com>
Cc: mst@redhat.com, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH V4 7/9] vhost: do not use RCU to synchronize MMU notifier
 with worker
Message-ID: <20190807120738.GB1557@ziepe.ca>
References: <20190807070617.23716-1-jasowang@redhat.com>
 <20190807070617.23716-8-jasowang@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190807070617.23716-8-jasowang@redhat.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 07, 2019 at 03:06:15AM -0400, Jason Wang wrote:
> We used to use RCU to synchronize MMU notifier with worker. This leads
> calling synchronize_rcu() in invalidate_range_start(). But on a busy
> system, there would be many factors that may slow down the
> synchronize_rcu() which makes it unsuitable to be called in MMU
> notifier.
> 
> So this patch switches use seqlock counter to track whether or not the
> map was used. The counter was increased when vq try to start or finish
> uses the map. This means, when it was even, we're sure there's no
> readers and MMU notifier is synchronized. When it was odd, it means
> there's a reader we need to wait it to be even again then we are
> synchronized. Consider the read critical section is pretty small the
> synchronization should be done very fast.
> 
> Reported-by: Michael S. Tsirkin <mst@redhat.com>
> Fixes: 7f466032dc9e ("vhost: access vq metadata through kernel virtual address")
> Signed-off-by: Jason Wang <jasowang@redhat.com>
>  drivers/vhost/vhost.c | 141 ++++++++++++++++++++++++++----------------
>  drivers/vhost/vhost.h |   7 ++-
>  2 files changed, 90 insertions(+), 58 deletions(-)
> 
> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> index cfc11f9ed9c9..57bfbb60d960 100644
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
> @@ -362,6 +361,40 @@ static bool vhost_map_range_overlap(struct vhost_uaddr *uaddr,
>  	return !(end < uaddr->uaddr || start > uaddr->uaddr - 1 + uaddr->size);
>  }
>  
> +static void inline vhost_vq_access_map_begin(struct vhost_virtqueue *vq)
> +{
> +	write_seqcount_begin(&vq->seq);
> +}
> +
> +static void inline vhost_vq_access_map_end(struct vhost_virtqueue *vq)
> +{
> +	write_seqcount_end(&vq->seq);
> +}

The write side of a seqlock only provides write barriers. Access to

	map = vq->maps[VHOST_ADDR_USED];

Still needs a read side barrier, and then I think this will be no
better than a normal spinlock.

It also doesn't seem like this algorithm even needs a seqlock, as this
is just a one bit flag

atomic_set_bit(using map)
smp_mb__after_atomic()
.. maps [...]
atomic_clear_bit(using map)


map = NULL;
smp_mb__before_atomic();
while (atomic_read_bit(using map))
   relax()

Again, not clear this could be faster than a spinlock when the
barriers are correct...

Jason

