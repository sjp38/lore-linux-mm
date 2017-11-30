Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3072C6B0038
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 15:55:04 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id g134so3331646oib.8
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 12:55:04 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 3si1560647oil.157.2017.11.30.12.55.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Nov 2017 12:55:03 -0800 (PST)
Subject: Re: [PATCH] list_lru: Prefetch neighboring list entries before
 acquiring lock
References: <1511965054-6328-1-git-send-email-longman@redhat.com>
 <20171129135319.ab078fbed566be8fc90c92ec@linux-foundation.org>
 <20171130004252.GR4094@dastard>
 <209d1aea-2951-9d4f-5638-8bc037a6676c@redhat.com>
 <20171130203800.GS4094@dastard>
From: Waiman Long <longman@redhat.com>
Message-ID: <04d15b8d-d69f-660f-2196-a10aab2fefa6@redhat.com>
Date: Thu, 30 Nov 2017 15:55:01 -0500
MIME-Version: 1.0
In-Reply-To: <20171130203800.GS4094@dastard>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 11/30/2017 03:38 PM, Dave Chinner wrote:
> On Thu, Nov 30, 2017 at 08:54:04AM -0500, Waiman Long wrote:
>>
>> For the record, I add one more list_empty() check at the beginning of
>> list_lru_del() in the patch for 2 purpose:
>> 1. it allows the code to bail out early.
> Which is what I said was wrong. You haven't addressed why you think
> it's safe to add racy specualtive checks to this code in your quest
> for speed.
>
> Also, I'm curious about is how much of the gain is from the
> prefetching, and how much of the gain is from avoiding the lock
> altogether by the early bailout...

The early bailout doesn't improve the test at all. In the case of
dentries, there is a flag that indicates that the dentry is in the LRU
list. So list_lru_del is only called when it is in the LRU list.

>> 2. It make sure the cacheline of the list_head entry itself is loaded.=

>>
>> Other than that, I only add a likely() qualifier to the existing
>> list_empty() check within the lock critical region.
> Yup, but in many cases programmers get the static branch prediction
> hints are wrong. In this case, you are supposing that nobody ever
> calls list_lru_del() on objects that aren't on the lru. That's not
> true - inodes that are being evicted may never have been on the LRU
> at all, but we still call through list_lru_del() so it can determine
> the LRU state correctly (e.g. cache cold rm -rf workloads)....
>
> IOWs, I'm pretty sure even just adding static branch prediction
> hints here is wrong....

In the case of dentries, the static branch is right. However it may not
be true for other users of list_lru, so I am OK to take them out. Thanks
for the explanation.

Cheers,
Longman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
