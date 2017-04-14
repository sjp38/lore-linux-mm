Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id EED056B0397
	for <linux-mm@kvack.org>; Fri, 14 Apr 2017 17:38:42 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id i13so25843297qki.16
        for <linux-mm@kvack.org>; Fri, 14 Apr 2017 14:38:42 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g124si2882642qkd.20.2017.04.14.14.38.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Apr 2017 14:38:39 -0700 (PDT)
Date: Sat, 15 Apr 2017 00:38:31 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [virtio-dev] Re: [PATCH v9 2/5] virtio-balloon:
 VIRTIO_BALLOON_F_BALLOON_CHUNKS
Message-ID: <20170415000934-mutt-send-email-mst@kernel.org>
References: <1492076108-117229-1-git-send-email-wei.w.wang@intel.com>
 <1492076108-117229-3-git-send-email-wei.w.wang@intel.com>
 <20170413184040-mutt-send-email-mst@kernel.org>
 <58F08A60.2020407@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <58F08A60.2020407@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, david@redhat.com, dave.hansen@intel.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com

On Fri, Apr 14, 2017 at 04:37:52PM +0800, Wei Wang wrote:
> On 04/14/2017 12:34 AM, Michael S. Tsirkin wrote:
> > On Thu, Apr 13, 2017 at 05:35:05PM +0800, Wei Wang wrote:
> > 
> > So we don't need the bitmap to talk to host, it is just
> > a data structure we chose to maintain lists of pages, right?
> Right. bitmap is the way to gather pages to chunk.
> It's only needed in the balloon page case.
> For the unused page case, we don't need it, since the free
> page blocks are already chunks.
> 
> > OK as far as it goes but you need much better isolation for it.
> > Build a data structure with APIs such as _init, _cleanup, _add, _clear,
> > _find_first, _find_next.
> > Completely unrelated to pages, it just maintains bits.
> > Then use it here.
> > 
> > 
> > >   static int oom_pages = OOM_VBALLOON_DEFAULT_PAGES;
> > >   module_param(oom_pages, int, S_IRUSR | S_IWUSR);
> > >   MODULE_PARM_DESC(oom_pages, "pages to free on OOM");
> > > @@ -50,6 +54,10 @@ MODULE_PARM_DESC(oom_pages, "pages to free on OOM");
> > >   static struct vfsmount *balloon_mnt;
> > >   #endif
> > > +/* Types of pages to chunk */
> > > +#define PAGE_CHUNK_TYPE_BALLOON 0
> > > +
> > Doesn't look like you are ever adding more types in this
> > patchset.  Pls keep code simple, generalize it later.
> > 
> "#define PAGE_CHUNK_TYPE_UNUSED 1" is added in another patch.

I would say add the extra code there too. Or maybe we can avoid
adding it altogether.

> Types of page to chunk are treated differently. Different types of page
> chunks are sent to the host via different protocols.
> 
> 1) PAGE_CHUNK_TYPE_BALLOON: Ballooned (i.e. inflated/deflated) pages
> to chunk.  For the ballooned type, it uses the basic chunk msg format:
> 
> virtio_balloon_page_chunk_hdr +
> virtio_balloon_page_chunk * MAX_PAGE_CHUNKS
> 
> 2) PAGE_CHUNK_TYPE_UNUSED: unused pages to chunk. It uses this miscq msg
> format:
> miscq_hdr +
> virtio_balloon_page_chunk_hdr +
> virtio_balloon_page_chunk * MAX_PAGE_CHUNKS
> 
> The chunk msg is actually the payload of the miscq msg.
> 
> 

So just combine the two message formats and then it'll all be easier?


> > > +#define MAX_PAGE_CHUNKS 4096
> > This is an order-4 allocation. I'd make it 4095 and then it's
> > an order-3 one.
> 
> Sounds good, thanks.
> I think it would be better to make it 4090. Leave some space for the hdr
> as well.

And miscq hdr. In fact just let compiler do the math - something like:
(8 * PAGE_SIZE - sizeof(hdr)) / sizeof(chunk)


