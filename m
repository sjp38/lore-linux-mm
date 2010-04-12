Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 7C0C56B01E3
	for <linux-mm@kvack.org>; Sun, 11 Apr 2010 22:27:08 -0400 (EDT)
Date: Mon, 12 Apr 2010 10:27:04 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: Downsides to madvise/fadvise(willneed) for application startup
Message-ID: <20100412022704.GB5151@localhost>
References: <4BBA6776.5060804@mozilla.com> <20100406095135.GB5183@cmpxchg.org> <20100407022456.GA9468@localhost> <4BBBF402.70403@mozilla.com> <20100407073847.GB17892@localhost> <4BBE1609.6080308@mozilla.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4BBE1609.6080308@mozilla.com>
Sender: owner-linux-mm@kvack.org
To: Taras Glek <tglek@mozilla.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Apr 09, 2010 at 01:44:41AM +0800, Taras Glek wrote:
> On 04/07/2010 12:38 AM, Wu Fengguang wrote:
> > On Wed, Apr 07, 2010 at 10:54:58AM +0800, Taras Glek wrote:
> >    
> >> On 04/06/2010 07:24 PM, Wu Fengguang wrote:
> >>      
> >>> Hi Taras,
> >>>
> >>> On Tue, Apr 06, 2010 at 05:51:35PM +0800, Johannes Weiner wrote:
> >>>
> >>>        
> >>>> On Mon, Apr 05, 2010 at 03:43:02PM -0700, Taras Glek wrote:
> >>>>
> >>>>          
> >>>>> Hello,
> >>>>> I am working on improving Mozilla startup times. It turns out that page
> >>>>> faults(caused by lack of cooperation between user/kernelspace) are the
> >>>>> main cause of slow startup. I need some insights from someone who
> >>>>> understands linux vm behavior.
> >>>>>
> >>>>>            
> >>> How about improve Fedora (and other distros) to preload Mozilla (and
> >>> other apps the user run at the previous boot) with fadvise() at boot
> >>> time? This sounds like the most reasonable option.
> >>>
> >>>        
> >> That's a slightly different usecase. I'd rather have all large apps
> >> startup as efficiently as possible without any hacks. Though until we
> >> get there, we'll be using all of the hacks we can.
> >>      
> > Boot time user space readahead can do better than kernel heuristic
> > readahead in several ways:
> >
> > - it can collect better knowledge on which files/pages will be used
> >    which lead to high readahead hit ratio and less cache consumption
> >
> > - it can submit readahead requests for many files in parallel,
> >    which enables queuing (elevator, NCQ etc.) optimizations
> >
> > So I won't call it dirty hack :)
> >
> >    
> Fair enough.
> >>> As for the kernel readahead, I have a patchset to increase default
> >>> mmap read-around size from 128kb to 512kb (except for small memory
> >>> systems).  This should help your case as well.
> >>>
> >>>        
> >> Yes. Is the current readahead really doing read-around(ie does it read
> >> pages before the one being faulted)? From what I've seen, having the
> >>      
> > Sure. It will do read-around from current fault offset - 64kb to +64kb.
> >    
> That's excellent.
> >    
> >> dynamic linker read binary sections backwards causes faults.
> >> http://sourceware.org/bugzilla/show_bug.cgi?id=11447
> >>      
> > There are too many data in
> > http://people.mozilla.com/~tglek/startup/systemtap_graphs/ld_bug/report.txt
> > Can you show me the relevant lines? (wondering if I can ever find such lines..)
> >    
> The first part of the file lists sections in a file and their hex 
> offset+size.
 
