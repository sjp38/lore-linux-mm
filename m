Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6837CC43613
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 23:48:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1445B20851
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 23:48:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="MSMUjfeu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1445B20851
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A09FA6B0003; Wed, 19 Jun 2019 19:48:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9BB7C8E0002; Wed, 19 Jun 2019 19:48:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8AC0A8E0001; Wed, 19 Jun 2019 19:48:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6A8616B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 19:48:22 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id u3so1130621ybu.7
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 16:48:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=mdR8cofBW05/dlJOYy5MJxgZ+fOVkZamOkomK1RfURQ=;
        b=dW38qDYKygWLWvxm/Hft9c73zyCRmKjxbTm2wASPz5qxiUm1ShW77mtwKtOL5t0BKU
         3zaA6DDB6EPUpuTCsnPdVuMz9Aqb4Q4lhPl0AWlUOAzpy00RdV/m9cUAx2BInMlgVfyz
         0Ywf6qCcRIyCv5LDnHn9sPtBlj2eVVIqjouZcHrix48ksK2YS7diYSB3TEvkrFJvXEvZ
         NOj8C1aDB9s2B5yDI18NhZmMV92Nl6uaRM05MaUPKFej8UbLVCYv5pcF9LWd03p8OUY5
         0oQRkbHJizqaJGrFTiDJaBWuylnZX+w2DSJ2FbFiYXKPb+QMC2Bro93XhOta6x/i75ag
         RwDg==
X-Gm-Message-State: APjAAAXIMEEJ4fQAQ0Mq/kwF3A6XWLy9aEiacT0PoDTcHnnduoykNTsr
	w0MBpBxgbNSxZSnFR9RuBXzClOXO/9neoIeet9e7S/Rdx4R9UFv21NJtYUFakOca0kaAihW0O9k
	Y7UvkXaCyPV1wXGRxMIo237c9Omri8QxO8PO0xLRVWunwyu2S1WI6vEHVGy0hcjVIOA==
X-Received: by 2002:a25:2154:: with SMTP id h81mr39573521ybh.436.1560988102129;
        Wed, 19 Jun 2019 16:48:22 -0700 (PDT)
X-Received: by 2002:a25:2154:: with SMTP id h81mr39573510ybh.436.1560988101488;
        Wed, 19 Jun 2019 16:48:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560988101; cv=none;
        d=google.com; s=arc-20160816;
        b=FSIdygMIjU1iXiCR8yRiESwrtWF3ZlaIbSZICU50NFMTSoHOWM563gM5fZtoYrFb8+
         ufgWvTXM6cLbJz2TtHHTCA4j3Mu/LjMEyGYc9nefNM4aXl3PeWRdsLMeVx6daEND5ckJ
         exiKjIEYH44Uesg409Yq2iwPINfhZELT+MSvB0sCipbNZjXojpToDCOKf+ST+sHvmhul
         NF4u3NvbQeHcz0GdAynkjZrXcQ70OLWH3nFmnwiTniES/pkpqZDzNLX9yvWE0T/pkM+v
         DzcqKP5P7ZGJvvxShIFls7WgPKCfzyDDtx/sE0xbLmf8C2uiQZ11cYjw90GFCqcy8Koh
         vH6g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=mdR8cofBW05/dlJOYy5MJxgZ+fOVkZamOkomK1RfURQ=;
        b=yCBJDZ2ZKu6eTkmnV+sjw96SO9PFiySRJG93MIdi6CN+5/edGVXbNf/aq72sGXi7Ah
         ECjOY9kDy6nd5Whh7uKz9eNLqmj7M5BIVUkMF2QaIbkHGLTfibkU6JEYRkcqTb1Qogh5
         uA11tQB9LOgNEjMLHKfKx/RjS7N1v/8JtTZoWPcEQsFFt0c5tKb1Zz33H8/zSJ7dzEiN
         EWZAa1gySjMjLShZXaSn+850XP3YpMlwAogcZK+po4bAJCY4jA6Iecb/xVerQP2z+ftp
         1WTdvpX9wMn/Snyw0Leq8pSGPhnhr26M6JMdyl7WoOvNNTOdPKHSVFUePOTIwjSsa7yy
         a4cA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=MSMUjfeu;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k84sor10431724ywa.160.2019.06.19.16.48.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Jun 2019 16:48:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=MSMUjfeu;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=mdR8cofBW05/dlJOYy5MJxgZ+fOVkZamOkomK1RfURQ=;
        b=MSMUjfeuIIMWIAJ5C708F/2OSLY+fwUt/8W9JQ1YSkbXB4N4Q/KUz+PAqWiyCtxC8I
         t2ShqEKiMO68Iqm8esLXZ/Zc7jP42gUYUUHcxfY7WsF1g58qaDBNxCjtKSEeZAGajpin
         g1Y7nWTBahghzM1misk6ZqrFiUnj28CVM157L+EHhMJN2buIPwJIaqWNds4zn16CNCW7
         gGnIXuRrqu1oS6c8flY0CYvv0irqfs04XyDUcJHjssdLgIdv9P0lrdc+zcNBY1Kn3Dyn
         H+bMYSUzFOTkJGi5uaUdG11jsKLbbr5RxTqXTYtoQoFV3+9GCaEo0YKYs4VGeS6F5Vxa
         VKjg==