I skimmed explanation of algorithms below but please make sure
code speaks for itself and add comments inline to document it.
Whenever you answered me inline this is where you want to
try to make code clearer and add comments.

Also, pls find ways to abstract the data structure so we don't
need to deal with its internals all over the code.


....

> > 
> > >   {
> > >   	struct scatterlist sg;
> > > +	struct virtio_balloon_page_chunk_hdr *hdr;
> > > +	void *buf;
> > >   	unsigned int len;
> > > -	sg_init_one(&sg, vb->pfns, sizeof(vb->pfns[0]) * vb->num_pfns);
> > > +	switch (type) {
> > > +	case PAGE_CHUNK_TYPE_BALLOON:
> > > +		hdr = vb->balloon_page_chunk_hdr;
> > > +		len = 0;
> > > +		break;
> > > +	default:
> > > +		dev_warn(&vb->vdev->dev, "%s: chunk %d of unknown pages\n",
> > > +			 __func__, type);
> > > +		return;
> > > +	}
> > > -	/* We should always be able to add one buffer to an empty queue. */
> > > -	virtqueue_add_outbuf(vq, &sg, 1, vb, GFP_KERNEL);
> > > -	virtqueue_kick(vq);
> > > +	buf = (void *)hdr - len;
> > Moving back to before the header? How can this make sense?
> > It works fine since len is 0, so just buf = hdr.
> > 
> For the unused page chunk case, it follows its own protocol:
> miscq_hdr + payload(chunk msg).
>  "buf = (void *)hdr - len" moves the buf pointer to the miscq_hdr, to send
> the entire miscq msg.

Well just pass the correct pointer in.

> Please check the patch for implementing the unused page chunk,
> it will be clear. If necessary, I can put "buf = (void *)hdr - len" from
> that patch.

Exactly. And all this pointer math is very messy. Please look for ways
to clean it. It's generally easy to fill structures:

struct foo *foo = kmalloc(..., sizeof(*foo) + n * sizeof(foo->a[0]));
for (i = 0; i < n; ++i)
	foo->a[i] = b;

this is the kind of code that's easy to understand and it's
obvious there are no overflows and no info leaks here.

> 
> > > +	len += sizeof(struct virtio_balloon_page_chunk_hdr);
> > > +	len += hdr->chunks * sizeof(struct virtio_balloon_page_chunk);
> > > +	sg_init_table(&sg, 1);
> > > +	sg_set_buf(&sg, buf, len);
> > > +	if (!virtqueue_add_outbuf(vq, &sg, 1, vb, GFP_KERNEL)) {
> > > +		virtqueue_kick(vq);
> > > +		if (busy_wait)
> > > +			while (!virtqueue_get_buf(vq, &len) &&
> > > +			       !virtqueue_is_broken(vq))
> > > +				cpu_relax();
> > > +		else
> > > +			wait_event(vb->acked, virtqueue_get_buf(vq, &len));
> > > +		hdr->chunks = 0;
> > Why zero it here after device used it? Better to zero before use.
> 
> hdr->chunks tells the host how many chunks are there in the payload.
> After the device use it, it is ready to zero it.

It's rather confusing. Try to pass # of chunks around
in some other way.

> > 
> > > +	}
> > > +}
> > > +
> > > +static void add_one_chunk(struct virtio_balloon *vb, struct virtqueue *vq,
> > > +			  int type, u64 base, u64 size)
> > what are the units here? Looks like it's in 4kbyte units?
> 
> what is the "unit" you referred to?
> This is the function to add one chunk, base pfn and size of the chunk are
> supplied to the function.
> 

Are both size and base in bytes then?
But you do not send them to host as is, you shift them for some reason
before sending them to host.


