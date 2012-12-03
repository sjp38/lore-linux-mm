Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id AD2A36B0062
	for <linux-mm@kvack.org>; Mon,  3 Dec 2012 18:44:22 -0500 (EST)
Date: Mon, 3 Dec 2012 15:44:20 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] memcg: debugging facility to access dangling memcgs.
Message-Id: <20121203154420.661f8e28.akpm@linux-foundation.org>
In-Reply-To: <1354541048-12597-1-git-send-email-glommer@parallels.com>
References: <1354541048-12597-1-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>

On Mon,  3 Dec 2012 17:24:08 +0400
Glauber Costa <glommer@parallels.com> wrote:

> If memcg is tracking anything other than plain user memory (swap, tcp
> buf mem, or slab memory), it is possible - and normal - that a reference
> will be held by the group after it is dead. Still, for developers, it
> would be extremely useful to be able to query about those states during
> debugging.
> 
> This patch provides a debugging facility in the root memcg, so we can
> inspect which memcgs still have pending objects, and what is the cause
> of this state.

As this is a developer-only thing, I suggest that we should avoid
burdening mainline with it.  How about we maintain this in -mm (and
hence in -next and mhocko's memcg tree) until we no longer see a need
for it?

> +config MEMCG_DEBUG_ASYNC_DESTROY
> +	bool "Memory Resource Controller Debug assynchronous object destruction"
> +	depends on MEMCG_KMEM || MEMCG_SWAP

Could also depend on DEBUG_VM, I guess.

> +	default n
> +	help
> +	  When a memcg is destroyed, the memory
> +	  consumed by it may not be immediately freed. This is because when some
> +	  extensions are used, such as swap or kernel memory, objects can
> +	  outlive the group and hold a reference to it.
> +
> +	  If this is the case, the dangling_memcgs file will show information
> +	  about what are the memcgs still alive, and which references are still
> +	  preventing it to be freed. There is nothing wrong with that, but it is
> +	  very useful when debugging, to know where this memory is being held.
> +	  This is a developer-oriented debugging facility only, and no
> +	  guarantees of interface stability will be given.
> +

fixlets:

--- a/init/Kconfig~memcg-debugging-facility-to-access-dangling-memcgs-fix
+++ a/init/Kconfig
@@ -897,14 +897,14 @@ config MEMCG_KMEM
 	  will ever exhaust kernel resources alone.
 
 config MEMCG_DEBUG_ASYNC_DESTROY
-	bool "Memory Resource Controller Debug assynchronous object destruction"
+	bool "Memory Resource Controller Debug asynchronous object destruction"
 	depends on MEMCG_KMEM || MEMCG_SWAP
 	default n
 	help
-	  When a memcg is destroyed, the memory
-	  consumed by it may not be immediately freed. This is because when some
-	  extensions are used, such as swap or kernel memory, objects can
-	  outlive the group and hold a reference to it.
+	  When a memcg is destroyed, the memory consumed by it may not be
+	  immediately freed. This is because when some extensions are used, such
+	  as swap or kernel memory, objects can outlive the group and hold a
+	  reference to it.
 
 	  If this is the case, the dangling_memcgs file will show information
 	  about what are the memcgs still alive, and which references are still
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
