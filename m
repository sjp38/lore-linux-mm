Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 25FEA6B0177
	for <linux-mm@kvack.org>; Wed, 11 Jun 2014 17:56:48 -0400 (EDT)
Received: by mail-pb0-f54.google.com with SMTP id jt11so251172pbb.13
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 14:56:47 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id g7si7950095pat.225.2014.06.11.14.56.46
        for <linux-mm@kvack.org>;
        Wed, 11 Jun 2014 14:56:47 -0700 (PDT)
Date: Wed, 11 Jun 2014 14:56:45 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] vmalloc: use rcu list iterator to reduce
 vmap_area_lock contention
Message-Id: <20140611145645.35da1237f28a787acbcac9b1@linux-foundation.org>
In-Reply-To: <20140611043404.GA14728@js1304-P5Q-DELUXE>
References: <1402453146-10057-1-git-send-email-iamjoonsoo.kim@lge.com>
	<5397CDC3.1050809@hurleysoftware.com>
	<20140611043404.GA14728@js1304-P5Q-DELUXE>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Peter Hurley <peter@hurleysoftware.com>, Zhang Yanfei <zhangyanfei.yes@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Richard Yao <ryao@gentoo.org>, Eric Dumazet <eric.dumazet@gmail.com>

On Wed, 11 Jun 2014 13:34:04 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:

> > While rcu list traversal over the vmap_area_list is safe, this may
> > arrive at different results than the spinlocked version. The rcu list
> > traversal version will not be a 'snapshot' of a single, valid instant
> > of the entire vmap_area_list, but rather a potential amalgam of
> > different list states.
> 
> Hello,
> 
> Yes, you are right, but I don't think that we should be strict here.
> Meminfo is already not a 'snapshot' at specific time. While we try to
> get certain stats, the other stats can change.
> And, although we may arrive at different results than the spinlocked
> version, the difference would not be large and would not make serious
> side-effect.

mm, well...  The spinlocked version will at least report a number which
*used* to be true.  The new improved racy version could for example see
a bunch of new allocations but fail to see the bunch of frees which
preceded those new allocations.  Net result: it reports allocation
totals which exceed anything which this kernel has ever sustained.

But hey, it's only /proc/meminfo:VmallocFoo.  I'll eat my hat if anyone
cares about it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
