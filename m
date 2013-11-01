Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-gg0-f206.google.com (mail-gg0-f206.google.com [209.85.161.206])
	by kanga.kvack.org (Postfix) with ESMTP id 700726B0035
	for <linux-mm@kvack.org>; Sat,  2 Nov 2013 12:53:10 -0400 (EDT)
Received: by mail-gg0-f206.google.com with SMTP id b1so45226ggn.9
        for <linux-mm@kvack.org>; Sat, 02 Nov 2013 09:53:10 -0700 (PDT)
Received: from psmtp.com ([74.125.245.206])
        by mx.google.com with SMTP id ph6si5205545pbb.7.2013.11.01.11.43.39
        for <linux-mm@kvack.org>;
        Fri, 01 Nov 2013 11:43:40 -0700 (PDT)
Date: Fri, 1 Nov 2013 14:43:32 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [Bug 64121] New: [BISECTED] "mm" performance regression updating
 from 3.2 to 3.3
Message-ID: <20131101184332.GF707@cmpxchg.org>
References: <bug-64121-27@https.bugzilla.kernel.org/>
 <20131031134610.30d4c0e98e58fb0484e988c1@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131031134610.30d4c0e98e58fb0484e988c1@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, thomas.jarosch@intra2net.com, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org

On Thu, Oct 31, 2013 at 01:46:10PM -0700, Andrew Morton wrote:
> 
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> On Thu, 31 Oct 2013 10:53:47 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:
> 
> > https://bugzilla.kernel.org/show_bug.cgi?id=64121
> > 
> >             Bug ID: 64121
> >            Summary: [BISECTED] "mm" performance regression updating from
> >                     3.2 to 3.3
> >            Product: Memory Management
> >            Version: 2.5
> >     Kernel Version: 3.3
> >           Hardware: i386
> >                 OS: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: normal
> >           Priority: P1
> >          Component: Other
> >           Assignee: akpm@linux-foundation.org
> >           Reporter: thomas.jarosch@intra2net.com
> >         Regression: No
> > 
> > Created attachment 112881
> >   --> https://bugzilla.kernel.org/attachment.cgi?id=112881&action=edit
> > Dmesg output
> > 
> > Hi,
> > 
> > I've updated a productive box running kernel 3.0.x to 3.4.67.
> > This caused a severe I/O performance regression.
> > 
> > After some hours I've bisected it down to this commit:
> > 
> > ---------------------------
> > # git bisect good
> > ab8fabd46f811d5153d8a0cd2fac9a0d41fb593d is the first bad commit
> > commit ab8fabd46f811d5153d8a0cd2fac9a0d41fb593d
> > Author: Johannes Weiner <jweiner@redhat.com>
> > Date:   Tue Jan 10 15:07:42 2012 -0800
> > 
> >     mm: exclude reserved pages from dirtyable memory
> > 
> >     Per-zone dirty limits try to distribute page cache pages allocated for
> >     writing across zones in proportion to the individual zone sizes, to reduce
> >     the likelihood of reclaim having to write back individual pages from the
> >     LRU lists in order to make progress.
> > 
> >     ...
> > ---------------------------
> > 
> > With the "problematic" patch:
> > # dd_rescue -A /dev/zero img.disk
> > dd_rescue: (info): ipos:     15296.0k, opos:     15296.0k, xferd:     15296.0k
> >                    errs:      0, errxfer:         0.0k, succxfer:     15296.0k
> >              +curr.rate:      681kB/s, avg.rate:      681kB/s, avg.load:  0.3%
> > 
> > 
> > Without the patch (using 25bd91bd27820d5971258cecd1c0e64b0e485144):
> > # dd_rescue -A /dev/zero img.disk
> > dd_rescue: (info): ipos:    293888.0k, opos:    293888.0k, xferd:    293888.0k
> >                    errs:      0, errxfer:         0.0k, succxfer:    293888.0k
> >              +curr.rate:    99935kB/s, avg.rate:    51625kB/s, avg.load:  3.3%
> > 
> > 
> > 
> > The kernel is 32bit using PAE mode. The system has 32GB of RAM.
> > (compiled with "gcc (GCC) 4.4.4 20100630 (Red Hat 4.4.4-10)")
> > 
> > Interestingly: If I limit the amount of RAM to roughly 20GB
> > via the "mem=20000m" boot parameter, the performance is fine.
> > When I increase it to f.e. "mem=23000m", performance is bad.
> > 
> > Also tested kernel 3.10.17 in 32bit + PAE mode,
> > it was fine out of the box.
> > 
> > 
> > So basically we need a fix for the LTS kernel 3.4, I can work around
> > this issue with "mem=20000m" until I upgrade to 3.10.
> > 
> > I'll probably have access to the hardware for one more week
> > to test patches, it was lent to me to debug this specific problem.
> > 
> > The same issue appeared on a complete different machine in July
> > using the same 3.4.x kernel. The box had 16GB of RAM.
> > I didn't get a chance to access the hardware back then.
> > 
> > Attached is the dmesg output and my kernel config.
> 
> 32GB of memory on a highmem machine just isn't going to work well,
> sorry.  Our rule of thumb is that 16G is the max.  If it was previously
> working OK with 32G then you were very lucky!
> 
> That being said, we should try to work out exactly why that commit
> caused the big slowdown - perhaps there is something we can do to
> restore things.  It appears that the (small?) increase in the per-zone
> dirty limit is what kicked things over - perhaps we can permit that to
> be tuned back again.  Or something.  Johannes, could you please have a
> think about it?

It is a combination of two separate things on these setups.

Traditionally, only lowmem is considered dirtyable so that dirty pages
don't scale with highmem and the kernel doesn't overburden itself with
lowmem pressure from buffers etc.  This is purely about accounting.

My patches on the other hand were about dirty page placement and
avoiding writeback from page reclaim: by subtracting the watermark and
the lowmem reserve (memory not available for user memory / cache) from
each zone's dirtyable memory, we make sure that the zone can always be
rebalanced without writeback.

The problem now is that the lowmem reserves scale with highmem and
there is a point where they entirely overshadow the Normal zone.  This
means that no page cache at all is allowed in lowmem.  Combine this
with how dirtyable memory excludes highmem, and the sum of all
dirtyable memory is nil.  This effectively disables the writeback
cache.

I figure if anything should be fixed it should be the full exclusion
of highmem from dirtyable memory and find a better way to calculate a
minimum.

HOWEVER,

the lowmem reserve is highmem/32 per default.  With a Normal zone of
around 900M, this requires 28G+ worth of HighMem to eclipse lowmem
entirely.  This is almost double of what you consider still okay...

So how would we even pick a sane minimum of dirtyable memory on these
machines?  It's impossible to pick something and say this should work
for most people, those setups are barely working to begin with.  Plus,
people can always set the vm.highmem_is_dirtyable sysctl to 1 or just
set dirty memory limits with dirty_bytes and dirty_background_bytes to
something that gets their crazy setups limping again.

Maybe we should just ignore everything above 16G on 32 bit, but that
would mean actively breaking setups that _individually_ worked before
and never actually hit problems due to their specific circumstances.

On the other hand, I don't think it's reasonable to support this
anymore and it should be more clear that people doing these things are
on their own.

What makes it worse is that all of these reports have been modern 64
bit machines, with modern amounts of memory, running 32 bit kernels.
I'd be more inclined to seriously look into this if it were hardware
that couldn't just run a 64 bit kernel...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
