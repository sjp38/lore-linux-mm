Subject: Re: [RFC][PATCH] prevent incorrect oom under split_lru
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <28c262360806242356n3f7e02abwfee1f6acf0fd2c61@mail.gmail.com>
References: <20080624092824.4f0440ca@bree.surriel.com>
	 <28c262360806242259k3ac308c4n7cee29b72456e95b@mail.gmail.com>
	 <20080625150141.D845.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <28c262360806242356n3f7e02abwfee1f6acf0fd2c61@mail.gmail.com>
Content-Type: text/plain
Date: Wed, 25 Jun 2008 14:11:25 +0200
Message-Id: <1214395885.15232.17.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: MinChan Kim <minchan.kim@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, akpm@linux-foundation.org, Takenori Nagano <t-nagano@ah.jp.nec.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2008-06-25 at 15:56 +0900, MinChan Kim wrote:
> On Wed, Jun 25, 2008 at 3:08 PM, KOSAKI Motohiro
> <kosaki.motohiro@jp.fujitsu.com> wrote:
> > Hi Kim-san,
> >
> >> >> So, if priority==0, We should try to reclaim all page for prevent OOM.
> >> >
> >> > You are absolutely right.  Good catch.
> >>
> >> I have a concern about application latency.
> >> If lru list have many pages, it take a very long time to scan pages.
> >> More system have many ram, More many time to scan pages.
> >
> > No problem.
> >
> > priority==0 indicate emergency.
> > it doesn't happend on typical workload.
> >
> 
> I see :)
> 
> But if such emergency happen in embedded system, application can't be
> executed for some time.
> I am not sure how long time it take.
> But In some application, schedule period is very important than memory
> reclaim latency.
> 
> Now, In your patch, when such emergency happen, it continue to reclaim
> page until it will scan entire page of lru list.
> It

IMHO embedded real-time apps shoud mlockall() and not do anything that
can result in memory allocations in their fast (deterministic) paths.

The much more important case is desktop usage - that is where we run non
real-time code, but do expect 'low' latency due to user-interaction.

>From hitting swap on my 512M laptop (rather frequent occurance) I know
we can do better here,..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
