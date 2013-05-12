Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 6C93E6B0033
	for <linux-mm@kvack.org>; Sun, 12 May 2013 12:36:19 -0400 (EDT)
Message-ID: <518FC4F9.5010505@redhat.com>
Date: Sun, 12 May 2013 12:36:09 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC 2/2] virtio_balloon: auto-ballooning support
References: <1368111229-29847-1-git-send-email-lcapitulino@redhat.com> <1368111229-29847-3-git-send-email-lcapitulino@redhat.com> <20130512143054.GI10144@redhat.com>
In-Reply-To: <20130512143054.GI10144@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Luiz Capitulino <lcapitulino@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, aquini@redhat.com, amit.shah@redhat.com, anton@enomsg.org

On 05/12/2013 10:30 AM, Michael S. Tsirkin wrote:
> On Thu, May 09, 2013 at 10:53:49AM -0400, Luiz Capitulino wrote:
>> Automatic ballooning consists of dynamically adjusting the guest's
>> balloon according to memory pressure in the host and in the guest.
>>
>> This commit implements the guest side of automatic balloning, which
>> basically consists of registering a shrinker callback with the kernel,
>> which will try to deflate the guest's balloon by the amount of pages
>> being requested. The shrinker callback is only registered if the host
>> supports the VIRTIO_BALLOON_F_AUTO_BALLOON feature bit.
>
> OK so we have a new feature bit, such that:
> - if AUTO_BALLOON is set in host, guest can leak a
>    page from a balloon at any time
>
> questions left unanswered
> - what meaning does num_pages have now?

"as large as we could go"

> - when will the balloon be re-inflated?

I believe the qemu changes Luiz wrote address that side,
with qemu-kvm getting notifications from the host kernel
when there is memory pressure, and shrinking the guest
in reaction to that notification.

> I'd like to see a spec patch addressing these questions.
>
> Would we ever want to mix the two types of ballooning?
> If yes possibly when we put a page in the balloon we
> might want to give host a hint "this page might be
> leaked again soon".

It might not be the same page, and the host really does
not care which page it is.

The automatic inflation happens when the host needs to
free up memory.

>> Automatic inflate is performed by the host.
>>
>> Here are some numbers. The test-case is to run 35 VMs (1G of RAM each)
>> in parallel doing a kernel build. Host has 32GB of RAM and 16GB of swap.
>> SWAP IN and SWAP OUT correspond to the number of pages swapped in and
>> swapped out, respectively.
>>
>> Auto-ballooning disabled:
>>
>> RUN  TIME(s)  SWAP IN  SWAP OUT
>>
>> 1    634      930980   1588522
>> 2    610      627422   1362174
>> 3    649      1079847  1616367
>> 4    543      953289   1635379
>> 5    642      913237   1514000
>>
>> Auto-ballooning enabled:
>>
>> RUN  TIME(s)  SWAP IN  SWAP OUT
>>
>> 1    629      901      12537
>> 2    624      981      18506
>> 3    626      573      9085
>> 4    631      2250     42534
>> 5    627      1610     20808
>
> So what exactly happens here?
> Much less swap in/out activity, but no gain
> in total runtime. Doesn't this show there's
> a bottleneck somewhere? Could be a problem in
> the implementation?

It could also be an issue with the benchmark chosen,
which may not have swap as its bottleneck at any point.

However, the reduced swapping is still very promising!

