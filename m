Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1FC386B0012
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 11:43:11 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id t10-v6so3281957plr.12
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 08:43:11 -0700 (PDT)
Received: from EUR02-VE1-obe.outbound.protection.outlook.com (mail-eopbgr20090.outbound.protection.outlook.com. [40.107.2.90])
        by mx.google.com with ESMTPS id r1si3410252pff.24.2018.03.21.08.43.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 21 Mar 2018 08:43:09 -0700 (PDT)
Subject: Re: [PATCH 03/10] mm: Assign memcg-aware shrinkers bitmap to memcg
References: <152163840790.21546.980703278415599202.stgit@localhost.localdomain>
 <152163850081.21546.6969747084834474733.stgit@localhost.localdomain>
 <20180321145625.GA4780@bombadil.infradead.org>
 <eda62454-5788-4f65-c2b5-719d4a98cb2a@virtuozzo.com>
 <20180321152647.GB4780@bombadil.infradead.org>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <638887a1-35f8-a71d-6e45-4e779eb62dc4@virtuozzo.com>
Date: Wed, 21 Mar 2018 18:43:01 +0300
MIME-Version: 1.0
In-Reply-To: <20180321152647.GB4780@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com, akpm@linux-foundation.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, hillf.zj@alibaba-inc.com, ying.huang@intel.com, mgorman@techsingularity.net, shakeelb@google.com, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 21.03.2018 18:26, Matthew Wilcox wrote:
> On Wed, Mar 21, 2018 at 06:12:17PM +0300, Kirill Tkhai wrote:
>> On 21.03.2018 17:56, Matthew Wilcox wrote:
>>> Why use your own bitmap here?  Why not use an IDA which can grow and
>>> shrink automatically without you needing to play fun games with RCU?
>>
>> Bitmap allows to use unlocked set_bit()/clear_bit() to maintain the map
>> of not empty shrinkers.
>>
>> So, the reason to use IDR here is to save bitmap memory? Does this mean
>> IDA works fast with sparse identifiers? It seems they require per-memcg
>> lock to call IDR primitives. I just don't have information about this.
>>
>> If so, which IDA primitive can be used to set particular id in bitmap?
>> There is idr_alloc_cyclic(idr, NULL, id, id+1, GFP_KERNEL) only I see
>> to do that.
> 
> You're confusing IDR and IDA in your email, which is unfortunate.
> 
> You can set a bit in an IDA by calling ida_simple_get(ida, n, n, GFP_FOO);
> You clear it by calling ida_simple_remove(ida, n);

I moved to IDR in the message, since IDA uses global spinlock. It will be
taken every time a first object is added to list_lru, or last is removed.
These may be frequently called operations, and they may scale not good
on big machines.

Using IDR will allow us to introduce memcg-related locks, but I'm still not
sure it's easy to introduce them in scalable-way. Simple set_bit()/clear_bit()
do not require locks at all.

> The identifiers aren't going to be all that sparse; after all you're
> allocating them from a global IDA.  Up to 62 identifiers will allocate
> no memory; 63-1024 identifiers will allocate a single 128 byte chunk.
> Between 1025 and 65536 identifiers, you'll allocate a 576-byte chunk
> and then 128-byte chunks for each block of 1024 identifiers (*).  One of
> the big wins with the IDA is that it will shrink again after being used.
> I didn't read all the way through your patchset to see if you bother to
> shrink your bitmap after it's no longer used, but most resizing bitmaps
> we have in the kernel don't bother with that part.
> 
> (*) Actually it's more complex than that... between 1025 and 1086,
> you'll have a 576 byte chunk, a 128-byte chunk and then use 62 bits of
> the next pointer before allocating a 128 byte chunk when reaching ID
> 1087.  Similar things happen for the 62 bits after 2048, 3076 and so on.
> The individual chunks aren't shrunk until they're empty so if you set ID
> 1025 and then ID 1100, then clear ID 1100, the 128-byte chunk will remain
> allocated until ID 1025 is cleared.  This probably doesn't matter to you.

Sound great, thanks for explaining this. The big problem I see is
that IDA/IDR add primitives allocate memory, while they will be used
in the places, where they mustn't fail. There is list_lru_add(), and
it's called unconditionally in current kernel code. The patchset makes
the bitmap be populated in this function. So, we can't use IDR there.

Thanks,
Kirill
