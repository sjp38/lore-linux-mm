Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9709F6B0038
	for <linux-mm@kvack.org>; Sun, 24 Sep 2017 02:10:48 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id a74so3939298oib.7
        for <linux-mm@kvack.org>; Sat, 23 Sep 2017 23:10:48 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d142sor1555728oig.299.2017.09.23.23.10.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 23 Sep 2017 23:10:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1506109927-17012-3-git-send-email-yang.s@alibaba-inc.com>
References: <1506109927-17012-1-git-send-email-yang.s@alibaba-inc.com> <1506109927-17012-3-git-send-email-yang.s@alibaba-inc.com>
From: Qixuan Wu <wuqixuan@gmail.com>
Date: Sun, 24 Sep 2017 14:10:46 +0800
Message-ID: <CAEjEV8DcOzh+TEeF4MmPTbAEq4ahCCCG3tiU975dhwauv2RgGQ@mail.gmail.com>
Subject: [PATCH 2/2] mm: oom: show unreclaimable slab info when kernel panic
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.s@alibaba-inc.com>
Cc: "cl@linux.com" <cl@linux.com>, "penberg@kernel.org" <penberg@kernel.org>, "rientjes@google.com" <rientjes@google.com>, "iamjoonsoo.kim@lge.com" <iamjoonsoo.kim@lge.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mhocko@kernel.org" <mhocko@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Sat, Sep 23, 2017, Yang Shi <yang.s@alibaba-inc.com> wrote=EF=BC=9A
>
> Kernel may panic when oom happens without killable process sometimes it
> is caused by huge unreclaimable slabs used by kernel.
>
> Although kdump could help debug such problem, however, kdump is not
> available on all architectures and it might be malfunction sometime.
> And, since kernel already panic it is worthy capturing such information
> in dmesg to aid touble shooting.
......

> +void dump_unreclaimable_slab(void)
> +{
> +       struct kmem_cache *s, *s2;
> +       struct slabinfo sinfo;
> +
> +       pr_info("Unreclaimable slab info:\n");
> +       pr_info("Name                      Used          Total\n");
> +
> +       /*
> +        * Here acquiring slab_mutex is unnecessary since we don't prefer=
 to
> +        * get sleep in oom path right before kernel panic, and avoid rac=
e
> +        * condition.
> +        * Since it is already oom, so there should be not any big alloca=
tion
> +        * which could change the statistics significantly.
> +        */
> +       list_for_each_entry_safe(s, s2, &slab_caches, list) {
> +               if (!is_root_cache(s) || (s->flags & SLAB_RECLAIM_ACCOUNT=
))
> +                       continue;
> +
> +               memset(&sinfo, 0, sizeof(sinfo));
> +               get_slabinfo(s, &sinfo);
> +
> +               if (sinfo.num_objs > 0)
> +                       pr_info("%-17s %10luKB %10luKB\n", cache_name(s),
> +                               (sinfo.active_objs * s->size) / 1024,
> +                               (sinfo.num_objs * s->size) / 1024);
> +       }
> +}
> +

Seems it's a good feature and patch is fine, maybe modify like below is bet=
ter.

Change
 if (sinfo.num_objs > 0)
to
 if (sinfo.num_objs > 0 && sinfo.actives_objs > 0)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
