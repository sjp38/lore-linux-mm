Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7C9F8C4360D
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 02:19:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0916E20863
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 02:19:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0916E20863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 715336B0005; Sun,  8 Sep 2019 22:19:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 69F966B0006; Sun,  8 Sep 2019 22:19:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 519256B0007; Sun,  8 Sep 2019 22:19:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0169.hostedemail.com [216.40.44.169])
	by kanga.kvack.org (Postfix) with ESMTP id 21E416B0005
	for <linux-mm@kvack.org>; Sun,  8 Sep 2019 22:19:38 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id B8396181AC9AE
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 02:19:37 +0000 (UTC)
X-FDA: 75913775994.11.table07_53edfff6c7506
X-HE-Tag: table07_53edfff6c7506
X-Filterd-Recvd-Size: 24818
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf25.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 02:19:36 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 222B0A46C10;
	Mon,  9 Sep 2019 02:19:35 +0000 (UTC)
Received: from [10.72.12.61] (ovpn-12-61.pek2.redhat.com [10.72.12.61])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 16CA960925;
	Mon,  9 Sep 2019 02:19:05 +0000 (UTC)
Subject: Re: [PATCH 2/2] vhost: re-introducing metadata acceleration through
 kernel virtual address
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org, jgg@mellanox.com,
 aarcange@redhat.com, jglisse@redhat.com, linux-mm@kvack.org,
 James Bottomley <James.Bottomley@hansenpartnership.com>,
 Christoph Hellwig <hch@infradead.org>, David Miller <davem@davemloft.net>,
 linux-arm-kernel@lists.infradead.org, linux-parisc@vger.kernel.org
References: <20190905122736.19768-1-jasowang@redhat.com>
 <20190905122736.19768-3-jasowang@redhat.com>
 <20190908063618-mutt-send-email-mst@kernel.org>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <1cb5aa8d-6213-5fce-5a77-fcada572c882@redhat.com>
