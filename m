Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id CBA706B02E3
	for <linux-mm@kvack.org>; Tue,  2 Jan 2018 21:30:05 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id x4so163103otg.5
        for <linux-mm@kvack.org>; Tue, 02 Jan 2018 18:30:05 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id j46si13122otb.76.2018.01.02.18.30.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 02 Jan 2018 18:30:03 -0800 (PST)
Subject: Re: [PATCH v20 4/7] virtio-balloon: VIRTIO_BALLOON_F_SG
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1513685879-21823-5-git-send-email-wei.w.wang@intel.com>
	<20171224032121.GA5273@bombadil.infradead.org>
	<201712241345.DIG21823.SLFOOJtQFOMVFH@I-love.SAKURA.ne.jp>
	<5A3F5A4A.1070009@intel.com>
	<20180102132419.GB8222@bombadil.infradead.org>
In-Reply-To: <20180102132419.GB8222@bombadil.infradead.org>
Message-Id: <201801031129.JFC18298.FJMHtOFLVSQOFO@I-love.SAKURA.ne.jp>
Date: Wed, 3 Jan 2018 11:29:23 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: willy@infradead.org, wei.w.wang@intel.com
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com

Matthew Wilcox wrote:
> The radix tree convention is objectively awful, which is why I'm working
> to change it.  Specifying the GFP flags at radix tree initialisation time
> rather than allocation time leads to all kinds of confusion.  The preload
> API is a pretty awful workaround, and it will go away once the XArray
> is working correctly.  That said, there's no alternative to it without
> making XBitmap depend on XArray, and I don't want to hold you up there.
> So there's an xb_preload for the moment.

I'm ready to propose cvbmp shown below as an alternative to xbitmap (but
specialized for virtio-balloon case). Wei, can you do some benchmarking
between xbitmap and cvbmp?
----------------------------------------
cvbmp: clustered values bitmap

This patch provides simple API for recording any "unsigned long" value and
for fetching recorded values in ascendant order, in order to allow handling
chunk of unique values efficiently.

The virtio-balloon driver manages memory pages (where the page frame number
is in unique "unsigned long" value range) between the host and the guest.
Currently that communication is using fixed sized array, and allowing that
communication to use scatter-gather API can improve performance a lot.

This patch is implemented for virtio-balloon driver as initial user. Since
the ballooning operation gathers many pages at once, gathered pages tend to
form a cluster (i.e. their values tend to fit bitmap based management).

This API will fail only when memory allocation failed while trying to record
an "unsigned long" value. All operations provided by this API never sleeps.
Also, this API does not provide exclusion control.
Therefore, the callers are responsible for e.g. inserting cond_resched() and
handling out of memory situation, and using rwlock or plain lock as needed.

Since virtio-balloon driver uses OOM notifier callback, in order to avoid
potential deadlock, the ballooning operation must not directly or indirectly
depend on __GFP_DIRECT_RECLAIM && !__GFP_NORETRY memory allocation.
Also, there should be no need to use __GFP_HIGH for memory allocation for
the ballooning operation, for if there is already little free memory such
that normal memory allocation requests will fail, the OOM notifier callback
will be fired by normal memory allocation requests, and the ballooning
operation will have to release memory just allocated. Therefore, this API
uses GFP_NOWAIT | __GFP_NOWARN for memory allocation.

If gathered pages tend to form a cluster, a bitmap for recording next
"unsigned long" value could be found at neighbor of the bitmap used for
recording previous "unsigned long" value. Therefore, this API uses
sequential seek rather than using some tree based algorithm (e.g. radix
tree or B+ tree) when finding a bitmap for recording an "unsigned long"
value. If values changes sequentially, this approach is much faster than
tree based algorithm.
----------------------------------------
/*
 * Clustered values bitmap.
 *
 * This file provides simple API for recording any "unsigned long" value and
 * for fetching recorded values in ascendant order, in order to allow handling
 * chunk of unique values efficiently.
 *
 * This API will fail only when memory allocation failed while trying to record
 * an "unsigned long" value. All operations provided by this API never sleeps.
 * Also, this API does not provide exclusion control.
 * Therefore, the callers are responsible for e.g. inserting cond_resched() and
 * handling out of memory situation, and using rwlock or plain lock as needed.
 */

/* Header file part. */

#include <linux/list.h>
 
