Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id ED13B8E0001
	for <linux-mm@kvack.org>; Fri, 28 Sep 2018 19:59:11 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id a77-v6so7250600wrc.16
        for <linux-mm@kvack.org>; Fri, 28 Sep 2018 16:59:11 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0094.outbound.protection.outlook.com. [104.47.1.94])
        by mx.google.com with ESMTPS id n2-v6si930549wre.370.2018.09.28.16.59.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 28 Sep 2018 16:59:10 -0700 (PDT)
Subject: Re: [PATCH] mm: Fix int overflow in callers of do_shrink_slab()
References: <153813407177.17544.14888305435570723973.stgit@localhost.localdomain>
 <20180928141509.fd8f8ac8c0ea61f0cb79d494@linux-foundation.org>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <ec297f1e-529e-799b-b98c-51472cd64b15@virtuozzo.com>
Date: Sat, 29 Sep 2018 02:58:54 +0300
MIME-Version: 1.0
In-Reply-To: <20180928141509.fd8f8ac8c0ea61f0cb79d494@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: gorcunov@openvz.org, mhocko@suse.com, aryabinin@virtuozzo.com, hannes@cmpxchg.org, penguin-kernel@I-love.SAKURA.ne.jp, shakeelb@google.com, jbacik@fb.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 29.09.2018 00:15, Andrew Morton wrote:
> On Fri, 28 Sep 2018 14:28:32 +0300 Kirill Tkhai <ktkhai@virtuozzo.com> wrote:
> 
>> do_shrink_slab() returns unsigned long value, and
>> the placing into int variable cuts high bytes off.
>> Then we compare ret and 0xfffffffe (since SHRINK_EMPTY
>> is converted to ret type).
>>
>> Thus, big number of objects returned by do_shrink_slab()
>> may be interpreted as SHRINK_EMPTY, if low bytes of
>> their value are equal to 0xfffffffe. Fix that
>> by declaration ret as unsigned long in these functions.
> 
> Sigh.  How many times has this happened.
> 
>> Reported-by: Cyrill Gorcunov <gorcunov@openvz.org>
> 
> What did he report?  Was it code inspection?  Did the kernel explode? 
> etcetera.  I'm thinking that the fix should be backported but to
> determine that, we need to understand the end-user runtime effects, as
> always.  Please.

Yeah, it was just code inspection. It's need to be a really unlucky person
to meet this in real life -- the probability is very small.

The runtime effect would be the following. Such the unlucky person would
have a single shrinker, which is never called for a single memory cgroup,
despite there are objects charged.

Thanks,
Kirill
