Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id E27A46B0005
	for <linux-mm@kvack.org>; Sat,  3 Feb 2018 11:14:19 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id b195so5327166wmb.1
        for <linux-mm@kvack.org>; Sat, 03 Feb 2018 08:14:19 -0800 (PST)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id 52si3834743wrx.215.2018.02.03.08.14.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 03 Feb 2018 08:14:18 -0800 (PST)
Subject: Re: [PATCH 3/6] struct page: add field for vm_struct
References: <20180130151446.24698-1-igor.stoppa@huawei.com>
 <20180130151446.24698-4-igor.stoppa@huawei.com>
 <alpine.DEB.2.20.1801311758340.21272@nuc-kabylake>
 <48fde114-d063-cfbf-e1b6-262411fcd963@huawei.com>
 <alpine.DEB.2.20.1802021240370.31548@nuc-kabylake>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <a12afe9b-79cf-d5c1-3795-89fbf61c6c9d@huawei.com>
Date: Sat, 3 Feb 2018 18:13:58 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1802021240370.31548@nuc-kabylake>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: jglisse@redhat.com, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, hch@infradead.org, willy@infradead.org, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com



On 02/02/18 20:43, Christopher Lameter wrote:
> On Thu, 1 Feb 2018, Igor Stoppa wrote:
> 
>>> Would it not be better to use compound page allocations here?

[...]

> Ok its compound_head(). See also the use in the SLAB and SLUB allocator.
> 
>> During hardened user copy permission check, I need to confirm if the
>> memory range that would be exposed to userspace is a legitimate
>> sub-range of a pmalloc allocation.
> 
> If you save the size in the head page struct then you could do that pretty
> fast.

Ok, now I get what you mean.
But it doesn't seem to fit the intended use case, for other reasons
(maybe the same, from 2 different POV):

- compound pages are aggregates of regular pages, in numbers that are
powers of 2, while the amount of pages to allocate is not known upfront.
One *could* give a hint to pmalloc about how many pages to allocate
every time there is a need to grow the pool.
Iow it would be the size of a chunk. But I'm afraid the granularity
would still be pretty low, so maybe it would be 2-4 times less.

- the property of the compound page will affect the property of all the
pages in the compound, so when one is write protected, it can generate a
lot of wasted memory, if there is too much slack (because of the order)
With vmalloc, I can allocate any number of pages, minimizing the waste.


Finally, there was a discussion about optimization:
http://www.openwall.com/lists/kernel-hardening/2017/08/07/2

The patch I sent does indeed take advantage of the new information, not
just for pmalloc use.

I have not measured if/where/what there is gain, but it does look like
the extra info can be exploited also elsewhere.

--
igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
