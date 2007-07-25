Date: Tue, 24 Jul 2007 21:46:51 -0700 (PDT)
From: david@lang.hm
Subject: Re: -mm merge plans for 2.6.23
In-Reply-To: <2c0942db0707240915h56e007e3l9110e24a065f2e73@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0707242130470.2229@asgard.lang.hm>
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>
 <200707102015.44004.kernel@kolivas.org>  <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com>
  <46A57068.3070701@yahoo.com.au>  <2c0942db0707232153j3670ef31kae3907dff1a24cb7@mail.gmail.com>
  <46A58B49.3050508@yahoo.com.au> <2c0942db0707240915h56e007e3l9110e24a065f2e73@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Lee <ray-lk@madrabbit.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Jesper Juhl <jesper.juhl@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, ck list <ck@vds.kolivas.org>, Ingo Molnar <mingo@elte.hu>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 24 Jul 2007, Ray Lee wrote:

> On 7/23/07, Nick Piggin <nickpiggin@yahoo.com.au> wrote:
>>  Ray Lee wrote:
>
>>  Looking at your past email, you have a 1GB desktop system and your
>>  overnight updatedb run is causing stuff to get swapped out such that
>>  swap prefetch makes it significantly better. This is really
>>  intriguing to me, and I would hope we can start by making this
>>  particular workload "not suck" without swap prefetch (and hopefully
>>  make it even better than it currently is with swap prefetch because
>>  we'll try not to evict useful file backed pages as well).
>
> updatedb is an annoying case, because one would hope that there would
> be a better way to deal with that highly specific workload. It's also
> pretty stat dominant, which puts it roughly in the same category as a
> git diff. (They differ in that updatedb does a lot of open()s and
> getdents on directories, git merely does a ton of lstat()s instead.)
>
> Anyway, my point is that I worry that tuning for an unusual and
> infrequent workload (which updatedb certainly is), is the wrong way to
> go.

updatedb pushing out program data may be able to be improved on with drop 
behind or similar.

however another scenerio that causes a similar problem is when a user is 
busy useing one of the big memory hogs and then switches to another (think 
switching between openoffice and firefox)

>>  After that we can look at other problems that swap prefetch helps
>>  with, or think of some ways to measure your "whole day" scenario.
>>
>>  So when/if you have time, I can cook up a list of things to monitor
>>  and possibly a patch to add some instrumentation over this updatedb
>>  run.
>
> That would be appreciated. Don't spend huge amounts of time on it,
> okay? Point me the right direction, and we'll see how far I can run
> with it.

you could make a synthetic test by writing a memory hog that allocates 3/4 
of your ram then pauses waiting for input and then randomly accesses the 
memory for a while (say randomly accessing 2x # of pages allocated) and 
then pausing again before repeating

run two of these, alternating which one is running at any one time. time 
how long it takes to do the random accesses.

the difference in this time should be a fair example of how much it would 
impact the user.

by the way, I've also seen comments on the Postgres performance mailing 
list about how slow linux is compared to other OS's in pulling data back 
in that's been pushed out to swap (not a factor on dedicated database 
machines, but a big factor on multi-purpose machines)

>>  Anyway, I realise swap prefetching has some situations where it will
>>  fundamentally outperform even the page replacement oracle. This is
>>  why I haven't asked for it to be dropped: it isn't a bad idea at all.
>
> <nod>
>
>>  However, if we can improve basic page reclaim where it is obviously
>>  lacking, that is always preferable. eg: being a highly speculative
>>  operation, swap prefetch is not great for power efficiency -- but we
>>  still want laptop users to have a good experience as well, right?
>
> Absolutely. Disk I/O is the enemy, and the best I/O is one you never
> had to do in the first place.

almost always true, however there is some amount of I/O that is free with 
todays drives (remember, they read the entire track into ram and then 
give you the sectors on the track that you asked for). and if you have a 
raid array this is even more true.

if you read one sector in from a raid5 array you have done all the same 
I/O that you would have to do to read in the entire stripe, but I don't 
believe that the current system will keep it all around if it exceeds the 
readahead limit.

so in many cases readahead may end up being significantly cheaper then you 
expect.

David Lang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
