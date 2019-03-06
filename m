Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B3B16C43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 16:31:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 51EA0206DD
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 16:31:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 51EA0206DD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E65AB8E0004; Wed,  6 Mar 2019 11:31:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E3D418E0003; Wed,  6 Mar 2019 11:31:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D06528E0004; Wed,  6 Mar 2019 11:31:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9C6778E0003
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 11:31:28 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id i66so10238123qke.21
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 08:31:28 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=vWjDEiShTtYZHLzV3ow5JATlpVpFdKwiiEiACkztbXc=;
        b=O+P2mxX0k7vhol0cZIV1tG2j/sSY8BWSclGJLF8/ZK+TKn/wqCpOwsN/oXFR0KSy8B
         O56MwJ6KkxEwvHA0kRbuDcqhi9YF4HC9LoREuiRkJbmli7FbLCUamRjLqAOqI1Njk7Mg
         otD/P7TWNSUPpeydDqBkcMnyUYcAwszSuV8scVsX4Ds1vDhvUzOMAfzLb7YUKYxww7zO
         TfQVSP96eXnzlYuQhBXT7Vh603+IOm+BuItaYsGeo8HzAcl5AitIRM8Q++3q6u0Vapy1
         /cv8sST5/7xMnBldiHa48IvZjKUaF6Napz4FNBMBlFBly0faPQ81SzFeWilf0w1vCkBD
         mnCA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAX9SNiIU/x3sQRca/K0okR2piIh71RyAGIeNJQz19Fpl0SAEdON
	fK5agYmWMdgO/KntOrc8xKLR/CJCEKWa/D2gSBlJkMUVJpb/XlF1LD4UJcuNLooYhBIdDcF97WZ
	i/DQeXS6LuXaVhnva1oxXGs4A1m7P9Q5kep4eBC7wAEz2O4AgaK4qSr+l6SMkinmF4exXQnGNy7
	QgltBpxEkYFi5+O5g7rXwOzcGriTLV6aOBmJyu1HBZMIek5aI5EZfYABfJnsBxMvJN26jjP8fFT
	nFGEDfWwZuWNaBKWm5LAeybE2l07VTC+m8sRinptUfprJJjdFfF1WSjKiCD/K6mpZpUoqrrOd4h
	anAFoL9FqzgRhog/tp8DCMmJbBuv2+HfRz8sjnMN/JMeORVIXzjkeH39RLSTWSivmvwlUob4xMq
	N
X-Received: by 2002:aed:236a:: with SMTP id i39mr6213258qtc.238.1551889888364;
        Wed, 06 Mar 2019 08:31:28 -0800 (PST)
X-Received: by 2002:aed:236a:: with SMTP id i39mr6213175qtc.238.1551889887186;
        Wed, 06 Mar 2019 08:31:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551889887; cv=none;
        d=google.com; s=arc-20160816;
        b=s7/LkwukcKidaTjQ+3/A9gckLhlsZ7S91yGpvQPvobnFHS5f5ZO2K22P92MhUsqUHZ
         OAAh+pRTvNe/7p6hoCHf013Aiq1O7xwEWT8kunn+HrMlyk0B9+iD1QVt1J/wfxUCbYij
         c1BwcuM5KuC8AqJToluOoPGT+qLqz36Sa5B8mi7j3wlUPy1+WwC0AcFegdA/hZtLNX74
         e//3u3ghxo3KZr6ROzi28rfxcn5eoki9lEdxvYE2es1p2PalclS6epAZXPusipnDS9IU
         iNDgHQBXNIoYzEwyIMSf00G011sb9mQ9XpffW1GIqgVbgA/Pidd0La99OyTYDpdCX9l9
         i9Ew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=vWjDEiShTtYZHLzV3ow5JATlpVpFdKwiiEiACkztbXc=;
        b=eTFQ7jWy3bTyMu2UJTh9DtRsh+As9RdkKj7wdFZ2TeoukSIx0RVjUFqmvLtQotrFCv
         9iCm9Lf64xv2eQr/yct+POzhoUDk+zJ34penuxQB+B91a1kRey8QqDW3LLE2zuvYxfPz
         2wbrkpD+dPURs4NDQikL/4d8ywh5r5Y4PNU2zPP7EwsOqEtOFnx22WZ1eccCRs1NAuis
         tiwIAIzmaJDNy694Hn/s7DNHq6VRNouY8ZMKar0+iDyHBWz3ChGzvc4Pu0L11/YnD5sF
         CBRd+YGtamc3u8l3/mN5Orr5VLUnMZF4YgqS/wWF5jxjC6PvfTl2qlDQZaYkLElw2vTQ
         jmDg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k44sor2549027qta.8.2019.03.06.08.31.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Mar 2019 08:31:27 -0800 (PST)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqx78FT+PTgz3Wv+wxfQwynpA8Sh3Bl3+3IGmU2qO6A7euVIuJ/SKC+7E0qJggTs1kCrb8Le+w==
