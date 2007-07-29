From: Daniel Hazelton <dhazelton@enter.net>
Subject: Re: RFT: updatedb "morning after" problem [was: Re: -mm merge plans for 2.6.23]
Date: Sun, 29 Jul 2007 17:06:28 -0400
References: <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com> <20070729123353.2bfb9630.pj@sgi.com> <2c0942db0707291300k3e30e410wdd0aba7644382e3b@mail.gmail.com>
In-Reply-To: <2c0942db0707291300k3e30e410wdd0aba7644382e3b@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200707291706.29100.dhazelton@enter.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Lee <ray-lk@madrabbit.org>
Cc: Paul Jackson <pj@sgi.com>, rene.herman@gmail.com, alan@lxorguk.ukuu.org.uk, david@lang.hm, efault@gmx.de, akpm@linux-foundation.org, mingo@elte.hu, frank@kingswood-consulting.co.uk, andi@firstfloor.org, nickpiggin@yahoo.com.au, jesper.juhl@gmail.com, ck@vds.kolivas.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sunday 29 July 2007 16:00:22 Ray Lee wrote:
> On 7/29/07, Paul Jackson <pj@sgi.com> wrote:
> > If the problem is reading stuff back in from swap at the *same time*
> > that the application is reading stuff from some user file system, and if
> > that user file system is on the same drive as the swap partition
> > (typical on laptops), then interleaving the user file system accesses
> > with the swap partition accesses might overwhelm all other performance
> > problems, due to the frequent long seeks between the two.
>
> Ah, so in a normal scenario where a working-set is getting faulted
> back in, we have the swap storage as well as the file-backed stuff
> that needs to be read as well. So even if swap is organized perfectly,
> we're still seeking. Damn.

That is one reason why I try to have swap on a device dedicated just for it. 
It helps keep the system from having to seek all over the drive for data. (I 
remember that this was recommended years ago with Windows - back when you 
could tell Windows where to put the swap file)

> On the other hand, that explains another thing that swap prefetch
> could be helping with -- if it preemptively faults the swap back in,
> then the file-backed stuff can be faulted back more quickly, just by
> the virtue of not needing to seek back and forth to swap for its
> stuff. Hadn't thought of that.

For it to really help swap-prefetch would have to be more aggressive. At the 
moment (if I'm reading the code correctly) the system has to have close to 
zero for it to kick in. A tunable knob controlling how much activity is too 
much for the prefetch to kick in would help with finding a sane default. IMHO 
it should be the one that provides the most benefit with the least hit to 
performance.

> That also implies that people running with swap files rather than swap
> partitions will see less of an issue. I should dig out my old compact
> flash card and try putting swap on that for a week.

Maybe. It all depends on how much seeking is needed to track down the pages in 
the swapfile and such. What would really help make the situation even better 
would be doing the log structured swap + cleaner. The log structured swap + 
cleaner should provide a performance boost by itself - add in the prefetch 
mechanism and the benefits are even more visible.

Another way to improve performance would require making the page replacement 
mechanism more intelligent. There are bounds to what can be done in the 
kernel without negatively impacting performance, but, if I've read the code 
correctly, there might be a better way to decide which pages to evict. One 
way to do this would be to implement some mechanism that allows the system to 
choose a single group of contiguous pages (or, say, a large soft-page) over 
swapping out a single page at a time.

(some form of memory defrag would also be nice, but I can't think of a way to 
do that without massively breaking everything)

<snip>
> > In case Andrew is so bored he read this far -- yes this wake-up sounds
> > like user space code, with minimal kernel changes to support any
> > particular lower level operation that we can't do already.
>
> He'd suggested using, uhm, ptrace_peek or somesuch for just such a
> purpose. The second half of the issue is to know when and what to
> target.

The userspace suggestion that was thrown out earlier would have been as 
error-prone and problematic as FUSE. A solution like you suggest would be 
workable - its small and does a task that is best done in userspace (IMHO). 
(IIRC, the original suggestion involved merging maps2 and another patchset 
into mainline and using that, combined with PEEKTEXT to provide for a 
userspace swap daemon. Swap, IMHO, should never be handled outside the 
kernel)

What might be useful is a userspace daemon that tracks memory pressure and 
uses a concise API to trigger various levels of prefetch and/or swap 
aggressiveness.

DRH

-- 
Dialup is like pissing through a pipette. Slow and excruciatingly painful.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