/* Tune this size between 8 and PAGE_SIZE * 8, in power of 2. */
#define CVBMP_SIZE 1024

struct cvbmp_node;
struct cvbmp_head {
	/*
	 * list[0] is used by currently used "struct cvbmp_node" list.
	 * list[1] is used by currently unused "struct cvbmp_node" list.
	 */
	struct list_head list[2];
	/*
	 * Previously used "struct cvbmp_node" which is used as a hint for
	 * next operation.
	 */
	struct cvbmp_node *last_used;
};

void cvbmp_init(struct cvbmp_head *head);
void cvbmp_destroy(struct cvbmp_head *head);
bool __must_check cvbmp_set_bit(struct cvbmp_head *head,
				const unsigned long value);
bool cvbmp_test_bit(struct cvbmp_head *head, const unsigned long value);
void cvbmp_clear_bit(struct cvbmp_head *head, const unsigned long value);
unsigned long cvbmp_get_bit_range(struct cvbmp_head *head,
				  unsigned long *start);
bool __must_check cvbmp_set_segment(struct cvbmp_head *head,
				    const unsigned long segment);
void cvbmp_clear_segment(struct cvbmp_head *head, const unsigned long segment);

/* C file part. */

#ifdef __KERNEL__
#include <linux/sched.h>
#include <linux/module.h>
#include <linux/slab.h>
#define assert(x) WARN_ON(!x)
#else
#include <linux/bitops.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <limits.h>
#define kfree free
#define kzalloc(size, flag) calloc(size, 1)
#define pr_info printf
#define cond_resched() do { } while (0)
#endif

struct cvbmp_node {
	/* List for chaining to "struct cvbmp_head". */
	struct list_head list;
	/* Starting segment for this offset bitmap. */
	unsigned long segment;
	/*
	 * Number of bits set in this offset bitmap. If this value is larger
	 * than CVBMP_SIZE, this value must be multiple of CVBMP_SIZE, for
	 * this entry represents start of segments with all "1" set.
	 */
	unsigned long bits;
	/*
	 * Offset bitmap of CVBMP_SIZE bits. This bitmap can be modified
	 * only if "bits <= CVBMP_SIZE" is true.
	 */
	unsigned long *bitmap;
};

/**
 * cvbmp_init - Initialize "struct cvbmp_head".
 *
 * @head: Pointer to "struct cvbmp_head".
 *
 * Returns nothing.
 */
void cvbmp_init(struct cvbmp_head *head)
{
	INIT_LIST_HEAD(&head->list[0]);
	INIT_LIST_HEAD(&head->list[1]);
	head->last_used = NULL;
}

/**
 * cvbmp_destroy - Finalize "struct cvbmp_head".
 *
 * @head: Pointer to "struct cvbmp_head".
 *
 * Returns nothing.
 */
void cvbmp_destroy(struct cvbmp_head *head)
{
	struct cvbmp_node *ptr;
	struct cvbmp_node *tmp;
	unsigned int i;

	for (i = 0; i < 2; i++) {
		list_for_each_entry_safe(ptr, tmp, &head->list[i], list) {
			list_del(&ptr->list);
			kfree(ptr->bitmap);
			kfree(ptr);
		}
	}
	head->last_used = NULL;
}

/**
 * __cvbmp_merge - Merge "struct cvbmp_node" with all "1" set.
 *
 * @head:    Pointer to "struct cvbmp_head".
 * @segment: Segment number to merge.
 * @ptr:     Pointer to "struct cvbmp_node" with all "1" set.
 *
 * Returns nothing.
 */
static void __cvbmp_merge(struct cvbmp_head *head, const unsigned long segment,
			  struct cvbmp_node *ptr)
{
	if (ptr != list_first_entry(&head->list[0], typeof(*ptr), list)) {
		struct cvbmp_node *prev = list_prev_entry(ptr, list);

		if (prev->segment + prev->bits / CVBMP_SIZE == segment) {
			list_del(&ptr->list);
			list_add(&ptr->list, &head->list[1]);
			prev->bits += CVBMP_SIZE;
			head->last_used = prev;
			ptr = prev;
		}
	}
	if (ptr != list_last_entry(&head->list[0], typeof(*ptr), list)) {
		struct cvbmp_node *next = list_next_entry(ptr, list);

		if (next->bits >= CVBMP_SIZE && next->segment == segment + 1) {
			list_del(&next->list);
			list_add(&next->list, &head->list[1]);
			ptr->bits += next->bits;
		}
	}
}

