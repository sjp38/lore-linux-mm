Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id D33FC6B0008
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 12:17:27 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id k8-v6so2465873qtj.18
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 09:17:27 -0700 (PDT)
Received: from EUR02-VE1-obe.outbound.protection.outlook.com (mail-eopbgr20110.outbound.protection.outlook.com. [40.107.2.110])
        by mx.google.com with ESMTPS id q20-v6si1409115qtc.381.2018.07.03.09.17.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 03 Jul 2018 09:17:26 -0700 (PDT)
Subject: Re: [PATCH v8 03/17] mm: Assign id to every memcg-aware shrinker
References: <153063036670.1818.16010062622751502.stgit@localhost.localdomain>
 <153063054586.1818.6041047871606697364.stgit@localhost.localdomain>
 <20180703152723.GB21590@bombadil.infradead.org>
 <CALvZod7xAP9AjRWp2XX1uJBkuOprYKCf7hzAXNTdw89dc-n4OA@mail.gmail.com>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <a9fe3e9e-a1b7-ee19-35e6-af32b5f25a37@virtuozzo.com>
Date: Tue, 3 Jul 2018 19:17:14 +0300
MIME-Version: 1.0
In-Reply-To: <CALvZod7xAP9AjRWp2XX1uJBkuOprYKCf7hzAXNTdw89dc-n4OA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>, Matthew Wilcox <willy@infradead.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Philippe Ombredanne <pombredanne@nexb.com>, stummala@codeaurora.org, gregkh@linuxfoundation.org, Stephen Rothwell <sfr@canb.auug.org.au>, Roman Gushchin <guro@fb.com>, mka@chromium.org, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Chris Wilson <chris@chris-wilson.co.uk>, longman@redhat.com, Minchan Kim <minchan@kernel.org>, Huang Ying <ying.huang@intel.com>, Mel Gorman <mgorman@techsingularity.net>, jbacik@fb.com, Guenter Roeck <linux@roeck-us.net>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, lirongqing@baidu.com, Andrey Ryabinin <aryabinin@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>

Hi, Shakeel,

On 03.07.2018 18:46, Shakeel Butt wrote:
> On Tue, Jul 3, 2018 at 8:27 AM Matthew Wilcox <willy@infradead.org> wrote:
>>
>> On Tue, Jul 03, 2018 at 06:09:05PM +0300, Kirill Tkhai wrote:
>>> +++ b/mm/vmscan.c
>>> @@ -169,6 +169,49 @@ unsigned long vm_total_pages;
>>>  static LIST_HEAD(shrinker_list);
>>>  static DECLARE_RWSEM(shrinker_rwsem);
>>>
>>> +#ifdef CONFIG_MEMCG_KMEM
>>> +static DEFINE_IDR(shrinker_idr);
>>> +static int shrinker_nr_max;
>>
>> So ... we've now got a list_head (shrinker_list) which contains all of
>> the shrinkers, plus a shrinker_idr which contains the memcg-aware shrinkers?
>>
>> Why not replace the shrinker_list with the shrinker_idr?  It's only used
>> twice in vmscan.c:
>>
>> void register_shrinker_prepared(struct shrinker *shrinker)
>> {
>>         down_write(&shrinker_rwsem);
>>         list_add_tail(&shrinker->list, &shrinker_list);
>>         up_write(&shrinker_rwsem);
>> }
>>
>>         list_for_each_entry(shrinker, &shrinker_list, list) {
>> ...
>>
>> The first is simply idr_alloc() and the second is
>>
>>         idr_for_each_entry(&shrinker_idr, shrinker, id) {
>>
>> I understand there's a difference between allocating the shrinker's ID and
>> adding it to the list.  You can do this by calling idr_alloc with NULL
>> as the pointer, and then using idr_replace() when you want to add the
>> shrinker to the list.  idr_for_each_entry() skips over NULL entries.
>>
>> This will actually reduce the size of each shrinker and be more
>> cache-efficient when calling the shrinkers.  I think we can also get
>> rid of the shrinker_rwsem eventually, but let's leave it for now.
> 
> Can you explain how you envision shrinker_rwsem can be removed? I am
> very much interested in doing that.

Have you tried to do some games with SRCU? It looks like we just need to
teach count_objects() and scan_objects() to work with semi-destructed
shrinkers. Though, this looks this will make impossible to introduce
shrinkers, which do synchronize_srcu() in scan_objects() for example.
Not sure, someone will actually use this, and this is possible to consider
as limitation.

Kirill
