Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id D78716B0006
	for <linux-mm@kvack.org>; Mon, 25 Feb 2013 12:29:41 -0500 (EST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Mon, 25 Feb 2013 12:29:40 -0500
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 9EC856E8048
	for <linux-mm@kvack.org>; Mon, 25 Feb 2013 12:29:34 -0500 (EST)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1PHTacm312846
	for <linux-mm@kvack.org>; Mon, 25 Feb 2013 12:29:36 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1PHTZmH014885
	for <linux-mm@kvack.org>; Mon, 25 Feb 2013 12:29:36 -0500
Message-ID: <512B9D8C.3090506@linux.vnet.ibm.com>
Date: Mon, 25 Feb 2013 11:21:16 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCHv6 4/8] zswap: add to mm/
References: <1361397888-14863-1-git-send-email-sjenning@linux.vnet.ibm.com> <1361397888-14863-5-git-send-email-sjenning@linux.vnet.ibm.com> <20130225043551.GA12158@lge.com>
In-Reply-To: <20130225043551.GA12158@lge.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Joe Perches <joe@perches.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On 02/24/2013 10:35 PM, Joonsoo Kim wrote:
> Hello, Seth.
> Here comes minor comments.
> 
<snip>
>> +static int __zswap_cpu_notifier(unsigned long action, unsigned long cpu)
>> +{
>> +	struct crypto_comp *tfm;
>> +	u8 *dst;
>> +
>> +	switch (action) {
>> +	case CPU_UP_PREPARE:
>> +		tfm = crypto_alloc_comp(zswap_compressor, 0, 0);
>> +		if (IS_ERR(tfm)) {
>> +			pr_err("can't allocate compressor transform\n");
>> +			return NOTIFY_BAD;
>> +		}
>> +		*per_cpu_ptr(zswap_comp_pcpu_tfms, cpu) = tfm;
>> +		dst = (u8 *)__get_free_pages(GFP_KERNEL, 1);
> 
> Order 1 is really needed?
> Following code uses only PAGE_SIZE, not 2 * PAGE_SIZE.

Yes, probably should add a comment here.

Some compression modules in the kernel, notably LZO, do not guard
against buffer overrun during compression.  In cases where LZO tries
to compress a page with high entropy (e.g. a page containing already
compressed data like JPEG), the compressed result can actually be
larger than the original data.  In this case, if the compression
buffer is only one page, we overrun.  I actually encountered this
during development.

> 
>> +		if (!dst) {
>> +			pr_err("can't allocate compressor buffer\n");
>> +			crypto_free_comp(tfm);
>> +			*per_cpu_ptr(zswap_comp_pcpu_tfms, cpu) = NULL;
>> +			return NOTIFY_BAD;
>> +		}
<snip>
>> +	buf = zs_map_object(tree->pool, handle, ZS_MM_WO);
>> +	memcpy(buf, dst, dlen);
>> +	zs_unmap_object(tree->pool, handle);
>> +	put_cpu_var(zswap_dstmem);
>> +
>> +	/* allocate entry */
>> +	entry = zswap_entry_cache_alloc(GFP_KERNEL);
>> +	if (!entry) {
>> +		zs_free(tree->pool, handle);
>> +		zswap_reject_kmemcache_fail++;
>> +		ret = -ENOMEM;
>> +		goto reject;
>> +	}
> 
> How about moving up zswap_entry_cache_alloc()?
> It can save compression processing time
> if zswap_entry_cache_alloc() is failed.

Will do.

> 
>> +
>> +	/* populate entry */
>> +	entry->type = type;
>> +	entry->offset = offset;
>> +	entry->handle = handle;
>> +	entry->length = dlen;
>> +
<snip>
>> +/* invalidates all pages for the given swap type */
>> +static void zswap_frontswap_invalidate_area(unsigned type)
>> +{
>> +	struct zswap_tree *tree = zswap_trees[type];
>> +	struct rb_node *node;
>> +	struct zswap_entry *entry;
>> +
>> +	if (!tree)
>> +		return;
>> +
>> +	/* walk the tree and free everything */
>> +	spin_lock(&tree->lock);
>> +	/*
>> +	 * TODO: Even though this code should not be executed because
>> +	 * the try_to_unuse() in swapoff should have emptied the tree,
>> +	 * it is very wasteful to rebalance the tree after every
>> +	 * removal when we are freeing the whole tree.
>> +	 *
>> +	 * If post-order traversal code is ever added to the rbtree
>> +	 * implementation, it should be used here.
>> +	 */
>> +	while ((node = rb_first(&tree->rbroot))) {
>> +		entry = rb_entry(node, struct zswap_entry, rbnode);
>> +		rb_erase(&entry->rbnode, &tree->rbroot);
>> +		zs_free(tree->pool, entry->handle);
>> +		zswap_entry_cache_free(entry);
>> +	}
> 
> You should decrease zswap_stored_pages in while loop.

Yes. Will do.

Thanks,
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