/**
 * __cvbmp_unmerge - Unmerge "struct cvbmp_node" with all "1" set.
 *
 * @head:    Pointer to "struct cvbmp_head".
 * @segment: Segment number to unmerge.
 * @ptr:     Pointer to "struct cvbmp_node" with all "1" set.
 *
 * Returns nothing.
 */
static struct cvbmp_node *__cvbmp_unmerge(struct cvbmp_head *head,
					  const unsigned long segment,
					  struct cvbmp_node *ptr)
{
	unsigned long diff = segment - ptr->segment;
	struct cvbmp_node *new;

again:
	new = list_first_entry(&head->list[1], typeof(*ptr), list);
	list_del(&new->list);
	if (!diff) {
		list_add_tail(&new->list, &ptr->list);
		new->segment = segment;
		new->bits = CVBMP_SIZE;
		ptr->bits -= CVBMP_SIZE;
		ptr->segment++;
		return new;
	}
	list_add(&new->list, &ptr->list);
	new->segment = segment;
	new->bits = ptr->bits - CVBMP_SIZE * diff;
	ptr->bits -= new->bits;
	if (new->bits <= CVBMP_SIZE)
		return new;
	ptr = new;
	diff = 0;
	goto again;
}

/**
 * __cvbmp_in_data - Check "struct cvbmp_node" segment.
 *
 * @ptr:     Pointer to "struct cvbmp_node".
 * @segment: Segment number to check.
 *
 * Returns true if @segment is in @ptr, false otherwise.
 */
static inline bool __cvbmp_segment_in_data(struct cvbmp_node *ptr,
				    const unsigned long segment)
{
	return ptr->segment <= segment &&
		segment <= ptr->segment + (ptr->bits - 1) / CVBMP_SIZE;
}

/**
 * __cvbmp_lookup - Find "struct cvbmp_node" segment.
 *
 * @head:    Pointer to "struct cvbmp_head".
 * @segment: Segment number to find.
 * @create:  Whether to create one if not found.
 *
 * Returns pointer to "struct cvbmp_node" on success, NULL otherwise.
 */
static struct cvbmp_node *__cvbmp_lookup(struct cvbmp_head *head,
					 const unsigned long segment,
					 const bool create)
{
	struct cvbmp_node *ptr = head->last_used;
	struct list_head *insert_pos;
	bool add_tail = false;

	if (!ptr) {
		insert_pos = &head->list[0];
		list_for_each_entry(ptr, &head->list[0], list) {
			if (ptr->segment >= segment)
				break;
			insert_pos = &ptr->list;
		}
	} else if (__cvbmp_segment_in_data(ptr, segment)) {
		return ptr;
	} else if (ptr->segment < segment) {
		insert_pos = &ptr->list;
		list_for_each_entry_continue(ptr, &head->list[0], list) {
			if (ptr->segment >= segment)
				break;
			insert_pos = &ptr->list;
		}
	} else {
		add_tail = true;
		insert_pos = &ptr->list;
		list_for_each_entry_continue_reverse(ptr, &head->list[0],
						     list) {
			if (ptr->segment <= segment)
				break;
			insert_pos = &ptr->list;
		}
	}
	if (&ptr->list != &head->list[0]) {
		if (__cvbmp_segment_in_data(ptr, segment))
			return ptr;
		ptr = list_prev_entry(ptr, list);
		if (__cvbmp_segment_in_data(ptr, segment))
			return ptr;
	}
	if (!create)
		return NULL;
	ptr = kzalloc(sizeof(*ptr), GFP_NOWAIT | __GFP_NOWARN);
	if (!ptr)
		return NULL;
	ptr->bitmap = kzalloc(CVBMP_SIZE / 8, GFP_NOWAIT | __GFP_NOWARN);
	if (!ptr->bitmap) {
		kfree(ptr);
		return NULL;
	}
	ptr->segment = segment;
	if (!add_tail)
		list_add(&ptr->list, insert_pos);
	else
		list_add_tail(&ptr->list, insert_pos);
	return ptr;
}

/**
 * cvbmp_set_bit - Set one "1" bit in the bitmap.
 *
 * @head:  Pointer to "struct cvbmp_head".
 * @value: Value to set bit.
 *
 * Returns true on success, false otherwise.
 */
