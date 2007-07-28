Date: Sat, 28 Jul 2007 01:55:58 -0700 (PDT)
From: david@lang.hm
Subject: Re: RFT: updatedb "morning after" problem [was: Re: -mm merge plans
 for 2.6.23]
In-Reply-To: <46AAEDEB.7040003@gmail.com>
Message-ID: <Pine.LNX.4.64.0707280138370.32476@asgard.lang.hm>
References: <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com>
 <20070727030040.0ea97ff7.akpm@linux-foundation.org> <1185531918.8799.17.camel@Homer.simpson.net>
 <200707271345.55187.dhazelton@enter.net> <46AA3680.4010508@gmail.com>
 <Pine.LNX.4.64.0707271239300.26221@asgard.lang.hm> <46AAEDEB.7040003@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rene Herman <rene.herman@gmail.com>
Cc: Daniel Hazelton <dhazelton@enter.net>, Mike Galbraith <efault@gmx.de>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Frank Kingswood <frank@kingswood-consulting.co.uk>, Andi Kleen <andi@firstfloor.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Ray Lee <ray-lk@madrabbit.org>, Jesper Juhl <jesper.juhl@gmail.com>, ck list <ck@vds.kolivas.org>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, 28 Jul 2007, Rene Herman wrote:

> On 07/27/2007 09:43 PM, david@lang.hm wrote:
>
>>  On Fri, 27 Jul 2007, Rene Herman wrote:
>> 
>> >  On 07/27/2007 07:45 PM, Daniel Hazelton wrote:
>> > 
>> > >   Questions about it:
>> > >   Q) Does swap-prefetch help with this?
>> > >   A) [From all reports I've seen (*)]
>> > >   Yes, it does. 
>> > 
>> >  No it does not. If updatedb filled memory to the point of causing 
>> >  swapping (which noone is reproducing anyway) it HAS FILLED MEMORY and 
>> >  swap-prefetch hasn't any memory to prefetch into -- updatedb itself 
>> >  doesn't use any significant memory.
>>
>>  however there are other programs which are known to take up significant
>>  amounts of memory and will cause the issue being described (openoffice for
>>  example)
>>
>>  please don't get hung up on the text 'updatedb' and accept that there are
>>  programs that do run intermittently and do use a significant amount of ram
>>  and then free it.
>
> Different issue. One that's worth pursueing perhaps, but a different issue 
> from the VFS caches issue that people have been trying to track down.

people are trying to track down the problem of their machine being slow 
until enough data is swapped back in to operate normally.

in at some situations swap prefetch can help becouse something that used 
memory freed it so there is free memory that could be filled with data 
(which is something that Linux does agressivly in most other situations)

in some other situations swap prefetch cannot help becouse useless data is 
getting cached at the expense of useful data.

nobody is arguing that swap prefetch helps in the second cast.

what people are arguing is that there are situations where it helps for 
the first case. on some machines and version of updatedb the nighly run of 
updatedb can cause both sets of problems. but the nightly updatedb run is 
not the only thing that can cause problems


but let's talk about the concept here for a little bit

the design is to use CPU and I/O capacity that's otherwise idle to fill 
free memory with data from swap.

pro:
   more ram has potentially useful data in it

con:
   it takes a little extra effort to give this memory to another app (the 
page must be removed from the list and zeroed at the time it's needed, I 
assume that the data is left in swap so that it doesn't have to be written 
out again)

   it adds some complexity to the kernel (~500 lines IIRC from this thread)

   by undoing recent swapouts it can potentially mask problems with swapout

it looks to me like unless the code was really bad (and after 23 months in 
-mm it doesn't sound like it is) that the only significant con left is the 
potential to mask other problems.

however there are many legitimate cases where it is definantly dong the 
right thing (swapout was correct in pushing out the pages, but now the 
cause of that preasure is gone). the amount of benifit from this will vary 
from situation to situation, but it's not reasonable to claim that this 
provides no benifit (you have benchmark numbers that show it in synthetic 
benchmarks, and you have user reports that show it in the real-worlk)

there are lots of things in the kernel who's job is to pre-fill the memroy 
with data that may (or may not) be useful in the future. this is just 
another method of filling the cache. it does so my saying "the user wanted 
these pages in the recent past, so it's a reasonable guess to say that the 
user will want them again in the future"

David Lang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
