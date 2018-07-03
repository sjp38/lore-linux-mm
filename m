Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 603236B026F
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 11:47:10 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id h14-v6so1246010pfi.19
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 08:47:10 -0700 (PDT)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50114.outbound.protection.outlook.com. [40.107.5.114])
        by mx.google.com with ESMTPS id q7-v6si1202631pgt.556.2018.07.03.08.47.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 03 Jul 2018 08:47:09 -0700 (PDT)
Subject: Re: [PATCH v8 03/17] mm: Assign id to every memcg-aware shrinker
References: <153063036670.1818.16010062622751502.stgit@localhost.localdomain>
 <153063054586.1818.6041047871606697364.stgit@localhost.localdomain>
 <20180703152723.GB21590@bombadil.infradead.org>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <2d845a0d-d147-7250-747e-27e493b6a627@virtuozzo.com>
Date: Tue, 3 Jul 2018 18:46:57 +0300
MIME-Version: 1.0
In-Reply-To: <20180703152723.GB21590@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: vdavydov.dev@gmail.com, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, lirongqing@baidu.com, aryabinin@virtuozzo.com, akpm@linux-foundation.org

On 03.07.2018 18:27, Matthew Wilcox wrote:
> On Tue, Jul 03, 2018 at 06:09:05PM +0300, Kirill Tkhai wrote:
>> +++ b/mm/vmscan.c
>> @@ -169,6 +169,49 @@ unsigned long vm_total_pages;
>>  static LIST_HEAD(shrinker_list);
>>  static DECLARE_RWSEM(shrinker_rwsem);
>>  
>> +#ifdef CONFIG_MEMCG_KMEM
>> +static DEFINE_IDR(shrinker_idr);
>> +static int shrinker_nr_max;
> 
> So ... we've now got a list_head (shrinker_list) which contains all of
> the shrinkers, plus a shrinker_idr which contains the memcg-aware shrinkers?
> 
> Why not replace the shrinker_list with the shrinker_idr?  It's only used
> twice in vmscan.c:
> 
> void register_shrinker_prepared(struct shrinker *shrinker)
> {
>         down_write(&shrinker_rwsem);
>         list_add_tail(&shrinker->list, &shrinker_list);
>         up_write(&shrinker_rwsem);
> }
> 
>         list_for_each_entry(shrinker, &shrinker_list, list) {
> ...
> 
> The first is simply idr_alloc() and the second is
> 
> 	idr_for_each_entry(&shrinker_idr, shrinker, id) {
> 
> I understand there's a difference between allocating the shrinker's ID and
> adding it to the list.  You can do this by calling idr_alloc with NULL
> as the pointer, and then using idr_replace() when you want to add the
> shrinker to the list.  idr_for_each_entry() skips over NULL entries.

shrinker_idr now contains only memcg-aware shrinkers, so all bits from memcg map
may be potentially populated. In case of memcg-aware shrinkers and !memcg-aware
shrinkers share the same numbers like you suggest, this will lead to increasing
size of memcg maps, which is bad for memory consumption. So, memcg-aware shrinkers
should to have its own IDR and its own numbers. The tricks like allocation big
IDs for !memcg-aware shrinkers seem bad for me, since they make the code more
complicated.

> This will actually reduce the size of each shrinker and be more
> cache-efficient when calling the shrinkers.  I think we can also get
> rid of the shrinker_rwsem eventually, but let's leave it for now.

This patchset does not make the cache-efficient bad, since without the patchset the situation
is so bad, that it's just impossible to talk about the cache efficiently,
so let's leave lockless iteration/etc for the future works.

Kirill
