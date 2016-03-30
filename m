Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id 5C26E6B0253
	for <linux-mm@kvack.org>; Wed, 30 Mar 2016 04:58:50 -0400 (EDT)
Received: by mail-qg0-f43.google.com with SMTP id n34so25189764qge.1
        for <linux-mm@kvack.org>; Wed, 30 Mar 2016 01:58:50 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m94si2855469qkh.12.2016.03.30.01.58.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Mar 2016 01:58:49 -0700 (PDT)
Date: Wed, 30 Mar 2016 10:58:44 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: 3.14.65: Memory leak when slub_debug is enabled
Message-ID: <20160330105844.4cf1f0b8@redhat.com>
In-Reply-To: <CAA4-JFLOmeYrWOEO_d2ALPgf0cWhC_fv1Gisz5fyH3uY1ogV1g@mail.gmail.com>
References: <CAA4-JFLOmeYrWOEO_d2ALPgf0cWhC_fv1Gisz5fyH3uY1ogV1g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ajay Patel <patela@gmail.com>
Cc: linux-kernel@vger.kernel.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.co, brouer@redhat.com, linux-mm <linux-mm@kvack.org>


Hi Ajay,

Could you please provide info on kernel .config settings via commands:

 grep HAVE_ALIGNED_STRUCT_PAGE .config
 grep CONFIG_HAVE_CMPXCHG_DOUBLE .config

You can try to further debug your problem by defining SLUB_DEBUG_CMPXCHG
manually in mm/slub.c to get some verbose output on the cmpxchg failures.

Is the "Marvell Armada dual core ARMV7" a 32-bit CPU?

--Jesper

On Tue, 29 Mar 2016 15:32:26 -0700 Ajay Patel <patela@gmail.com> wrote:

> We have custom board with Marvell Armada dual core ARMV7.
> The driver uses buffers from kmalloc-8192 slab heavily.
> When slub_debug is enabled, the kmalloc-8192 active slabs are
> increasing. The slub stats shows  cmpxchg_double_fail and objects_partial
> are increasing too. Eventually system panics on oom.
> 
> Following patch fixes the issue.
> Has anybody encountered this issue?
> Is this right fix?
> 
> I am not in mailing list please cc me.
> 
> Thanks
> Ajay
> 
> 
> --- slub.c.orig Tue Mar 29 11:54:42 2016
> +++ slub.c      Tue Mar 29 15:08:30 2016
> @@ -1562,9 +1562,12 @@
>         void *freelist;
>         unsigned long counters;
>         struct page new;
> +       int retry_count = 0;
> +#define RETRY_COUNT 10
> 
>         lockdep_assert_held(&n->list_lock);
> 
> +again:
>         /*
>          * Zap the freelist and set the frozen bit.
>          * The old freelist is the list of objects for the
> @@ -1587,8 +1590,13 @@
>         if (!__cmpxchg_double_slab(s, page,
>                         freelist, counters,
>                         new.freelist, new.counters,
> -                       "acquire_slab"))
> +                       "acquire_slab")) {
> +               if (retry_count++ < RETRY_COUNT) {
> +                       new.frozen = 0;
> +                       goto again;
> +               }
>                 return NULL;
> +       }
> 
>         remove_partial(n, page);
>         WARN_ON(!freelist);



-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