> 
> > 
> > > +	if (hdr->chunks == MAX_PAGE_CHUNKS)
> > > +		send_page_chunks(vb, vq, type, false);
> > 		and zero chunks here?
> > > +}
> > > +
> > > +static void chunking_pages_from_bmap(struct virtio_balloon *vb,
> > Does this mean "convert_bmap_to_chunks"?
> > 
> 
> Yes.
> 

Pls name it accordingly then.

> > > +				     struct virtqueue *vq,
> > > +				     unsigned long pfn_start,
> > > +				     unsigned long *bmap,
> > > +				     unsigned long len)
> > > +{
> > > +	unsigned long pos = 0, end = len * BITS_PER_BYTE;
> > > +
> > > +	while (pos < end) {
> > > +		unsigned long one = find_next_bit(bmap, end, pos);
> > > +
> > > +		if (one < end) {
> > > +			unsigned long chunk_size, zero;
> > > +
> > > +			zero = find_next_zero_bit(bmap, end, one + 1);
> > 
> > zero and one are unhelpful names unless they equal 0 and 1.
> > current/next?
> > 
> 
> I think it is clear if we think about the bitmap, for example:
> 00001111000011110000
> one = the position of the next "1" bit,
> zero= the position of the next "0" bit, starting from one.
> 
> Then, it is clear, chunk_size= zero - one
> 
> would it be better to use pos_0 and pos_1?

Oh, so it's next_zero_bit and next_bit.


> > > +			if (zero >= end)
> > > +				chunk_size = end - one;
> > > +			else
> > > +				chunk_size = zero - one;
> > > +
> > > +			if (chunk_size)
> > > +				add_one_chunk(vb, vq, PAGE_CHUNK_TYPE_BALLOON,
> > > +					      pfn_start + one, chunk_size);
> > Still not so what does a bit refer to? page or 4kbytes?
> > I think it should be a page.
> A bit in the bitmap corresponds to a pfn of a balloon page(4KB).

That's a waste on systems with large page sizes, and it does not
look like you handle that case correctly.


> But I think it doesn't matter here, since it is pfn.
> Using the above example:
> 00001111000011110000
> 
> If the starting bit above corresponds to pfn-0x1000 (i.e. pfn_start)
> Then the chunk base = 0x1004
> (one is the position of the "Set" bit, which is 4), so pfn_start +one=0x1004
> 
> > > +static void tell_host(struct virtio_balloon *vb, struct virtqueue *vq)
> > > +{
> > > +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_BALLOON_CHUNKS)) {
> > > +		int pfns, page_bmaps, i;
> > > +		unsigned long pfn_start, pfns_len;
> > > +
> > > +		pfn_start = vb->pfn_start;
> > > +		pfns = vb->pfn_stop - pfn_start + 1;
> > > +		pfns = roundup(roundup(pfns, BITS_PER_LONG),
> > > +			       PFNS_PER_PAGE_BMAP);
> > > +		page_bmaps = pfns / PFNS_PER_PAGE_BMAP;
> > > +		pfns_len = pfns / BITS_PER_BYTE;
> > > +
> > > +		for (i = 0; i < page_bmaps; i++) {
> > > +			unsigned int bmap_len = PAGE_BMAP_SIZE;
> > > +
> > > +			/* The last one takes the leftover only */
> > I don't understand what does this mean.
> Still use the ruler analogy here: the object is 11-meter long, and we have
> a 2-meter long ruler. The 5th time has covered 10 meters of the object, Then
> the last time, the leftover is 1 meter, which means we can use half of the
> ruler
> to cover the left 1 meter.
> 
> Back to the implementation here, if there are only 10 pfns left in the last
> round,
> I think it's not necessary to search the entire page_bmap[] till the end.


Pls reword the comment to make it a whole sentence.


> > > +static void set_page_bmap(struct virtio_balloon *vb,
> > > +			  struct list_head *pages, struct virtqueue *vq)
> > > +{
> > > +	unsigned long pfn_start, pfn_stop;
> > > +	struct page *page;
> > > +	bool found;
> > > +
> > > +	vb->pfn_min = rounddown(vb->pfn_min, BITS_PER_LONG);
> > > +	vb->pfn_max = roundup(vb->pfn_max, BITS_PER_LONG);
> > > +
> > > +	extend_page_bmap_size(vb, vb->pfn_max - vb->pfn_min + 1);
> > This might not do anything in particular might not cover the
> > given pfn range. Do we care? Why not?
> 
> We have allocated only 1 page_bmap[], which is able to cover 1GB memory.
> To inflate 2GB, it will try to extend by getting one more page_bmap,
> page_bmap[1].
> 
> > > +	pfn_start = vb->pfn_min;
> > > +
> > > +	while (pfn_start < vb->pfn_max) {
> > > +		pfn_stop = pfn_start + PFNS_PER_PAGE_BMAP * vb->page_bmaps;
> > > +		pfn_stop = pfn_stop < vb->pfn_max ? pfn_stop : vb->pfn_max;
> > > +
> > > +		vb->pfn_start = pfn_start;
> > > +		clear_page_bmap(vb);
> > > +		found = false;
> > > +
> > > +		list_for_each_entry(page, pages, lru) {
> > > +			unsigned long bmap_idx, bmap_pos, balloon_pfn;
> > > +
> > > +			balloon_pfn = page_to_balloon_pfn(page);
> > > +			if (balloon_pfn < pfn_start || balloon_pfn > pfn_stop)
> > > +				continue;
> > > +			bmap_idx = (balloon_pfn - pfn_start) /
> > > +				   PFNS_PER_PAGE_BMAP;
> > > +			bmap_pos = (balloon_pfn - pfn_start) %
> > > +				   PFNS_PER_PAGE_BMAP;
> > > +			set_bit(bmap_pos, vb->page_bmap[bmap_idx]);
> > Looks like this will crash if bmap_idx is out of range or
> > if page_bmap allocation failed.
> 
> No, it won't. Please think about the analogy Case 2.2: pfn_start is updated
> in each round. Like in the 2nd round, pfn_start is updated to 2, balloon_pfn
> will be a value between 2 and 4, so the result of
> "(balloon_pfn - pfn_start) /  PFNS_PER_PAGE_BMAP" will always be 0 when
> we only have page_bmap[0].

All these cases confuse too much. Pls abstract away the underlying data
structure (or better find an appropriate existing one). Things should
become clearer then.



> >   #ifdef CONFIG_BALLOON_COMPACTION
> > +
> > +static void tell_host_one_page(struct virtio_balloon *vb,
> > +			       struct virtqueue *vq, struct page *page)
> > +{
> > +	add_one_chunk(vb, vq, PAGE_CHUNK_TYPE_BALLOON, page_to_pfn(page), 1);
> > This passes 4kbytes to host which seems wrong - I think you want a full page.
> 
> OK. It should be
> add_one_chunk(vb, vq, PAGE_CHUNK_TYPE_BALLOON,
>                           page_to_pfn(page), VIRTIO_BALLOON_PAGES_PER_PAGE)
> 
> right?
> 
> If Page=2*BalloonPage, it will pass 2*4K to the host.

I guess, or better use whole page units.


> +static void balloon_page_chunk_init(struct virtio_balloon *vb)
> +{
> +	void *buf;
> +
> +	/*
> +	 * By default, we allocate page_bmap[0] only. More page_bmap will be
> +	 * allocated on demand.
> +	 */
> +	vb->page_bmap[0] = kmalloc(PAGE_BMAP_SIZE, GFP_KERNEL);
> +	buf = kmalloc(sizeof(struct virtio_balloon_page_chunk_hdr) +
> +		      sizeof(struct virtio_balloon_page_chunk) *
> +		      MAX_PAGE_CHUNKS, GFP_KERNEL);
> +	if (!vb->page_bmap[0] || !buf) {
> +		__virtio_clear_bit(vb->vdev, VIRTIO_BALLOON_F_BALLOON_CHUNKS);
> 
> > this doesn't work as expected as features has been OK'd by then.
> > You want something like
> > validate_features that I posted. See
> > "virtio: allow drivers to validate features".
> 
> OK. I will change it after that patch is merged.

It's upstream now.


> > 
> > > +		kfree(vb->page_bmap[0]);
> > Looks like this will double free. you want to zero them I think.
> > 
> 
> OK. I'll NULL the pointers after kfree().
> 
> 
> 
> Best,
> Wei
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
