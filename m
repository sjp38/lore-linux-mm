Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id AF0556B0033
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 11:22:46 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id y124so4265615oie.0
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 08:22:46 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id c197si1769729oih.198.2017.12.15.08.22.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 15 Dec 2017 08:22:43 -0800 (PST)
Subject: Re: [PATCH v19 3/7] xbitmap: add more operations
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <5A311C5E.7000304@intel.com>
	<201712132316.EJJ57332.MFOSJHOFFVLtQO@I-love.SAKURA.ne.jp>
	<5A31F445.6070504@intel.com>
	<201712150129.BFC35949.FFtFOLSOJOQHVM@I-love.SAKURA.ne.jp>
	<20171214181219.GA26124@bombadil.infradead.org>
In-Reply-To: <20171214181219.GA26124@bombadil.infradead.org>
Message-Id: <201712160121.BEJ26052.HOFFOOQFMLtSVJ@I-love.SAKURA.ne.jp>
Date: Sat, 16 Dec 2017 01:21:52 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: willy@infradead.org
Cc: wei.w.wang@intel.com, virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com, nilal@redhat.com, riel@redhat.com

Matthew Wilcox wrote:
> On Fri, Dec 15, 2017 at 01:29:45AM +0900, Tetsuo Handa wrote:
> > > > Also, one more thing you need to check. Have you checked how long does
> > > > xb_find_next_set_bit(xb, 0, ULONG_MAX) on an empty xbitmap takes?
> > > > If it causes soft lockup warning, should we add cond_resched() ?
> > > > If yes, you have to document that this API might sleep. If no, you
> > > > have to document that the caller of this API is responsible for
> > > > not to pass such a large value range.
> > > 
> > > Yes, that will take too long time. Probably we can document some 
> > > comments as a reminder for the callers.
> > 
> > Then, I feel that API is poorly implemented. There is no need to brute-force
> > when scanning [0, ULONG_MAX] range. If you eliminate exception path and
> > redesign the data structure, xbitmap will become as simple as a sample
> > implementation shown below. Not tested yet, but I think that this will be
> > sufficient for what virtio-baloon wants to do; i.e. find consecutive "1" bits
> > quickly. I didn't test whether finding "struct ulong_list_data" using radix
> > tree can improve performance.
> 
> find_next_set_bit() is just badly implemented.  There is no need to
> redesign the data structure.  It should be a simple matter of:
> 
>  - look at ->head, see it is NULL, return false.
> 
> If bit 100 is set and you call find_next_set_bit(101, ULONG_MAX), it
> should look at block 0, see there is a pointer to it, scan the block,
> see there are no bits set above 100, then realise we're at the end of
> the tree and stop.
> 
> If bit 2000 is set, and you call find_next_set_bit(2001, ULONG_MAX)
> tit should look at block 1, see there's no bit set after bit 2001, then
> look at the other blocks in the node, see that all the pointers are NULL
> and stop.
> 
> This isn't rocket science, we already do something like this in the radix
> tree and it'll be even easier to do in the XArray.  Which I'm going back
> to working on now.
> 

My understanding is that virtio-balloon wants to handle sparsely spreaded
unsigned long values (which is PATCH 4/7) and wants to find all chunks of
consecutive "1" bits efficiently. Therefore, I guess that holding the values
in ascending order at store time is faster than sorting the values at read
time. I don't know how to use radix tree API, but I think that B+ tree API
suits for holding the values in ascending order.

We wait for Wei to post radix tree version combined into one patch and then
compare performance between radix tree version and B+ tree version (shown
below)?

----------
#include <linux/module.h>
#include <linux/slab.h>
#include <linux/btree.h>

#define BITMAP_LEN 1024

struct ulong_list_data {
	/* Segment for this offset bitmap. */
	unsigned long segment;
	/* Number of bits set in this offset bitmap. */
	unsigned long bits;
	/* Offset bitmap of BITMAP_LEN bits. */
	unsigned long *bitmap;
};

struct ulong_list_head {
	struct btree_headl btree;
	struct ulong_list_data *last_used;
};

static int init_ulong(struct ulong_list_head *head)
{
	head->last_used = NULL;
	return btree_initl(&head->btree);
}

static bool set_ulong(struct ulong_list_head *head, const unsigned long value)
{
	struct ulong_list_data *ptr = head->last_used;
	const unsigned long segment = value / BITMAP_LEN;
	const unsigned long offset = value % BITMAP_LEN;

	if (!ptr || ptr->segment != segment)
		ptr = btree_lookupl(&head->btree, ~segment);
	if (!ptr) {
		ptr = kzalloc(sizeof(*ptr), GFP_NOWAIT | __GFP_NOWARN);
		if (!ptr)
			goto out1;
		ptr->bitmap = kzalloc(BITMAP_LEN / 8,
				      GFP_NOWAIT | __GFP_NOWARN);
		if (!ptr->bitmap)
			goto out2;
		if (btree_insertl(&head->btree, ~segment, ptr,
				   GFP_NOWAIT | __GFP_NOWARN))
			goto out3;
		ptr->segment = segment;
	}
	head->last_used = ptr;
	if (!test_bit(offset, ptr->bitmap)) {
		__set_bit(offset, ptr->bitmap);
		ptr->bits++;
	}
	return true;
out3:
	kfree(ptr->bitmap);
out2:
	kfree(ptr);
out1:
	return false;
}

