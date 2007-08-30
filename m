Message-ID: <46D6E8CE.6080205@tmr.com>
Date: Thu, 30 Aug 2007 11:57:02 -0400
From: Bill Davidsen <davidsen@tmr.com>
MIME-Version: 1.0
Subject: Re: speeding up swapoff
References: <1188394172.22156.67.camel@localhost>	 <20070829073040.1ec35176@laptopd505.fenrus.org> <1188398683.22156.77.camel@localhost>
In-Reply-To: <1188398683.22156.77.camel@localhost>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Drake <ddrake@brontes3d.com>
Cc: Arjan van de Ven <arjan@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Daniel Drake wrote:
> On Wed, 2007-08-29 at 07:30 -0700, Arjan van de Ven wrote:
>>> My experiments show that when there is not much free physical memory,
>>> swapoff moves pages out of swap at a rate of approximately 5mb/sec.
>> sounds like about disk speed (at random-seek IO pattern)
> 
> We are only using 'standard' seagate SATA disks, but I would have
> thought much more performance (40+ mb/sec) would be reachable.
> 
>> before you go there... is this a "real life" problem? Or just a
>> mostly-artificial corner case? (the answer to that obviously is
>> relevant for the 'should we really care' question)
> 
> It's more-or-less a real life problem. We have an interactive
> application which, when triggered by the user, performs rendering tasks
> which must operate in real-time. In attempt to secure performance, we
> want to ensure everything is memory resident and that nothing might be
> swapped out during the process. So, we run swapoff at that time.

So the real issue isn't that your process doesn't run fast enough 
without doing swapoff, but that swapoff itself takes too long.
> 
> If there is a decent number of pages swapped out, the user sits for a
> while at a 'please wait' screen, which is not desirable. To throw some
> numbers out there, likely more than a minute for 400mb of swapped pages.
> 
> Sure, we could run the whole interactive application with swap disabled,
> which is pretty much what we do. However we have other non-real-time
> processing tasks which are very memory hungry and do require swap. So,
> there are 'corner cases' where the user can reach the real-time part of
> the interactive application when there is a lot of memory swapped out.

How much is "a lot?" You said 400MB, you can add a few GB of RAM and 
eliminate the problem at that size. Run the application in a virtual 
machine which has enough dedicated memory? I think xen will do that. Run 
"swap" on a ramdisk? I don't think swapoff was designed as a fast 
operation, although your performance is pretty leisurely. ;-)

I assume you looked at mlock() and it doesn't fit your usage, or you 
don't control the application behavior, or its limitations make it 
unsuitable in some other way.
> 
>> Another question, if this is during system shutdown, maybe that's a
>> valid case for flushing most of the pagecache first (from userspace)
>> since most of what's there won't be used again anyway. If that's enough
>> to make this go faster...
> 
> Shutdown isn't a concern here.
> 
>> A third question, have you investigated what happens if a process gets
>> killed that has pages in swap; as long as we don't page those in but
>> just forget about them, that would solve the shutdown problem nicely
>> (since we kill stuff first anyway there)
> 
> According to top, those pages in swap disappear when the process is
> killed. So, I don't think there are any swap-related performance issues
> on the shutdown path.
> 
> Thanks.


-- 
Bill Davidsen <davidsen@tmr.com>
   "We have more to fear from the bungling of the incompetent than from
the machinations of the wicked."  - from Slashdot

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