bool cvbmp_set_bit(struct cvbmp_head *head, const unsigned long value)
{
	struct cvbmp_node *ptr;
	const unsigned long segment = value / CVBMP_SIZE;
	const unsigned long offset = value % CVBMP_SIZE;

	ptr = __cvbmp_lookup(head, segment, true);
	if (!ptr)
		return false;
	head->last_used = ptr;
	if (test_bit(offset, ptr->bitmap))
		return true;
	__set_bit(offset, ptr->bitmap);
	ptr->bits++;
	if (ptr->bits == CVBMP_SIZE)
		__cvbmp_merge(head, segment, ptr);
	return true;
}

/**
 * cvbmp_test_bit - Test one "1" bit in the bitmap.
 *
 * @head:  Pointer to "struct cvbmp_head".
 * @value: Value to test bit.
 *
 * Returns true if "1" bit is set, false otherwise.
 */
bool cvbmp_test_bit(struct cvbmp_head *head, const unsigned long value)
{
	struct cvbmp_node *ptr;
	const unsigned long segment = value / CVBMP_SIZE;
	const unsigned long offset = value % CVBMP_SIZE;

	ptr = __cvbmp_lookup(head, segment, false);
	return ptr && test_bit(offset, ptr->bitmap);
}

/**
 * __cvbmp_neighbor - Find neighbor "struct cvbmp_node" segment.
 *
 * @head: Pointer to "struct cvbmp_head".
 * @ptr:  Pointer to "struct cvbmp_node".
 *
 * Returns pointer to "struct cvbmp_node" on success, NULL otherwise.
 */
static struct cvbmp_node *__cvbmp_neighbor(struct cvbmp_head *head,
					   struct cvbmp_node *ptr)
{
	if (ptr != list_first_entry(&head->list[0], typeof(*ptr), list))
		return list_prev_entry(ptr, list);
	if (ptr != list_last_entry(&head->list[0], typeof(*ptr), list))
		return list_next_entry(ptr, list);
	return NULL;
}

/**
 * cvbmp_clear_bit - Clear one "1" bit in the bitmap.
 *
 * @head:  Pointer to "struct cvbmp_head".
 * @value: Value to clear bit.
 *
 * Returns nothing.
 */
void cvbmp_clear_bit(struct cvbmp_head *head, const unsigned long value)
{
	struct cvbmp_node *ptr;
	const unsigned long segment = value / CVBMP_SIZE;
	const unsigned long offset = value % CVBMP_SIZE;

	ptr = __cvbmp_lookup(head, segment, false);
	if (!ptr)
		return;
	if (ptr->bits > CVBMP_SIZE)
		ptr = __cvbmp_unmerge(head, segment, ptr);
	head->last_used = ptr;
	if (!test_bit(offset, ptr->bitmap))
		return;
	__clear_bit(offset, ptr->bitmap);
	if (--ptr->bits)
		return;
	head->last_used = __cvbmp_neighbor(head, ptr);
	list_del(&ptr->list);
	kfree(ptr->bitmap);
	kfree(ptr);
}

/**
 * cvbmp_get_bit_range - Get range of "1" bits.
 *
 * @head:  Pointer to "struct cvbmp_head".
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
unsigned long cvbmp_get_bit_range(struct cvbmp_head *head, unsigned long *start)
{
	struct cvbmp_node *ptr;
	unsigned long segment = *start / CVBMP_SIZE;
	unsigned int offset = *start % CVBMP_SIZE;
	unsigned long ret = CVBMP_SIZE;

	list_for_each_entry(ptr, &head->list[0], list) {
		if (ptr->segment + ((ptr->bits - 1) / CVBMP_SIZE) < segment)
			continue;
		if (ptr->segment > segment)
			offset = 0;
		ret = find_next_bit(ptr->bitmap, CVBMP_SIZE, offset);
		if (ret < CVBMP_SIZE)
			break;
	}
	if (ret == CVBMP_SIZE)
		return 0;
	if (segment < ptr->segment)
		segment = ptr->segment;
	*start = segment * CVBMP_SIZE + ret;
	ret = find_next_zero_bit(ptr->bitmap, CVBMP_SIZE, ret);
	if (ret == CVBMP_SIZE) {
		segment = ptr->segment + ((ptr->bits - 1) / CVBMP_SIZE);
		list_for_each_entry_continue(ptr, &head->list[0], list) {
			if (ptr->segment != segment + 1)
				break;
			segment = ptr->segment + ((ptr->bits - 1) / CVBMP_SIZE);
			if (ptr->bits >= CVBMP_SIZE)
				continue;
			ret = find_next_zero_bit(ptr->bitmap, CVBMP_SIZE, 0);
			break;
		}
	}
	return segment * CVBMP_SIZE + ret - *start;
}

/**
 * cvbmp_set_segment - Set CVBMP_SIZE "1" bits in the bitmap.
 *
 * @head:    Pointer to "struct cvbmp_head".
 * @segment: Segment to set.
 *
 * Returns true on success, false otherwise.
 */
