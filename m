Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f44.google.com (mail-yh0-f44.google.com [209.85.213.44])
	by kanga.kvack.org (Postfix) with ESMTP id C600E6B0032
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 22:01:03 -0400 (EDT)
Received: by yhak3 with SMTP id k3so14801089yha.2
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 19:01:03 -0700 (PDT)
Received: from resqmta-ch2-02v.sys.comcast.net (resqmta-ch2-02v.sys.comcast.net. [2001:558:fe21:29:69:252:207:34])
        by mx.google.com with ESMTPS id ht7si13215144vdb.50.2015.06.09.19.00.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 09 Jun 2015 19:01:02 -0700 (PDT)
Date: Tue, 9 Jun 2015 21:00:58 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC][PATCH 0/5] do not dereference NULL pools in pools' destroy()
 functions
In-Reply-To: <20150609185150.8c9fed8d.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.11.1506092056570.6964@east.gentwo.org>
References: <1433851493-23685-1-git-send-email-sergey.senozhatsky@gmail.com> <20150609142523.b717dba6033ee08de997c8be@linux-foundation.org> <alpine.DEB.2.11.1506092008220.3300@east.gentwo.org> <20150609185150.8c9fed8d.akpm@linux-foundation.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Minchan Kim <minchan@kernel.org>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, sergey.senozhatsky.work@gmail.com, Joe Perches <joe@perches.com>

On Tue, 9 Jun 2015, Andrew Morton wrote:

> > Why do this at all?
>
> For the third time: because there are approx 200 callsites which are
> already doing it.

Did some grepping and I did see some call sites that do this but the
majority has to do other processing as well.

200 call sites? Do we have that many uses of caches? Typical prod system
have ~190 caches active and the merging brings that down to half of that.

> More than half of the kmem_cache_destroy() callsites are declining that
> value by open-coding the NULL test.  That's reality and we should recognize
> it.

Well that may just indicate that we need to have a look at those
callsites and the reason there to use a special cache at all. If the cache
is just something that kmalloc can provide then why create a special
cache. On the other hand if something special needs to be accomplished
then it would make sense to have special processing on kmem_cache_destroy.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
