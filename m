Subject: Re: [PATCH] Bug in mm/thrash.c function grab_swap_token()
From: Ashwin Chaugule <ashwin.chaugule@celunite.com>
Reply-To: ashwin.chaugule@celunite.com
In-Reply-To: <20070510152957.edb26df3.akpm@linux-foundation.org>
References: <20070510122359.GA16433@srv1-m700-lanp.koti>
	 <20070510152957.edb26df3.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Date: Fri, 11 May 2007 12:19:27 +0530
Message-Id: <1178866168.4497.6.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mikukkon@iki.fi, Mika Kukkonen <mikukkon@miku.homelinux.net>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, ashwin.chaugule@gmail.com
List-ID: <linux-mm.kvack.org>

On Thu, 2007-05-10 at 15:29 -0700, Andrew Morton wrote:
> On Thu, 10 May 2007 15:24:00 +0300
> Mika Kukkonen <mikukkon@miku.homelinux.net> wrote:
> 
> > Following bug was uncovered by compiling with '-W' flag:
> > 
> >   CC      mm/thrash.o
> > mm/thrash.c: In function A?AcAcA?A!A?A?grab_swap_tokenA?AcAcA?A!AcA?Ac:
> > mm/thrash.c:52: warning: comparison of unsigned expression < 0 is always false
> > 
> > Variable token_priority is unsigned, so decrementing first and then
> > checking the result does not work; fixed by reversing the test, patch
> > attached (compile tested only). 
> > 
> > I am not sure if likely() makes much sense in this new situation, but
> > I'll let somebody else to make a decision on that.
> > 
> > Signed-off-by: Mika Kukkonen <mikukkon@iki.fi>
> > 
> > diff --git a/mm/thrash.c b/mm/thrash.c
> > index 9ef9071..c4c5205 100644
> > --- a/mm/thrash.c
> > +++ b/mm/thrash.c
> > @@ -48,9 +48,8 @@ void grab_swap_token(void)
> >  		if (current_interval < current->mm->last_interval)
> >  			current->mm->token_priority++;
> >  		else {
> > -			current->mm->token_priority--;
> > -			if (unlikely(current->mm->token_priority < 0))
> > -				current->mm->token_priority = 0;
> > +			if (likely(current->mm->token_priority > 0))
> > +				current->mm->token_priority--;
> >  		}
> >  		/* Check if we deserve the token */
> >  		if (current->mm->token_priority >
> 
> argh.
> 
> This has potential to cause large changes in system performance.

I'm not sure how. Although, I think the logic still remains the same.
IOW, if the prio decrements to zero, it will remain zero until it
contends for token rapidly. 

The likely part is unnecessary.

Thanks Mika. Let me submit this patch, coz I'd like to change my email
address in thrash.c



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
