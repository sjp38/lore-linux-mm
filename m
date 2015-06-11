Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vn0-f53.google.com (mail-vn0-f53.google.com [209.85.216.53])
	by kanga.kvack.org (Postfix) with ESMTP id 58DBF6B0032
	for <linux-mm@kvack.org>; Thu, 11 Jun 2015 13:26:14 -0400 (EDT)
Received: by vnbg190 with SMTP id g190so1981003vnb.8
        for <linux-mm@kvack.org>; Thu, 11 Jun 2015 10:26:14 -0700 (PDT)
Received: from resqmta-ch2-12v.sys.comcast.net (resqmta-ch2-12v.sys.comcast.net. [2001:558:fe21:29:69:252:207:44])
        by mx.google.com with ESMTPS id ui18si2040724vdb.37.2015.06.11.10.26.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 11 Jun 2015 10:26:13 -0700 (PDT)
Date: Thu, 11 Jun 2015 12:26:11 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC][PATCH 0/5] do not dereference NULL pools in pools' destroy()
 functions
In-Reply-To: <20150609191755.867a36c3.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.11.1506111212530.18426@east.gentwo.org>
References: <1433851493-23685-1-git-send-email-sergey.senozhatsky@gmail.com> <20150609142523.b717dba6033ee08de997c8be@linux-foundation.org> <alpine.DEB.2.11.1506092008220.3300@east.gentwo.org> <20150609185150.8c9fed8d.akpm@linux-foundation.org>
 <alpine.DEB.2.11.1506092056570.6964@east.gentwo.org> <20150609191755.867a36c3.akpm@linux-foundation.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Minchan Kim <minchan@kernel.org>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, sergey.senozhatsky.work@gmail.com, Joe Perches <joe@perches.com>

On Tue, 9 Jun 2015, Andrew Morton wrote:

> > > More than half of the kmem_cache_destroy() callsites are declining that
> > > value by open-coding the NULL test.  That's reality and we should recognize
> > > it.
> >
> > Well that may just indicate that we need to have a look at those
> > callsites and the reason there to use a special cache at all.
>
> This makes no sense.  Go look at the code.
> drivers/staging/lustre/lustre/llite/super25.c, for example.  It's all
> in the basic unwind/recover/exit code.

That is screwed up code. I'd do that without the checks simply with a
series of kmem_cache_destroys().

> > If the cache
> > is just something that kmalloc can provide then why create a special
> > cache. On the other hand if something special needs to be accomplished
> > then it would make sense to have special processing on kmem_cache_destroy.
>
> This has nothing to do with anything.  We're talking about a basic "if
> I created this cache then destroy it" operation.

As you see in this code snipped you cannot continue if a certain operation
during setup fails. At that point it is known which caches exist and
therefore kmem_cache_destroy() can be called without the checks.

> It's a common pattern.  mm/ exists to serve client code and as a lot of
> client code is doing this, we should move it into mm/ so as to serve
> client code better.

Doing this seems to encourage sloppy coding practices.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