bool cvbmp_set_segment(struct cvbmp_head *head, const unsigned long segment)
{
	struct cvbmp_node *ptr;

	if (!cvbmp_set_bit(head, segment * CVBMP_SIZE))
		return false;
	ptr = head->last_used;
	if (ptr->bits >= CVBMP_SIZE)
		return true;
	ptr->bits = CVBMP_SIZE;
	memset(ptr->bitmap, 0xFF, CVBMP_SIZE / 8);
	__cvbmp_merge(head, segment, ptr);
	return true;
}

/**
 * cvbmp_clear_segment - Clear CVBMP_SIZE "1" bits in the bitmap.
 *
 * @head:    Pointer to "struct cvbmp_head".
 * @segment: Segment to set.
 *
 * Returns nothing.
 */
void cvbmp_clear_segment(struct cvbmp_head *head, const unsigned long segment)
{
	struct cvbmp_node *ptr;

	cvbmp_clear_bit(head, segment * CVBMP_SIZE);
	ptr = head->last_used;
	if (!ptr || ptr->segment != segment)
		return;
	head->last_used = __cvbmp_neighbor(head, ptr);
	list_del(&ptr->list);
	kfree(ptr->bitmap);
	kfree(ptr);
}

/* Module testing part. */

struct expect {
	unsigned long start;
	unsigned long end;
};

static void dump(struct cvbmp_head *head)
{
	struct cvbmp_node *ptr;

	pr_info("Debug dump start\n");
	list_for_each_entry(ptr, &head->list[0], list)
		pr_info("  %20lu %20lu (%20lu)\n", ptr->bits,
			ptr->segment * CVBMP_SIZE, ptr->segment);
	pr_info("Debug dump end\n");
}

static void check_result(struct cvbmp_head *head, const struct expect *expect,
			 const unsigned int num)
{
	unsigned long start = 0;
	unsigned long len;
	unsigned int i;

	for (i = 0; i < num; i++) {
		len = cvbmp_get_bit_range(head, &start);
		if (len == 0 || start != expect[i].start ||
		    len != expect[i].end - expect[i].start + 1) {
			dump(head);
			pr_info("start=%lu/%lu end=%lu/%lu\n", start,
				expect[i].start, start + len - 1,
				expect[i].end);
			assert(len != 0 && start == expect[i].start &&
			     len == expect[i].end - expect[i].start + 1);
		}
		start += len;
	}
	len = !num || start ? cvbmp_get_bit_range(head, &start) : 0;
	if (len) {
		dump(head);
		assert(len == 0);
	}
}

#define SET_BIT(i) assert(cvbmp_set_bit(&head, i))
#define CLEAR_BIT(i) cvbmp_clear_bit(&head, i)
#define SET_SEGMENT(i) assert(cvbmp_set_segment(&head, i))
#define CLEAR_SEGMENT(i) cvbmp_clear_segment(&head, i)

#define TEST_BIT(i) {				\
	SET_BIT(i);				\
	assert(cvbmp_test_bit(&head, i));	\
	CLEAR_BIT(i);				\
	assert(!cvbmp_test_bit(&head, i));	\
	SET_SEGMENT(i / CVBMP_SIZE);		\
	assert(cvbmp_test_bit(&head, i));	\
	CLEAR_SEGMENT(i / CVBMP_SIZE);		\
	assert(!cvbmp_test_bit(&head, i));	\
	}