X-Google-Smtp-Source: APXvYqwXXDiu34H1Done8oxemcyeGdttzq+yvBnu/E8HZ/ceNguvnB/CiOduLOD/BnON5rB7aDDp3Zdct/GtF4kOBVo=
X-Received: by 2002:a81:a55:: with SMTP id 82mr37827365ywk.205.1560988100833;
 Wed, 19 Jun 2019 16:48:20 -0700 (PDT)
MIME-Version: 1.0
References: <20190619171621.26209-1-longman@redhat.com>
In-Reply-To: <20190619171621.26209-1-longman@redhat.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Wed, 19 Jun 2019 16:48:09 -0700
Message-ID: <CALvZod7pdOx0a1v4oX5-7ZfCykM8iwRwPkW-+gbO1B4+j1SXqw@mail.gmail.com>
Subject: Re: [PATCH v2] mm, memcg: Add a memcg_slabinfo debugfs file
To: Waiman Long <longman@redhat.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, 
	David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, 
	Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, 
	Vladimir Davydov <vdavydov.dev@gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Waiman,

On Wed, Jun 19, 2019 at 10:16 AM Waiman Long <longman@redhat.com> wrote:
>
> There are concerns about memory leaks from extensive use of memory
> cgroups as each memory cgroup creates its own set of kmem caches. There
> is a possiblity that the memcg kmem caches may remain even after the
> memory cgroups have been offlined. Therefore, it will be useful to show
> the status of each of memcg kmem caches.
>
> This patch introduces a new <debugfs>/memcg_slabinfo file which is
> somewhat similar to /proc/slabinfo in format, but lists only information
> about kmem caches that have child memcg kmem caches. Information
> available in /proc/slabinfo are not repeated in memcg_slabinfo.
>
> A portion of a sample output of the file was:
>
>   # <name> <css_id[:dead]> <active_objs> <num_objs> <active_slabs> <num_slabs>
>   rpc_inode_cache   root          13     51      1      1
>   rpc_inode_cache     48           0      0      0      0
>   fat_inode_cache   root           1     45      1      1
>   fat_inode_cache     41           2     45      1      1
>   xfs_inode         root         770    816     24     24
>   xfs_inode           92          22     34      1      1
>   xfs_inode           88:dead      1     34      1      1
>   xfs_inode           89:dead     23     34      1      1
>   xfs_inode           85           4     34      1      1
>   xfs_inode           84           9     34      1      1
>
> The css id of the memcg is also listed. If a memcg is not online,
> the tag ":dead" will be attached as shown above.
>
> Suggested-by: Shakeel Butt <shakeelb@google.com>
> Signed-off-by: Waiman Long <longman@redhat.com>
> ---
>  mm/slab_common.c | 57 ++++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 57 insertions(+)
>
> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index 58251ba63e4a..2bca1558a722 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -17,6 +17,7 @@
>  #include <linux/uaccess.h>
>  #include <linux/seq_file.h>
>  #include <linux/proc_fs.h>
> +#include <linux/debugfs.h>
>  #include <asm/cacheflush.h>
>  #include <asm/tlbflush.h>
>  #include <asm/page.h>
> @@ -1498,6 +1499,62 @@ static int __init slab_proc_init(void)
>         return 0;
>  }
>  module_init(slab_proc_init);
> +
> +#if defined(CONFIG_DEBUG_FS) && defined(CONFIG_MEMCG_KMEM)
> +/*
> + * Display information about kmem caches that have child memcg caches.
> + */
> +static int memcg_slabinfo_show(struct seq_file *m, void *unused)
> +{
> +       struct kmem_cache *s, *c;
> +       struct slabinfo sinfo;
> +
> +       mutex_lock(&slab_mutex);

On large machines there can be thousands of memcgs and potentially
each memcg can have hundreds of kmem caches. So, the slab_mutex can be
held for a very long time.

Our internal implementation traverses the memcg tree and then
traverses 'memcg->kmem_caches' within the slab_mutex (and
cond_resched() after unlock).

> +       seq_puts(m, "# <name> <css_id[:dead]> <active_objs> <num_objs>");
> +       seq_puts(m, " <active_slabs> <num_slabs>\n");
> +       list_for_each_entry(s, &slab_root_caches, root_caches_node) {
> +               /*
> +                * Skip kmem caches that don't have any memcg children.
> +                */
> +               if (list_empty(&s->memcg_params.children))
> +                       continue;
> +
> +               memset(&sinfo, 0, sizeof(sinfo));
> +               get_slabinfo(s, &sinfo);
> +               seq_printf(m, "%-17s root      %6lu %6lu %6lu %6lu\n",
> +                          cache_name(s), sinfo.active_objs, sinfo.num_objs,
> +                          sinfo.active_slabs, sinfo.num_slabs);
> +
> +               for_each_memcg_cache(c, s) {
> +                       struct cgroup_subsys_state *css;
> +                       char *dead = "";
> +
> +                       css = &c->memcg_params.memcg->css;
> +                       if (!(css->flags & CSS_ONLINE))
> +                               dead = ":dead";

Please note that Roman's kmem cache reparenting patch series have made
kmem caches of zombie memcgs a bit tricky. On memcg offlining the
memcg kmem caches are reparented and the css->id can get recycled. So,
we want to know that the a kmem cache is reparented and which memcg it
belonged to initially. Determining if a kmem cache is reparented, we
can store a flag on the kmem cache and for the previous memcg we can
use fhandle. However to not make this more complicated, for now, we
can just have the info that the kmem cache was reparented i.e. belongs
to an offlined memcg.

> +
> +                       memset(&sinfo, 0, sizeof(sinfo));
> +                       get_slabinfo(c, &sinfo);
> +                       seq_printf(m, "%-17s %4d%5s %6lu %6lu %6lu %6lu\n",
> +                                  cache_name(c), css->id, dead,
> +                                  sinfo.active_objs, sinfo.num_objs,
> +                                  sinfo.active_slabs, sinfo.num_slabs);
> +               }
> +       }
> +       mutex_unlock(&slab_mutex);
> +       return 0;
> +}
> +DEFINE_SHOW_ATTRIBUTE(memcg_slabinfo);
> +
> +static int __init memcg_slabinfo_init(void)
> +{
> +       debugfs_create_file("memcg_slabinfo", S_IFREG | S_IRUGO,
> +                           NULL, NULL, &memcg_slabinfo_fops);
> +       return 0;
> +}
> +
> +late_initcall(memcg_slabinfo_init);
> +#endif /* CONFIG_DEBUG_FS && CONFIG_MEMCG_KMEM */
>  #endif /* CONFIG_SLAB || CONFIG_SLUB_DEBUG */
>
>  static __always_inline void *__do_krealloc(const void *p, size_t new_size,
> --
> 2.18.1
>

