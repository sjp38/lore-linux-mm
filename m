Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 71EA56B0033
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 22:45:16 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id x24so3033420pgv.5
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 19:45:16 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id i136si2278810pgc.293.2017.12.13.19.45.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Dec 2017 19:45:15 -0800 (PST)
Message-ID: <5A31F445.6070504@intel.com>
Date: Thu, 14 Dec 2017 11:47:17 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v19 3/7] xbitmap: add more operations
References: <1513079759-14169-1-git-send-email-wei.w.wang@intel.com>	<1513079759-14169-4-git-send-email-wei.w.wang@intel.com>	<201712122220.IFH05261.LtJOFFSFHVMQOO@I-love.SAKURA.ne.jp>	<5A311C5E.7000304@intel.com> <201712132316.EJJ57332.MFOSJHOFFVLtQO@I-love.SAKURA.ne.jp>
In-Reply-To: <201712132316.EJJ57332.MFOSJHOFFVLtQO@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com, nilal@redhat.com, riel@redhat.com

On 12/13/2017 10:16 PM, Tetsuo Handa wrote:
> Wei Wang wrote:
>> On 12/12/2017 09:20 PM, Tetsuo Handa wrote:
>>> Wei Wang wrote:
>>>> +void xb_clear_bit_range(struct xb *xb, unsigned long start, unsigned long end)
>>>> +{
>>>> +	struct radix_tree_root *root = &xb->xbrt;
>>>> +	struct radix_tree_node *node;
>>>> +	void **slot;
>>>> +	struct ida_bitmap *bitmap;
>>>> +	unsigned int nbits;
>>>> +
>>>> +	for (; start < end; start = (start | (IDA_BITMAP_BITS - 1)) + 1) {
>>>> +		unsigned long index = start / IDA_BITMAP_BITS;
>>>> +		unsigned long bit = start % IDA_BITMAP_BITS;
>>>> +
>>>> +		bitmap = __radix_tree_lookup(root, index, &node, &slot);
>>>> +		if (radix_tree_exception(bitmap)) {
>>>> +			unsigned long ebit = bit + 2;
>>>> +			unsigned long tmp = (unsigned long)bitmap;
>>>> +
>>>> +			nbits = min(end - start + 1, BITS_PER_LONG - ebit);
>>>> +
>>>> +			if (ebit >= BITS_PER_LONG)
>>> What happens if we hit this "continue;" when "index == ULONG_MAX / IDA_BITMAP_BITS" ?
>> Thanks. I also improved the test case for this. I plan to change the
>> implementation a little bit to avoid such overflow (has passed the test
>> case that I have, just post out for another set of eyes):
>>
>> {
>> ...
>>           unsigned long idx = start / IDA_BITMAP_BITS;
>>           unsigned long bit = start % IDA_BITMAP_BITS;
>>           unsigned long idx_end = end / IDA_BITMAP_BITS;
>>           unsigned long ret;
>>
>>           for (idx = start / IDA_BITMAP_BITS; idx <= idx_end; idx++) {
>>                   unsigned long ida_start = idx * IDA_BITMAP_BITS;
>>
>>                   bitmap = __radix_tree_lookup(root, idx, &node, &slot);
>>                   if (radix_tree_exception(bitmap)) {
>>                           unsigned long tmp = (unsigned long)bitmap;
>>                           unsigned long ebit = bit + 2;
>>
>>                           if (ebit >= BITS_PER_LONG)
>>                                   continue;
> Will you please please do eliminate exception path?

Please first see my explanations below, I'll try to help you understand 
it thoroughly. If it is really too complex to understand it finally, 
then I think we can start from the fundamental part by removing the 
exceptional path if no objections from others.

> I can't interpret what "ebit >= BITS_PER_LONG" means.
> The reason you "continue;" is that all bits beyond are "0", isn't it?
> Then, it would make sense to "continue;" when finding next "1" because
> all bits beyond are "0". But how does it make sense to "continue;" when
> finding next "0" despite all bits beyond are "0"?


Not the case actually. Please see this example:
1) xb_set_bit(10); // bit 10 is set, so an exceptional entry (i.e. 
[0:62]) is used
2) xb_clear_bit_range(66, 2048);
     - One ida bitmap size is 1024 bits, so this clear will be performed 
with 2 loops, first to clear [66, 1024), second to clear [1024, 2048)
     - When the first loop clears [66, 1024), and finds that it is an 
exception entry (because bit 10 is set, and the 62 bit entry is enough 
to cover). Another point we have to remember is that an exceptional 
entry implies that the rest of bits [63, 1024) are all 0s.
     - The starting bit 66 already exceeds the the exceptional entry bit 
range [0, 62], and with the fact that the rest of bits are all 0s, so it 
is time to just "continue", which goes to the second range [1024, 2048)

I used the example of xb_clear_bit_range(), and xb_find_next_bit() is 
the same fundamentally. Please let me know if anywhere still looks fuzzy.


>
>>                           if (set)
>>                                   ret = find_next_bit(&tmp,
>> BITS_PER_LONG, ebit);
>>                           else
>>                                   ret = find_next_zero_bit(&tmp,
>> BITS_PER_LONG,
>>                                                            ebit);
>>                           if (ret < BITS_PER_LONG)
>>                                   return ret - 2 + ida_start;
>>                   } else if (bitmap) {
>>                           if (set)
>>                                   ret = find_next_bit(bitmap->bitmap,
>>                                                       IDA_BITMAP_BITS, bit);
>>                           else
>>                                   ret = find_next_zero_bit(bitmap->bitmap,
>> IDA_BITMAP_BITS, bit);
> "bit" may not be 0 for the first round and "bit" is always 0 afterwords.
> But where is the guaranteed that "end" is a multiple of IDA_BITMAP_BITS ?
> Please explain why it is correct to use IDA_BITMAP_BITS unconditionally
> for the last round.

There missed something here, it will be:

nbits = min(end - ida_start + 1, IDA_BITMAP_BITS - bit);
if (set)
     ret = find_next_bit(bitmap->bitmap, nbits, bit);
else
     ret = find_next_zero_bit(bitmap->bitmap,
                                            nbits, bit);
if (ret < nbits)
     return ret + ida_start;


>>>> +/**
>>>> + * xb_find_next_set_bit - find the next set bit in a range
>>>> + * @xb: the xbitmap to search
>>>> + * @start: the start of the range, inclusive
>>>> + * @end: the end of the range, exclusive
>>>> + *
>>>> + * Returns: the index of the found bit, or @end + 1 if no such bit is found.
>>>> + */
>>>> +unsigned long xb_find_next_set_bit(struct xb *xb, unsigned long start,
>>>> +				   unsigned long end)
>>>> +{
>>>> +	return xb_find_next_bit(xb, start, end, 1);
>>>> +}
>>> Won't "exclusive" loose ability to handle ULONG_MAX ? Since this is a
>>> library module, missing ability to handle ULONG_MAX sounds like an omission.
>>> Shouldn't we pass (or return) whether "found or not" flag (e.g. strtoul() in
>>> C library function)?
>>>
>>>     bool xb_find_next_set_bit(struct xb *xb, unsigned long start, unsigned long end, unsigned long *result);
>>>     unsigned long xb_find_next_set_bit(struct xb *xb, unsigned long start, unsigned long end, bool *found);
>> Yes, ULONG_MAX needs to be tested by xb_test_bit(). Compared to checking
>> the return value, would it be the same to let the caller check for the
>> ULONG_MAX boundary?
>>
> Why the caller needs to care about whether it is ULONG_MAX or not?

I don't stick with this one, and will use the method that you suggested. 
Thanks for the review.


>
> Also, one more thing you need to check. Have you checked how long does
> xb_find_next_set_bit(xb, 0, ULONG_MAX) on an empty xbitmap takes?
> If it causes soft lockup warning, should we add cond_resched() ?
> If yes, you have to document that this API might sleep. If no, you
> have to document that the caller of this API is responsible for
> not to pass such a large value range.

Yes, that will take too long time. Probably we can document some 
comments as a reminder for the callers.

Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
