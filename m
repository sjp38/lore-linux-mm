Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id C91C06B0038
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 08:03:03 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id i17so5103599otb.2
        for <linux-mm@kvack.org>; Fri, 01 Dec 2017 05:03:03 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id y133si2087184oiy.238.2017.12.01.05.03.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 01 Dec 2017 05:03:02 -0800 (PST)
Subject: Re: [PATCH v18 05/10] xbitmap: add more operations
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1511963726-34070-1-git-send-email-wei.w.wang@intel.com>
	<1511963726-34070-6-git-send-email-wei.w.wang@intel.com>
	<201711301934.CDC21800.FSLtJFFOOVQHMO@I-love.SAKURA.ne.jp>
	<5A210C96.8050208@intel.com>
In-Reply-To: <5A210C96.8050208@intel.com>
Message-Id: <201712012202.BDE13557.MJFQLtOOHVOFSF@I-love.SAKURA.ne.jp>
Date: Fri, 1 Dec 2017 22:02:01 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: wei.w.wang@intel.com
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com, nilal@redhat.com, riel@redhat.com

Wei Wang wrote:
> On 11/30/2017 06:34 PM, Tetsuo Handa wrote:
> > Wei Wang wrote:
> >> + * @start: the start of the bit range, inclusive
> >> + * @end: the end of the bit range, inclusive
> >> + *
> >> + * This function is used to clear a bit in the xbitmap. If all the bits of the
> >> + * bitmap are 0, the bitmap will be freed.
> >> + */
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
> > "nbits = min(end - start + 1," seems to expect that start == end is legal
> > for clearing only 1 bit. But this function is no-op if start == end.
> > Please clarify what "inclusive" intended.
> 
> If xb_clear_bit_range(xb,10,10), then it is effectively the same as 
> xb_clear_bit(10). Why would it be illegal?
> 
> "@start inclusive" means that the @start will also be included to be 
> cleared.

If start == end is legal,

   for (; start < end; start = (start | (IDA_BITMAP_BITS - 1)) + 1) {

makes this loop do nothing because 10 < 10 is false.



> 
> >
> >> +static inline __always_inline void bitmap_clear(unsigned long *map,
> >> +						unsigned int start,
> >> +						unsigned int nbits)
> >> +{
> >> +	if (__builtin_constant_p(nbits) && nbits == 1)
> >> +		__clear_bit(start, map);
> >> +	else if (__builtin_constant_p(start & 7) && IS_ALIGNED(start, 8) &&
> >> +		 __builtin_constant_p(nbits & 7) && IS_ALIGNED(nbits, 8))
> > It looks strange to apply __builtin_constant_p test to variables after "& 7".
> >
> 
> I think this is normal - if the variables are known at compile time, the 
> calculation will be done at compile time (termed constant folding).

I think that

+	else if (__builtin_constant_p(start) && IS_ALIGNED(start, 8) &&
+		 __builtin_constant_p(nbits) && IS_ALIGNED(nbits, 8))

is more readable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
