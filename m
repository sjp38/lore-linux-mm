Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 47C416B005D
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 03:20:42 -0400 (EDT)
Received: by mail-lb0-f169.google.com with SMTP id k6so175801lbo.14
        for <linux-mm@kvack.org>; Fri, 19 Oct 2012 00:20:40 -0700 (PDT)
Date: Fri, 19 Oct 2012 10:20:32 +0300 (EEST)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [PATCH 2/2] slub: remove one code path and reduce lock contention
 in __slab_free()
In-Reply-To: <1345042960-6287-2-git-send-email-js1304@gmail.com>
Message-ID: <alpine.LFD.2.02.1210191020010.4221@tux.localdomain>
References: <1345042960-6287-1-git-send-email-js1304@gmail.com> <1345042960-6287-2-git-send-email-js1304@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>

On Thu, 16 Aug 2012, Joonsoo Kim wrote:
> When we try to free object, there is some of case that we need
> to take a node lock. This is the necessary step for preventing a race.
> After taking a lock, then we try to cmpxchg_double_slab().
> But, there is a possible scenario that cmpxchg_double_slab() is failed
> with taking a lock. Following example explains it.
> 
> CPU A               CPU B
> need lock
> ...                 need lock
> ...                 lock!!
> lock..but spin      free success
> spin...             unlock
> lock!!
> free fail
> 
> In this case, retry with taking a lock is occured in CPU A.
> I think that in this case for CPU A,
> "release a lock first, and re-take a lock if necessary" is preferable way.
> 
> There are two reasons for this.
> 
> First, this makes __slab_free()'s logic somehow simple.
> With this patch, 'was_frozen = 1' is "always" handled without taking a lock.
> So we can remove one code path.
> 
> Second, it may reduce lock contention.
> When we do retrying, status of slab is already changed,
> so we don't need a lock anymore in almost every case.
> "release a lock first, and re-take a lock if necessary" policy is
> helpful to this.
> 
> Signed-off-by: Joonsoo Kim <js1304@gmail.com>
> Cc: Christoph Lameter <cl@linux.com>
> Acked-by: Christoph Lameter <cl@linux.com>

Applied, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
