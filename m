Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id C62776B0032
	for <linux-mm@kvack.org>; Mon,  5 Jan 2015 03:39:17 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id kq14so28264084pab.20
        for <linux-mm@kvack.org>; Mon, 05 Jan 2015 00:39:17 -0800 (PST)
Received: from out11.biz.mail.alibaba.com (out114-135.biz.mail.alibaba.com. [205.204.114.135])
        by mx.google.com with ESMTP id y5si49932810pas.143.2015.01.05.00.39.14
        for <linux-mm@kvack.org>;
        Mon, 05 Jan 2015 00:39:16 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
Subject: Re: [PATCH 1/2] mm/slub: optimize alloc/free fastpath by removing preemption on/off
Date: Mon, 05 Jan 2015 16:37:35 +0800
Message-ID: <023701d028c2$dba2cb30$92e86190$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Joonsoo Kim' <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, 'Christoph Lameter' <cl@linux.com>, 'Pekka Enberg' <penberg@kernel.org>, 'David Rientjes' <rientjes@google.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Steven Rostedt <rostedt@goodmis.org>, 'Jesper Dangaard Brouer' <brouer@redhat.com>

> 
> We had to insert a preempt enable/disable in the fastpath a while ago
> in order to guarantee that tid and kmem_cache_cpu are retrieved on the
> same cpu. It is the problem only for CONFIG_PREEMPT in which scheduler
> can move the process to other cpu during retrieving data.
> 
> Now, I reach the solution to remove preempt enable/disable in the fastpath.
> If tid is matched with kmem_cache_cpu's tid after tid and kmem_cache_cpu
> are retrieved by separate this_cpu operation, it means that they are
> retrieved on the same cpu. If not matched, we just have to retry it.
> 
> With this guarantee, preemption enable/disable isn't need at all even if
> CONFIG_PREEMPT, so this patch removes it.
> 
> I saw roughly 5% win in a fast-path loop over kmem_cache_alloc/free
> in CONFIG_PREEMPT. (14.821 ns -> 14.049 ns)
> 
> Below is the result of Christoph's slab_test reported by
> Jesper Dangaard Brouer.
> 
> * Before
> 
>  Single thread testing
>  =====================
>  1. Kmalloc: Repeatedly allocate then free test
>  10000 times kmalloc(8) -> 49 cycles kfree -> 62 cycles
>  10000 times kmalloc(16) -> 48 cycles kfree -> 64 cycles
>  10000 times kmalloc(32) -> 53 cycles kfree -> 70 cycles
>  10000 times kmalloc(64) -> 64 cycles kfree -> 77 cycles
>  10000 times kmalloc(128) -> 74 cycles kfree -> 84 cycles
>  10000 times kmalloc(256) -> 84 cycles kfree -> 114 cycles
>  10000 times kmalloc(512) -> 83 cycles kfree -> 116 cycles
>  10000 times kmalloc(1024) -> 81 cycles kfree -> 120 cycles
>  10000 times kmalloc(2048) -> 104 cycles kfree -> 136 cycles
>  10000 times kmalloc(4096) -> 142 cycles kfree -> 165 cycles
>  10000 times kmalloc(8192) -> 238 cycles kfree -> 226 cycles
>  10000 times kmalloc(16384) -> 403 cycles kfree -> 264 cycles
>  2. Kmalloc: alloc/free test
>  10000 times kmalloc(8)/kfree -> 68 cycles
>  10000 times kmalloc(16)/kfree -> 68 cycles
>  10000 times kmalloc(32)/kfree -> 69 cycles
>  10000 times kmalloc(64)/kfree -> 68 cycles
>  10000 times kmalloc(128)/kfree -> 68 cycles
>  10000 times kmalloc(256)/kfree -> 68 cycles
>  10000 times kmalloc(512)/kfree -> 74 cycles
>  10000 times kmalloc(1024)/kfree -> 75 cycles
>  10000 times kmalloc(2048)/kfree -> 74 cycles
>  10000 times kmalloc(4096)/kfree -> 74 cycles
>  10000 times kmalloc(8192)/kfree -> 75 cycles
>  10000 times kmalloc(16384)/kfree -> 510 cycles
> 
> * After
> 
>  Single thread testing
>  =====================
>  1. Kmalloc: Repeatedly allocate then free test
>  10000 times kmalloc(8) -> 46 cycles kfree -> 61 cycles
>  10000 times kmalloc(16) -> 46 cycles kfree -> 63 cycles
>  10000 times kmalloc(32) -> 49 cycles kfree -> 69 cycles
>  10000 times kmalloc(64) -> 57 cycles kfree -> 76 cycles
>  10000 times kmalloc(128) -> 66 cycles kfree -> 83 cycles
>  10000 times kmalloc(256) -> 84 cycles kfree -> 110 cycles
>  10000 times kmalloc(512) -> 77 cycles kfree -> 114 cycles
>  10000 times kmalloc(1024) -> 80 cycles kfree -> 116 cycles
>  10000 times kmalloc(2048) -> 102 cycles kfree -> 131 cycles
>  10000 times kmalloc(4096) -> 135 cycles kfree -> 163 cycles
>  10000 times kmalloc(8192) -> 238 cycles kfree -> 218 cycles
>  10000 times kmalloc(16384) -> 399 cycles kfree -> 262 cycles
>  2. Kmalloc: alloc/free test
>  10000 times kmalloc(8)/kfree -> 65 cycles
>  10000 times kmalloc(16)/kfree -> 66 cycles
>  10000 times kmalloc(32)/kfree -> 65 cycles
>  10000 times kmalloc(64)/kfree -> 66 cycles
>  10000 times kmalloc(128)/kfree -> 66 cycles
>  10000 times kmalloc(256)/kfree -> 71 cycles
>  10000 times kmalloc(512)/kfree -> 72 cycles
>  10000 times kmalloc(1024)/kfree -> 71 cycles
>  10000 times kmalloc(2048)/kfree -> 71 cycles
>  10000 times kmalloc(4096)/kfree -> 71 cycles
>  10000 times kmalloc(8192)/kfree -> 65 cycles
>  10000 times kmalloc(16384)/kfree -> 511 cycles
> 
> Most of the results are better than before.
> 
> Note that this change slightly worses performance in !CONFIG_PREEMPT,
> roughly 0.3%. Implementing each case separately would help performance,
> but, since it's so marginal, I didn't do that. This would help
> maintanance since we have same code for all cases.
> 
> Tested-by: Jesper Dangaard Brouer <brouer@redhat.com>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>  mm/slub.c |   26 +++++++++++++-------------
>  1 file changed, 13 insertions(+), 13 deletions(-)
> 
> diff --git a/mm/slub.c b/mm/slub.c
> index fe376fe..0624608 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -2398,13 +2398,15 @@ redo:
>  	 * reading from one cpu area. That does not matter as long
>  	 * as we end up on the original cpu again when doing the cmpxchg.
>  	 *
> -	 * Preemption is disabled for the retrieval of the tid because that
> -	 * must occur from the current processor. We cannot allow rescheduling
> -	 * on a different processor between the determination of the pointer
> -	 * and the retrieval of the tid.
> +	 * We should guarantee that tid and kmem_cache are retrieved on
> +	 * the same cpu. It could be different if CONFIG_PREEMPT so we need
> +	 * to check if it is matched or not.
>  	 */
> -	preempt_disable();
> -	c = this_cpu_ptr(s->cpu_slab);
> +	do {
> +		tid = this_cpu_read(s->cpu_slab->tid);
> +		c = this_cpu_ptr(s->cpu_slab);
> +	} while (IS_ENABLED(CONFIG_PREEMPT) && unlikely(tid != c->tid));
> +	barrier();

Help maintenance more if barrier is documented in commit message.
> 
>  	/*
>  	 * The transaction ids are globally unique per cpu and per operation on
> @@ -2412,8 +2414,6 @@ redo:
>  	 * occurs on the right processor and that there was no operation on the
>  	 * linked list in between.
>  	 */
> -	tid = c->tid;
> -	preempt_enable();
> 
>  	object = c->freelist;
>  	page = c->page;
> @@ -2659,11 +2659,11 @@ redo:
>  	 * data is retrieved via this pointer. If we are on the same cpu
>  	 * during the cmpxchg then the free will succedd.
>  	 */
> -	preempt_disable();
> -	c = this_cpu_ptr(s->cpu_slab);
> -
> -	tid = c->tid;
> -	preempt_enable();
> +	do {
> +		tid = this_cpu_read(s->cpu_slab->tid);
> +		c = this_cpu_ptr(s->cpu_slab);
> +	} while (IS_ENABLED(CONFIG_PREEMPT) && unlikely(tid != c->tid));
> +	barrier();
> 
ditto
>  	if (likely(page == c->page)) {
>  		set_freepointer(s, object, c->freelist);
> --
> 1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