static void test1(void)
{
	struct cvbmp_head head;
	unsigned long i;

	for (i = 1; i; i *= 2) {
		cvbmp_init(&head);
		TEST_BIT(i);
		cvbmp_destroy(&head);
	}

	for (i = ULONG_MAX; i; i /= 2) {
		cvbmp_init(&head);
		TEST_BIT(i);
		cvbmp_destroy(&head);
	}

	{
		const struct expect expect[] = {
			{ 100 * CVBMP_SIZE, 100 * CVBMP_SIZE }
		};

		cvbmp_init(&head);
		check_result(&head, NULL, 0);
		SET_BIT(100 * CVBMP_SIZE);
		check_result(&head, expect, ARRAY_SIZE(expect));
		CLEAR_BIT(100 * CVBMP_SIZE);
		check_result(&head, NULL, 0);
		cvbmp_destroy(&head);
	}
		
	{
		const struct expect expect[] = { { 0, 16 * CVBMP_SIZE - 1 } };

		cvbmp_init(&head);
		for (i = 0; i < 16 * CVBMP_SIZE; i += 2)
			SET_BIT(i);
		for (i = 1; i < 16 * CVBMP_SIZE; i += 2)
			SET_BIT(i);
		check_result(&head, expect, ARRAY_SIZE(expect));
		for (i = 0; i < 16 * CVBMP_SIZE; i++)
			CLEAR_BIT(i);
		cvbmp_destroy(&head);
	}

	{
		const struct expect expect[] = { { 0, 16 * CVBMP_SIZE - 1 } };

		cvbmp_init(&head);
		for (i = 0; i < 16; i += 2)
			SET_SEGMENT(i);
		for (i = 1; i < 16; i += 2)
			SET_SEGMENT(i);
		check_result(&head, expect, ARRAY_SIZE(expect));
		for (i = 0; i < 16; i++)
			CLEAR_SEGMENT(i);
		cvbmp_destroy(&head);
	}

	{
		const struct expect expect[] = {
			{ 100 * CVBMP_SIZE, 116 * CVBMP_SIZE - 1 }
		};

		cvbmp_init(&head);
		for (i = 101; i < 116; i += 2)
			SET_SEGMENT(i);
		for (i = 100; i < 116; i += 2)
			SET_SEGMENT(i);
		check_result(&head, expect, ARRAY_SIZE(expect));
		for (i = 100; i < 116; i++)
			CLEAR_SEGMENT(i);
		cvbmp_destroy(&head);
	}

	{
		const struct expect expect[] = {
			{ 50 * CVBMP_SIZE, 50 * CVBMP_SIZE },
			{ 100 * CVBMP_SIZE, 100 * CVBMP_SIZE },
			{ 200 * CVBMP_SIZE, 200 * CVBMP_SIZE },
			{ 300 * CVBMP_SIZE, 300 * CVBMP_SIZE }
		};
		
		cvbmp_init(&head);
		SET_BIT(100 * CVBMP_SIZE);
		SET_BIT(300 * CVBMP_SIZE);
		SET_BIT(50 * CVBMP_SIZE);
		SET_BIT(200 * CVBMP_SIZE);
		check_result(&head, expect, ARRAY_SIZE(expect));
		CLEAR_BIT(100 * CVBMP_SIZE);
		CLEAR_BIT(300 * CVBMP_SIZE);
		CLEAR_BIT(50 * CVBMP_SIZE);
		CLEAR_BIT(200 * CVBMP_SIZE);
		cvbmp_destroy(&head);
	}

	{
		const struct expect expect[] = {
			{ 100 * CVBMP_SIZE, 100 * CVBMP_SIZE },
			{ 200 * CVBMP_SIZE, 200 * CVBMP_SIZE },
			{ 250 * CVBMP_SIZE, 250 * CVBMP_SIZE },
			{ 300 * CVBMP_SIZE, 300 * CVBMP_SIZE }
		};
		
		cvbmp_init(&head);
		SET_BIT(100 * CVBMP_SIZE);
		SET_BIT(300 * CVBMP_SIZE);
		SET_BIT(250 * CVBMP_SIZE);
		SET_BIT(200 * CVBMP_SIZE);
		check_result(&head, expect, ARRAY_SIZE(expect));
		CLEAR_BIT(100 * CVBMP_SIZE);
		CLEAR_BIT(300 * CVBMP_SIZE);
		CLEAR_BIT(250 * CVBMP_SIZE);
		CLEAR_BIT(200 * CVBMP_SIZE);
		cvbmp_destroy(&head);
	}

	{
		const struct expect expect[] = {
			{ 0, CVBMP_SIZE - 1},
			{ LONG_MAX / 2 - CVBMP_SIZE + 1, LONG_MAX / 2 },
			{ ULONG_MAX - CVBMP_SIZE + 1, ULONG_MAX }
		};

		cvbmp_init(&head);
		SET_SEGMENT(ULONG_MAX / CVBMP_SIZE);
		SET_SEGMENT(0);
		SET_SEGMENT(LONG_MAX / 2 / CVBMP_SIZE);
		check_result(&head, expect, ARRAY_SIZE(expect));
		CLEAR_SEGMENT(ULONG_MAX / CVBMP_SIZE);
		CLEAR_SEGMENT(0);
		CLEAR_SEGMENT(LONG_MAX / 2 / CVBMP_SIZE);
		cvbmp_destroy(&head);
	}

	{
		unsigned long bit;
		struct expect expect[] = {
			{ 100 * CVBMP_SIZE, 0 },
			{ 0, 110 * CVBMP_SIZE - 1 }
		};

		cvbmp_init(&head);
		for (i = 100; i < 110; i++)
			SET_SEGMENT(i);
		for (i = 100; i < 110; i++) {
			bit = i * CVBMP_SIZE + CVBMP_SIZE / 2;
			CLEAR_BIT(bit);
			expect[0].end = bit - 1;
			expect[1].start = bit + 1;
			check_result(&head, expect, 2);
			SET_BIT(bit);
		}
		for (i = 101; i < 109; i++) {
			bit = i * CVBMP_SIZE;
			CLEAR_BIT(bit);
			expect[0].end = bit - 1;
			expect[1].start = bit + 1;
			check_result(&head, expect, 2);
			SET_BIT(bit);
			bit = i * CVBMP_SIZE + CVBMP_SIZE - 1;
			CLEAR_BIT(bit);
			expect[0].end = bit - 1;
			expect[1].start = bit + 1;
			check_result(&head, expect, 2);
			SET_BIT(bit);
		}
		for (i = 100; i < 110; i++)
			CLEAR_SEGMENT(i);
		cvbmp_destroy(&head);
	}
}