X-Received: by 2002:ac8:31ab:: with SMTP id h40mr6578368qte.122.1551889886815;
        Wed, 06 Mar 2019 08:31:26 -0800 (PST)
Received: from redhat.com (pool-173-76-246-42.bstnma.fios.verizon.net. [173.76.246.42])
        by smtp.gmail.com with ESMTPSA id o3sm1032894qte.55.2019.03.06.08.31.25
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 06 Mar 2019 08:31:25 -0800 (PST)
Date: Wed, 6 Mar 2019 11:31:23 -0500
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Jason Wang <jasowang@redhat.com>
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	peterx@redhat.com, linux-mm@kvack.org, aarcange@redhat.com
Subject: Re: [RFC PATCH V2 5/5] vhost: access vq metadata through kernel
 virtual address
Message-ID: <20190306092837-mutt-send-email-mst@kernel.org>
References: <1551856692-3384-1-git-send-email-jasowang@redhat.com>
 <1551856692-3384-6-git-send-email-jasowang@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1551856692-3384-6-git-send-email-jasowang@redhat.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 06, 2019 at 02:18:12AM -0500, Jason Wang wrote:
> It was noticed that the copy_user() friends that was used to access
> virtqueue metdata tends to be very expensive for dataplane
> implementation like vhost since it involves lots of software checks,
> speculation barrier, hardware feature toggling (e.g SMAP). The
> extra cost will be more obvious when transferring small packets since
> the time spent on metadata accessing become more significant.
> 
> This patch tries to eliminate those overheads by accessing them
> through kernel virtual address by vmap(). To make the pages can be
> migrated, instead of pinning them through GUP, we use MMU notifiers to
> invalidate vmaps and re-establish vmaps during each round of metadata
> prefetching if necessary. It looks to me .invalidate_range() is
> sufficient for catching this since we don't need extra TLB flush. For
> devices that doesn't use metadata prefetching, the memory accessors
> fallback to normal copy_user() implementation gracefully. The
> invalidation was synchronized with datapath through vq mutex, and in
> order to avoid hold vq mutex during range checking, MMU notifier was
> teared down when trying to modify vq metadata.
> 
> Dirty page checking is done by calling set_page_dirty_locked()
> explicitly for the page that used ring stay after each round of
> processing.
> 
> Note that this was only done when device IOTLB is not enabled. We
> could use similar method to optimize it in the future.
> 
> Tests shows at most about 22% improvement on TX PPS when using
> virtio-user + vhost_net + xdp1 + TAP on 2.6GHz Broadwell:
> 
>         SMAP on | SMAP off
> Before: 5.0Mpps | 6.6Mpps
> After:  6.1Mpps | 7.4Mpps
> 
> Cc: <linux-mm@kvack.org>
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
>  drivers/vhost/net.c   |   2 +
>  drivers/vhost/vhost.c | 281 +++++++++++++++++++++++++++++++++++++++++++++++++-
>  drivers/vhost/vhost.h |  16 +++
>  3 files changed, 297 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> index bf55f99..c276371 100644
> --- a/drivers/vhost/net.c
> +++ b/drivers/vhost/net.c
> @@ -982,6 +982,7 @@ static void handle_tx(struct vhost_net *net)
>  	else
>  		handle_tx_copy(net, sock);
>  
> +	vq_meta_prefetch_done(vq);
>  out:
>  	mutex_unlock(&vq->mutex);
>  }
> @@ -1250,6 +1251,7 @@ static void handle_rx(struct vhost_net *net)
>  		vhost_net_enable_vq(net, vq);
>  out:
>  	vhost_net_signal_used(nvq);
> +	vq_meta_prefetch_done(vq);
>  	mutex_unlock(&vq->mutex);
>  }
>  
> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> index 1015464..36ccf7c 100644
> --- a/drivers/vhost/vhost.c
> +++ b/drivers/vhost/vhost.c
> @@ -434,6 +434,74 @@ static size_t vhost_get_desc_size(struct vhost_virtqueue *vq, int num)
>  	return sizeof(*vq->desc) * num;
>  }
>  
> +static void vhost_uninit_vmap(struct vhost_vmap *map)
> +{
> +	if (map->addr) {
> +		vunmap(map->unmap_addr);
> +		kfree(map->pages);
> +		map->pages = NULL;
> +		map->npages = 0;
> +	}
> +
> +	map->addr = NULL;
> +	map->unmap_addr = NULL;
> +}
> +
> +static void vhost_invalidate_vmap(struct vhost_virtqueue *vq,
> +				  struct vhost_vmap *map,
> +				  unsigned long ustart,
> +				  size_t size,
> +				  unsigned long start,
> +				  unsigned long end)
> +{
> +	if (end < ustart || start > ustart - 1 + size)
> +		return;
> +
> +	dump_stack();
> +	mutex_lock(&vq->mutex);
> +	vhost_uninit_vmap(map);
> +	mutex_unlock(&vq->mutex);
> +}
> +
> +
> +static void vhost_invalidate(struct vhost_dev *dev,
> +			     unsigned long start, unsigned long end)
> +{
> +	int i;
> +
> +	for (i = 0; i < dev->nvqs; i++) {
> +		struct vhost_virtqueue *vq = dev->vqs[i];
> +
> +		vhost_invalidate_vmap(vq, &vq->avail_ring,
> +				      (unsigned long)vq->avail,
> +				      vhost_get_avail_size(vq, vq->num),
> +				      start, end);
> +		vhost_invalidate_vmap(vq, &vq->desc_ring,
> +				      (unsigned long)vq->desc,
> +				      vhost_get_desc_size(vq, vq->num),
> +				      start, end);
> +		vhost_invalidate_vmap(vq, &vq->used_ring,
> +				      (unsigned long)vq->used,
> +				      vhost_get_used_size(vq, vq->num),
> +				      start, end);
> +	}
> +}
> +
> +
> +static void vhost_invalidate_range(struct mmu_notifier *mn,
> +				   struct mm_struct *mm,
> +				   unsigned long start, unsigned long end)
> +{
> +	struct vhost_dev *dev = container_of(mn, struct vhost_dev,
> +					     mmu_notifier);
> +
> +	vhost_invalidate(dev, start, end);
> +}
> +
> +static const struct mmu_notifier_ops vhost_mmu_notifier_ops = {
> +	.invalidate_range = vhost_invalidate_range,
> +};
> +
>  void vhost_dev_init(struct vhost_dev *dev,
>  		    struct vhost_virtqueue **vqs, int nvqs, int iov_limit)
>  {


Note that
.invalidate_range seems to be called after page lock has
been dropped.

Looking at page dirty below:




> @@ -449,6 +517,7 @@ void vhost_dev_init(struct vhost_dev *dev,
>  	dev->mm = NULL;
>  	dev->worker = NULL;
>  	dev->iov_limit = iov_limit;
> +	dev->mmu_notifier.ops = &vhost_mmu_notifier_ops;
>  	init_llist_head(&dev->work_list);
>  	init_waitqueue_head(&dev->wait);
>  	INIT_LIST_HEAD(&dev->read_list);
> @@ -462,6 +531,9 @@ void vhost_dev_init(struct vhost_dev *dev,
>  		vq->indirect = NULL;
>  		vq->heads = NULL;
>  		vq->dev = dev;
> +		vq->avail_ring.addr = NULL;
> +		vq->used_ring.addr = NULL;
> +		vq->desc_ring.addr = NULL;
>  		mutex_init(&vq->mutex);
>  		vhost_vq_reset(dev, vq);
>  		if (vq->handle_kick)
> @@ -542,7 +614,13 @@ long vhost_dev_set_owner(struct vhost_dev *dev)
>  	if (err)
>  		goto err_cgroup;
>  
> +	err = mmu_notifier_register(&dev->mmu_notifier, dev->mm);
> +	if (err)
> +		goto err_mmu_notifier;
> +
>  	return 0;
> +err_mmu_notifier:
> +	vhost_dev_free_iovecs(dev);
>  err_cgroup:
>  	kthread_stop(worker);
>  	dev->worker = NULL;
> @@ -633,6 +711,81 @@ static void vhost_clear_msg(struct vhost_dev *dev)
>  	spin_unlock(&dev->iotlb_lock);
>  }
>  
> +static int vhost_init_vmap(struct vhost_dev *dev,
> +			   struct vhost_vmap *map, unsigned long uaddr,
> +			   size_t size, int write)
> +{
> +	struct page **pages;
> +	int npages = DIV_ROUND_UP(size, PAGE_SIZE);
> +	int npinned;
> +	void *vaddr;
> +	int err = -EFAULT;
> +
> +	err = -ENOMEM;
> +	pages = kmalloc_array(npages, sizeof(struct page *), GFP_KERNEL);
> +	if (!pages)
> +		goto err_uaddr;
> +
> +	err = EFAULT;
> +	npinned = get_user_pages_fast(uaddr, npages, write, pages);
> +	if (npinned != npages)
> +		goto err_gup;
> +
> +	vaddr = vmap(pages, npages, VM_MAP, PAGE_KERNEL);
> +	if (!vaddr)
> +		goto err_gup;
> +
> +	map->addr = vaddr + (uaddr & (PAGE_SIZE - 1));
> +	map->unmap_addr = vaddr;
> +	map->npages = npages;
> +	map->pages = pages;
> +
> +err_gup:
> +	/* Don't pin pages, mmu notifier will notify us about page
> +	 * migration.
> +	 */
> +	if (npinned > 0)
> +		release_pages(pages, npinned);
> +err_uaddr:
> +	return err;
> +}
> +
> +static void vhost_uninit_vq_vmaps(struct vhost_virtqueue *vq)
> +{
> +	vhost_uninit_vmap(&vq->avail_ring);
> +	vhost_uninit_vmap(&vq->desc_ring);
> +	vhost_uninit_vmap(&vq->used_ring);
> +}
> +
> +static int vhost_setup_avail_vmap(struct vhost_virtqueue *vq,
> +				  unsigned long avail)
> +{
> +	return vhost_init_vmap(vq->dev, &vq->avail_ring, avail,
> +			       vhost_get_avail_size(vq, vq->num), false);
> +}
> +
> +static int vhost_setup_desc_vmap(struct vhost_virtqueue *vq,
> +				 unsigned long desc)
> +{
> +	return vhost_init_vmap(vq->dev, &vq->desc_ring, desc,
> +			       vhost_get_desc_size(vq, vq->num), false);
> +}
> +
> +static int vhost_setup_used_vmap(struct vhost_virtqueue *vq,
> +				 unsigned long used)
> +{
> +	return vhost_init_vmap(vq->dev, &vq->used_ring, used,
> +			       vhost_get_used_size(vq, vq->num), true);
> +}
> +
> +static void vhost_set_vmap_dirty(struct vhost_vmap *used)
> +{
> +	int i;
> +
> +	for (i = 0; i < used->npages; i++)
> +		set_page_dirty_lock(used->pages[i]);


This seems to rely on page lock to mark page dirty.

Could it happen that page writeback will check the
page, find it clean, and then you mark it dirty and then
invalidate callback is called?


> +}
> +
>  void vhost_dev_cleanup(struct vhost_dev *dev)
>  {
>  	int i;
> @@ -662,8 +815,12 @@ void vhost_dev_cleanup(struct vhost_dev *dev)
>  		kthread_stop(dev->worker);
>  		dev->worker = NULL;
>  	}
> -	if (dev->mm)
> +	for (i = 0; i < dev->nvqs; i++)
> +		vhost_uninit_vq_vmaps(dev->vqs[i]);
> +	if (dev->mm) {
> +		mmu_notifier_unregister(&dev->mmu_notifier, dev->mm);
>  		mmput(dev->mm);
> +	}
>  	dev->mm = NULL;
>  }
>  EXPORT_SYMBOL_GPL(vhost_dev_cleanup);
> @@ -892,6 +1049,16 @@ static inline void __user *__vhost_get_user(struct vhost_virtqueue *vq,
>  
>  static inline int vhost_put_avail_event(struct vhost_virtqueue *vq)
>  {
> +	if (!vq->iotlb) {
> +		struct vring_used *used = vq->used_ring.addr;
> +
> +		if (likely(used)) {
> +			*((__virtio16 *)&used->ring[vq->num]) =
> +				cpu_to_vhost16(vq, vq->avail_idx);
> +			return 0;
> +		}
> +	}
> +
>  	return vhost_put_user(vq, cpu_to_vhost16(vq, vq->avail_idx),
>  			      vhost_avail_event(vq));
>  }
> @@ -900,6 +1067,16 @@ static inline int vhost_put_used(struct vhost_virtqueue *vq,
>  				 struct vring_used_elem *head, int idx,
>  				 int count)
>  {
> +	if (!vq->iotlb) {
> +		struct vring_used *used = vq->used_ring.addr;
> +
> +		if (likely(used)) {
> +			memcpy(used->ring + idx, head,
> +			       count * sizeof(*head));
> +			return 0;
> +		}
> +	}
> +
>  	return vhost_copy_to_user(vq, vq->used->ring + idx, head,
>  				  count * sizeof(*head));
>  }
> @@ -907,6 +1084,15 @@ static inline int vhost_put_used(struct vhost_virtqueue *vq,
>  static inline int vhost_put_used_flags(struct vhost_virtqueue *vq)
>  
>  {
> +	if (!vq->iotlb) {
> +		struct vring_used *used = vq->used_ring.addr;
> +
> +		if (likely(used)) {
> +			used->flags = cpu_to_vhost16(vq, vq->used_flags);
> +			return 0;
> +		}
> +	}
> +
>  	return vhost_put_user(vq, cpu_to_vhost16(vq, vq->used_flags),
>  			      &vq->used->flags);
>  }
> @@ -914,6 +1100,15 @@ static inline int vhost_put_used_flags(struct vhost_virtqueue *vq)
>  static inline int vhost_put_used_idx(struct vhost_virtqueue *vq)
>  
>  {
> +	if (!vq->iotlb) {
> +		struct vring_used *used = vq->used_ring.addr;
> +
> +		if (likely(used)) {
> +			used->idx = cpu_to_vhost16(vq, vq->last_used_idx);
> +			return 0;
> +		}
> +	}
> +
>  	return vhost_put_user(vq, cpu_to_vhost16(vq, vq->last_used_idx),
>  			      &vq->used->idx);
>  }
> @@ -959,12 +1154,30 @@ static void vhost_dev_unlock_vqs(struct vhost_dev *d)
>  static inline int vhost_get_avail_idx(struct vhost_virtqueue *vq,
>  				      __virtio16 *idx)
>  {
> +	if (!vq->iotlb) {
> +		struct vring_avail *avail = vq->avail_ring.addr;
> +
> +		if (likely(avail)) {
> +			*idx = avail->idx;
> +			return 0;
> +		}
> +	}
> +
>  	return vhost_get_avail(vq, *idx, &vq->avail->idx);
>  }
>  
>  static inline int vhost_get_avail_head(struct vhost_virtqueue *vq,
>  				       __virtio16 *head, int idx)
>  {
> +	if (!vq->iotlb) {
> +		struct vring_avail *avail = vq->avail_ring.addr;
> +
> +		if (likely(avail)) {
> +			*head = avail->ring[idx & (vq->num - 1)];
> +			return 0;
> +		}
> +	}
> +
>  	return vhost_get_avail(vq, *head,
>  			       &vq->avail->ring[idx & (vq->num - 1)]);
>  }
> @@ -972,24 +1185,60 @@ static inline int vhost_get_avail_head(struct vhost_virtqueue *vq,
>  static inline int vhost_get_avail_flags(struct vhost_virtqueue *vq,
>  					__virtio16 *flags)
>  {
> +	if (!vq->iotlb) {
> +		struct vring_avail *avail = vq->avail_ring.addr;
> +
> +		if (likely(avail)) {
> +			*flags = avail->flags;
> +			return 0;
> +		}
> +	}
> +
>  	return vhost_get_avail(vq, *flags, &vq->avail->flags);
>  }
>  
>  static inline int vhost_get_used_event(struct vhost_virtqueue *vq,
>  				       __virtio16 *event)
>  {
> +	if (!vq->iotlb) {
> +		struct vring_avail *avail = vq->avail_ring.addr;
> +
> +		if (likely(avail)) {
> +			*event = (__virtio16)avail->ring[vq->num];
> +			return 0;
> +		}
> +	}
> +
>  	return vhost_get_avail(vq, *event, vhost_used_event(vq));
>  }
>  
>  static inline int vhost_get_used_idx(struct vhost_virtqueue *vq,
>  				     __virtio16 *idx)
>  {
> +	if (!vq->iotlb) {
> +		struct vring_used *used = vq->used_ring.addr;
> +
> +		if (likely(used)) {
> +			*idx = used->idx;
> +			return 0;
> +		}
> +	}
> +
>  	return vhost_get_used(vq, *idx, &vq->used->idx);
>  }
>  
>  static inline int vhost_get_desc(struct vhost_virtqueue *vq,
>  				 struct vring_desc *desc, int idx)
>  {
> +	if (!vq->iotlb) {
> +		struct vring_desc *d = vq->desc_ring.addr;
> +
> +		if (likely(d)) {
> +			*desc = *(d + idx);
> +			return 0;
> +		}
> +	}
> +
>  	return vhost_copy_from_user(vq, desc, vq->desc + idx, sizeof(*desc));
>  }
>  
> @@ -1330,8 +1579,16 @@ int vq_meta_prefetch(struct vhost_virtqueue *vq)
>  {
>  	unsigned int num = vq->num;
>  
> -	if (!vq->iotlb)
> +	if (!vq->iotlb) {
> +		if (unlikely(!vq->avail_ring.addr))
> +			vhost_setup_avail_vmap(vq, (unsigned long)vq->avail);
> +		if (unlikely(!vq->desc_ring.addr))
> +			vhost_setup_desc_vmap(vq, (unsigned long)vq->desc);
> +		if (unlikely(!vq->used_ring.addr))
> +			vhost_setup_used_vmap(vq, (unsigned long)vq->used);
> +
>  		return 1;
> +	}
>  
>  	return iotlb_access_ok(vq, VHOST_ACCESS_RO, (u64)(uintptr_t)vq->desc,
>  			       vhost_get_desc_size(vq, num), VHOST_ADDR_DESC) &&
> @@ -1343,6 +1600,15 @@ int vq_meta_prefetch(struct vhost_virtqueue *vq)
>  }
>  EXPORT_SYMBOL_GPL(vq_meta_prefetch);
>  
> +void vq_meta_prefetch_done(struct vhost_virtqueue *vq)
> +{
> +	if (vq->iotlb)
> +		return;
> +	if (likely(vq->used_ring.addr))
> +		vhost_set_vmap_dirty(&vq->used_ring);
> +}
> +EXPORT_SYMBOL_GPL(vq_meta_prefetch_done);
> +
>  /* Can we log writes? */
>  /* Caller should have device mutex but not vq mutex */
>  bool vhost_log_access_ok(struct vhost_dev *dev)
> @@ -1483,6 +1749,13 @@ long vhost_vring_ioctl(struct vhost_dev *d, unsigned int ioctl, void __user *arg
>  
>  	mutex_lock(&vq->mutex);
>  
> +	/* Unregister MMU notifer to allow invalidation callback
> +	 * can access vq->avail, vq->desc , vq->used and vq->num
> +	 * without holding vq->mutex.
> +	 */
> +	if (d->mm)
> +		mmu_notifier_unregister(&d->mmu_notifier, d->mm);
> +
>  	switch (ioctl) {
>  	case VHOST_SET_VRING_NUM:
>  		/* Resizing ring with an active backend?
> @@ -1499,6 +1772,7 @@ long vhost_vring_ioctl(struct vhost_dev *d, unsigned int ioctl, void __user *arg
>  			r = -EINVAL;
>  			break;
>  		}
> +		vhost_uninit_vq_vmaps(vq);
>  		vq->num = s.num;
>  		break;
>  	case VHOST_SET_VRING_BASE:
> @@ -1581,6 +1855,7 @@ long vhost_vring_ioctl(struct vhost_dev *d, unsigned int ioctl, void __user *arg
>  		vq->avail = (void __user *)(unsigned long)a.avail_user_addr;
>  		vq->log_addr = a.log_guest_addr;
>  		vq->used = (void __user *)(unsigned long)a.used_user_addr;
> +		vhost_uninit_vq_vmaps(vq);
>  		break;
>  	case VHOST_SET_VRING_KICK:
>  		if (copy_from_user(&f, argp, sizeof f)) {
> @@ -1656,6 +1931,8 @@ long vhost_vring_ioctl(struct vhost_dev *d, unsigned int ioctl, void __user *arg
>  	if (pollstart && vq->handle_kick)
>  		r = vhost_poll_start(&vq->poll, vq->kick);
>  
> +	if (d->mm)
> +		mmu_notifier_register(&d->mmu_notifier, d->mm);
>  	mutex_unlock(&vq->mutex);
>  
>  	if (pollstop && vq->handle_kick)
> diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
> index 7a7fc00..146076e 100644
> --- a/drivers/vhost/vhost.h
> +++ b/drivers/vhost/vhost.h
> @@ -12,6 +12,8 @@
>  #include <linux/virtio_config.h>
>  #include <linux/virtio_ring.h>
>  #include <linux/atomic.h>
> +#include <linux/pagemap.h>
> +#include <linux/mmu_notifier.h>
>  
>  struct vhost_work;
>  typedef void (*vhost_work_fn_t)(struct vhost_work *work);
> @@ -80,6 +82,13 @@ enum vhost_uaddr_type {
>  	VHOST_NUM_ADDRS = 3,
>  };
>  
> +struct vhost_vmap {
> +	void *addr;
> +	void *unmap_addr;
> +	int npages;
> +	struct page **pages;
> +};
> +
>  /* The virtqueue structure describes a queue attached to a device. */
>  struct vhost_virtqueue {
>  	struct vhost_dev *dev;
> @@ -90,6 +99,11 @@ struct vhost_virtqueue {
>  	struct vring_desc __user *desc;
>  	struct vring_avail __user *avail;
>  	struct vring_used __user *used;
> +
> +	struct vhost_vmap avail_ring;
> +	struct vhost_vmap desc_ring;
> +	struct vhost_vmap used_ring;
> +
>  	const struct vhost_umem_node *meta_iotlb[VHOST_NUM_ADDRS];
>  	struct file *kick;
>  	struct eventfd_ctx *call_ctx;
> @@ -158,6 +172,7 @@ struct vhost_msg_node {
>  
>  struct vhost_dev {
>  	struct mm_struct *mm;
> +	struct mmu_notifier mmu_notifier;
>  	struct mutex mutex;
>  	struct vhost_virtqueue **vqs;
>  	int nvqs;
> @@ -210,6 +225,7 @@ int vhost_log_write(struct vhost_virtqueue *vq, struct vhost_log *log,
>  		    unsigned int log_num, u64 len,
>  		    struct iovec *iov, int count);
>  int vq_meta_prefetch(struct vhost_virtqueue *vq);
> +void vq_meta_prefetch_done(struct vhost_virtqueue *vq);
>  
>  struct vhost_msg_node *vhost_new_msg(struct vhost_virtqueue *vq, int type);
>  void vhost_enqueue_msg(struct vhost_dev *dev,
> -- 
> 1.8.3.1

