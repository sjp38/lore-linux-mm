Subject: Re: [PATCH] leak less memory in failure paths of
	alloc_rt_sched_group()
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <alpine.LNX.1.00.0803030002520.4939@dragon.funnycrock.com>
References: <alpine.LNX.1.00.0803030002520.4939@dragon.funnycrock.com>
Content-Type: text/plain
Date: Mon, 03 Mar 2008 00:19:52 +0100
Message-Id: <1204499992.6240.109.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jesper Juhl <jesper.juhl@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Mon, 2008-03-03 at 00:09 +0100, Jesper Juhl wrote:
> In kernel/sched.c b/kernel/sched.c::alloc_rt_sched_group() we currently do 
> some paired memory allocations, and if one fails we bail out without 
> freeing the previous one.
> 
> If we fail inside the loop we should proably roll the whole thing back. 
> This patch does not do that, it simply frees the first member of the 
> paired alloc if the second fails. This is not perfect, but it's a simple 
> change that will, at least, result in us leaking a little less than we 
> currently do when an allocation fails.
> 
> So, not perfect, but better than what we currently have.
> Please consider applying.

Doesn't the following handle that:

sched_create_group()
{
...
	if (!alloc_rt_sched_group())
		goto err;
...

err:
	free_sched_group();
}


free_sched_group()
{
...
	free_rt_sched_group();
...
}

free_rt_sched_group()
{
 	free all relevant stuff
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
