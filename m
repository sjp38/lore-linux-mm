Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 470E66B0038
	for <linux-mm@kvack.org>; Fri, 14 Apr 2017 04:36:15 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id m28so46633923pgn.14
        for <linux-mm@kvack.org>; Fri, 14 Apr 2017 01:36:15 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id x142si1197383pgx.284.2017.04.14.01.36.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Apr 2017 01:36:13 -0700 (PDT)
Message-ID: <58F08A60.2020407@intel.com>
Date: Fri, 14 Apr 2017 16:37:52 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [virtio-dev] Re: [PATCH v9 2/5] virtio-balloon: VIRTIO_BALLOON_F_BALLOON_CHUNKS
References: <1492076108-117229-1-git-send-email-wei.w.wang@intel.com> <1492076108-117229-3-git-send-email-wei.w.wang@intel.com> <20170413184040-mutt-send-email-mst@kernel.org>
In-Reply-To: <20170413184040-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, david@redhat.com, dave.hansen@intel.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com

On 04/14/2017 12:34 AM, Michael S. Tsirkin wrote:
> On Thu, Apr 13, 2017 at 05:35:05PM +0800, Wei Wang wrote:
>
> So we don't need the bitmap to talk to host, it is just
> a data structure we chose to maintain lists of pages, right?
Right. bitmap is the way to gather pages to chunk.
It's only needed in the balloon page case.
For the unused page case, we don't need it, since the free
page blocks are already chunks.

> OK as far as it goes but you need much better isolation for it.
> Build a data structure with APIs such as _init, _cleanup, _add, _clear,
> _find_first, _find_next.
> Completely unrelated to pages, it just maintains bits.
> Then use it here.
>
>
>>   static int oom_pages = OOM_VBALLOON_DEFAULT_PAGES;
>>   module_param(oom_pages, int, S_IRUSR | S_IWUSR);
>>   MODULE_PARM_DESC(oom_pages, "pages to free on OOM");
>> @@ -50,6 +54,10 @@ MODULE_PARM_DESC(oom_pages, "pages to free on OOM");
>>   static struct vfsmount *balloon_mnt;
>>   #endif
>>   
>> +/* Types of pages to chunk */
>> +#define PAGE_CHUNK_TYPE_BALLOON 0
>> +
> Doesn't look like you are ever adding more types in this
> patchset.  Pls keep code simple, generalize it later.
>
"#define PAGE_CHUNK_TYPE_UNUSED 1" is added in another patch.

Types of page to chunk are treated differently. Different types of page
chunks are sent to the host via different protocols.

1) PAGE_CHUNK_TYPE_BALLOON: Ballooned (i.e. inflated/deflated) pages
to chunk.  For the ballooned type, it uses the basic chunk msg format:

virtio_balloon_page_chunk_hdr +
virtio_balloon_page_chunk * MAX_PAGE_CHUNKS

2) PAGE_CHUNK_TYPE_UNUSED: unused pages to chunk. It uses this miscq msg
format:
miscq_hdr +
virtio_balloon_page_chunk_hdr +
virtio_balloon_page_chunk * MAX_PAGE_CHUNKS

The chunk msg is actually the payload of the miscq msg.



>> +#define MAX_PAGE_CHUNKS 4096
> This is an order-4 allocation. I'd make it 4095 and then it's
> an order-3 one.

Sounds good, thanks.
I think it would be better to make it 4090. Leave some space for the hdr
as well.

