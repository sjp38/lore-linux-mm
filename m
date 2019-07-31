Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BC962C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 08:51:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 70C7D2089E
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 08:51:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 70C7D2089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1F67A8E0005; Wed, 31 Jul 2019 04:51:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 159E08E0001; Wed, 31 Jul 2019 04:51:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 021228E0005; Wed, 31 Jul 2019 04:51:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id CDAA38E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 04:51:03 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id j81so57202931qke.23
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 01:51:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=v9ue5hbhd2MohnslbZ4usWyHKBolEutg8/RwpvveSzA=;
        b=XI+OfFGOF6gWKaZF6KA8zw57GB2fbFygLEa12z1GFgrJ3fdsfRGYzati4e42S8UGt8
         CWEy4XfJ1JceftdljaKdyj/LUbUhRDENVkY7Zc5l6LBNWVXKjA1+dIxtmHTWSYgs3vP/
         lxbdatO7sgnJQhKBR3mgSuKd2PT6AgslnEXSUgf+tnlc5ewxeqvjII/CUUT6FgGScsU1
         dBeumwNX+yDMEqLS997yValn5bWquxx8bNiLao4zfeNNY0+vWi45TbhlJ+m16eSm5DXu
         I0AHaQ58XqmMu6LSIVWcer3+LkBtWHaVeiXVCVWWs2zx0HNXfDwIrZqOz6UQ4PadAWOR
         hyTw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWmuCn3sCiQEWxiNwKLUWtX3vId369IU7u5DfRVUy4to5oLqDRZ
	qn9J8HD0Z6lafI4uEBzCTGsGBoKU2DbM/T+m1mXPuQ/EXOQFuMIxdn4jkW69RTt/PDbTAN4SI2C
	xeMUMSrodDZh2vYJJpGP3+j16JUZWVQvgX91d7a6DegUZxIHWw8/6O3cREE0SoUl2nQ==
X-Received: by 2002:ac8:32a1:: with SMTP id z30mr85540430qta.117.1564563063557;
        Wed, 31 Jul 2019 01:51:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz5Zjqjn7jgpLhw4Ssjh22SsHYHY5VBhybNC/uW24F/ov1I2UrqFtzr2XNCQajM+dtj+9mG
X-Received: by 2002:ac8:32a1:: with SMTP id z30mr85540395qta.117.1564563062674;
        Wed, 31 Jul 2019 01:51:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564563062; cv=none;
        d=google.com; s=arc-20160816;
        b=SOF7O5rIG2dPHx6Aa8zyDem7j3KH030nhngiY3fT+RFrUX2bZ1OEOkVeSfV5grQvRt
         8z59rWZA04g3ZzTAhXILUoAMfk9pRu/XPr9+I0YJ8WC66DnhWzJU6P5sDsehhTEuNgZ4
         YWvAm4bkzevuYkDunyTTU2aUpWNznuDLQAt/c7ttgeLpOYuBLMkibuCT5SAvzoA+P9P4
         WvBqTTLOVyfY5Y0NvkN8eMrpONLs5cB1s98L9NDsNSttQbsWYlzOtV/PhRLYoDHnLg30
         wYuLU6H5hJQmKZEa5Kf3vYj4GVoS+HkOEmpnlfz1kAlDMIR/oWEcB7YD7vLkCUiBCtsA
         crBw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=v9ue5hbhd2MohnslbZ4usWyHKBolEutg8/RwpvveSzA=;
        b=XKGeqECSC2P8DANC7ssWnu2x6aUzGB7a5Q7A2Q1BReucNRj1ewIqaGhS6VrD/wFySx
         FBEc3AmoOJCJSQ0nbCjwy3zTFSg05HORPEl/ikJoD9sjThmM6mbLwsBfqN8QRMUnKYmi
         T+tdSy+9p0J6vpHoBtRJyu8De89bHkmz+GcbY+bpnJp0y9Ev+lu2gqmKFEZmnrhvvfAG
         ML+lU8EtMfoTcb8PEDfEUs8cVAxonA92DB4d3Rzw4R5szJ+INiWQvFWBy/B76YffaZj+
         SoBLBtqcwE6c9NZdsnDpwAzV39JMPpbq0nW1TxFXdZD7Ro0eFVKIg49fi5AWshRS2cqU
         uxXQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q16si41673775qtc.362.2019.07.31.01.51.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 01:51:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id CF17C3084025;
	Wed, 31 Jul 2019 08:51:01 +0000 (UTC)
