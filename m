Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id 1A0306B0253
	for <linux-mm@kvack.org>; Fri,  7 Aug 2015 19:32:38 -0400 (EDT)
Received: by qgeh16 with SMTP id h16so85143334qge.3
        for <linux-mm@kvack.org>; Fri, 07 Aug 2015 16:32:37 -0700 (PDT)
Received: from hm8853-n-138.locaweb.com.br (hm8853-n-138.locaweb.com.br. [189.126.112.138])
        by mx.google.com with ESMTP id 21si20923623qhh.47.2015.08.07.16.32.36
        for <linux-mm@kvack.org>;
        Fri, 07 Aug 2015 16:32:36 -0700 (PDT)
Received: from mcbain0011.correio.biz (189.126.112.14) by hm8853-n-21.locaweb.com.br id hol04m1un305 for <linux-mm@kvack.org>; Fri, 7 Aug 2015 20:33:29 -0300 (envelope-from <cesarb@cesarb.eti.br>)
Subject: Re: Potential data race in SyS_swapon
References: <CAAeHK+w7bQtAUAWFrcqE5Gf8t8nZoHim6iXg1axXdC_bVmrNDw@mail.gmail.com>
From: Cesar Eduardo Barros <cesarb@cesarb.eti.br>
Message-ID: <55C54010.4000904@cesarb.eti.br>
Date: Fri, 7 Aug 2015 20:32:32 -0300
MIME-Version: 1.0
In-Reply-To: <CAAeHK+w7bQtAUAWFrcqE5Gf8t8nZoHim6iXg1axXdC_bVmrNDw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, Hugh Dickins <hughd@google.com>, Miklos Szeredi <mszeredi@suse.cz>, Jason Low <jason.low2@hp.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>

Em 07-08-2015 13:14, Andrey Konovalov escreveu:
> Hi!
>
> We are working on a dynamic data race detector for the Linux kernel
> called KernelThreadSanitizer (ktsan)
> (https://github.com/google/ktsan/wiki).
>
> While running ktsan on the upstream revision 21bdb584af8c with trinity
> we got a few reports from SyS_swapon, here is one of them:

[...]

> The race is happening when accessing the swap_file field of a
> swap_info_struct struct.
>
> 2392         for (i = 0; i < nr_swapfiles; i++) {
> 2393                 struct swap_info_struct *q = swap_info[i];
> 2394
> 2395                 if (q == p || !q->swap_file)
> 2396                         continue;
> 2397                 if (mapping == q->swap_file->f_mapping) {
> 2398                         error = -EBUSY;
> 2399                         goto bad_swap;
> 2400                 }
> 2401         }
>
> 2539         spin_lock(&swap_lock);
> 2540         p->swap_file = NULL;
> 2541         p->flags = 0;
> 2542         spin_unlock(&swap_lock);

There's another (more important) place which sets the swap_file field to 
NULL, it's within swapoff. It's also protected by swap_lock.

> Since the swap_lock lock is not taken in the first snippet, it's
> possible for q->swap_file to be assigned to NULL and reloaded between
> executing lines 2395 and 2397, which might lead to a null pointer
> dereference.

I agree with that analysis. It should be possible to hit by racing 
swapon of a file with swapoff of another.

> Looks like the swap_lock should be taken when iterating through the
> swap_info array on lines 2392 - 2401.

I'd take that lock a couple of lines earlier, so that every place that 
sets the swap_file field on a swap_info_struct is behind swap_lock, for 
simplicity.

-- 
Cesar Eduardo Barros
cesarb@cesarb.eti.br

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
