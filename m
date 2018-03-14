Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 824156B000D
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 12:12:12 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id x8so2258169wrg.14
        for <linux-mm@kvack.org>; Wed, 14 Mar 2018 09:12:12 -0700 (PDT)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id k8si2105728wrf.484.2018.03.14.09.12.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Mar 2018 09:12:10 -0700 (PDT)
Subject: Re: [RFC PATCH v19 0/8] mm: security: ro protection for dynamic data
References: <20180313214554.28521-1-igor.stoppa@huawei.com>
 <a9bfc57f-1591-21b6-1676-b60341a2fadd@huawei.com>
 <20180314115653.GD29631@bombadil.infradead.org>
 <8623382b-cdbe-8862-8c2f-fa5bc6a1213a@huawei.com>
 <20180314130418.GG29631@bombadil.infradead.org>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <9623b0d1-4ace-b3e7-b861-edba03b8a8cd@huawei.com>
Date: Wed, 14 Mar 2018 18:11:22 +0200
MIME-Version: 1.0
In-Reply-To: <20180314130418.GG29631@bombadil.infradead.org>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: keescook@chromium.org, david@fromorbit.com, rppt@linux.vnet.ibm.com, mhocko@kernel.org, labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com



On 14/03/18 15:04, Matthew Wilcox wrote:

> I don't necessarily think you should use it as-is,

I think I simply cannot use it as-is, because it seems to use linear
memory, while I need virtual. This reason alone would require a rewrite
of several parts.

> but the principle it uses
> seems like a better match to me than the rather complex genalloc.

It uses meta data in a different way than genalloc.
There is probably a tipping point where one implementation becomes more
space-efficient than the other.

Probably page_frag does well with relatively large allocations, while
genalloc seems to be better for small (few allocation units) allocations.

Also, in case of high variance in the size of the allocations, genalloc
requires the allocation unit to be small enough to fit the smallest
request (otherwise one must accept some slack), while page_frag doesn't
care if the allocation is small or large.

page_frag otoh, seems to not support the reuse of space that was freed,
since there is only

But could you please explain to what you are referring to, when you say
that page_frag has "significantly lower overhead" ?

Is it because it doesn't try to reclaim space that was freed, until the
whole page is empty?

I see different trade-offs, but I am probably either missing or
underestimating the main reason why you think this is better.

And probably I am missing the capability of judging what is acceptable
in certain cases.

Ex: if the pfree is called only on error paths, is it ok to not claim
back the memory released, if it's less than one page?

To be clear: I do not want to hold to genalloc just because I have
already implemented it. I can at least sketch a version with page_frag,
but I would like to understand why its trade-offs are better :-)

> Just allocate some pages and track the offset within those pages that 

> is the current allocation point.


> It's less than 100 lines of code!

Strictly speaking it is true, but it all relies on other functions,
which must be rewritten, because they use linear address, while this
must work with virtual (vmalloc) addresses.

Also, I see that the code relies a lot on order of allocation.
I think we had similar discussion wrt compound pages.

It seems to me wasteful, if I have a request of, say, 5 pages, and I end
up allocating 8.

I do not recall anyone giving a justification like:
"yeah, it uses extra pages, but it's preferable, for reasons X, Y and Z,
so it's a good trade-off"

Could it be that it's normal RAM is considered less precious than the
special memory genalloc is written for, so normal RAM is not really
proactively reused, while special memory is treated as a more valuable
resource that should not be wasted?


--
igor