Date: Mon, 9 Sep 2019 10:18:57 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190908063618-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.6.2 (mx1.redhat.com [10.5.110.68]); Mon, 09 Sep 2019 02:19:35 +0000 (UTC)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/9/8 =E4=B8=8B=E5=8D=887:05, Michael S. Tsirkin wrote:
> On Thu, Sep 05, 2019 at 08:27:36PM +0800, Jason Wang wrote:
>> This is a rework on the commit 7f466032dc9e ("vhost: access vq
>> metadata through kernel virtual address").
>>
>> It was noticed that the copy_to/from_user() friends that was used to
>> access virtqueue metdata tends to be very expensive for dataplane
>> implementation like vhost since it involves lots of software checks,
>> speculation barriers,
> So if we drop speculation barrier,
> there's a problem here in access will now be speculated.
> This effectively disables the defence in depth effect of
> b3bbfb3fb5d25776b8e3f361d2eedaabb0b496cd
>      x86: Introduce __uaccess_begin_nospec() and uaccess_try_nospec
>
>
> So now we need to sprinkle array_index_nospec or barrier_nospec over th=
e
> code whenever we use an index we got from userspace.
> See below for some examples.
>
>
>> hardware feature toggling (e.g SMAP). The
>> extra cost will be more obvious when transferring small packets since
>> the time spent on metadata accessing become more significant.
>>
>> This patch tries to eliminate those overheads by accessing them
>> through direct mapping of those pages. Invalidation callbacks is
>> implemented for co-operation with general VM management (swap, KSM,
>> THP or NUMA balancing). We will try to get the direct mapping of vq
>> metadata before each round of packet processing if it doesn't
>> exist. If we fail, we will simplely fallback to copy_to/from_user()
>> friends.
>>
>> This invalidation, direct mapping access and set are synchronized
>> through spinlock. This takes a step back from the original commit
>> 7f466032dc9e ("vhost: access vq metadata through kernel virtual
>> address") which tries to RCU which is suspicious and hard to be
>> reviewed. This won't perform as well as RCU because of the atomic,
>> this could be addressed by the future optimization.
>>
>> This method might does not work for high mem page which requires
>> temporary mapping so we just fallback to normal
>> copy_to/from_user() and may not for arch that has virtual tagged cache
>> since extra cache flushing is needed to eliminate the alias. This will
>> result complex logic and bad performance. For those archs, this patch
>> simply go for copy_to/from_user() friends. This is done by ruling out
>> kernel mapping codes through ARCH_IMPLEMENTS_FLUSH_DCACHE_PAGE.
>>
>> Note that this is only done when device IOTLB is not enabled. We
>> could use similar method to optimize IOTLB in the future.
>>
>> Tests shows at most about 22% improvement on TX PPS when using
>> virtio-user + vhost_net + xdp1 + TAP on 4.0GHz Kaby Lake.
>>
>>          SMAP on | SMAP off
>> Before: 4.9Mpps | 6.9Mpps
>> After:  6.0Mpps | 7.5Mpps
>>
>> On a elder CPU Sandy Bridge without SMAP support. TX PPS doesn't see
>> any difference.
> Why is not Kaby Lake with SMAP off the same as Sandy Bridge?


I don't know, I guess it was because the atomic is l


>
>
>> Cc: Andrea Arcangeli <aarcange@redhat.com>
>> Cc: James Bottomley <James.Bottomley@hansenpartnership.com>
>> Cc: Christoph Hellwig <hch@infradead.org>
>> Cc: David Miller <davem@davemloft.net>
>> Cc: Jerome Glisse <jglisse@redhat.com>
>> Cc: Jason Gunthorpe <jgg@mellanox.com>
>> Cc: linux-mm@kvack.org
>> Cc: linux-arm-kernel@lists.infradead.org
>> Cc: linux-parisc@vger.kernel.org
>> Signed-off-by: Jason Wang <jasowang@redhat.com>
>> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
>> ---
>>   drivers/vhost/vhost.c | 551 ++++++++++++++++++++++++++++++++++++++++=
+-
>>   drivers/vhost/vhost.h |  41 ++++
>>   2 files changed, 589 insertions(+), 3 deletions(-)
>>
>> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
>> index 791562e03fe0..f98155f28f02 100644
>> --- a/drivers/vhost/vhost.c
>> +++ b/drivers/vhost/vhost.c
>> @@ -298,6 +298,182 @@ static void vhost_vq_meta_reset(struct vhost_dev=
 *d)
>>   		__vhost_vq_meta_reset(d->vqs[i]);
>>   }
>>  =20
>> +#if VHOST_ARCH_CAN_ACCEL_UACCESS
>> +static void vhost_map_unprefetch(struct vhost_map *map)
>> +{
>> +	kfree(map->pages);
>> +	kfree(map);
>> +}
>> +
>> +static void vhost_set_map_dirty(struct vhost_virtqueue *vq,
>> +				struct vhost_map *map, int index)
>> +{
>> +	struct vhost_uaddr *uaddr =3D &vq->uaddrs[index];
>> +	int i;
>> +
>> +	if (uaddr->write) {
>> +		for (i =3D 0; i < map->npages; i++)
>> +			set_page_dirty(map->pages[i]);
>> +	}
>> +}
>> +
>> +static void vhost_uninit_vq_maps(struct vhost_virtqueue *vq)
>> +{
>> +	struct vhost_map *map[VHOST_NUM_ADDRS];
>> +	int i;
>> +
>> +	spin_lock(&vq->mmu_lock);
>> +	for (i =3D 0; i < VHOST_NUM_ADDRS; i++) {
>> +		map[i] =3D vq->maps[i];
>> +		if (map[i]) {
>> +			vhost_set_map_dirty(vq, map[i], i);
>> +			vq->maps[i] =3D NULL;
>> +		}
>> +	}
>> +	spin_unlock(&vq->mmu_lock);
>> +
>> +	/* No need for synchronization since we are serialized with
>> +	 * memory accessors (e.g vq mutex held).
>> +	 */
>> +
>> +	for (i =3D 0; i < VHOST_NUM_ADDRS; i++)
>> +		if (map[i])
>> +			vhost_map_unprefetch(map[i]);
>> +
>> +}
>> +
>> +static void vhost_reset_vq_maps(struct vhost_virtqueue *vq)
>> +{
>> +	int i;
>> +
>> +	vhost_uninit_vq_maps(vq);
>> +	for (i =3D 0; i < VHOST_NUM_ADDRS; i++)
>> +		vq->uaddrs[i].size =3D 0;
>> +}
>> +
>> +static bool vhost_map_range_overlap(struct vhost_uaddr *uaddr,
>> +				     unsigned long start,
>> +				     unsigned long end)
>> +{
>> +	if (unlikely(!uaddr->size))
>> +		return false;
>> +
>> +	return !(end < uaddr->uaddr || start > uaddr->uaddr - 1 + uaddr->siz=
e);
>> +}
>> +
>> +static void inline vhost_vq_access_map_begin(struct vhost_virtqueue *=
vq)
>> +{
>> +	spin_lock(&vq->mmu_lock);
>> +}
>> +
>> +static void inline vhost_vq_access_map_end(struct vhost_virtqueue *vq=
)
>> +{
>> +	spin_unlock(&vq->mmu_lock);
>> +}
>> +
>> +static int vhost_invalidate_vq_start(struct vhost_virtqueue *vq,
>> +				     int index,
>> +				     unsigned long start,
>> +				     unsigned long end,
>> +				     bool blockable)
>> +{
>> +	struct vhost_uaddr *uaddr =3D &vq->uaddrs[index];
>> +	struct vhost_map *map;
>> +
>> +	if (!vhost_map_range_overlap(uaddr, start, end))
>> +		return 0;
>> +	else if (!blockable)
>> +		return -EAGAIN;
>> +
>> +	spin_lock(&vq->mmu_lock);
>> +	++vq->invalidate_count;
>> +
>> +	map =3D vq->maps[index];
>> +	if (map)
>> +		vq->maps[index] =3D NULL;
>> +	spin_unlock(&vq->mmu_lock);
>> +
>> +	if (map) {
>> +		vhost_set_map_dirty(vq, map, index);
>> +		vhost_map_unprefetch(map);
>> +	}
>> +
>> +	return 0;
>> +}
>> +
>> +static void vhost_invalidate_vq_end(struct vhost_virtqueue *vq,
>> +				    int index,
>> +				    unsigned long start,
>> +				    unsigned long end)
>> +{
>> +	if (!vhost_map_range_overlap(&vq->uaddrs[index], start, end))
>> +		return;
>> +
>> +	spin_lock(&vq->mmu_lock);
>> +	--vq->invalidate_count;
>> +	spin_unlock(&vq->mmu_lock);
>> +}
>> +
>> +static int vhost_invalidate_range_start(struct mmu_notifier *mn,
>> +					const struct mmu_notifier_range *range)
>> +{
>> +	struct vhost_dev *dev =3D container_of(mn, struct vhost_dev,
>> +					     mmu_notifier);
>> +	bool blockable =3D mmu_notifier_range_blockable(range);
>> +	int i, j, ret;
>> +
>> +	for (i =3D 0; i < dev->nvqs; i++) {
>> +		struct vhost_virtqueue *vq =3D dev->vqs[i];
>> +
>> +		for (j =3D 0; j < VHOST_NUM_ADDRS; j++) {
>> +			ret =3D vhost_invalidate_vq_start(vq, j,
>> +							range->start,
>> +							range->end, blockable);
>> +			if (ret)
>> +				return ret;
>> +		}
>> +	}
>> +
>> +	return 0;
>> +}
>> +
>> +static void vhost_invalidate_range_end(struct mmu_notifier *mn,
>> +				       const struct mmu_notifier_range *range)
>> +{
>> +	struct vhost_dev *dev =3D container_of(mn, struct vhost_dev,
>> +					     mmu_notifier);
>> +	int i, j;
>> +
>> +	for (i =3D 0; i < dev->nvqs; i++) {
>> +		struct vhost_virtqueue *vq =3D dev->vqs[i];
>> +
>> +		for (j =3D 0; j < VHOST_NUM_ADDRS; j++)
>> +			vhost_invalidate_vq_end(vq, j,
>> +						range->start,
>> +						range->end);
>> +	}
>> +}
>> +
>> +static const struct mmu_notifier_ops vhost_mmu_notifier_ops =3D {
>> +	.invalidate_range_start =3D vhost_invalidate_range_start,
>> +	.invalidate_range_end =3D vhost_invalidate_range_end,
>> +};
>> +
>> +static void vhost_init_maps(struct vhost_dev *dev)
>> +{
>> +	struct vhost_virtqueue *vq;
>> +	int i, j;
>> +
>> +	dev->mmu_notifier.ops =3D &vhost_mmu_notifier_ops;
>> +
>> +	for (i =3D 0; i < dev->nvqs; ++i) {
>> +		vq =3D dev->vqs[i];
>> +		for (j =3D 0; j < VHOST_NUM_ADDRS; j++)
>> +			vq->maps[j] =3D NULL;
>> +	}
>> +}
>> +#endif
>> +
>>   static void vhost_vq_reset(struct vhost_dev *dev,
>>   			   struct vhost_virtqueue *vq)
>>   {
>> @@ -326,7 +502,11 @@ static void vhost_vq_reset(struct vhost_dev *dev,
>>   	vq->busyloop_timeout =3D 0;
>>   	vq->umem =3D NULL;
>>   	vq->iotlb =3D NULL;
>> +	vq->invalidate_count =3D 0;
>>   	__vhost_vq_meta_reset(vq);
>> +#if VHOST_ARCH_CAN_ACCEL_UACCESS
>> +	vhost_reset_vq_maps(vq);
>> +#endif
>>   }
>>  =20
>>   static int vhost_worker(void *data)
>> @@ -471,12 +651,15 @@ void vhost_dev_init(struct vhost_dev *dev,
>>   	dev->iov_limit =3D iov_limit;
>>   	dev->weight =3D weight;
>>   	dev->byte_weight =3D byte_weight;
>> +	dev->has_notifier =3D false;
>>   	init_llist_head(&dev->work_list);
>>   	init_waitqueue_head(&dev->wait);
>>   	INIT_LIST_HEAD(&dev->read_list);
>>   	INIT_LIST_HEAD(&dev->pending_list);
>>   	spin_lock_init(&dev->iotlb_lock);
>> -
>> +#if VHOST_ARCH_CAN_ACCEL_UACCESS
>> +	vhost_init_maps(dev);
>> +#endif
>>  =20
>>   	for (i =3D 0; i < dev->nvqs; ++i) {
>>   		vq =3D dev->vqs[i];
>> @@ -485,6 +668,7 @@ void vhost_dev_init(struct vhost_dev *dev,
>>   		vq->heads =3D NULL;
>>   		vq->dev =3D dev;
>>   		mutex_init(&vq->mutex);
>> +		spin_lock_init(&vq->mmu_lock);
>>   		vhost_vq_reset(dev, vq);
>>   		if (vq->handle_kick)
>>   			vhost_poll_init(&vq->poll, vq->handle_kick,
>> @@ -564,7 +748,19 @@ long vhost_dev_set_owner(struct vhost_dev *dev)
>>   	if (err)
>>   		goto err_cgroup;
>>  =20
>> +#if VHOST_ARCH_CAN_ACCEL_UACCESS
>> +	err =3D mmu_notifier_register(&dev->mmu_notifier, dev->mm);
>> +	if (err)
>> +		goto err_mmu_notifier;
>> +#endif
>> +	dev->has_notifier =3D true;
>> +
>>   	return 0;
>> +
>> +#if VHOST_ARCH_CAN_ACCEL_UACCESS
>> +err_mmu_notifier:
>> +	vhost_dev_free_iovecs(dev);
>> +#endif
>>   err_cgroup:
>>   	kthread_stop(worker);
>>   	dev->worker =3D NULL;
>> @@ -655,6 +851,107 @@ static void vhost_clear_msg(struct vhost_dev *de=
v)
>>   	spin_unlock(&dev->iotlb_lock);
>>   }
>>  =20
>> +#if VHOST_ARCH_CAN_ACCEL_UACCESS
>> +static void vhost_setup_uaddr(struct vhost_virtqueue *vq,
>> +			      int index, unsigned long uaddr,
>> +			      size_t size, bool write)
>> +{
>> +	struct vhost_uaddr *addr =3D &vq->uaddrs[index];
>> +
>> +	addr->uaddr =3D uaddr;
>> +	addr->size =3D size;
>> +	addr->write =3D write;
>> +}
>> +
>> +static void vhost_setup_vq_uaddr(struct vhost_virtqueue *vq)
>> +{
>> +	vhost_setup_uaddr(vq, VHOST_ADDR_DESC,
>> +			  (unsigned long)vq->desc,
>> +			  vhost_get_desc_size(vq, vq->num),
>> +			  false);
>> +	vhost_setup_uaddr(vq, VHOST_ADDR_AVAIL,
>> +			  (unsigned long)vq->avail,
>> +			  vhost_get_avail_size(vq, vq->num),
>> +			  false);
>> +	vhost_setup_uaddr(vq, VHOST_ADDR_USED,
>> +			  (unsigned long)vq->used,
>> +			  vhost_get_used_size(vq, vq->num),
>> +			  true);
>> +}
>> +
>> +static int vhost_map_prefetch(struct vhost_virtqueue *vq,
>> +			       int index)
>> +{
>> +	struct vhost_map *map;
>> +	struct vhost_uaddr *uaddr =3D &vq->uaddrs[index];
>> +	struct page **pages;
>> +	int npages =3D DIV_ROUND_UP(uaddr->size, PAGE_SIZE);
>> +	int npinned;
>> +	void *vaddr, *v;
>> +	int err;
>> +	int i;
>> +
>> +	spin_lock(&vq->mmu_lock);
>> +
>> +	err =3D -EFAULT;
>> +	if (vq->invalidate_count)
>> +		goto err;
>> +
>> +	err =3D -ENOMEM;
>> +	map =3D kmalloc(sizeof(*map), GFP_ATOMIC);
>> +	if (!map)
>> +		goto err;
>> +
>> +	pages =3D kmalloc_array(npages, sizeof(struct page *), GFP_ATOMIC);
>> +	if (!pages)
>> +		goto err_pages;
>> +
>> +	err =3D EFAULT;
>> +	npinned =3D __get_user_pages_fast(uaddr->uaddr, npages,
>> +					uaddr->write, pages);
>> +	if (npinned > 0)
>> +		release_pages(pages, npinned);
>> +	if (npinned !=3D npages)
>> +		goto err_gup;
>> +
>> +	for (i =3D 0; i < npinned; i++)
>> +		if (PageHighMem(pages[i]))
>> +			goto err_gup;
>> +
>> +	vaddr =3D v =3D page_address(pages[0]);
>> +
>> +	/* For simplicity, fallback to userspace address if VA is not
>> +	 * contigious.
>> +	 */
>> +	for (i =3D 1; i < npinned; i++) {
>> +		v +=3D PAGE_SIZE;
>> +		if (v !=3D page_address(pages[i]))
>> +			goto err_gup;
>> +	}
>> +
>> +	map->addr =3D vaddr + (uaddr->uaddr & (PAGE_SIZE - 1));
>> +	map->npages =3D npages;
>> +	map->pages =3D pages;
>> +
>> +	vq->maps[index] =3D map;
>> +	/* No need for a synchronize_rcu(). This function should be
>> +	 * called by dev->worker so we are serialized with all
>> +	 * readers.
>> +	 */
>> +	spin_unlock(&vq->mmu_lock);
>> +
>> +	return 0;
>> +
>> +err_gup:
>> +	kfree(pages);
>> +err_pages:
>> +	kfree(map);
>> +err:
>> +	spin_unlock(&vq->mmu_lock);
>> +	return err;
>> +}
>> +#endif
>> +
>>   void vhost_dev_cleanup(struct vhost_dev *dev)
>>   {
>>   	int i;
>> @@ -684,8 +981,20 @@ void vhost_dev_cleanup(struct vhost_dev *dev)
>>   		kthread_stop(dev->worker);
>>   		dev->worker =3D NULL;
>>   	}
>> -	if (dev->mm)
>> +	if (dev->mm) {
>> +#if VHOST_ARCH_CAN_ACCEL_UACCESS
>> +		if (dev->has_notifier) {
>> +			mmu_notifier_unregister(&dev->mmu_notifier,
>> +						dev->mm);
>> +			dev->has_notifier =3D false;
>> +		}
>> +#endif
>>   		mmput(dev->mm);
>> +	}
>> +#if VHOST_ARCH_CAN_ACCEL_UACCESS
>> +	for (i =3D 0; i < dev->nvqs; i++)
>> +		vhost_uninit_vq_maps(dev->vqs[i]);
>> +#endif
>>   	dev->mm =3D NULL;
>>   }
>>   EXPORT_SYMBOL_GPL(vhost_dev_cleanup);
>> @@ -914,6 +1223,26 @@ static inline void __user *__vhost_get_user(stru=
ct vhost_virtqueue *vq,
>>  =20
>>   static inline int vhost_put_avail_event(struct vhost_virtqueue *vq)
>>   {
>> +#if VHOST_ARCH_CAN_ACCEL_UACCESS
>> +	struct vhost_map *map;
>> +	struct vring_used *used;
>> +
>> +	if (!vq->iotlb) {
>> +		vhost_vq_access_map_begin(vq);
>> +
>> +		map =3D vq->maps[VHOST_ADDR_USED];
>> +		if (likely(map)) {
>> +			used =3D map->addr;
>> +			*((__virtio16 *)&used->ring[vq->num]) =3D
>> +				cpu_to_vhost16(vq, vq->avail_idx);
>> +			vhost_vq_access_map_end(vq);
>> +			return 0;
>> +		}
>> +
>> +		vhost_vq_access_map_end(vq);
>> +	}
>> +#endif
>> +
>>   	return vhost_put_user(vq, cpu_to_vhost16(vq, vq->avail_idx),
>>   			      vhost_avail_event(vq));
>>   }
>> @@ -922,6 +1251,27 @@ static inline int vhost_put_used(struct vhost_vi=
rtqueue *vq,
>>   				 struct vring_used_elem *head, int idx,
>>   				 int count)
>>   {
>> +#if VHOST_ARCH_CAN_ACCEL_UACCESS
>> +	struct vhost_map *map;
>> +	struct vring_used *used;
>> +	size_t size;
>> +
>> +	if (!vq->iotlb) {
>> +		vhost_vq_access_map_begin(vq);
>> +
>> +		map =3D vq->maps[VHOST_ADDR_USED];
>> +		if (likely(map)) {
>> +			used =3D map->addr;
>> +			size =3D count * sizeof(*head);
>> +			memcpy(used->ring + idx, head, size);
>> +			vhost_vq_access_map_end(vq);
>> +			return 0;
>> +		}
>> +
>> +		vhost_vq_access_map_end(vq);
>> +	}
>> +#endif
>> +
>>   	return vhost_copy_to_user(vq, vq->used->ring + idx, head,
>>   				  count * sizeof(*head));
>>   }
>> @@ -929,6 +1279,25 @@ static inline int vhost_put_used(struct vhost_vi=
rtqueue *vq,
>>   static inline int vhost_put_used_flags(struct vhost_virtqueue *vq)
>>  =20
>>   {
>> +#if VHOST_ARCH_CAN_ACCEL_UACCESS
>> +	struct vhost_map *map;
>> +	struct vring_used *used;
>> +
>> +	if (!vq->iotlb) {
>> +		vhost_vq_access_map_begin(vq);
>> +
>> +		map =3D vq->maps[VHOST_ADDR_USED];
>> +		if (likely(map)) {
>> +			used =3D map->addr;
>> +			used->flags =3D cpu_to_vhost16(vq, vq->used_flags);
>> +			vhost_vq_access_map_end(vq);
>> +			return 0;
>> +		}
>> +
>> +		vhost_vq_access_map_end(vq);
>> +	}
>> +#endif
>> +
>>   	return vhost_put_user(vq, cpu_to_vhost16(vq, vq->used_flags),
>>   			      &vq->used->flags);
>>   }
>> @@ -936,6 +1305,25 @@ static inline int vhost_put_used_flags(struct vh=
ost_virtqueue *vq)
>>   static inline int vhost_put_used_idx(struct vhost_virtqueue *vq)
>>  =20
>>   {
>> +#if VHOST_ARCH_CAN_ACCEL_UACCESS
>> +	struct vhost_map *map;
>> +	struct vring_used *used;
>> +
>> +	if (!vq->iotlb) {
>> +		vhost_vq_access_map_begin(vq);
>> +
>> +		map =3D vq->maps[VHOST_ADDR_USED];
>> +		if (likely(map)) {
>> +			used =3D map->addr;
>> +			used->idx =3D cpu_to_vhost16(vq, vq->last_used_idx);
>> +			vhost_vq_access_map_end(vq);
>> +			return 0;
>> +		}
>> +
>> +		vhost_vq_access_map_end(vq);
>> +	}
>> +#endif
>> +
>>   	return vhost_put_user(vq, cpu_to_vhost16(vq, vq->last_used_idx),
>>   			      &vq->used->idx);
>>   }
>> @@ -981,12 +1369,50 @@ static void vhost_dev_unlock_vqs(struct vhost_d=
ev *d)
>>   static inline int vhost_get_avail_idx(struct vhost_virtqueue *vq,
>>   				      __virtio16 *idx)
>>   {
>> +#if VHOST_ARCH_CAN_ACCEL_UACCESS
>> +	struct vhost_map *map;
>> +	struct vring_avail *avail;
>> +
>> +	if (!vq->iotlb) {
>> +		vhost_vq_access_map_begin(vq);
>> +
>> +		map =3D vq->maps[VHOST_ADDR_AVAIL];
>> +		if (likely(map)) {
>> +			avail =3D map->addr;
>> +			*idx =3D avail->idx;
> index can now be speculated.

[...]


> +		vhost_vq_access_map_begin(vq);
> +
> +		map =3D vq->maps[VHOST_ADDR_AVAIL];
> +		if (likely(map)) {
> +			avail =3D map->addr;
> +			*head =3D avail->ring[idx & (vq->num - 1)];
>
> Since idx can be speculated, I guess we need array_index_nospec here?


So we have

ACQUIRE(mmu_lock)

get idx

RELEASE(mmu_lock)

ACQUIRE(mmu_lock)

read array[idx]

RELEASE(mmu_lock)

Then I think idx can't be speculated consider we've passed RELEASE +=20
ACQUIRE?


>
>
>> +			vhost_vq_access_map_end(vq);
>> +			return 0;
>> +		}
>> +
>> +		vhost_vq_access_map_end(vq);
>> +	}
>> +#endif
>> +
>>   	return vhost_get_avail(vq, *head,
>>   			       &vq->avail->ring[idx & (vq->num - 1)]);
>>   }
>> @@ -994,24 +1420,98 @@ static inline int vhost_get_avail_head(struct v=
host_virtqueue *vq,
>>   static inline int vhost_get_avail_flags(struct vhost_virtqueue *vq,
>>   					__virtio16 *flags)
>>   {
>> +#if VHOST_ARCH_CAN_ACCEL_UACCESS
>> +	struct vhost_map *map;
>> +	struct vring_avail *avail;
>> +
>> +	if (!vq->iotlb) {
>> +		vhost_vq_access_map_begin(vq);
>> +
>> +		map =3D vq->maps[VHOST_ADDR_AVAIL];
>> +		if (likely(map)) {
>> +			avail =3D map->addr;
>> +			*flags =3D avail->flags;
>> +			vhost_vq_access_map_end(vq);
>> +			return 0;
>> +		}
>> +
>> +		vhost_vq_access_map_end(vq);
>> +	}
>> +#endif
>> +
>>   	return vhost_get_avail(vq, *flags, &vq->avail->flags);
>>   }
>>  =20
>>   static inline int vhost_get_used_event(struct vhost_virtqueue *vq,
>>   				       __virtio16 *event)
>>   {
>> +#if VHOST_ARCH_CAN_ACCEL_UACCESS
>> +	struct vhost_map *map;
>> +	struct vring_avail *avail;
>> +
>> +	if (!vq->iotlb) {
>> +		vhost_vq_access_map_begin(vq);
>> +		map =3D vq->maps[VHOST_ADDR_AVAIL];
>> +		if (likely(map)) {
>> +			avail =3D map->addr;
>> +			*event =3D (__virtio16)avail->ring[vq->num];
>> +			vhost_vq_access_map_end(vq);
>> +			return 0;
>> +		}
>> +		vhost_vq_access_map_end(vq);
>> +	}
>> +#endif
>> +
>>   	return vhost_get_avail(vq, *event, vhost_used_event(vq));
>>   }
>>  =20
>>   static inline int vhost_get_used_idx(struct vhost_virtqueue *vq,
>>   				     __virtio16 *idx)
>>   {
>> +#if VHOST_ARCH_CAN_ACCEL_UACCESS
>> +	struct vhost_map *map;
>> +	struct vring_used *used;
>> +
>> +	if (!vq->iotlb) {
>> +		vhost_vq_access_map_begin(vq);
>> +
>> +		map =3D vq->maps[VHOST_ADDR_USED];
>> +		if (likely(map)) {
>> +			used =3D map->addr;
>> +			*idx =3D used->idx;
>> +			vhost_vq_access_map_end(vq);
>> +			return 0;
>> +		}
>> +
>> +		vhost_vq_access_map_end(vq);
>> +	}
>> +#endif
>> +
>>   	return vhost_get_used(vq, *idx, &vq->used->idx);
>>   }
>
> This seems to be used during init. Why do we bother
> accelerating this?


Ok, I can remove this part in next version.


>
>
>>  =20
>>   static inline int vhost_get_desc(struct vhost_virtqueue *vq,
>>   				 struct vring_desc *desc, int idx)
>>   {
>> +#if VHOST_ARCH_CAN_ACCEL_UACCESS
>> +	struct vhost_map *map;
>> +	struct vring_desc *d;
>> +
>> +	if (!vq->iotlb) {
>> +		vhost_vq_access_map_begin(vq);
>> +
>> +		map =3D vq->maps[VHOST_ADDR_DESC];
>> +		if (likely(map)) {
>> +			d =3D map->addr;
>> +			*desc =3D *(d + idx);
>
> Since idx can be speculated, I guess we need array_index_nospec here?


This is similar to the above avail idx case.


>
>
>> +			vhost_vq_access_map_end(vq);
>> +			return 0;
>> +		}
>> +
>> +		vhost_vq_access_map_end(vq);
>> +	}
>> +#endif
>> +
>>   	return vhost_copy_from_user(vq, desc, vq->desc + idx, sizeof(*desc)=
);
>>   }
>>  =20
> I also wonder about the userspace address we get eventualy.
> It would seem that we need to prevent that from speculating -
> and that seems like a good idea even if this patch isn't
> applied. As you are playing with micro-benchmarks, maybe
> you could the below patch?


Let me test it.

Thanks


> It's unfortunately untested.
> Thanks a lot in advance!
>
> =3D=3D=3D>
> vhost: block speculation of translated descriptors
>
> iovec addresses coming from vhost are assumed to be
> pre-validated, but in fact can be speculated to a value
> out of range.
>
> Userspace address are later validated with array_index_nospec so we can
> be sure kernel info does not leak through these addresses, but vhost
> must also not leak userspace info outside the allowed memory table to
> guests.
>
> Following the defence in depth principle, make sure
> the address is not validated out of node range.
>
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
>
> ---
>
>
> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> index 5dc174ac8cac..863e25011ef6 100644
> --- a/drivers/vhost/vhost.c
> +++ b/drivers/vhost/vhost.c
> @@ -2072,7 +2076,9 @@ static int translate_desc(struct vhost_virtqueue =
*vq, u64 addr, u32 len,
>   		size =3D node->size - addr + node->start;
>   		_iov->iov_len =3D min((u64)len - s, size);
>   		_iov->iov_base =3D (void __user *)(unsigned long)
> -			(node->userspace_addr + addr - node->start);
> +			(node->userspace_addr +
> +			 array_index_nospec(addr - node->start,
> +					    node->size));
>   		s +=3D size;
>   		addr +=3D size;
>   		++ret;

