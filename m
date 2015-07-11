Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f171.google.com (mail-ie0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id 352886B0253
	for <linux-mm@kvack.org>; Fri, 10 Jul 2015 21:33:44 -0400 (EDT)
Received: by iebmu5 with SMTP id mu5so205948365ieb.1
        for <linux-mm@kvack.org>; Fri, 10 Jul 2015 18:33:44 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id r89si8948427ioi.24.2015.07.10.18.33.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Jul 2015 18:33:43 -0700 (PDT)
Date: Fri, 10 Jul 2015 18:33:57 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC] mm/shrinker: define INIT_SHRINKER macro
Message-Id: <20150710183357.30605207.akpm@linux-foundation.org>
In-Reply-To: <20150711012513.GB811@swordfish>
References: <20150710011211.GB584@swordfish>
	<20150710153235.835c4992fbce526da23361d0@linux-foundation.org>
	<20150711012513.GB811@swordfish>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, 11 Jul 2015 10:25:13 +0900 Sergey Senozhatsky <sergey.senozhatsky@gmail.com> wrote:

> > > I was thinking of a trivial INIT_SHRINKER macro to init `struct shrinker'
> > > internal members (composed in email client, not tested)
> > > 
> > > include/linux/shrinker.h
> > > 
> > > #define INIT_SHRINKER(s)			\
> > > 	do {					\
> > > 		(s)->nr_deferred = NULL;	\
> > > 		INIT_LIST_HEAD(&(s)->list);	\
> > > 	} while (0)
> > 
> > Spose so.  Although it would be simpler to change unregister_shrinker()
> > to bale out if list.next==NULL and then say "all zeroes is the
> > initialized state".
> 
> Yes, or '->nr_deferred == NULL' -- we can't have NULL ->nr_deferred
> in a properly registered shrinker (as of now)

list.next seems safer because that will always be non-zero.  But
whatever - we can change it later.
 
> But that will not work if someone has accidentally passed not zeroed
> out pointer to unregister.

I wouldn't worry about that really.  If you pass a pointer to
uninitialized memory, the kernel will explode.  That's true of just
about every pointer-accepting function in the kernel.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