> Also, what happened with the balloon?
> Did we end up with balloon completely inflated? deflated?
>
> One question to consider: possibly if we are
> going to reuse the page in the balloon soon,
> we might want to bypass notify before use for it?
> Maybe that will help speed things up.
>
>
>> Signed-off-by: Luiz Capitulino <lcapitulino@redhat.com>
>> ---
>>   drivers/virtio/virtio_balloon.c     | 55 +++++++++++++++++++++++++++++++++++++
>>   include/uapi/linux/virtio_balloon.h |  1 +
>>   2 files changed, 56 insertions(+)
>>
>> diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
>> index 9d5fe2b..f9dcae8 100644
>> --- a/drivers/virtio/virtio_balloon.c
>> +++ b/drivers/virtio/virtio_balloon.c
>> @@ -71,6 +71,9 @@ struct virtio_balloon
>>   	/* Memory statistics */
>>   	int need_stats_update;
>>   	struct virtio_balloon_stat stats[VIRTIO_BALLOON_S_NR];
>> +
>> +	/* Memory shrinker */
>> +	struct shrinker shrinker;
>>   };
>>
>>   static struct virtio_device_id id_table[] = {
>> @@ -126,6 +129,7 @@ static void set_page_pfns(u32 pfns[], struct page *page)
>>   		pfns[i] = page_to_balloon_pfn(page) + i;
>>   }
>>
>> +/* This function should be called with vb->balloon_mutex held */
>>   static void fill_balloon(struct virtio_balloon *vb, size_t num)
>>   {
>>   	struct balloon_dev_info *vb_dev_info = vb->vb_dev_info;
>> @@ -166,6 +170,7 @@ static void release_pages_by_pfn(const u32 pfns[], unsigned int num)
>>   	}
>>   }
>>
>> +/* This function should be called with vb->balloon_mutex held */
>>   static void leak_balloon(struct virtio_balloon *vb, size_t num)
>>   {
>>   	struct page *page;
>> @@ -285,6 +290,45 @@ static void update_balloon_size(struct virtio_balloon *vb)
>>   			      &actual, sizeof(actual));
>>   }
>>
>> +static unsigned long balloon_get_nr_pages(const struct virtio_balloon *vb)
>> +{
>> +	return vb->num_pages / VIRTIO_BALLOON_PAGES_PER_PAGE;
>> +}
>> +
>> +static int balloon_shrinker(struct shrinker *shrinker,struct shrink_control *sc)
>> +{
>> +	unsigned int nr_pages, new_target;
>> +	struct virtio_balloon *vb;
>> +
>> +	vb = container_of(shrinker, struct virtio_balloon, shrinker);
>> +	if (!mutex_trylock(&vb->balloon_lock)) {
>> +		return -1;
>> +	}
>> +
>> +	nr_pages = balloon_get_nr_pages(vb);
>> +	if (!sc->nr_to_scan || !nr_pages) {
>> +		goto out;
>> +	}
>> +
>> +	/*
>> +	 * If the current balloon size is greater than the number of
>> +	 * pages being reclaimed by the kernel, deflate only the needed
>> +	 * amount. Otherwise deflate everything we have.
>> +	 */
>> +	new_target = 0;
>> +	if (nr_pages > sc->nr_to_scan) {
>> +		new_target = nr_pages - sc->nr_to_scan;
>> +	}
>> +
>> +	leak_balloon(vb, new_target);
>> +	update_balloon_size(vb);
>> +	nr_pages = balloon_get_nr_pages(vb);
>> +
>> +out:
>> +	mutex_unlock(&vb->balloon_lock);
>> +	return nr_pages;
>> +}
>> +
>>   static int balloon(void *_vballoon)
>>   {
>>   	struct virtio_balloon *vb = _vballoon;
>> @@ -471,6 +515,13 @@ static int virtballoon_probe(struct virtio_device *vdev)
>>   		goto out_del_vqs;
>>   	}
>>
>> +	memset(&vb->shrinker, 0, sizeof(vb->shrinker));
>> +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_AUTO_BALLOON)) {
>> +		vb->shrinker.shrink = balloon_shrinker;
>> +		vb->shrinker.seeks = DEFAULT_SEEKS;
>> +		register_shrinker(&vb->shrinker);
>> +	}
>> +
>>   	return 0;
>>
>>   out_del_vqs:
>> @@ -487,6 +538,9 @@ out:
>>
>>   static void remove_common(struct virtio_balloon *vb)
>>   {
>> +	if (vb->shrinker.shrink)
>> +		unregister_shrinker(&vb->shrinker);
>> +
>>   	/* There might be pages left in the balloon: free them. */
>>   	mutex_lock(&vb->balloon_lock);
>>   	while (vb->num_pages)
>> @@ -543,6 +597,7 @@ static int virtballoon_restore(struct virtio_device *vdev)
>>   static unsigned int features[] = {
>>   	VIRTIO_BALLOON_F_MUST_TELL_HOST,
>>   	VIRTIO_BALLOON_F_STATS_VQ,
>> +	VIRTIO_BALLOON_F_AUTO_BALLOON,
>>   };
>>
>>   static struct virtio_driver virtio_balloon_driver = {
>> diff --git a/include/uapi/linux/virtio_balloon.h b/include/uapi/linux/virtio_balloon.h
>> index 5e26f61..bd378a4 100644
>> --- a/include/uapi/linux/virtio_balloon.h
>> +++ b/include/uapi/linux/virtio_balloon.h
>> @@ -31,6 +31,7 @@
>>   /* The feature bitmap for virtio balloon */
>>   #define VIRTIO_BALLOON_F_MUST_TELL_HOST	0 /* Tell before reclaiming pages */
>>   #define VIRTIO_BALLOON_F_STATS_VQ	1 /* Memory Stats virtqueue */
>> +#define VIRTIO_BALLOON_F_AUTO_BALLOON	2 /* Automatic ballooning */
>>
>>   /* Size of a PFN in the balloon interface. */
>>   #define VIRTIO_BALLOON_PFN_SHIFT 12
>> --
>> 1.8.1.4


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