static void clear_ulong(struct ulong_list_head *head, const unsigned long value)
{
	struct ulong_list_data *ptr = head->last_used;
	const unsigned long segment = value / BITMAP_LEN;
	const unsigned long offset = value % BITMAP_LEN;

	if (!ptr || ptr->segment != segment) {
		ptr = btree_lookupl(&head->btree, ~segment);
		if (!ptr)
			return;
		head->last_used = ptr;
	}
	if (!test_bit(offset, ptr->bitmap))
		return;
	__clear_bit(offset, ptr->bitmap);
	if (--ptr->bits)
		return;
	btree_removel(&head->btree, ~segment);
	if (head->last_used == ptr)
		head->last_used = NULL;
	kfree(ptr->bitmap);
	kfree(ptr);
}

static void destroy_ulong(struct ulong_list_head *head)
{
	struct ulong_list_data *ptr;
	unsigned long segment;

	btree_for_each_safel(&head->btree, segment, ptr) {
		btree_removel(&head->btree, segment);
		kfree(ptr->bitmap);
		kfree(ptr);
	}
	btree_destroyl(&head->btree);
	head->last_used = NULL;
}

/*
 * get_ulong_set_range - Get range of "1" bits.
 *
 * @head:  Pointer to "struct ulong_list_head".
 * @start: Pointer to "unsigned long" which holds starting bit upon entry and
 *         holds found bit upon return.
 *
 * Returns length of consecutive "1" bits which start from @start or higher.
 * @start is updated to hold actual location where "1" bit started. The caller
 * can call this function again after adding return value of this function to
 * @start, but be sure to check for overflow which will happen when the last
 * bit (the ULONG_MAX'th bit) is "1".
 *
 * Returns 0 if no "1" bit was found in @start and afterwords bits. It does not
 * make sense to call this function again in that case.
 */
static unsigned long get_ulong_set_range(struct ulong_list_head *head,
					 unsigned long *start)
{
	struct ulong_list_data *ptr;
	unsigned long segment = *start / BITMAP_LEN;
	unsigned int offset = *start % BITMAP_LEN;
	unsigned long ret = BITMAP_LEN;
	unsigned long key = 0;

	btree_for_each_safel(&head->btree, key, ptr) {
		if (ptr->segment < segment)
			continue;
		if (ptr->segment > segment)
			offset = 0;
		ret = find_next_bit(ptr->bitmap, BITMAP_LEN, offset);
		if (ret < BITMAP_LEN)
			break;
	}
	if (ret == BITMAP_LEN)
		return 0;
	segment = ptr->segment;
	*start = segment * BITMAP_LEN + ret;
	ret = find_next_zero_bit(ptr->bitmap, BITMAP_LEN, ret);
	if (ret == BITMAP_LEN)
		while ((ptr = btree_get_prevl(&head->btree, &key)) != NULL) {
			if (ptr->segment != segment + 1)
				break;
			segment++;
			if (ptr->bits == BITMAP_LEN)
				continue;
			ret = find_next_zero_bit(ptr->bitmap, BITMAP_LEN, 0);
			break;
		}
	return segment * BITMAP_LEN + ret - *start;
}

static int __init test_init(void)
{
	struct ulong_list_data *ptr;
	struct ulong_list_head head;
	unsigned long key;
	unsigned long start = 0;
	unsigned long len;

	if (init_ulong(&head))
		return -ENOMEM;

	set_ulong(&head, 0);
	set_ulong(&head, 10);
	set_ulong(&head, 11);
	set_ulong(&head, 1000000);
	set_ulong(&head, 12);
	clear_ulong(&head, 11);
	for (len = 1048576; len < 1048576 + BITMAP_LEN * 3; len++)
		set_ulong(&head, len);
	for (len = 1048576 + BITMAP_LEN; len < 1048576 + BITMAP_LEN * 2; len++)
		set_ulong(&head, len);
	clear_ulong(&head, 1048600);
	set_ulong(&head, 2000000000);
	for (len = ULONG_MAX - 1; len >= ULONG_MAX - BITMAP_LEN * 3; len--)
		set_ulong(&head, len);
	pr_info("Debug dump start\n");
	btree_for_each_safel(&head.btree, key, ptr)
		pr_info("Segment %lu %lu\n", ptr->segment, ptr->bits);
	pr_info("Debug dump end\n");

	while ((len = get_ulong_set_range(&head, &start)) > 0) {
		pr_info("Range %lu@%lu\n", len, start);
		start += len;
		if (!start)
			break;
	}
	destroy_ulong(&head);
	return -EINVAL;
}

module_init(test_init);
MODULE_LICENSE("GPL");
----------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
