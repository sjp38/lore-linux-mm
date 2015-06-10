Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 127596B0032
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 22:15:03 -0400 (EDT)
Received: by padev16 with SMTP id ev16so24575528pad.0
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 19:15:02 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id kg4si11339937pad.60.2015.06.09.19.15.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jun 2015 19:15:02 -0700 (PDT)
Date: Tue, 9 Jun 2015 19:17:55 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC][PATCH 0/5] do not dereference NULL pools in pools'
 destroy() functions
Message-Id: <20150609191755.867a36c3.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.11.1506092056570.6964@east.gentwo.org>
References: <1433851493-23685-1-git-send-email-sergey.senozhatsky@gmail.com>
	<20150609142523.b717dba6033ee08de997c8be@linux-foundation.org>
	<alpine.DEB.2.11.1506092008220.3300@east.gentwo.org>
	<20150609185150.8c9fed8d.akpm@linux-foundation.org>
	<alpine.DEB.2.11.1506092056570.6964@east.gentwo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Minchan Kim <minchan@kernel.org>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, sergey.senozhatsky.work@gmail.com, Joe Perches <joe@perches.com>

On Tue, 9 Jun 2015 21:00:58 -0500 (CDT) Christoph Lameter <cl@linux.com> wrote:

> On Tue, 9 Jun 2015, Andrew Morton wrote:
> 
> > > Why do this at all?
> >
> > For the third time: because there are approx 200 callsites which are
> > already doing it.
> 
> Did some grepping and I did see some call sites that do this but the
> majority has to do other processing as well.
> 
> 200 call sites? Do we have that many uses of caches? Typical prod system
> have ~190 caches active and the merging brings that down to half of that.

I didn't try terribly hard.

z:/usr/src/linux-4.1-rc7> grep -r -C1 kmem_cache_destroy .  | grep "if [(]" | wc -l
158

It's a lot, anyway.

> > More than half of the kmem_cache_destroy() callsites are declining that
> > value by open-coding the NULL test.  That's reality and we should recognize
> > it.
> 
> Well that may just indicate that we need to have a look at those
> callsites and the reason there to use a special cache at all.

This makes no sense.  Go look at the code. 
drivers/staging/lustre/lustre/llite/super25.c, for example.  It's all
in the basic unwind/recover/exit code.

> If the cache
> is just something that kmalloc can provide then why create a special
> cache. On the other hand if something special needs to be accomplished
> then it would make sense to have special processing on kmem_cache_destroy.

This has nothing to do with anything.  We're talking about a basic "if
I created this cache then destroy it" operation.

It's a common pattern.  mm/ exists to serve client code and as a lot of
client code is doing this, we should move it into mm/ so as to serve
client code better.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
