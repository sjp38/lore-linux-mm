Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id BEEA88D0039
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 06:24:32 -0500 (EST)
Subject: Re: [Bug 29772] New: memory compaction crashed
From: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <20110224103706.GR15652@csn.ul.ie>
References: <bug-29772-27@https.bugzilla.kernel.org/>
	 <20110223134015.be96110b.akpm@linux-foundation.org>
	 <20110223233934.GN15652@csn.ul.ie>
	 <1298537237.3764.17.camel@jlt3.sipsolutions.net>
	 <20110224103706.GR15652@csn.ul.ie>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 24 Feb 2011 12:25:50 +0100
Message-ID: <1298546750.3764.23.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org

On Thu, 2011-02-24 at 10:37 +0000, Mel Gorman wrote:

> > Yes. I was using evince to pan around in a fairly large PDF that really
> > is a large single-page bitmap, but that's about it. I also have a fairly
> > large (bit more than full HD) external monitor, both of these probably
> > take some amount of memory. The system had been up for a while few hours
> > at most, with similar workloads, sometimes a kernel compile (but none
> > was running at the time).

> Is this reproducible or did it just happen the once?

It happened only once so far. And it wasn't the first time I was doing
this (panning large files) either.

> > > Can you tell me what line the instruction ffffffff8100f1c2 corresponds to? If
> > > you have CONFIG_DEBUG_INFO set, it should be a case of telling me what the
> > > output of "addr2line -e vmlinux 0xffffffff8100f1c2" is. On a similar note,
> > > do you know what sort of crash this was? i.e. was it a NULL deference or
> > > did a VM_BUG_ON or BUG_ON hit such as VM_BUG_ON(PageTransCompound(page))?
> > > Was CONFIG_DEBUG_VM set? Actually, it would be preferable to have the
> > > whole .config attached to the bugzilla if possible please.
> > 
> > Attached the config. addr2line failed so I probably don't have enough
> > debug info,
> 
> Indeed not, can you enable CONFIG_DEBUG_INFO for future reference
> please? It'll be easier to figure out where things crashed exactly.
> Also, what compiler are you using?

$ gcc --version
gcc-4.5.real (Debian 4.5.2-2) 4.5.2

I thought I had DEBUG_INFO, but I just checked in my .config and I it
seems not. My mistake. Is DEBUG_INFO_REDUCED=y acceptable? From
experience, not setting that takes an order of magnitude longer to
compile on my laptop.

> > ffffffff8110f197:       48 81 c3 ff 07 00 00    add    $0x7ff,%rbx
> > ffffffff8110f19e:       4c 89 45 a0             mov    %r8,-0x60(%rbp)
> > ffffffff8110f1a2:       48 81 e3 00 fc ff ff    and    $0xfffffffffffffc00,%rbx
> > ffffffff8110f1a9:       48 ff cb                dec    %rbx
> > ffffffff8110f1ac:       0f 1f 40 00             nopl   0x0(%rax)
> > ffffffff8110f1b0:       48 ff c3                inc    %rbx
> > ffffffff8110f1b3:       49 39 de                cmp    %rbx,%r14
> > ffffffff8110f1b6:       76 58                   jbe    0xffffffff8110f210
> > ffffffff8110f1b8:       48 6b cb 38             imul   $0x38,%rbx,%rcx
> > ffffffff8110f1bc:       49 ff c4                inc    %r12
> > ffffffff8110f1bf:       4c 01 f9                add    %r15,%rcx
> > ffffffff8110f1c2:****   8b 41 0c                mov    0xc(%rcx),%eax
> > ffffffff8110f1c5:       83 f8 fe                cmp    $0xfffffffffffffffe,%eax
> > ffffffff8110f1c8:       74 e6                   je     0xffffffff8110f1b0
> > ffffffff8110f1ca:       41 80 7d 40 00          cmpb   $0x0,0x40(%r13)
> > ffffffff8110f1cf:       74 8f                   je     0xffffffff8110f160
> > ffffffff8110f1d1:       48 8b 01                mov    (%rcx),%rax
> > ffffffff8110f1d4:       a8 20                   test   $0x20,%al
> > ffffffff8110f1d6:       74 d8                   je     0xffffffff8110f1b0
> > 
> > (this matches the Code: in the picture) which means it was some sort of
> > bad pointer dereference since %rcx is 0xffffea0000a00000 (I think). That
> > almost seems like a valid pointer, hmm.
> > 
> 
> I believe this corresponds to;
> 
>         for (; low_pfn < end_pfn; low_pfn++) {
>                 struct page *page;
>                 if (!pfn_valid_within(low_pfn))
>                         continue;
>                 nr_scanned++;
> 
>                 /* Get the page and skip if free */
>                 page = pfn_to_page(low_pfn);
>                 if (PageBuddy(page))			<----- HERE
>                         continue;
> 
> rcx is storing a struct page pointer and the 0xc offset is the _mapcount.
> It should be "impossible" for this page to be invalid though so I'm wondering
> if there is some other memory corruption going on.

Possible. I had some graphics issues with X hanging once a while, but
with all of those I could still ssh in and reboot the machine.

> > Also,
> > since I was working on the kernel and didn't make a snapshot, I rebuilt
> > the image using the attached config. That shouldn't change anything
> > (went back to the same sources), but still -- FYI.
> > 
> 
> Can you also enable;
> 
> CONFIG_DEBUG_INFO
> CONFIG_DEBUG_VM
> 
> If this works for you, also enable
> 
> CONFIG_DEBUG_PAGEALLOC
> 
> The last option should work but it'll also slow your machine quite a
> bit.

Ok, I'll give it a try.

> > > However, I can't see what this corresponds to. eac0466 is not a commit I
> > > can identify and the "dirty" implies that it's patched. How does this
> > > kernel differ from mainline?
> > 
> > The "-wl" indicates that it's a wireless-testing kernel (John Linville's
> > repository), but I'm using iwlwifi-2.6 right now. The -dirty indicates
> > that I've played with it, but only in the wireless code; the diffstat
> > between this and rc6 indicates that only wireless, bluetooth and some
> > tiny arch/arm changes are in here.
> > 
> 
> There is a chance this is a driver bug that is corrupting memory. With
> the debug options above, it would be worth trying to stress the machine
> with network traffic with mainline, the wireless testing tree and
> iwlwifi-2.6 (out of tree driver?) and see does each behave differently.

I'd agree, but it's unlikely to be network -- my laptop doesn't even
have iwlwifi hardware (which iwlwifi-2.6 contains, not out of tree, but
our development tree, I just run it out of habit); and I wasn't even
using wireless at all; networking itself and ethernet drivers are
untouched in this tree.

Thanks,
Johannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
