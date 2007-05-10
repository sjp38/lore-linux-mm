Date: Thu, 10 May 2007 15:29:57 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Bug in mm/thrash.c function grab_swap_token()
Message-Id: <20070510152957.edb26df3.akpm@linux-foundation.org>
In-Reply-To: <20070510122359.GA16433@srv1-m700-lanp.koti>
References: <20070510122359.GA16433@srv1-m700-lanp.koti>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mikukkon@iki.fi
Cc: Mika Kukkonen <mikukkon@miku.homelinux.net>, ashwin.chaugule@celunite.com, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, 10 May 2007 15:24:00 +0300
Mika Kukkonen <mikukkon@miku.homelinux.net> wrote:

> Following bug was uncovered by compiling with '-W' flag:
> 
>   CC      mm/thrash.o
> mm/thrash.c: In function a??grab_swap_tokena??:
> mm/thrash.c:52: warning: comparison of unsigned expression < 0 is always false
> 
> Variable token_priority is unsigned, so decrementing first and then
> checking the result does not work; fixed by reversing the test, patch
> attached (compile tested only). 
> 
> I am not sure if likely() makes much sense in this new situation, but
> I'll let somebody else to make a decision on that.
> 
> Signed-off-by: Mika Kukkonen <mikukkon@iki.fi>
> 
> diff --git a/mm/thrash.c b/mm/thrash.c
> index 9ef9071..c4c5205 100644
> --- a/mm/thrash.c
> +++ b/mm/thrash.c
> @@ -48,9 +48,8 @@ void grab_swap_token(void)
>  		if (current_interval < current->mm->last_interval)
>  			current->mm->token_priority++;
>  		else {
> -			current->mm->token_priority--;
> -			if (unlikely(current->mm->token_priority < 0))
> -				current->mm->token_priority = 0;
> +			if (likely(current->mm->token_priority > 0))
> +				current->mm->token_priority--;
>  		}
>  		/* Check if we deserve the token */
>  		if (current->mm->token_priority >

argh.

This has potential to cause large changes in system performance.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
