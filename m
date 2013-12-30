Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id AC24C6B0031
	for <linux-mm@kvack.org>; Sun, 29 Dec 2013 20:08:10 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id fa1so11175376pad.10
        for <linux-mm@kvack.org>; Sun, 29 Dec 2013 17:08:10 -0800 (PST)
Received: from e28smtp01.in.ibm.com (e28smtp01.in.ibm.com. [122.248.162.1])
        by mx.google.com with ESMTPS id o7si20688367pbb.130.2013.12.29.17.08.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 29 Dec 2013 17:08:08 -0800 (PST)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Mon, 30 Dec 2013 06:38:05 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 0219FE0056
	for <linux-mm@kvack.org>; Mon, 30 Dec 2013 06:40:40 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBU180Mp53084328
	for <linux-mm@kvack.org>; Mon, 30 Dec 2013 06:38:00 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBU181Sr011703
	for <linux-mm@kvack.org>; Mon, 30 Dec 2013 06:38:01 +0530
Date: Mon, 30 Dec 2013 09:08:00 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/slub: fix accumulate per cpu partial cache objects
Message-ID: <52c0c778.470b440a.3fc0.ffffa9b1SMTPIN_ADDED_BROKEN@mx.google.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1388137619-14741-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <52BE2E74.1070107@huawei.com>
 <CAOJsxLFH5LGuF+vutPzB90EM9o376Jc99-rjY4qq18d1KQshhg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOJsxLFH5LGuF+vutPzB90EM9o376Jc99-rjY4qq18d1KQshhg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Li Zefan <lizefan@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Sun, Dec 29, 2013 at 01:49:48PM +0200, Pekka Enberg wrote:
>On Sat, Dec 28, 2013 at 3:50 AM, Li Zefan <lizefan@huawei.com> wrote:
>> On 2013/12/27 17:46, Wanpeng Li wrote:
>>> SLUB per cpu partial cache is a list of slab caches to accelerate objects
>>> allocation. However, current codes just accumulate the objects number of
>>> the first slab cache of per cpu partial cache instead of traverse the whole
>>> list.
>>>
>>> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>>> ---
>>>  mm/slub.c |   32 +++++++++++++++++++++++---------
>>>  1 files changed, 23 insertions(+), 9 deletions(-)
>>>
>>> diff --git a/mm/slub.c b/mm/slub.c
>>> index 545a170..799bfdc 100644
>>> --- a/mm/slub.c
>>> +++ b/mm/slub.c
>>> @@ -4280,7 +4280,7 @@ static ssize_t show_slab_objects(struct kmem_cache *s,
>>>                       struct kmem_cache_cpu *c = per_cpu_ptr(s->cpu_slab,
>>>                                                              cpu);
>>>                       int node;
>>> -                     struct page *page;
>>> +                     struct page *page, *p;
>>>
>>>                       page = ACCESS_ONCE(c->page);
>>>                       if (!page)
>>> @@ -4298,8 +4298,9 @@ static ssize_t show_slab_objects(struct kmem_cache *s,
>>>                       nodes[node] += x;
>>>
>>>                       page = ACCESS_ONCE(c->partial);
>>> -                     if (page) {
>>> -                             x = page->pobjects;
>>> +                     while ((p = page)) {
>>> +                             page = p->next;
>>> +                             x = p->pobjects;
>>>                               total += x;
>>>                               nodes[node] += x;
>>>                       }
>>
>> Can we apply this patch first? It was sent month ago, but Pekka was not responsive.
>
>Applied. Wanpeng, care to resend your patch?

Zefan's patch is good enough, mine doesn't need any more.

Regards,
Wanpeng Li 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
