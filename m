Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 2B9C36B0082
	for <linux-mm@kvack.org>; Tue, 11 Mar 2014 07:51:46 -0400 (EDT)
Received: by mail-wi0-f170.google.com with SMTP id n15so683480wiw.5
        for <linux-mm@kvack.org>; Tue, 11 Mar 2014 04:51:45 -0700 (PDT)
Received: from mail-we0-x22c.google.com (mail-we0-x22c.google.com [2a00:1450:400c:c03::22c])
        by mx.google.com with ESMTPS id wp2si21124600wjc.153.2014.03.11.04.51.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 11 Mar 2014 04:51:44 -0700 (PDT)
Received: by mail-we0-f172.google.com with SMTP id t61so10005645wes.3
        for <linux-mm@kvack.org>; Tue, 11 Mar 2014 04:51:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <002701cf3c49$be67da30$3b378e90$@lge.com>
References: <002701cf3c49$be67da30$3b378e90$@lge.com>
From: SeongJae Park <sj38.park@gmail.com>
Date: Tue, 11 Mar 2014 20:51:13 +0900
Message-ID: <CAEjAshodkKhOJvM+8+pmAuHJMD0Za7EtNZ+pDxz9i7v_Pav1RA@mail.gmail.com>
Subject: Re: Subject: [PATCH] mm: use vm_map_ram for only temporal object
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gioh Kim <gioh.kim@lge.com>
Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, =?UTF-8?B?7J206rG07Zi4?= <gunho.lee@lge.com>, chanho.min@lge.com, Johannes Weiner <hannes@cmpxchg.org>

Hello Gioh,

On Mon, Mar 10, 2014 at 7:16 PM, Gioh Kim <gioh.kim@lge.com> wrote:
>
> The vm_map_ram has fragment problem because it couldn't
> purge a chunk(ie, 4M address space) if there is a pinning object in
> that addresss space. So it could consume all VMALLOC address space
> easily.
> We can fix the fragmentation problem with using vmap instead of vm_map_ram
> but vmap is known to slow operation compared to vm_map_ram. Minchan said
> vm_map_ram is 5 times faster than vmap in his experiment. So I thought
> we should fix fragment problem of vm_map_ram because our proprietary
> GPU driver has used it heavily.
>
> On second thought, it's not an easy because we should reuse freed
> space for solving the problem and it could make more IPI and bitmap operation
> for searching hole. It could mitigate API's goal which is very fast mapping.
> And even fragmentation problem wouldn't show in 64 bit machine.
>
> Another option is that the user should separate long-life and short-life
> object and use vmap for long-life but vm_map_ram for short-life.
> If we inform the user about the characteristic of vm_map_ram
> the user can choose one according to the page lifetime.
>
> Let's add some notice messages to user.
>
> Signed-off-by: Gioh Kim <gioh.kim@lge.com>
> Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
> ---
>  mm/vmalloc.c |    6 ++++++
>  1 file changed, 6 insertions(+)
>
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 0fdf968..85b6687 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -1083,6 +1083,12 @@ EXPORT_SYMBOL(vm_unmap_ram);
>   * @node: prefer to allocate data structures on this node
>   * @prot: memory protection to use. PAGE_KERNEL for regular RAM
>   *
> + * If you use this function for below VMAP_MAX_ALLOC pages, it could be faster
> + * than vmap so it's good. But if you mix long-life and short-life object
> + * with vm_map_ram, it could consume lots of address space by fragmentation
> + * (expecially, 32bit machine). You could see failure in the end.

looks like trivial typo. Shouldn't s/expecially/especially/ ?

Thanks.

> + * Please use this function for short-life object.
> + *
>   * Returns: a pointer to the address that has been mapped, or %NULL on failure
>   */
>  void *vm_map_ram(struct page **pages, unsigned int count, int node, pgprot_t prot)
> --
> 1.7.9.5
>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a hrefmailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
