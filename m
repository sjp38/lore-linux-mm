From: Al Boldi <a1426z@gawab.com>
Subject: Re: -mm merge plans for 2.6.23
Date: Wed, 25 Jul 2007 23:16:01 +0300
Message-ID: <200707252316.01021.a1426z@gawab.com>
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0707242130470.2229@asgard.lang.hm>
	<2c0942db0707250855v414cd72di1e859da423fa6a3a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Return-path: <ck-bounces@vds.kolivas.org>
In-Reply-To: <2c0942db0707250855v414cd72di1e859da423fa6a3a@mail.gmail.com>
Content-Disposition: inline
List-Unsubscribe: <http://bhhdoa.org.au/mailman/listinfo/ck>,
	<mailto:ck-request@vds.kolivas.org?subject=unsubscribe>
List-Archive: <http://bhhdoa.org.au/pipermail/ck>
List-Post: <mailto:ck@vds.kolivas.org>
List-Help: <mailto:ck-request@vds.kolivas.org?subject=help>
List-Subscribe: <http://bhhdoa.org.au/mailman/listinfo/ck>,
	<mailto:ck-request@vds.kolivas.org?subject=subscribe>
Sender: ck-bounces@vds.kolivas.org
Errors-To: ck-bounces@vds.kolivas.org
To: Ray Lee <ray-lk@madrabbit.org>, "david@lang.hm" <david@lang.hm>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Jesper Juhl <jesper.juhl@gmail.com>, linux-kernel@vger.kernel.org, ck list <ck@vds.kolivas.org>, linux-mm@kvack.org, Paul Jackson <pj@sgi.com>, Andrew Morton <akpm@linux-foundation.org>
List-Id: linux-mm.kvack.org

Ray Lee wrote:
> On 7/24/07, david@lang.hm <david@lang.hm> wrote:
> > by the way, I've also seen comments on the Postgres performance mailing
> > list about how slow linux is compared to other OS's in pulling data back
> > in that's been pushed out to swap (not a factor on dedicated database
> > machines, but a big factor on multi-purpose machines)
>
> Yeah, akpm and... one of the usual suspects, had mentioned something
> such as 2.6 is half the speed of 2.4 for swapin. (Let's see if I can
> find a reference for that, it's been a year or more...) Okay,
> misremembered. Swap in is half the speed of swap out (
> http://lkml.org/lkml/2007/1/22/173 ). Al Boldi (added to the CC:, poor
> sod), is the one who knows how to measure that, I'm guessing.
>
> Al? How are you coming up with those figures? I'm interested in
> reproducing it. It could be due to something stupid, such as the VM
> faulting things out in reverse order or something...

Thanks for asking.  I'm rather surprised why nobody's noticing any of this 
slowdown.  To be fair, it's not really a regression, on the contrary, 2.4 is 
lot worse wrt swapin and swapout, and Rik van Riel even considers a 50% 
swapin slowdown wrt swapout something like better than expected (see thread 
'[RFC] kswapd: Kernel Swapper performance').  He probably meant random 
swapin, which seems to offer a 4x slowdown.

There are two ways to reproduce this:

1. swsusp to disk reports ~44mb/s swapout, and ~25mb/s swapin during resume

2. tmpfs swapout is superfast, whereas swapin is really slow
(see thread '[PATCH] free swap space when (re)activating page')

Here is an excerpt from that thread (note machine config in first line):

============================================
 RAM 512mb , SWAP 1G
 #mount -t tmpfs -o size=1G none /dev/shm
 #time cat /dev/full > /dev/shm/x.dmp
 15sec
 #time cat /dev/shm/x.dmp > /dev/null
 58sec
 #time cat /dev/shm/x.dmp > /dev/null
 72sec
 #time cat /dev/shm/x.dmp > /dev/null
 85sec
 #time cat /dev/shm/x.dmp > /dev/null
 93sec
 #time cat /dev/shm/x.dmp > /dev/null
 99sec
============================================

As you can see, swapout is running full wirespeed, whereas swapin not only is 
4x slower, but increasingly gets the VM tangled up to end at a ~6x slowdown.

So again, I'm really surprised people haven't noticed.


Thanks!

--
Al