> lines like 0 512 offset(#1) mean a read at position 0 of 512 bytes. 
> Incidentally this first read is coming from vfs_read, so the log doesn't 
> take account readahead (unlike the other reads caused by mmap page faults).

Yes, every binary/library starts with this 512b read.  It is requested
by ld.so/ld-linux.so, and will trigger a 4-page readahead. This is not
good readahead. I wonder if ld.so can switch to mmap read for the
first read, in order to trigger a larger 128kb readahead. However this
will introduce a little overhead on VMA operations.

> So
> 15310848 131072 offset(#2)=====================
> eaa73c 1523c .bss
> eaa73c 19d1e .comment
> 
> 15142912 131072 offset(#3)=====================
> e810d4 200 .dynamic
> e812d4 470 .got
> e81744 3b50 .got.plt
> e852a0 2549c .data
> 
> Shows 2 reads where the dynamic linker first seeks to the end of the 
> file(to zero out .bss, causing IO via COW) and the backtracks to
> read in .dynamic. However you are right, all of the backtracking reads 
> are over 64K.

This is interesting finding to me, Thanks for the explanation :)

> Thanks for explaining that. I am guessing your change to boost 
> readaround will fix this issue nicely for firefox.

You are welcome.

> >>>
> >>>        
> >>>>> Current Situation:
> >>>>> The dynamic linker mmap()s  executable and data sections of our
> >>>>> executable but it doesn't call madvise().
> >>>>> By default page faults trigger 131072byte reads. To make matters worse,
> >>>>> the compile-time linker + gcc lay out code in a manner that does not
> >>>>> correspond to how the resulting executable will be executed(ie the
> >>>>> layout is basically random). This means that during startup 15-40mb
> >>>>> binaries are read in basically random fashion. Even if one orders the
> >>>>> binary optimally, throughput is still suboptimal due to the puny readahead.
> >>>>>
> >>>>> IO Hints:
> >>>>> Fortunately when one specifies madvise(WILLNEED) pagefaults trigger 2mb
> >>>>> reads and a binary that tends to take 110 page faults(ie program stops
> >>>>> execution and waits for disk) can be reduced down to 6. This has the
> >>>>> potential to double application startup of large apps without any clear
> >>>>> downsides.
> >>>>>
> >>>>> Suse ships their glibc with a dynamic linker patch to fadvise()
> >>>>> dynamic libraries(not sure why they switched from doing madvise
> >>>>> before).
> >>>>>
> >>>>>            
> >>> This is interesting. I wonder how SuSE implements the policy.
> >>> Do you have the patch or some strace output that demonstrates the
> >>> fadvise() call?
> >>>
> >>>        
> >> glibc-2.3.90-ld.so-madvise.diff in
> >> http://www.rpmseek.com/rpm/glibc-2.4-31.12.3.src.html?hl=com&cba=0:G:0:3732595:0:15:0:
> >>      
> > 550 Can't open
> > /pub/linux/distributions/suse/pub/suse/update/10.1/rpm/src/glibc-2.4-31.12.3.src.rpm:
> > No such file or directory
> >
> > OK I give up.
> >
> >    
> >> As I recall they just fadvise the filedescriptor before accessing it.
> >>      
> > Obviously this is a bit risky for small memory systems..
> >
> >    
> >>>>> I filed a glibc bug about this at
> >>>>> http://sourceware.org/bugzilla/show_bug.cgi?id=11431 . Uli commented
> >>>>> with his concern about wasting memory resources. What is the impact of
> >>>>> madvise(WILLNEED) or the fadvise equivalent on systems under memory
> >>>>> pressure? Does the kernel simply start ignoring these hints?
> >>>>>
> >>>>>            
> >>>> It will throttle based on memory pressure.  In idle situations it will
> >>>> eat your file cache, however, to satisfy the request.
> >>>>
> >>>> Now, the file cache should be much bigger than the amount of unneeded
> >>>> pages you prefault with the hint over the whole library, so I guess the
> >>>> benefit of prefaulting the right pages outweighs the downside of evicting
> >>>> some cache for unused library pages.
> >>>>
> >>>> Still, it's a workaround for deficits in the demand-paging/readahead
> >>>> heuristics and thus a bit ugly, I feel.  Maybe Wu can help.
> >>>>
> >>>>          
> >>> Program page faults are inherently random, so the straightforward
> >>> solution would be to increase the mmap read-around size (for desktops
> >>> with reasonable large memory), rather than to improve program layout
> >>> or readahead heuristics :)
> >>>
> >>>        
> >> Program page faults may exhibit random behavior once they've started.
> >>      
> > Right.
> >
> >    
> >> During startup page-in pattern of over-engineered OO applications is
> >> very predictable. Programs are laid out based on compilation units,
> >> which have no relation to how they are executed. Another problem is that
> >> any large old application will have lots of code that is either rarely
> >> executed or completely dead. Random sprinkling of live code among mostly
> >> unneeded code is a problem.
> >>      
> > Agreed.
> >
> >    
> >> I'm able to reduce startup pagefaults by 2.5x and mem usage by a few MB
> >> with proper binary layout. Even if one lays out a program wrongly, the
> >> worst-case pagein pattern will be pretty similar to what it is by default.
> >>      
> > That's great. When will we enjoy your research fruits? :)
> >    
> Released it yesterday. Hopefully other bloated binaries will benefit 
> from this too.
> 
> http://blog.mozilla.com/tglek/2010/04/07/icegrind-valgrind-plugin-for-optimizing-cold-startup/

It sounds painful to produce the valgrind log, fortunately the end
user won't suffer.

Is it viable to turn on the "-ffunction-sections -fdata-sections"
options distribution wide? If so, you may sell it to Fedora :)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