>
>>   struct virtio_balloon {
>>   	struct virtio_device *vdev;
>>   	struct virtqueue *inflate_vq, *deflate_vq, *stats_vq;
>> @@ -78,6 +86,32 @@ struct virtio_balloon {
>>   	/* Synchronize access/update to this struct virtio_balloon elements */
>>   	struct mutex balloon_lock;
>>   
>> +	/*
>> +	 * Buffer for PAGE_CHUNK_TYPE_BALLOON:
>> +	 * virtio_balloon_page_chunk_hdr +
>> +	 * virtio_balloon_page_chunk * MAX_PAGE_CHUNKS
>> +	 */
>> +	struct virtio_balloon_page_chunk_hdr *balloon_page_chunk_hdr;
>> +	struct virtio_balloon_page_chunk *balloon_page_chunk;
>> +
>> +	/* Bitmap used to record pages */
>> +	unsigned long *page_bmap[PAGE_BMAP_COUNT_MAX];
>> +	/* Number of the allocated page_bmap */
>> +	unsigned int page_bmaps;
>> +
>> +	/*
>> +	 * The allocated page_bmap size may be smaller than the pfn range of
>> +	 * the ballooned pages. In this case, we need to use the page_bmap
>> +	 * multiple times to cover the entire pfn range. It's like using a
>> +	 * short ruler several times to finish measuring a long object.
>> +	 * The start location of the ruler in the next measurement is the end
>> +	 * location of the ruler in the previous measurement.
>> +	 *
>> +	 * pfn_max & pfn_min: forms the pfn range of the ballooned pages
>> +	 * pfn_start & pfn_stop: records the start and stop pfn in each cover
> cover? what does this mean?
>
> looks like you only use these to pass data to tell_host.
> so pass these as parameters and you won't need to keep
> them in this structure.
>
> And then you can move this comment to set_page_bmap where
> it belongs.
>
>> +	 */
>> +	unsigned long pfn_min, pfn_max, pfn_start, pfn_stop;
>> +
>>   	/* The array of pfns we tell the Host about. */
>>   	unsigned int num_pfns;
>>   	__virtio32 pfns[VIRTIO_BALLOON_ARRAY_PFNS_MAX];
>> @@ -110,20 +144,201 @@ static void balloon_ack(struct virtqueue *vq)
>>   	wake_up(&vb->acked);
>>   }
>>   
>> -static void tell_host(struct virtio_balloon *vb, struct virtqueue *vq)
>> +static inline void init_page_bmap_range(struct virtio_balloon *vb)
>> +{
>> +	vb->pfn_min = ULONG_MAX;
>> +	vb->pfn_max = 0;
>> +}
>> +
>> +static inline void update_page_bmap_range(struct virtio_balloon *vb,
>> +					  struct page *page)
>> +{
>> +	unsigned long balloon_pfn = page_to_balloon_pfn(page);
>> +
>> +	vb->pfn_min = min(balloon_pfn, vb->pfn_min);
>> +	vb->pfn_max = max(balloon_pfn, vb->pfn_max);
>> +}
>> +
>> +/* The page_bmap size is extended by adding more number of page_bmap */
> did you mean
>
> 	Allocate more bitmaps to cover the given number of pfns
> 	and add them to page_bmap
>
> ?
>
> This isn't what this function does.
> It blindly assumes 1 bitmap is allocated
> and allocates more, up to PAGE_BMAP_COUNT_MAX.
>

Please let me use a concrete analogy to explain this algorithm:
We have a 2-meter long ruler (i.e. page_bmap[0]).

Case 1:
To measure a  1-meter long object (i.e. pfn_max=1, pfn_min=0),
we can simply use the ruler once and get to know that the object
is 1-meter long.

Case 2:
To measure a 11-meter long object (i.e. pfn_max=11, pfn_min=0).
We will first see if we can extend the 2-meter long ruler, for example,
to 12-meter by getting another five 2-meter rulers and combine them
(i.e. extend_page_bmap_size() to allocate page_bmap[1],
page_bmap[2]...page_bmap[5]).
Case 2.1: If the length of the ruler is successfully extended to
                 12-meter, that is, we get a 12-meter long ruler, then we
                 can simply use the ruler once and know the length of the
                 object is 11-meter.
Case 2.2: If the ruler failed to be extended. Then we need to use the
                 2-meter long ruler 6 times to measure the 11-meter long
                 object:
                 1st time: pfn_start=0, pfn_stop=2;
                 2nd time: pfn_start=2, pfn_stop=4;
                 ..
                 6th time: pfn_start=10, pfn_stop=11
                 Still, we covered the entire length of the long object 
with the
                 short ruler that we have. But we used it 6 times (i.e. use
                 page_bmap[0], 6 times).

Based on the understanding of this analogy, I think the following
questions would be easier to understand.

>> +static void extend_page_bmap_size(struct virtio_balloon *vb,
>> +				  unsigned long pfns)
>> +{
>> +	int i, bmaps;
>> +	unsigned long bmap_len;
>> +
>> +	bmap_len = ALIGN(pfns, BITS_PER_LONG) / BITS_PER_BYTE;
>> +	bmap_len = ALIGN(bmap_len, PAGE_BMAP_SIZE);
> Align? PAGE_BMAP_SIZE doesn't even have to be a power of 2 ...

ThoughPAGE_BMAP_SIZE has been set to 32K in the implementation,
would you prefer to use roundup() here?


>> +	bmaps = min((int)(bmap_len / PAGE_BMAP_SIZE),
>> +		    PAGE_BMAP_COUNT_MAX);
> I got lost here.
>
> Please use things like ARRAY_SIZE instead of macros.

PAGE_BMAP_COUNT_MAX is the total amount of page_bmap[] that is
allowed to be allocated on demand. It is 32 in the implementation.

For example, if the calculation shows that it needs 100 page_bmap[],
but we can only afford 32, so use 32 for bmaps, instead of 100. The
the following implementation go through Case 2.2.



>> +
>> +	for (i = 1; i < bmaps; i++) {
>> +		vb->page_bmap[i] = kmalloc(PAGE_BMAP_SIZE, GFP_KERNEL);
>> +		if (vb->page_bmap[i])
>> +			vb->page_bmaps++;
>> +		else
>> +			break;
>> +	}
>> +}
>> +
>> +static void free_extended_page_bmap(struct virtio_balloon *vb)
>> +{
>> +	int i, bmaps = vb->page_bmaps;
>> +
>> +	for (i = 1; i < bmaps; i++) {
>> +		kfree(vb->page_bmap[i]);
>> +		vb->page_bmap[i] = NULL;
>> +		vb->page_bmaps--;
>> +	}
>> +}
>> +
> What's the magic number 1 here?
> Maybe you want to document what is going on.
> Here's a guess:
>
> We keep a single bmap around at all times.
> If memory does not fit there, we allocate up to
> PAGE_BMAP_COUNT_MAX of chunks.
>

Right. By default, we have only 1 page_bmap[] allocated.


>> +static void free_page_bmap(struct virtio_balloon *vb)
>> +{
>> +	int i;
>> +
>> +	for (i = 0; i < vb->page_bmaps; i++)
>> +		kfree(vb->page_bmap[i]);
>> +}
>> +
>> +static void clear_page_bmap(struct virtio_balloon *vb)
>> +{
>> +	int i;
>> +
>> +	for (i = 0; i < vb->page_bmaps; i++)
>> +		memset(vb->page_bmap[i], 0, PAGE_BMAP_SIZE);
>> +}
>> +
>> +static void send_page_chunks(struct virtio_balloon *vb, struct virtqueue *vq,
>> +			     int type, bool busy_wait)
> busy_wait seems unused. pls drop.

It will be used in the other patch (the 5th patch) for sending unused pages.
Probably I can add it from that patch.

>
>>   {
>>   	struct scatterlist sg;
>> +	struct virtio_balloon_page_chunk_hdr *hdr;
>> +	void *buf;
>>   	unsigned int len;
>>   
>> -	sg_init_one(&sg, vb->pfns, sizeof(vb->pfns[0]) * vb->num_pfns);
>> +	switch (type) {
>> +	case PAGE_CHUNK_TYPE_BALLOON:
>> +		hdr = vb->balloon_page_chunk_hdr;
>> +		len = 0;
>> +		break;
>> +	default:
>> +		dev_warn(&vb->vdev->dev, "%s: chunk %d of unknown pages\n",
>> +			 __func__, type);
>> +		return;
>> +	}
>>   
>> -	/* We should always be able to add one buffer to an empty queue. */
>> -	virtqueue_add_outbuf(vq, &sg, 1, vb, GFP_KERNEL);
>> -	virtqueue_kick(vq);
>> +	buf = (void *)hdr - len;
> Moving back to before the header? How can this make sense?
> It works fine since len is 0, so just buf = hdr.
>
For the unused page chunk case, it follows its own protocol:
miscq_hdr + payload(chunk msg).
  "buf = (void *)hdr - len" moves the buf pointer to the miscq_hdr, to send
the entire miscq msg.

Please check the patch for implementing the unused page chunk,
it will be clear. If necessary, I can put "buf = (void *)hdr - len" from 
that patch.


>> +	len += sizeof(struct virtio_balloon_page_chunk_hdr);
>> +	len += hdr->chunks * sizeof(struct virtio_balloon_page_chunk);
>> +	sg_init_table(&sg, 1);
>> +	sg_set_buf(&sg, buf, len);
>> +	if (!virtqueue_add_outbuf(vq, &sg, 1, vb, GFP_KERNEL)) {
>> +		virtqueue_kick(vq);
>> +		if (busy_wait)
>> +			while (!virtqueue_get_buf(vq, &len) &&
>> +			       !virtqueue_is_broken(vq))
>> +				cpu_relax();
>> +		else
>> +			wait_event(vb->acked, virtqueue_get_buf(vq, &len));
>> +		hdr->chunks = 0;
> Why zero it here after device used it? Better to zero before use.

hdr->chunks tells the host how many chunks are there in the payload.
After the device use it, it is ready to zero it.

>
>> +	}
>> +}
>> +
>> +static void add_one_chunk(struct virtio_balloon *vb, struct virtqueue *vq,
>> +			  int type, u64 base, u64 size)
> what are the units here? Looks like it's in 4kbyte units?

what is the "unit" you referred to?
This is the function to add one chunk, base pfn and size of the chunk are
supplied to the function.



>
>> +	if (hdr->chunks == MAX_PAGE_CHUNKS)
>> +		send_page_chunks(vb, vq, type, false);
> 		and zero chunks here?
>> +}
>> +
>> +static void chunking_pages_from_bmap(struct virtio_balloon *vb,
> Does this mean "convert_bmap_to_chunks"?
>

Yes.


>> +				     struct virtqueue *vq,
>> +				     unsigned long pfn_start,
>> +				     unsigned long *bmap,
>> +				     unsigned long len)
>> +{
>> +	unsigned long pos = 0, end = len * BITS_PER_BYTE;
>> +
>> +	while (pos < end) {
>> +		unsigned long one = find_next_bit(bmap, end, pos);
>> +
>> +		if (one < end) {
>> +			unsigned long chunk_size, zero;
>> +
>> +			zero = find_next_zero_bit(bmap, end, one + 1);
>
> zero and one are unhelpful names unless they equal 0 and 1.
> current/next?
>

I think it is clear if we think about the bitmap, for example:
00001111000011110000
one = the position of the next "1" bit,
zero= the position of the next "0" bit, starting from one.

Then, it is clear, chunk_size= zero - one

would it be better to use pos_0 and pos_1?

>> +			if (zero >= end)
>> +				chunk_size = end - one;
>> +			else
>> +				chunk_size = zero - one;
>> +
>> +			if (chunk_size)
>> +				add_one_chunk(vb, vq, PAGE_CHUNK_TYPE_BALLOON,
>> +					      pfn_start + one, chunk_size);
> Still not so what does a bit refer to? page or 4kbytes?
> I think it should be a page.
A bit in the bitmap corresponds to a pfn of a balloon page(4KB).
But I think it doesn't matter here, since it is pfn.
Using the above example:
00001111000011110000

If the starting bit above corresponds to pfn-0x1000 (i.e. pfn_start)
Then the chunk base = 0x1004
(one is the position of the "Set" bit, which is 4), so pfn_start 
+one=0x1004

>> +static void tell_host(struct virtio_balloon *vb, struct virtqueue *vq)
>> +{
>> +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_BALLOON_CHUNKS)) {
>> +		int pfns, page_bmaps, i;
>> +		unsigned long pfn_start, pfns_len;
>> +
>> +		pfn_start = vb->pfn_start;
>> +		pfns = vb->pfn_stop - pfn_start + 1;
>> +		pfns = roundup(roundup(pfns, BITS_PER_LONG),
>> +			       PFNS_PER_PAGE_BMAP);
>> +		page_bmaps = pfns / PFNS_PER_PAGE_BMAP;
>> +		pfns_len = pfns / BITS_PER_BYTE;
>> +
>> +		for (i = 0; i < page_bmaps; i++) {
>> +			unsigned int bmap_len = PAGE_BMAP_SIZE;
>> +
>> +			/* The last one takes the leftover only */
> I don't understand what does this mean.
Still use the ruler analogy here: the object is 11-meter long, and we have
a 2-meter long ruler. The 5th time has covered 10 meters of the object, Then
the last time, the leftover is 1 meter, which means we can use half of 
the ruler
to cover the left 1 meter.

Back to the implementation here, if there are only 10 pfns left in the 
last round,
I think it's not necessary to search the entire page_bmap[] till the end.

>> +static void set_page_bmap(struct virtio_balloon *vb,
>> +			  struct list_head *pages, struct virtqueue *vq)
>> +{
>> +	unsigned long pfn_start, pfn_stop;
>> +	struct page *page;
>> +	bool found;
>> +
>> +	vb->pfn_min = rounddown(vb->pfn_min, BITS_PER_LONG);
>> +	vb->pfn_max = roundup(vb->pfn_max, BITS_PER_LONG);
>> +
>> +	extend_page_bmap_size(vb, vb->pfn_max - vb->pfn_min + 1);
> This might not do anything in particular might not cover the
> given pfn range. Do we care? Why not?

We have allocated only 1 page_bmap[], which is able to cover 1GB memory.
To inflate 2GB, it will try to extend by getting one more page_bmap, 
page_bmap[1].

>> +	pfn_start = vb->pfn_min;
>> +
>> +	while (pfn_start < vb->pfn_max) {
>> +		pfn_stop = pfn_start + PFNS_PER_PAGE_BMAP * vb->page_bmaps;
>> +		pfn_stop = pfn_stop < vb->pfn_max ? pfn_stop : vb->pfn_max;
>> +
>> +		vb->pfn_start = pfn_start;
>> +		clear_page_bmap(vb);
>> +		found = false;
>> +
>> +		list_for_each_entry(page, pages, lru) {
>> +			unsigned long bmap_idx, bmap_pos, balloon_pfn;
>> +
>> +			balloon_pfn = page_to_balloon_pfn(page);
>> +			if (balloon_pfn < pfn_start || balloon_pfn > pfn_stop)
>> +				continue;
>> +			bmap_idx = (balloon_pfn - pfn_start) /
>> +				   PFNS_PER_PAGE_BMAP;
>> +			bmap_pos = (balloon_pfn - pfn_start) %
>> +				   PFNS_PER_PAGE_BMAP;
>> +			set_bit(bmap_pos, vb->page_bmap[bmap_idx]);
> Looks like this will crash if bmap_idx is out of range or
> if page_bmap allocation failed.

No, it won't. Please think about the analogy Case 2.2: pfn_start is updated
in each round. Like in the 2nd round, pfn_start is updated to 2, balloon_pfn
will be a value between 2 and 4, so the result of
"(balloon_pfn - pfn_start) /  PFNS_PER_PAGE_BMAP" will always be 0 when
we only have page_bmap[0].

>   
>   #ifdef CONFIG_BALLOON_COMPACTION
> +
> +static void tell_host_one_page(struct virtio_balloon *vb,
> +			       struct virtqueue *vq, struct page *page)
> +{
> +	add_one_chunk(vb, vq, PAGE_CHUNK_TYPE_BALLOON, page_to_pfn(page), 1);
> This passes 4kbytes to host which seems wrong - I think you want a full page.

OK. It should be
add_one_chunk(vb, vq, PAGE_CHUNK_TYPE_BALLOON,
                           page_to_pfn(page), VIRTIO_BALLOON_PAGES_PER_PAGE)

right?

If Page=2*BalloonPage, it will pass 2*4K to the host.

+static void balloon_page_chunk_init(struct virtio_balloon *vb)
+{
+	void *buf;
+
+	/*
+	 * By default, we allocate page_bmap[0] only. More page_bmap will be
+	 * allocated on demand.
+	 */
+	vb->page_bmap[0] = kmalloc(PAGE_BMAP_SIZE, GFP_KERNEL);
+	buf = kmalloc(sizeof(struct virtio_balloon_page_chunk_hdr) +
+		      sizeof(struct virtio_balloon_page_chunk) *
+		      MAX_PAGE_CHUNKS, GFP_KERNEL);
+	if (!vb->page_bmap[0] || !buf) {
+		__virtio_clear_bit(vb->vdev, VIRTIO_BALLOON_F_BALLOON_CHUNKS);

> this doesn't work as expected as features has been OK'd by then.
> You want something like
> validate_features that I posted. See
> "virtio: allow drivers to validate features".

OK. I will change it after that patch is merged.

>
>> +		kfree(vb->page_bmap[0]);
> Looks like this will double free. you want to zero them I think.
>

OK. I'll NULL the pointers after kfree().



Best,
Wei



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