static void test2(void)
{
	struct cvbmp_head head;
	unsigned long start;
	unsigned long i;
	const struct expect expect[] = {
		{ 0, 0 },
		{ 10, 10 },
		{ 12, 12 },
		{ 1000000, 1000000 },
		{ 1048576, 1048600 + CVBMP_SIZE * 2 - 2 - 1 },
		{ 1048600 + CVBMP_SIZE * 2 - 2 + 1,
		  1048576 + CVBMP_SIZE * 3 - 1 },
		{ 1000000000, 1234567890 - 1 },
		{ 1234567890 + 1, 1000000000 * 2 - 2 },
		{ 2000000000, 2000000000 },
		{ ULONG_MAX - CVBMP_SIZE * 3 + 1, ULONG_MAX }
	};

	cvbmp_init(&head);

	SET_BIT(0);
	SET_BIT(10);
	SET_BIT(11);
	SET_BIT(1000000);
	SET_BIT(12);
	SET_BIT(2000000000);
	CLEAR_BIT(11);
	for (i = 1048576; i < 1048576 + CVBMP_SIZE * 3; i += CVBMP_SIZE)
		SET_SEGMENT(i / CVBMP_SIZE);
	for (i = 1048576 + CVBMP_SIZE; i < 1048576 + CVBMP_SIZE * 2;
	     i += CVBMP_SIZE)
		SET_SEGMENT(i / CVBMP_SIZE);
	CLEAR_BIT(1048600 + CVBMP_SIZE * 2 - 2);
	for (i = ULONG_MAX; i > ULONG_MAX - CVBMP_SIZE * 3; i--)
		SET_BIT(i);
	SET_BIT(ULONG_MAX);
	for (start = 0; start < 1; start++)
		for (i = 1000000000; i <= 1000000000 * 2 - 2; i += 1) {
			if (start + i <= 1000000000 * 2 - 2)
				SET_BIT(start + i);
			cond_resched();
		}
	CLEAR_BIT(1234567890);

	check_result(&head, expect, ARRAY_SIZE(expect));

	cvbmp_destroy(&head);
}

#ifdef __KERNEL__
static int __init test_init(void)
{
	test1();
	test2();
	return -EINVAL;
}

module_init(test_init);
MODULE_LICENSE("GPL");
#else
int __weak main(int argc, char *argv[])
{
	test1();
	test2();
	return 0;
}
#endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
