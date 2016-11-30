Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id EF5F86B0038
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 14:15:24 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id y71so42493054pgd.0
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 11:15:24 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id 33si37045655pli.217.2016.11.30.11.15.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Nov 2016 11:15:23 -0800 (PST)
Subject: Re: [PATCH kernel v5 5/5] virtio-balloon: tell host vm's unused page
 info
References: <1480495397-23225-1-git-send-email-liang.z.li@intel.com>
 <1480495397-23225-6-git-send-email-liang.z.li@intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <438dd41a-fdf1-2a77-ef9c-8c103f492b2f@intel.com>
Date: Wed, 30 Nov 2016 11:15:23 -0800
MIME-Version: 1.0
In-Reply-To: <1480495397-23225-6-git-send-email-liang.z.li@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Liang Li <liang.z.li@intel.com>, kvm@vger.kernel.org
Cc: virtualization@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, virtio-dev@lists.oasis-open.org, qemu-devel@nongnu.org, quintela@redhat.com, dgilbert@redhat.com, mst@redhat.com, jasowang@redhat.com, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, mhocko@suse.com, pbonzini@redhat.com, Mel Gorman <mgorman@techsingularity.net>, Cornelia Huck <cornelia.huck@de.ibm.com>, Amit Shah <amit.shah@redhat.com>

On 11/30/2016 12:43 AM, Liang Li wrote:
> +static void send_unused_pages_info(struct virtio_balloon *vb,
> +				unsigned long req_id)
> +{
> +	struct scatterlist sg_in;
> +	unsigned long pos = 0;
> +	struct virtqueue *vq = vb->req_vq;
> +	struct virtio_balloon_resp_hdr *hdr = vb->resp_hdr;
> +	int ret, order;
> +
> +	mutex_lock(&vb->balloon_lock);
> +
> +	for (order = MAX_ORDER - 1; order >= 0; order--) {

I scratched my head for a bit on this one.  Why are you walking over
orders, *then* zones.  I *think* you're doing it because you can
efficiently fill the bitmaps at a given order for all zones, then move
to a new bitmap.  But, it would be interesting to document this.

> +		pos = 0;
> +		ret = get_unused_pages(vb->resp_data,
> +			 vb->resp_buf_size / sizeof(unsigned long),
> +			 order, &pos);

FWIW, get_unsued_pages() is a pretty bad name.  "get" usually implies
bumping reference counts or consuming something.  You're just
"recording" or "marking" them.

> +		if (ret == -ENOSPC) {
> +			void *new_resp_data;
> +
> +			new_resp_data = kmalloc(2 * vb->resp_buf_size,
> +						GFP_KERNEL);
> +			if (new_resp_data) {
> +				kfree(vb->resp_data);
> +				vb->resp_data = new_resp_data;
> +				vb->resp_buf_size *= 2;

What happens to the data in ->resp_data at this point?  Doesn't this
just throw it away?

...
> +struct page_info_item {
> +	__le64 start_pfn : 52; /* start pfn for the bitmap */
> +	__le64 page_shift : 6; /* page shift width, in bytes */
> +	__le64 bmap_len : 6;  /* bitmap length, in bytes */
> +};

Is 'bmap_len' too short?  a 64-byte buffer is a bit tiny.  Right?

> +static int  mark_unused_pages(struct zone *zone,
> +		unsigned long *unused_pages, unsigned long size,
> +		int order, unsigned long *pos)
> +{
> +	unsigned long pfn, flags;
> +	unsigned int t;
> +	struct list_head *curr;
> +	struct page_info_item *info;
> +
> +	if (zone_is_empty(zone))
> +		return 0;
> +
> +	spin_lock_irqsave(&zone->lock, flags);
> +
> +	if (*pos + zone->free_area[order].nr_free > size)
> +		return -ENOSPC;

Urg, so this won't partially fill?  So, what the nr_free pages limit
where we no longer fit in the kmalloc()'d buffer where this simply won't
work?

> +	for (t = 0; t < MIGRATE_TYPES; t++) {
> +		list_for_each(curr, &zone->free_area[order].free_list[t]) {
> +			pfn = page_to_pfn(list_entry(curr, struct page, lru));
> +			info = (struct page_info_item *)(unused_pages + *pos);
> +			info->start_pfn = pfn;
> +			info->page_shift = order + PAGE_SHIFT;
> +			*pos += 1;
> +		}
> +	}

Do we need to fill in ->bmap_len here?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
