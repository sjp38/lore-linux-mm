Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 0821A6B01EE
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 03:38:50 -0400 (EDT)
Date: Wed, 7 Apr 2010 15:38:47 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: Downsides to madvise/fadvise(willneed) for application startup
Message-ID: <20100407073847.GB17892@localhost>
References: <4BBA6776.5060804@mozilla.com> <20100406095135.GB5183@cmpxchg.org> <20100407022456.GA9468@localhost> <4BBBF402.70403@mozilla.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4BBBF402.70403@mozilla.com>
Sender: owner-linux-mm@kvack.org
To: Taras Glek <tglek@mozilla.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 07, 2010 at 10:54:58AM +0800, Taras Glek wrote:
> On 04/06/2010 07:24 PM, Wu Fengguang wrote:
> > Hi Taras,
> >
> > On Tue, Apr 06, 2010 at 05:51:35PM +0800, Johannes Weiner wrote:
> >    
> >> On Mon, Apr 05, 2010 at 03:43:02PM -0700, Taras Glek wrote:
> >>      
> >>> Hello,
> >>> I am working on improving Mozilla startup times. It turns out that page
> >>> faults(caused by lack of cooperation between user/kernelspace) are the
> >>> main cause of slow startup. I need some insights from someone who
> >>> understands linux vm behavior.
> >>>        
> > How about improve Fedora (and other distros) to preload Mozilla (and
> > other apps the user run at the previous boot) with fadvise() at boot
> > time? This sounds like the most reasonable option.
> >    
> That's a slightly different usecase. I'd rather have all large apps 
> startup as efficiently as possible without any hacks. Though until we 
> get there, we'll be using all of the hacks we can.

Boot time user space readahead can do better than kernel heuristic
readahead in several ways:

- it can collect better knowledge on which files/pages will be used
  which lead to high readahead hit ratio and less cache consumption

- it can submit readahead requests for many files in parallel,
  which enables queuing (elevator, NCQ etc.) optimizations

So I won't call it dirty hack :)

> > As for the kernel readahead, I have a patchset to increase default
> > mmap read-around size from 128kb to 512kb (except for small memory
> > systems).  This should help your case as well.
> >    
> Yes. Is the current readahead really doing read-around(ie does it read 
> pages before the one being faulted)? From what I've seen, having the 

Sure. It will do read-around from current fault offset - 64kb to +64kb.

> dynamic linker read binary sections backwards causes faults.
> http://sourceware.org/bugzilla/show_bug.cgi?id=11447

There are too many data in
http://people.mozilla.com/~tglek/startup/systemtap_graphs/ld_bug/report.txt
Can you show me the relevant lines? (wondering if I can ever find such lines..)

> >    
> >>> Current Situation:
> >>> The dynamic linker mmap()s  executable and data sections of our
> >>> executable but it doesn't call madvise().
> >>> By default page faults trigger 131072byte reads. To make matters worse,
> >>> the compile-time linker + gcc lay out code in a manner that does not
> >>> correspond to how the resulting executable will be executed(ie the
> >>> layout is basically random). This means that during startup 15-40mb
> >>> binaries are read in basically random fashion. Even if one orders the
> >>> binary optimally, throughput is still suboptimal due to the puny readahead.
> >>>
> >>> IO Hints:
> >>> Fortunately when one specifies madvise(WILLNEED) pagefaults trigger 2mb
> >>> reads and a binary that tends to take 110 page faults(ie program stops
> >>> execution and waits for disk) can be reduced down to 6. This has the
> >>> potential to double application startup of large apps without any clear
> >>> downsides.
> >>>
> >>> Suse ships their glibc with a dynamic linker patch to fadvise()
> >>> dynamic libraries(not sure why they switched from doing madvise
> >>> before).
> >>>        
> > This is interesting. I wonder how SuSE implements the policy.
> > Do you have the patch or some strace output that demonstrates the
> > fadvise() call?
> >    
> glibc-2.3.90-ld.so-madvise.diff in 
> http://www.rpmseek.com/rpm/glibc-2.4-31.12.3.src.html?hl=com&cba=0:G:0:3732595:0:15:0: 

550 Can't open
/pub/linux/distributions/suse/pub/suse/update/10.1/rpm/src/glibc-2.4-31.12.3.src.rpm:
No such file or directory

OK I give up.

> As I recall they just fadvise the filedescriptor before accessing it.

Obviously this is a bit risky for small memory systems..

> >>> I filed a glibc bug about this at
> >>> http://sourceware.org/bugzilla/show_bug.cgi?id=11431 . Uli commented
> >>> with his concern about wasting memory resources. What is the impact of
> >>> madvise(WILLNEED) or the fadvise equivalent on systems under memory
> >>> pressure? Does the kernel simply start ignoring these hints?
> >>>        
> >> It will throttle based on memory pressure.  In idle situations it will
> >> eat your file cache, however, to satisfy the request.
> >>
> >> Now, the file cache should be much bigger than the amount of unneeded
> >> pages you prefault with the hint over the whole library, so I guess the
> >> benefit of prefaulting the right pages outweighs the downside of evicting
> >> some cache for unused library pages.
> >>
> >> Still, it's a workaround for deficits in the demand-paging/readahead
> >> heuristics and thus a bit ugly, I feel.  Maybe Wu can help.
> >>      
> > Program page faults are inherently random, so the straightforward
> > solution would be to increase the mmap read-around size (for desktops
> > with reasonable large memory), rather than to improve program layout
> > or readahead heuristics :)
> >    
> Program page faults may exhibit random behavior once they've started.

Right.

> During startup page-in pattern of over-engineered OO applications is 
> very predictable. Programs are laid out based on compilation units, 
> which have no relation to how they are executed. Another problem is that 
> any large old application will have lots of code that is either rarely 
> executed or completely dead. Random sprinkling of live code among mostly 
> unneeded code is a problem.

Agreed.

> I'm able to reduce startup pagefaults by 2.5x and mem usage by a few MB 
> with proper binary layout. Even if one lays out a program wrongly, the 
> worst-case pagein pattern will be pretty similar to what it is by default.

That's great. When will we enjoy your research fruits? :)

> But yes, I completely agree that it would be awesome to increase the 
> readahead size proportionally to available memory. It's a little silly 
> to be reading tens of megabytes in 128kb increments :)  You rock for 
> trying to modernize this.

Thank you. I guess the 128kb is more than ten years old..

Cheers,
Fengguang

> >    
> >>> Also, once an application is started is it reasonable to keep it
> >>> madvise(WILLNEED)ed or should the madvise flags be reset?
> >>>        
> >> It's a one-time operation that starts immediate readahead, no permanent
> >> changes are done.
> >>      
> > Right. The kernel regard WILLNEED as a readahead request from userspace.
> >
> >    
> >>> Perhaps the kernel could monitor the page-in patterns to increase the
> >>> readahead sizes? This may already happen, I've noticed that a handful of
> >>> pagefaults trigger>  131072bytes of IO, perhaps this just needs tweaking.
> >>>        
> >> CCd the man :-)
> >>      
> > Thank you :)
> >
> > Cheers,
> > Fengguang
> >    
> 
> Cheers,
> Taras

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
