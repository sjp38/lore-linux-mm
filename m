Received: by wa-out-1112.google.com with SMTP id m33so5297146wag.8
        for <linux-mm@kvack.org>; Sun, 02 Mar 2008 15:29:19 -0800 (PST)
Message-ID: <9a8748490803021529m695f91egcc9e4dba13a5c911@mail.gmail.com>
Date: Mon, 3 Mar 2008 00:29:19 +0100
From: "Jesper Juhl" <jesper.juhl@gmail.com>
Subject: Re: [PATCH] leak less memory in failure paths of alloc_rt_sched_group()
In-Reply-To: <1204499992.6240.109.camel@lappy>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <alpine.LNX.1.00.0803030002520.4939@dragon.funnycrock.com>
	 <1204499992.6240.109.camel@lappy>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On 03/03/2008, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
>
>  On Mon, 2008-03-03 at 00:09 +0100, Jesper Juhl wrote:
>  > In kernel/sched.c b/kernel/sched.c::alloc_rt_sched_group() we currently do
>  > some paired memory allocations, and if one fails we bail out without
>  > freeing the previous one.
>  >
>  > If we fail inside the loop we should proably roll the whole thing back.
>  > This patch does not do that, it simply frees the first member of the
>  > paired alloc if the second fails. This is not perfect, but it's a simple
>  > change that will, at least, result in us leaking a little less than we
>  > currently do when an allocation fails.
>  >
>  > So, not perfect, but better than what we currently have.
>  > Please consider applying.
>
>
> Doesn't the following handle that:
>
>  sched_create_group()
>  {
>  ...
>         if (!alloc_rt_sched_group())
>                 goto err;
>  ...
>
>  err:
>         free_sched_group();
>  }
>
>
>  free_sched_group()
>  {
>  ...
>         free_rt_sched_group();
>  ...
>  }
>
>  free_rt_sched_group()
>  {
>         free all relevant stuff
>  }
>

Hmmm, it might. I must admit I only looked at alloc_rt_sched_group()
isolated, and what I saw looked like leaks. It seems I need to do a
more thorough reading of the code to be dead sure.

-- 
Jesper Juhl <jesper.juhl@gmail.com>
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please      http://www.expita.com/nomime.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
