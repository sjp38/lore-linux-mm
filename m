Subject: Re: speeding up swapoff
From: Daniel Drake <ddrake@brontes3d.com>
In-Reply-To: <20070829073040.1ec35176@laptopd505.fenrus.org>
References: <1188394172.22156.67.camel@localhost>
	 <20070829073040.1ec35176@laptopd505.fenrus.org>
Content-Type: text/plain
Date: Wed, 29 Aug 2007 10:44:43 -0400
Message-Id: <1188398683.22156.77.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arjan van de Ven <arjan@infradead.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 2007-08-29 at 07:30 -0700, Arjan van de Ven wrote:
> > My experiments show that when there is not much free physical memory,
> > swapoff moves pages out of swap at a rate of approximately 5mb/sec.
> 
> sounds like about disk speed (at random-seek IO pattern)

We are only using 'standard' seagate SATA disks, but I would have
thought much more performance (40+ mb/sec) would be reachable.

> before you go there... is this a "real life" problem? Or just a
> mostly-artificial corner case? (the answer to that obviously is
> relevant for the 'should we really care' question)

It's more-or-less a real life problem. We have an interactive
application which, when triggered by the user, performs rendering tasks
which must operate in real-time. In attempt to secure performance, we
want to ensure everything is memory resident and that nothing might be
swapped out during the process. So, we run swapoff at that time.

If there is a decent number of pages swapped out, the user sits for a
while at a 'please wait' screen, which is not desirable. To throw some
numbers out there, likely more than a minute for 400mb of swapped pages.

Sure, we could run the whole interactive application with swap disabled,
which is pretty much what we do. However we have other non-real-time
processing tasks which are very memory hungry and do require swap. So,
there are 'corner cases' where the user can reach the real-time part of
the interactive application when there is a lot of memory swapped out.

> Another question, if this is during system shutdown, maybe that's a
> valid case for flushing most of the pagecache first (from userspace)
> since most of what's there won't be used again anyway. If that's enough
> to make this go faster...

Shutdown isn't a concern here.

> A third question, have you investigated what happens if a process gets
> killed that has pages in swap; as long as we don't page those in but
> just forget about them, that would solve the shutdown problem nicely
> (since we kill stuff first anyway there)

According to top, those pages in swap disappear when the process is
killed. So, I don't think there are any swap-related performance issues
on the shutdown path.

Thanks.
-- 
Daniel Drake
Brontes Technologies, A 3M Company
http://www.brontes3d.com/opensource

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
