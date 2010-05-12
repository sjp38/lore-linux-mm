Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 80DE66B020A
	for <linux-mm@kvack.org>; Wed, 12 May 2010 03:34:31 -0400 (EDT)
Date: Wed, 12 May 2010 00:32:46 -0400
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm] cpuset,mm: fix no node to alloc memory when
 changing cpuset's mems - fix2
Message-Id: <20100512003246.9f0ee03c.akpm@linux-foundation.org>
In-Reply-To: <4BEA56D3.6040705@cn.fujitsu.com>
References: <4BEA56D3.6040705@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: miaox@cn.fujitsu.com
Cc: David Rientjes <rientjes@google.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>, Paul Menage <menage@google.com>, Linux-Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 12 May 2010 15:20:51 +0800 Miao Xie <miaox@cn.fujitsu.com> wrote:

> @@ -985,6 +984,7 @@ repeat:
>  	 * for the read-side.
>  	 */
>  	while (ACCESS_ONCE(tsk->mems_allowed_change_disable)) {
> +		task_unlock(tsk);
>  		if (!task_curr(tsk))
>  			yield();
>  		goto repeat;

Oh, I meant to mention that.  No yield()s, please.  Their duration is
highly unpredictable.  Can we do something more deterministic here?

Did you consider doing all this with locking?  get_mems_allowed() does
mutex_lock(current->lock)?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
