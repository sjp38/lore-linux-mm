Received: from atlas.CARNet.hr (zcalusic@atlas.CARNet.hr [161.53.123.163])
	by kvack.org (8.8.7/8.8.7) with ESMTP id HAA11462
	for <linux-mm@kvack.org>; Fri, 24 Jul 1998 07:26:41 -0400
Subject: Re: More info: 2.1.108 page cache performance on low memory
References: <Pine.LNX.3.96.980723214715.18464B-100000@mirkwood.dummy.home>
Reply-To: Zlatko.Calusic@CARNet.hr
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 24 Jul 1998 13:21:29 +0200
In-Reply-To: Rik van Riel's message of "Thu, 23 Jul 1998 21:51:37 +0200 (CEST)"
Message-ID: <87af5zlcjq.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, "Stephen C. Tweedie" <sct@redhat.com>, "Eric W. Biederman" <ebiederm+eric@npwt.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel <H.H.vanRiel@phys.uu.nl> writes:

> On 23 Jul 1998, Zlatko Calusic wrote:
> 
> > One wrong way of fixing it is to limit page cache size, IMNSHO.
> > 
> > I tried the other way, to age page cache harder, and it looks like it
> > works very well. Patch is simple, so simple that I can't understand
> > nobody suggested (something like) it yet.
> 
> These solutions are somewhat the same, but your one may take
> a little less computational power and has a tradeoff in the
> fact that it is very inflexible.

Same? Not in your wildest dream. :)

Limiting means puting "arbitrary" limit. Then page cache would NEVER
grow above that limit.

That's how buffer cache work at the present. It never grows above cca
30% of physical memory installed. That means lots of unused memory...
I don't like it. Many times, no matter how heavy I/O I have, last 20MB
(for exampl, but in many real cases) are free, unused, WASTED.

I see that only on two OSes, NT and recent 2.1.x Linuces.

I know I can change that limit in /proc/sys... but I was always
wondering why is default set so low.

With harder aging you're NOT limiting size of page cache. You
just say  to that subsystem to be polite, but if you have lots of
memory, that memory will be instantly used by the cache. That's
FUNDAMENTALLY different from limiting.

Triple aging has all good characteristics of aging.

Why do you think it is inflexible?

> 
> > --- filemap.c.virgin   Tue Jul 21 18:41:30 1998
> > +++ filemap.c   Thu Jul 23 12:14:43 1998
> > +                       age_page(page);
> > +                       age_page(page);
> >                         age_page(page);
> > If I put only two age_page()s, there's still too much swapping for my
> > taste.
> > With three age_page()s, read performance is as expected, and still we
> > manage memory more efficiently than without page aging.
> 
> This only proves that three age_page()s are a good number
> for _your_ computer and your workload.
> 

Could be. So I'd like to see other people benchmarks.
I hope I'm not theonly speed freak around. :)

I will post another, completely different set of benchmarks today.
Under different initial conditions, so as to simulate different
machines and loads.

> > Comments?
> 
> As Stephen put it so nicely when I (in a bad mood) proposed
> another artificial limit:
> " O no, another arbitrary limit in the kernel! "
> 

I couldn't agree more. I like sane defaults. And simple solutions,
more than anything.

> And another one of Stephen's wisdoms (heavily paraphrased!):
> " Good solutions are dynamic and/or self-tuning "
> [Sorry Stephen, this was VERY heavily paraphrased :)]
> 

Agreed, but only if that self-tuning does not take more code than
the core functionality in itself. :)

I'm very satisfied with changes (in .109 I think)
free_memory_available() went through. Old function was much too much
unnessecary complicated and not useful at all. And unreadable.

Regards,
-- 
Posted by Zlatko Calusic           E-mail: <Zlatko.Calusic@CARNet.hr>
---------------------------------------------------------------------
	       File not found. Should I fake it? (Y/N)
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
