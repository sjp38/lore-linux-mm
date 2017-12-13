Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 48E406B0033
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 09:17:58 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id e41so2657259itd.5
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 06:17:58 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id r21si1345742ioi.177.2017.12.13.06.17.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 13 Dec 2017 06:17:57 -0800 (PST)
Subject: Re: [PATCH v19 3/7] xbitmap: add more operations
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1513079759-14169-1-git-send-email-wei.w.wang@intel.com>
	<1513079759-14169-4-git-send-email-wei.w.wang@intel.com>
	<201712122220.IFH05261.LtJOFFSFHVMQOO@I-love.SAKURA.ne.jp>
	<5A311C5E.7000304@intel.com>
In-Reply-To: <5A311C5E.7000304@intel.com>
Message-Id: <201712132316.EJJ57332.MFOSJHOFFVLtQO@I-love.SAKURA.ne.jp>
Date: Wed, 13 Dec 2017 23:16:56 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: wei.w.wang@intel.com
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com, nilal@redhat.com, riel@redhat.com

Wei Wang wrote:
> On 12/12/2017 09:20 PM, Tetsuo Handa wrote:
> > Wei Wang wrote:
> >> +void xb_clear_bit_range(struct xb *xb, unsigned long start, unsigned long end)
> >> +{
> >> +	struct radix_tree_root *root = &xb->xbrt;
> >> +	struct radix_tree_node *node;
> >> +	void **slot;
> >> +	struct ida_bitmap *bitmap;
> >> +	unsigned int nbits;
> >> +
> >> +	for (; start < end; start = (start | (IDA_BITMAP_BITS - 1)) + 1) {
> >> +		unsigned long index = start / IDA_BITMAP_BITS;
> >> +		unsigned long bit = start % IDA_BITMAP_BITS;
> >> +
> >> +		bitmap = __radix_tree_lookup(root, index, &node, &slot);
> >> +		if (radix_tree_exception(bitmap)) {
> >> +			unsigned long ebit = bit + 2;
> >> +			unsigned long tmp = (unsigned long)bitmap;
> >> +
> >> +			nbits = min(end - start + 1, BITS_PER_LONG - ebit);
> >> +
> >> +			if (ebit >= BITS_PER_LONG)
> > What happens if we hit this "continue;" when "index == ULONG_MAX / IDA_BITMAP_BITS" ?
> 
> Thanks. I also improved the test case for this. I plan to change the 
> implementation a little bit to avoid such overflow (has passed the test 
> case that I have, just post out for another set of eyes):
> 
> {
> ...
>          unsigned long idx = start / IDA_BITMAP_BITS;
>          unsigned long bit = start % IDA_BITMAP_BITS;
>          unsigned long idx_end = end / IDA_BITMAP_BITS;
>          unsigned long ret;
> 
>          for (idx = start / IDA_BITMAP_BITS; idx <= idx_end; idx++) {
>                  unsigned long ida_start = idx * IDA_BITMAP_BITS;
> 
>                  bitmap = __radix_tree_lookup(root, idx, &node, &slot);
>                  if (radix_tree_exception(bitmap)) {
>                          unsigned long tmp = (unsigned long)bitmap;
>                          unsigned long ebit = bit + 2;
> 
>                          if (ebit >= BITS_PER_LONG)
>                                  continue;

Will you please please do eliminate exception path?
I can't interpret what "ebit >= BITS_PER_LONG" means.
The reason you "continue;" is that all bits beyond are "0", isn't it?
Then, it would make sense to "continue;" when finding next "1" because
all bits beyond are "0". But how does it make sense to "continue;" when
finding next "0" despite all bits beyond are "0"?

>                          if (set)
>                                  ret = find_next_bit(&tmp, 
> BITS_PER_LONG, ebit);
>                          else
>                                  ret = find_next_zero_bit(&tmp, 
> BITS_PER_LONG,
>                                                           ebit);
>                          if (ret < BITS_PER_LONG)
>                                  return ret - 2 + ida_start;
>                  } else if (bitmap) {
>                          if (set)
>                                  ret = find_next_bit(bitmap->bitmap,
>                                                      IDA_BITMAP_BITS, bit);
>                          else
>                                  ret = find_next_zero_bit(bitmap->bitmap,
> IDA_BITMAP_BITS, bit);

"bit" may not be 0 for the first round and "bit" is always 0 afterwords.
But where is the guaranteed that "end" is a multiple of IDA_BITMAP_BITS ?
Please explain why it is correct to use IDA_BITMAP_BITS unconditionally
for the last round.

>                          if (ret < IDA_BITMAP_BITS)
>                                  return ret + ida_start;
>                  } else if (!bitmap && !set) {

At this point bitmap == NULL is guaranteed. Thus, "!bitmap && " is pointless.

>                          return bit + IDA_BITMAP_BITS * idx;
>                  }
>                  bit = 0;
>          }
> 
>          return end;
> }
> 
> 



> >
> >> +/**
> >> + * xb_find_next_set_bit - find the next set bit in a range
> >> + * @xb: the xbitmap to search
> >> + * @start: the start of the range, inclusive
> >> + * @end: the end of the range, exclusive
> >> + *
> >> + * Returns: the index of the found bit, or @end + 1 if no such bit is found.
> >> + */
> >> +unsigned long xb_find_next_set_bit(struct xb *xb, unsigned long start,
> >> +				   unsigned long end)
> >> +{
> >> +	return xb_find_next_bit(xb, start, end, 1);
> >> +}
> > Won't "exclusive" loose ability to handle ULONG_MAX ? Since this is a
> > library module, missing ability to handle ULONG_MAX sounds like an omission.
> > Shouldn't we pass (or return) whether "found or not" flag (e.g. strtoul() in
> > C library function)?
> >
> >    bool xb_find_next_set_bit(struct xb *xb, unsigned long start, unsigned long end, unsigned long *result);
> >    unsigned long xb_find_next_set_bit(struct xb *xb, unsigned long start, unsigned long end, bool *found);
> 
> Yes, ULONG_MAX needs to be tested by xb_test_bit(). Compared to checking 
> the return value, would it be the same to let the caller check for the 
> ULONG_MAX boundary?
> 

Why the caller needs to care about whether it is ULONG_MAX or not?

Also, one more thing you need to check. Have you checked how long does
xb_find_next_set_bit(xb, 0, ULONG_MAX) on an empty xbitmap takes?
If it causes soft lockup warning, should we add cond_resched() ?
If yes, you have to document that this API might sleep. If no, you
have to document that the caller of this API is responsible for
not to pass such a large value range.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
