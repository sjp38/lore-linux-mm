Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id 9275E6B0253
	for <linux-mm@kvack.org>; Fri, 10 Jul 2015 18:32:37 -0400 (EDT)
Received: by igcqs7 with SMTP id qs7so22599624igc.0
        for <linux-mm@kvack.org>; Fri, 10 Jul 2015 15:32:37 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id f4si419556igc.19.2015.07.10.15.32.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Jul 2015 15:32:37 -0700 (PDT)
Date: Fri, 10 Jul 2015 15:32:35 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC] mm/shrinker: define INIT_SHRINKER macro
Message-Id: <20150710153235.835c4992fbce526da23361d0@linux-foundation.org>
In-Reply-To: <20150710011211.GB584@swordfish>
References: <20150710011211.GB584@swordfish>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Fri, 10 Jul 2015 10:12:11 +0900 Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com> wrote:

> Shrinker API does not handle nicely unregister_shrinker() on a not-registered
> ->shrinker. Looking at shrinker users, they all have to (a) carry on some sort
> of a flag telling that "unregister_shrinker()" will not blow up... or (b) just
> be fishy
> 
> ...
>
> I was thinking of a trivial INIT_SHRINKER macro to init `struct shrinker'
> internal members (composed in email client, not tested)
> 
> include/linux/shrinker.h
> 
> #define INIT_SHRINKER(s)			\
> 	do {					\
> 		(s)->nr_deferred = NULL;	\
> 		INIT_LIST_HEAD(&(s)->list);	\
> 	} while (0)

Spose so.  Although it would be simpler to change unregister_shrinker()
to bale out if list.next==NULL and then say "all zeroes is the
initialized state".

> --- a/include/linux/shrinker.h
> +++ b/include/linux/shrinker.h
> @@ -63,6 +63,12 @@ struct shrinker {
>  };
>  #define DEFAULT_SEEKS 2 /* A good number if you don't know better. */
>  
> +#define INIT_SHRINKER(s) 			\
> +	do {					\
> +		INIT_LIST_HEAD(&(s)->list);	\
> +		(s)->nr_deferred = NULL;	\
> +	} while (0)
> +

The only reason to make this a macro would be so that it can be used at
compile-time, with something like

static struct shrinker my_shrinker = INIT_SHRINKER(&my_shrinker);

But as we're not planning on doing that, we implement it in C, please.

Also, shrinker_init() would be a better name.  Although we already
mucked up shrinker_register() and shrinker_unregister().


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