Received: from [10.72.12.51] (ovpn-12-51.pek2.redhat.com [10.72.12.51])
	by smtp.corp.redhat.com (Postfix) with ESMTP id F03B85D6A7;
	Wed, 31 Jul 2019 08:50:55 +0000 (UTC)
Subject: Re: [PATCH V2 7/9] vhost: do not use RCU to synchronize MMU notifier
 with worker
To: mst@redhat.com, kvm@vger.kernel.org,
 virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jgg@ziepe.ca
References: <20190731084655.7024-1-jasowang@redhat.com>
 <20190731084655.7024-8-jasowang@redhat.com>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <cab99dc3-962e-57a2-70f3-73e9f64f3a49@redhat.com>
Date: Wed, 31 Jul 2019 16:50:54 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190731084655.7024-8-jasowang@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Wed, 31 Jul 2019 08:51:01 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/7/31 下午4:46, Jason Wang wrote:
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
> synchronized. To avoid full memory barrier, store_release +
> load_acquire on the counter is used.


For reviewers, I try hard to avoid e.g smp_mb(), please double check 
whether or not this trick work.

Thanks


>
> Consider the read critical section is pretty small the synchronization
> should be done very fast.
>
> Note the patch lead about 3% PPS dropping.
>
> Reported-by: Michael S. Tsirkin <mst@redhat.com>
> Fixes: 7f466032dc9e ("vhost: access vq metadata through kernel virtual address")
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
>   drivers/vhost/vhost.c | 145 ++++++++++++++++++++++++++----------------
>   drivers/vhost/vhost.h |   7 +-
>   2 files changed, 94 insertions(+), 58 deletions(-)
>
> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> index cfc11f9ed9c9..db2c81cb1e90 100644
> --- a/drivers/vhost/vhost.c
> +++ b/drivers/vhost/vhost.c
> @@ -324,17 +324,16 @@ static void vhost_uninit_vq_maps(struct vhost_virtqueue *vq)
>   
>   	spin_lock(&vq->mmu_lock);
>   	for (i = 0; i < VHOST_NUM_ADDRS; i++) {
> -		map[i] = rcu_dereference_protected(vq->maps[i],
> -				  lockdep_is_held(&vq->mmu_lock));
> +		map[i] = vq->maps[i];
>   		if (map[i]) {
>   			vhost_set_map_dirty(vq, map[i], i);
> -			rcu_assign_pointer(vq->maps[i], NULL);
> +			vq->maps[i] = NULL;
>   		}
>   	}
>   	spin_unlock(&vq->mmu_lock);
>   
> -	/* No need for synchronize_rcu() or kfree_rcu() since we are
> -	 * serialized with memory accessors (e.g vq mutex held).
> +	/* No need for synchronization since we are serialized with
> +	 * memory accessors (e.g vq mutex held).
>   	 */
>   
>   	for (i = 0; i < VHOST_NUM_ADDRS; i++)
> @@ -362,6 +361,44 @@ static bool vhost_map_range_overlap(struct vhost_uaddr *uaddr,
>   	return !(end < uaddr->uaddr || start > uaddr->uaddr - 1 + uaddr->size);
>   }
>   
> +static void inline vhost_vq_access_map_begin(struct vhost_virtqueue *vq)
> +{
> +	int ref = READ_ONCE(vq->ref);
> +
> +	smp_store_release(&vq->ref, ref + 1);
> +	/* Make sure ref counter is visible before accessing the map */
> +	smp_load_acquire(&vq->ref);
> +}
> +
> +static void inline vhost_vq_access_map_end(struct vhost_virtqueue *vq)
> +{
> +	int ref = READ_ONCE(vq->ref);
> +
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
> +
> +	ref = READ_ONCE(vq->ref);
> +	if (ref & 0x1) {
> +		/* When ref change, we are sure no reader can see
> +		 * previous map */
> +		while (READ_ONCE(vq->ref) == ref) {
> +			set_current_state(TASK_RUNNING);
> +			schedule();
> +		}
> +	}
> +	/* Make sure ref counter was checked before any other
> +	 * operations that was dene on map. */
> +	smp_mb();
> +}
> +
>   static void vhost_invalidate_vq_start(struct vhost_virtqueue *vq,
>   				      int index,
>   				      unsigned long start,
> @@ -376,16 +413,15 @@ static void vhost_invalidate_vq_start(struct vhost_virtqueue *vq,
>   	spin_lock(&vq->mmu_lock);
>   	++vq->invalidate_count;
>   
> -	map = rcu_dereference_protected(vq->maps[index],
> -					lockdep_is_held(&vq->mmu_lock));
> +	map = vq->maps[index];
>   	if (map) {
>   		vhost_set_map_dirty(vq, map, index);
> -		rcu_assign_pointer(vq->maps[index], NULL);
> +		vq->maps[index] = NULL;
>   	}
>   	spin_unlock(&vq->mmu_lock);
>   
>   	if (map) {
> -		synchronize_rcu();
> +		vhost_vq_sync_access(vq);
>   		vhost_map_unprefetch(map);
>   	}
>   }
> @@ -457,7 +493,7 @@ static void vhost_init_maps(struct vhost_dev *dev)
>   	for (i = 0; i < dev->nvqs; ++i) {
>   		vq = dev->vqs[i];
>   		for (j = 0; j < VHOST_NUM_ADDRS; j++)
> -			RCU_INIT_POINTER(vq->maps[j], NULL);
> +			vq->maps[j] = NULL;
>   	}
>   }
>   #endif
> @@ -655,6 +691,7 @@ void vhost_dev_init(struct vhost_dev *dev,
>   		vq->indirect = NULL;
>   		vq->heads = NULL;
>   		vq->dev = dev;
> +		vq->ref = 0;
>   		mutex_init(&vq->mutex);
>   		spin_lock_init(&vq->mmu_lock);
>   		vhost_vq_reset(dev, vq);
> @@ -921,7 +958,7 @@ static int vhost_map_prefetch(struct vhost_virtqueue *vq,
>   	map->npages = npages;
>   	map->pages = pages;
>   
> -	rcu_assign_pointer(vq->maps[index], map);
> +	vq->maps[index] = map;
>   	/* No need for a synchronize_rcu(). This function should be
>   	 * called by dev->worker so we are serialized with all
>   	 * readers.
> @@ -1216,18 +1253,18 @@ static inline int vhost_put_avail_event(struct vhost_virtqueue *vq)
>   	struct vring_used *used;
>   
>   	if (!vq->iotlb) {
> -		rcu_read_lock();
> +		vhost_vq_access_map_begin(vq);
>   
> -		map = rcu_dereference(vq->maps[VHOST_ADDR_USED]);
> +		map = vq->maps[VHOST_ADDR_USED];
>   		if (likely(map)) {
>   			used = map->addr;
>   			*((__virtio16 *)&used->ring[vq->num]) =
>   				cpu_to_vhost16(vq, vq->avail_idx);
> -			rcu_read_unlock();
> +			vhost_vq_access_map_end(vq);
>   			return 0;
>   		}
>   
> -		rcu_read_unlock();
> +		vhost_vq_access_map_end(vq);
>   	}
>   #endif
>   
> @@ -1245,18 +1282,18 @@ static inline int vhost_put_used(struct vhost_virtqueue *vq,
>   	size_t size;
>   
>   	if (!vq->iotlb) {
> -		rcu_read_lock();
> +		vhost_vq_access_map_begin(vq);
>   
> -		map = rcu_dereference(vq->maps[VHOST_ADDR_USED]);
> +		map = vq->maps[VHOST_ADDR_USED];
>   		if (likely(map)) {
>   			used = map->addr;
>   			size = count * sizeof(*head);
>   			memcpy(used->ring + idx, head, size);
> -			rcu_read_unlock();
> +			vhost_vq_access_map_end(vq);
>   			return 0;
>   		}
>   
> -		rcu_read_unlock();
> +		vhost_vq_access_map_end(vq);
>   	}
>   #endif
>   
> @@ -1272,17 +1309,17 @@ static inline int vhost_put_used_flags(struct vhost_virtqueue *vq)
>   	struct vring_used *used;
>   
>   	if (!vq->iotlb) {
> -		rcu_read_lock();
> +		vhost_vq_access_map_begin(vq);
>   
> -		map = rcu_dereference(vq->maps[VHOST_ADDR_USED]);
> +		map = vq->maps[VHOST_ADDR_USED];
>   		if (likely(map)) {
>   			used = map->addr;
>   			used->flags = cpu_to_vhost16(vq, vq->used_flags);
> -			rcu_read_unlock();
> +			vhost_vq_access_map_end(vq);
>   			return 0;
>   		}
>   
> -		rcu_read_unlock();
> +		vhost_vq_access_map_end(vq);
>   	}
>   #endif
>   
> @@ -1298,17 +1335,17 @@ static inline int vhost_put_used_idx(struct vhost_virtqueue *vq)
>   	struct vring_used *used;
>   
>   	if (!vq->iotlb) {
> -		rcu_read_lock();
> +		vhost_vq_access_map_begin(vq);
>   
> -		map = rcu_dereference(vq->maps[VHOST_ADDR_USED]);
> +		map = vq->maps[VHOST_ADDR_USED];
>   		if (likely(map)) {
>   			used = map->addr;
>   			used->idx = cpu_to_vhost16(vq, vq->last_used_idx);
> -			rcu_read_unlock();
> +			vhost_vq_access_map_end(vq);
>   			return 0;
>   		}
>   
> -		rcu_read_unlock();
> +		vhost_vq_access_map_end(vq);
>   	}
>   #endif
>   
> @@ -1362,17 +1399,17 @@ static inline int vhost_get_avail_idx(struct vhost_virtqueue *vq,
>   	struct vring_avail *avail;
>   
>   	if (!vq->iotlb) {
> -		rcu_read_lock();
> +		vhost_vq_access_map_begin(vq);
>   
> -		map = rcu_dereference(vq->maps[VHOST_ADDR_AVAIL]);
> +		map = vq->maps[VHOST_ADDR_AVAIL];
>   		if (likely(map)) {
>   			avail = map->addr;
>   			*idx = avail->idx;
> -			rcu_read_unlock();
> +			vhost_vq_access_map_end(vq);
>   			return 0;
>   		}
>   
> -		rcu_read_unlock();
> +		vhost_vq_access_map_end(vq);
>   	}
>   #endif
>   
> @@ -1387,17 +1424,17 @@ static inline int vhost_get_avail_head(struct vhost_virtqueue *vq,
>   	struct vring_avail *avail;
>   
>   	if (!vq->iotlb) {
> -		rcu_read_lock();
> +		vhost_vq_access_map_begin(vq);
>   
> -		map = rcu_dereference(vq->maps[VHOST_ADDR_AVAIL]);
> +		map = vq->maps[VHOST_ADDR_AVAIL];
>   		if (likely(map)) {
>   			avail = map->addr;
>   			*head = avail->ring[idx & (vq->num - 1)];
> -			rcu_read_unlock();
> +			vhost_vq_access_map_end(vq);
>   			return 0;
>   		}
>   
> -		rcu_read_unlock();
> +		vhost_vq_access_map_end(vq);
>   	}
>   #endif
>   
> @@ -1413,17 +1450,17 @@ static inline int vhost_get_avail_flags(struct vhost_virtqueue *vq,
>   	struct vring_avail *avail;
>   
>   	if (!vq->iotlb) {
> -		rcu_read_lock();
> +		vhost_vq_access_map_begin(vq);
>   
> -		map = rcu_dereference(vq->maps[VHOST_ADDR_AVAIL]);
> +		map = vq->maps[VHOST_ADDR_AVAIL];
>   		if (likely(map)) {
>   			avail = map->addr;
>   			*flags = avail->flags;
> -			rcu_read_unlock();
> +			vhost_vq_access_map_end(vq);
>   			return 0;
>   		}
>   
> -		rcu_read_unlock();
> +		vhost_vq_access_map_end(vq);
>   	}
>   #endif
>   
> @@ -1438,15 +1475,15 @@ static inline int vhost_get_used_event(struct vhost_virtqueue *vq,
>   	struct vring_avail *avail;
>   
>   	if (!vq->iotlb) {
> -		rcu_read_lock();
> -		map = rcu_dereference(vq->maps[VHOST_ADDR_AVAIL]);
> +		vhost_vq_access_map_begin(vq);
> +		map = vq->maps[VHOST_ADDR_AVAIL];
>   		if (likely(map)) {
>   			avail = map->addr;
>   			*event = (__virtio16)avail->ring[vq->num];
> -			rcu_read_unlock();
> +			vhost_vq_access_map_end(vq);
>   			return 0;
>   		}
> -		rcu_read_unlock();
> +		vhost_vq_access_map_end(vq);
>   	}
>   #endif
>   
> @@ -1461,17 +1498,17 @@ static inline int vhost_get_used_idx(struct vhost_virtqueue *vq,
>   	struct vring_used *used;
>   
>   	if (!vq->iotlb) {
> -		rcu_read_lock();
> +		vhost_vq_access_map_begin(vq);
>   
> -		map = rcu_dereference(vq->maps[VHOST_ADDR_USED]);
> +		map = vq->maps[VHOST_ADDR_USED];
>   		if (likely(map)) {
>   			used = map->addr;
>   			*idx = used->idx;
> -			rcu_read_unlock();
> +			vhost_vq_access_map_end(vq);
>   			return 0;
>   		}
>   
> -		rcu_read_unlock();
> +		vhost_vq_access_map_end(vq);
>   	}
>   #endif
>   
> @@ -1486,17 +1523,17 @@ static inline int vhost_get_desc(struct vhost_virtqueue *vq,
>   	struct vring_desc *d;
>   
>   	if (!vq->iotlb) {
> -		rcu_read_lock();
> +		vhost_vq_access_map_begin(vq);
>   
> -		map = rcu_dereference(vq->maps[VHOST_ADDR_DESC]);
> +		map = vq->maps[VHOST_ADDR_DESC];
>   		if (likely(map)) {
>   			d = map->addr;
>   			*desc = *(d + idx);
> -			rcu_read_unlock();
> +			vhost_vq_access_map_end(vq);
>   			return 0;
>   		}
>   
> -		rcu_read_unlock();
> +		vhost_vq_access_map_end(vq);
>   	}
>   #endif
>   
> @@ -1843,13 +1880,11 @@ static bool iotlb_access_ok(struct vhost_virtqueue *vq,
>   #if VHOST_ARCH_CAN_ACCEL_UACCESS
>   static void vhost_vq_map_prefetch(struct vhost_virtqueue *vq)
>   {
> -	struct vhost_map __rcu *map;
> +	struct vhost_map *map;
>   	int i;
>   
>   	for (i = 0; i < VHOST_NUM_ADDRS; i++) {
> -		rcu_read_lock();
> -		map = rcu_dereference(vq->maps[i]);
> -		rcu_read_unlock();
> +		map = vq->maps[i];
>   		if (unlikely(!map))
>   			vhost_map_prefetch(vq, i);
>   	}
> diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
> index a9a2a93857d2..f9e9558a529d 100644
> --- a/drivers/vhost/vhost.h
> +++ b/drivers/vhost/vhost.h
> @@ -115,16 +115,17 @@ struct vhost_virtqueue {
>   #if VHOST_ARCH_CAN_ACCEL_UACCESS
>   	/* Read by memory accessors, modified by meta data
>   	 * prefetching, MMU notifier and vring ioctl().
> -	 * Synchonrized through mmu_lock (writers) and RCU (writers
> -	 * and readers).
> +	 * Synchonrized through mmu_lock (writers) and ref counters,
> +	 * see vhost_vq_access_map_begin()/vhost_vq_access_map_end().
>   	 */
> -	struct vhost_map __rcu *maps[VHOST_NUM_ADDRS];
> +	struct vhost_map *maps[VHOST_NUM_ADDRS];
>   	/* Read by MMU notifier, modified by vring ioctl(),
>   	 * synchronized through MMU notifier
>   	 * registering/unregistering.
>   	 */
>   	struct vhost_uaddr uaddrs[VHOST_NUM_ADDRS];
>   #endif
> +	int ref;
>   	const struct vhost_umem_node *meta_iotlb[VHOST_NUM_ADDRS];
>   
>   	struct file *kick;

