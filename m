Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 737AF6B0003
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 11:28:07 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id y16-v6so1108952pgv.23
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 08:28:07 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id v6-v6si1323094plp.60.2018.07.03.08.28.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 03 Jul 2018 08:28:06 -0700 (PDT)
Date: Tue, 3 Jul 2018 08:27:23 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v8 03/17] mm: Assign id to every memcg-aware shrinker
Message-ID: <20180703152723.GB21590@bombadil.infradead.org>
References: <153063036670.1818.16010062622751502.stgit@localhost.localdomain>
 <153063054586.1818.6041047871606697364.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <153063054586.1818.6041047871606697364.stgit@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: vdavydov.dev@gmail.com, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, lirongqing@baidu.com, aryabinin@virtuozzo.com, akpm@linux-foundation.org

On Tue, Jul 03, 2018 at 06:09:05PM +0300, Kirill Tkhai wrote:
> +++ b/mm/vmscan.c
> @@ -169,6 +169,49 @@ unsigned long vm_total_pages;
>  static LIST_HEAD(shrinker_list);
>  static DECLARE_RWSEM(shrinker_rwsem);
>  
> +#ifdef CONFIG_MEMCG_KMEM
> +static DEFINE_IDR(shrinker_idr);
> +static int shrinker_nr_max;

So ... we've now got a list_head (shrinker_list) which contains all of
the shrinkers, plus a shrinker_idr which contains the memcg-aware shrinkers?

Why not replace the shrinker_list with the shrinker_idr?  It's only used
twice in vmscan.c:

void register_shrinker_prepared(struct shrinker *shrinker)
{
        down_write(&shrinker_rwsem);
        list_add_tail(&shrinker->list, &shrinker_list);
        up_write(&shrinker_rwsem);
}

        list_for_each_entry(shrinker, &shrinker_list, list) {
...

The first is simply idr_alloc() and the second is

	idr_for_each_entry(&shrinker_idr, shrinker, id) {

I understand there's a difference between allocating the shrinker's ID and
adding it to the list.  You can do this by calling idr_alloc with NULL
as the pointer, and then using idr_replace() when you want to add the
shrinker to the list.  idr_for_each_entry() skips over NULL entries.

This will actually reduce the size of each shrinker and be more
cache-efficient when calling the shrinkers.  I think we can also get
rid of the shrinker_rwsem eventually, but let's leave it for now.
