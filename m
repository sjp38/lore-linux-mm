Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 41A096B0038
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 06:59:28 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id j26so5466016pff.8
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 03:59:28 -0800 (PST)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id e9si2294607plk.690.2017.12.07.03.59.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Dec 2017 03:59:26 -0800 (PST)
Message-ID: <5A292D94.5000700@intel.com>
Date: Thu, 07 Dec 2017 20:01:24 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v18 05/10] xbitmap: add more operations
References: <201711301934.CDC21800.FSLtJFFOOVQHMO@I-love.SAKURA.ne.jp>	<5A210C96.8050208@intel.com>	<201712012202.BDE13557.MJFQLtOOHVOFSF@I-love.SAKURA.ne.jp>	<286AC319A985734F985F78AFA26841F739376DA1@shsmsx102.ccr.corp.intel.com>	<20171201172519.GA27192@bombadil.infradead.org> <201712031050.IAC64520.QVLFFOOJOSFtHM@I-love.SAKURA.ne.jp>
In-Reply-To: <201712031050.IAC64520.QVLFFOOJOSFtHM@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, willy@infradead.org
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com, nilal@redhat.com, riel@redhat.com

On 12/03/2017 09:50 AM, Tetsuo Handa wrote:
> Matthew Wilcox wrote:
>> On Fri, Dec 01, 2017 at 03:09:08PM +0000, Wang, Wei W wrote:
>>> On Friday, December 1, 2017 9:02 PM, Tetsuo Handa wrote:
>>>> If start == end is legal,
>>>>
>>>>     for (; start < end; start = (start | (IDA_BITMAP_BITS - 1)) + 1) {
>>>>
>>>> makes this loop do nothing because 10 < 10 is false.
>>> How about "start <= end "?
>> Don't ask Tetsuo for his opinion, write some userspace code that uses it.
>>
> Please be sure to prepare for "end == -1UL" case, for "start < end" will become
> true when "start = (start | (IDA_BITMAP_BITS - 1)) + 1" made "start == 0" due to
> overflow.

I think there is one more corner case with this API: searching for bit 
"1" from [0, ULONG_MAX] while no bit is set in the range, there appear 
to be no possible value that we can return (returning "end + 1" will be 
"ULONG_MAX + 1", which is 0)
I plan to make the "end" be exclusive of the searching, that is, [start, 
end), and return "end" if no such bit is found.

For cases like [16, 16), returning 16 doesn't mean bit 16 is 1 or 0, it 
simply means there is no bits to search in the given range, since 16 is 
exclusive.

Please let me know if you have a different thought.

Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
