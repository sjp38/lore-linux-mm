Content-Type: text/plain;
  charset="iso-8859-1"
From: Ed Tomlinson <tomlins@cam.org>
Subject: Re: Linux-2.4.1-pre11
Date: Sun, 28 Jan 2001 23:29:36 -0500
References: <Pine.LNX.4.10.10101281049240.3812-100000@penguin.transmeta.com>
In-Reply-To: <Pine.LNX.4.10.10101281049240.3812-100000@penguin.transmeta.com>
MIME-Version: 1.0
Message-Id: <01012823293600.07314@oscar>
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>, Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Feedback is nice...

The way you would like refill_inactive defined raises a question or two.  The
patches now have it runing in two modes, which you object to.  The way I read
what you say the real way to fix this would be to refactor refill_inactive.

result = refill_inactive(count) 

which has one goal of getting count pages inactivated.  There should also be 
a function to do the bg_aging, something like.

result = balance_activates(background)

The goal of which is to ensure that for every page we activate we also age a 
page down.  This might move some pages to the inactive list and might trigger 
some swapouts.  

This could also be hidden in refill_inactive triggered by a count of zero but 
this implies that refill_inactive must have a side effect of decrementing the 
background counter which is not the nicest thing to do.

Comments?
Ed Tomlinson


On January 28, 2001 02:32 pm, Linus Torvalds wrote:
> [ Cc'd to linux-mm, because I'm trying to also explain what kind of code I
>   like, and because the more people who understand how I judge the
>   "goodness" of code, the happier I hope I will be. ]
>
> On Sun, 28 Jan 2001, Marcelo Tosatti wrote:
> > Why you have not applied the conditional background page aging patch?
>
> Because it's only performance, not stability, and every time I look at the
> patch it looks ugly to me. Let me explain.
>
> Quite frankly, I suspect I'd like the thing much more if it didn't have a
> "background" flag, but a more specific thing. I hate overloading functions
> with two things and then having flags that change the behaviour of them. I
> like arguments that say "do THIS". I do not like arguments that say "I'm
> THIS, do whatever you want that you think will satisfy me".
>
> For example, I don't like how the current one has the "oneshot" parameter.
> I'd much rather just have
>
> 	deactivated = refill_inactive_scan(count);
>
> where the "count" would be the thing we ask for, and "deactivated" would
> obviously be how many we got. No "background" or "oneshot". The "oneshot"
> stuff in particular makes the
>
> 	while (refill_inactive_scan(DEF_PRIORITY, one)) ...
>
> logic look completely buggered: first we ask for it to exit after having
> found _one_, and then we have a loop that does this "count" times. Where's
> the logic?
>
> But at the same time, the "oneshot" parameter _does_ fulfill my need for
> well-defined behaviour. It says "DO THIS!". Or at least it tries to. It
> doesn't say "I like the color blue, so try to take that into account when
> you do whatever you like to do".
>
> Your "background" paramater makes the whole parameter pretty fluffy, in my
> opinion.. Why do we exit early when '!background'? Where's the
> _philosophy_ of the function? What do the arguments really mean? You can't
> read the callers and understand what the callers really are trying to do..
>
> Now, to me the "background" check should be in the caller. Th ecaller
> knows that it's doing background activity, so the _caller_ should be the
> one that say "when in the background, DO THIS!". Instead of letting the
> function try to decide on its own what it is we want when we're in the
> background.
>
> And conversely the "how many pages should be try to de-activate" logic
> should be in "refill_inactive_scan". So to me, the following calling
> convetion would make some amount of sense:
>
>  - refill_inactive_scan() calling convention change: it should be
>
> 	int refill_inactive_scan(int nr_to_deactivate);
>
>    and basically return the number of pages it de-activated, with the
>    parameter being how many pages we _want_ to de-activate. We've already
>    stopped using the priority (it's always DEF_PROPROTY), so we can drop
>    that. And I'd like the other parameter to _mean_ something, if you see
>    what I'm saying.
>
>    "Try to scan for THIS many" is a meaning. "Try to scan in the
>    background" doesn't really mean anything. What does "background" mean
>    to the scanning logic? It means something to the caller, but not to the
>    scanner.
>
>  - kswapd, before it calls refill_inactive_scan(), would basically do
>    something like
>
> 	nr = free_shortage() + inactive_shortage();
> 	if (nr > MAXSCAN)
> 		nr = MAXSCAN;
> 	if (nr || bg_page_aging)
> 		refill_inactive_scan(nr);
>
>    which again has some _meaning_. You can point to it and say: we want to
>    de-activate "nr" pages because we're short on memory. But even if the
>    answer is "zero", we may want to do some aging in the background, so
>    "refill_inactive_scan()" can know that a zero argument means that we
>    don't _really_ want to deactivate anything.
>
>    See how you can _read_ the calling code directly? Show the above five
>    lines to a programmer who hasn't even seen what it is that
>    "refill_inactive_scan()" actually does, and I bet he can guess what
>    we're trying to do.
>
>    That's what I mean with _meaning_. Which the current code lacks, and
>    which your change makes even less of.
>
>    And note how "refill_inactive_scan(0)" is automatically a logical
>    special case. It tells refill_inactive_scan() that we don't actually
>    want to _really_ deactivate anything, so we're obviously just doing the
>    aging.
>
>  - refill_inactive() can do
>
> 	count -= refill_inactive_scan(count);
>
>    instead of the current while-loop. Again, you can pretty much see from
>    that one line what it tries to do.
>
> Now, I'm not saying the above is how it must be done. The above is meant
> more as an example of an interface and a logic that I can follow, and that
> I think is more appropriate for programming. Programming is never about
> asking the computer to do something and telling it what the constraints
> are (a constraint would be "do this, but remember that we're a background
> process"). Programming is about telling the computer what to do. You
> should NOT say:
>
>  "please scan some pages in the ackground"
>
> but instead say
>
>  "scan and age the active list, and deactive up to 5 pages"
>
> You're the captain. Don't say "Please". Say "Make it so".
>
> 		Linus
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux.eu.org/Linux-MM/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
