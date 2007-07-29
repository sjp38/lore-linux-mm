Date: Sun, 29 Jul 2007 14:19:58 -0700 (PDT)
From: david@lang.hm
Subject: Re: RFT: updatedb "morning after" problem [was: Re: -mm merge plans
 for 2.6.23]
In-Reply-To: <46AC9DC5.8070900@gmail.com>
Message-ID: <Pine.LNX.4.64.0707291405350.15835@asgard.lang.hm>
References: <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com>
 <20070727030040.0ea97ff7.akpm@linux-foundation.org> <1185531918.8799.17.camel@Homer.simpson.net>
 <200707271345.55187.dhazelton@enter.net> <46AA3680.4010508@gmail.com>
 <Pine.LNX.4.64.0707271239300.26221@asgard.lang.hm> <46AAEDEB.7040003@gmail.com>
 <Pine.LNX.4.64.0707280138370.32476@asgard.lang.hm> <46AB166A.2000300@gmail.com>
 <Pine.LNX.4.64.0707281349540.32476@asgard.lang.hm> <46AC6771.8080000@gmail.com>
 <Pine.LNX.4.64.0707290420250.15835@asgard.lang.hm> <46AC9DC5.8070900@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rene Herman <rene.herman@gmail.com>
Cc: Daniel Hazelton <dhazelton@enter.net>, Mike Galbraith <efault@gmx.de>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Frank Kingswood <frank@kingswood-consulting.co.uk>, Andi Kleen <andi@firstfloor.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Ray Lee <ray-lk@madrabbit.org>, Jesper Juhl <jesper.juhl@gmail.com>, ck list <ck@vds.kolivas.org>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, 29 Jul 2007, Rene Herman wrote:

> On 07/29/2007 01:41 PM, david@lang.hm wrote:
>
>>  I agree that tinkering with the core VM code should not be done lightly,
>>  but this has been put through the proper process and is stalled with no
>>  hints on how to move forward.
>
> It has not. Concerns that were raised (by specifically Nick Piggin) weren't 
> being addressed.

I may have missed them, but what I saw from him weren't specific issues, 
but instead a nebulous 'something better may come along later'

>>  forget the nightly cron jobs for the moment. think of this scenerio. you
>>  have your memory fairly full with apps that you have open (including
>>  firefox with many tabs), you receive a spreadsheet you need to look at, so
>>  you fire up openoffice to look at it. then you exit openoffice and try
>>  to go back to firefox (after a pause while you walk to the printer to
>>  get the printout of the spreadsheet)
>
> And swinging a dead rat from its tail facing east-wards while reciting 
> Documentation/CodingStyle.
>
> Okay, very very sorry, that was particularly childish, but that "walking to 
> the printer" is ofcourse completely constructed and this _is_ something to 
> take into account.

yes it was contrived for simplicity.

the same effect would happen if instead of going back to firefox the user 
instead went to their e-mail software and read some mail. doing so should 
still make the machine idle enough to let prefetch kick in.

> Swap-prefetch wants to be free, which (also again) it is 
> doing a good job at it seems, but this also means that it waits for the VM to 
> be _very_ idle before it does anything and as such, we cannot just forget the 
> "nightly" scenario and pretend it's about something else entirely. As long as 
> the machine's being used, swap-prefetch doesn't kick in.

how long does the machine need to be idle? if someone spends 30 seconds 
reading an e-mail that's an incredibly long time for the system and I 
would think it should be enough to let the prefetch kick in.

>> >  -- 3: no serious consideration of possible alternatives
>> > 
>> >  Tweaking existing use-oce logic is one I've heard but if we consider 
>> >  the i/dcache issue dead, I believe that one is as well. Going to 
>> >  userspace is another one. Largest theoretical potential. I myself am 
>> >  extremely sceptical about the Linux userland, and largely equate it 
>> >  with "smallest _practical_ potential" -- but that might just be me.
>> > 
>> >  A larger swap granularity, possible even a self-training 
>> >  granularity. Up to now, seeks only get costlier and costlier with 
>> >  respect to reads with every generation of disk (flash would largely 
>> >  overcome it though) and doing more in one read/write _greatly_ 
>> >  improves throughput, maybe up to the point that swap-prefetch is no 
>> >  longer very useful. I myself don't know about the tradeoffs 
>> >  involved.
>>
>>  larger swap granularity may help, but waiting for the user to need the
>>  ram and have to wait for it to be read back in is always going to be
>>  worse for the user then pre-populating the free memory (for the case
>>  where the pre-population is right, for other cases it's the same). so
>>  I see this as a red herring
>
> I saw Chris Snook make a good post here and am going to defer this part to 
> that discussion:
>
> http://lkml.org/lkml/2007/7/27/421
>
> But no, it's not a red herring if _practically_ speaking the swapin is fast 
> enough once started that people don't actually mind anymore since in that 
> case you could simply do without yet more additional VM complexity (and 
> kernel daemon).

swapin will always require disk access, and avoiding doing disk access 
while the user is waiting for it by doing it when the system isn't useing 
the disk will always be a win (possibly not as large of a win, but still a 
win) on slow laptop drives where you may only get 20MB/second of reads 
under optimal situations it doesn't take much reading to be noticed by the 
user.

>>  there are fully legitimate situations where this is useful, the 'papering
>>  over' effect is not referring to these, it's referring to other possible
>>  problems in the future.
>
> No, it's not just future. Just look at the various things under discussion 
> now such as improved use-once and better swapin.

and these thing do not conflict with prefetch, they compliment it.

improved use-once will avoid pushing things out to swap in the first 
place. this will help during normal workloads so is valuble in any case.

better swapin (I assume you are talking about things like larger swap 
granularity) will also help during normal workloads when you are thrashing 
into swap.

prefetch will help when you have pushed things out to swap and now have 
free memory and a momentarily idle system.

David Lang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
