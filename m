Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 510976B000E
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 07:22:46 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id j12so1445777pff.18
        for <linux-mm@kvack.org>; Wed, 14 Mar 2018 04:22:46 -0700 (PDT)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id f86si1335868pfk.179.2018.03.14.04.22.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Mar 2018 04:22:45 -0700 (PDT)
Subject: Re: [RFC PATCH v19 0/8] mm: security: ro protection for dynamic data
References: <20180313214554.28521-1-igor.stoppa@huawei.com>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <a9bfc57f-1591-21b6-1676-b60341a2fadd@huawei.com>
Date: Wed, 14 Mar 2018 13:21:54 +0200
MIME-Version: 1.0
In-Reply-To: <20180313214554.28521-1-igor.stoppa@huawei.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: willy@infradead.org, keescook@chromium.org
Cc: david@fromorbit.com, rppt@linux.vnet.ibm.com, mhocko@kernel.org, labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On 13/03/18 23:45, Igor Stoppa wrote:

[...]

Some more thoughts about the open topics:

> Discussion topics that are unclear if they are closed and would need
> comment from those who initiated them, if my answers are accepted or not:
> 
> * @Kees Cook proposed to have first self testing for genalloc, to
>   validate the following patch, adding tracing of allocations
>   My answer was that such tests would also need patching, therefore they 
>   could not certify that the functionality is corect both before and
>   after the genalloc bitmap modification.

This is the only one where I still couldn't find a solution.
If Matthew Wilcox's proposal about implementing the the genalloc bitmap
would work, then this too could be done, but I think this alternate
bitmap proposed has problems. More on it below.

> * @Kees Cook proposed to turn the self testing into modules.
>   My answer was that the functionality is intentionally tested very early
>   in the boot phase, to prevent unexplainable errors, should the feature
>   really fail.

This could be workable, if it's acceptable that the early testing is
performed only when the module is compiled in.
I do not expect the module-based testing to bring much value, but it
doesn't do harm. Is this acceptable?

> * @Matthew Wilcox proposed to use a different mechanism for the genalloc
>   bitmap: 2 bitmaps, one for occupation and one for start.
>   And possibly use an rbtree for the starts.
>   My answer was that this solution is less optimized, because it scatters
>   the data of one allocation across multiple words/pages, plus is not
>   a transaction anymore. And the particular distribution of sizes of
>   allocation is likely to eat up much more memory than the bitmap.

I think I can describe a scenario where the split bitmaps would not work
(based on my understanding of the proposal), but I would appreciate a
review. Here it is:

* One allocation (let's call it allocation A) is already present in both
bitmaps:
  - its units of allocation are marked in the "space" bitmap
  - its starting bit is marked in the "starts" bitmap

* Another allocation (let's call it allocation B) is undergoing:
  - some of its units of allocation (starting from the beginning) are
    marked in the "space" bitmap
  - the starting bit is *not* yet marked in the "starts" bitmap

* B occupies the space immediately after A

* While B is being written, A is freed

* Having to determine the length of A, the "space" bitmap will be
  searched, then the "starts" bitmap


The space initially allocated for B will be wrongly accounted for A,
because there is no empty gap in-between and the beginning of B is not
yet marked.

The implementation which interleaves "space" and "start" does not suffer
from this sort of races, because the alteration of the interleaved
bitmaps is atomic.

However, at the very least, some more explanation is needed in the
documentation/code, because this scenario is not exactly obvious.

Does this justification for the use of interleaved bitmaps (iow the
current implementation) make sense?

--
igor
