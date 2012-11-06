Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 38E706B0044
	for <linux-mm@kvack.org>; Mon,  5 Nov 2012 19:33:15 -0500 (EST)
Date: Mon, 5 Nov 2012 16:33:13 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v6 20/29] memcg: skip memcg kmem allocations in
 specified code regions
Message-Id: <20121105163313.c555a2b1.akpm@linux-foundation.org>
In-Reply-To: <1351771665-11076-21-git-send-email-glommer@parallels.com>
References: <1351771665-11076-1-git-send-email-glommer@parallels.com>
	<1351771665-11076-21-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>

On Thu,  1 Nov 2012 16:07:36 +0400
Glauber Costa <glommer@parallels.com> wrote:

> This patch creates a mechanism that skip memcg allocations during
> certain pieces of our core code. It basically works in the same way
> as preempt_disable()/preempt_enable(): By marking a region under
> which all allocations will be accounted to the root memcg.
> 
> We need this to prevent races in early cache creation, when we
> allocate data using caches that are not necessarily created already.
> 
> ...
>
> +static inline void memcg_stop_kmem_account(void)
> +{
> +	if (!current->mm)
> +		return;

It is utterly unobvious to this reader why the code tests ->mm in this
fashion.  So we need either smarter readers or a code comment.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
