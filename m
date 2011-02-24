Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 93B2E8D0039
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 05:37:37 -0500 (EST)
Date: Thu, 24 Feb 2011 10:37:06 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [Bug 29772] New: memory compaction crashed
Message-ID: <20110224103706.GR15652@csn.ul.ie>
References: <bug-29772-27@https.bugzilla.kernel.org/> <20110223134015.be96110b.akpm@linux-foundation.org> <20110223233934.GN15652@csn.ul.ie> <1298537237.3764.17.camel@jlt3.sipsolutions.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1298537237.3764.17.camel@jlt3.sipsolutions.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Berg <johannes@sipsolutions.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org

On Thu, Feb 24, 2011 at 09:47:17AM +0100, Johannes Berg wrote:
> On Wed, 2011-02-23 at 23:39 +0000, Mel Gorman wrote:
> 
> > > screenshot here: https://bugzilla.kernel.org/attachment.cgi?id=48772
> > > 
> > 
> > isolate_migratepages is hit any time compaction runs so I'm wondering
> > what is special about this test case. I'm assuming as evince crashed
> > that it's a normalish desktop and wasn't running anything in particular.
> > Is that true?
> 
> Yes. I was using evince to pan around in a fairly large PDF that really
> is a large single-page bitmap, but that's about it. I also have a fairly
> large (bit more than full HD) external monitor, both of these probably
> take some amount of memory. The system had been up for a while few hours
> at most, with similar workloads, sometimes a kernel compile (but none
> was running at the time).
> 

Is this reproducible or did it just happen the once?

> > Can you tell me what line the instruction ffffffff8100f1c2 corresponds to? If
> > you have CONFIG_DEBUG_INFO set, it should be a case of telling me what the
> > output of "addr2line -e vmlinux 0xffffffff8100f1c2" is. On a similar note,
> > do you know what sort of crash this was? i.e. was it a NULL deference or
> > did a VM_BUG_ON or BUG_ON hit such as VM_BUG_ON(PageTransCompound(page))?
> > Was CONFIG_DEBUG_VM set? Actually, it would be preferable to have the
> > whole .config attached to the bugzilla if possible please.
> 
> Attached the config. addr2line failed so I probably don't have enough
> debug info,

Indeed not, can you enable CONFIG_DEBUG_INFO for future reference
please? It'll be easier to figure out where things crashed exactly.
Also, what compiler are you using?

> but then again I think you got the address wrong -- don't
> you want fff8110f1c2?

Yes, my bad.

> That at least makes addr2line point to
> compaction.c (no line info), and the code there is
> 
> ffffffff8110f197:       48 81 c3 ff 07 00 00    add    $0x7ff,%rbx
> ffffffff8110f19e:       4c 89 45 a0             mov    %r8,-0x60(%rbp)
> ffffffff8110f1a2:       48 81 e3 00 fc ff ff    and    $0xfffffffffffffc00,%rbx
> ffffffff8110f1a9:       48 ff cb                dec    %rbx
> ffffffff8110f1ac:       0f 1f 40 00             nopl   0x0(%rax)
> ffffffff8110f1b0:       48 ff c3                inc    %rbx
> ffffffff8110f1b3:       49 39 de                cmp    %rbx,%r14
> ffffffff8110f1b6:       76 58                   jbe    0xffffffff8110f210
> ffffffff8110f1b8:       48 6b cb 38             imul   $0x38,%rbx,%rcx
> ffffffff8110f1bc:       49 ff c4                inc    %r12
> ffffffff8110f1bf:       4c 01 f9                add    %r15,%rcx
> ffffffff8110f1c2:****   8b 41 0c                mov    0xc(%rcx),%eax
> ffffffff8110f1c5:       83 f8 fe                cmp    $0xfffffffffffffffe,%eax
> ffffffff8110f1c8:       74 e6                   je     0xffffffff8110f1b0
> ffffffff8110f1ca:       41 80 7d 40 00          cmpb   $0x0,0x40(%r13)
> ffffffff8110f1cf:       74 8f                   je     0xffffffff8110f160
> ffffffff8110f1d1:       48 8b 01                mov    (%rcx),%rax
> ffffffff8110f1d4:       a8 20                   test   $0x20,%al
> ffffffff8110f1d6:       74 d8                   je     0xffffffff8110f1b0
> 
> (this matches the Code: in the picture) which means it was some sort of
> bad pointer dereference since %rcx is 0xffffea0000a00000 (I think). That
> almost seems like a valid pointer, hmm.
> 

I believe this corresponds to;

        for (; low_pfn < end_pfn; low_pfn++) {
                struct page *page;
                if (!pfn_valid_within(low_pfn))
                        continue;
                nr_scanned++;

                /* Get the page and skip if free */
                page = pfn_to_page(low_pfn);
                if (PageBuddy(page))			<----- HERE
                        continue;

rcx is storing a struct page pointer and the 0xc offset is the _mapcount.
It should be "impossible" for this page to be invalid though so I'm wondering
if there is some other memory corruption going on.

> > Can I also see a full dmesg with the kernel parameters "loglevel=9
> > mminit_loglevel=4" please? I know the crash won't be included but I want
> > to see what your memory layout looks like to see can I spot anything
> > unusual about it.
> 
> Yes, but I'll have to generate it first, will send it later today.

Thanks.

> Also,
> since I was working on the kernel and didn't make a snapshot, I rebuilt
> the image using the attached config. That shouldn't change anything
> (went back to the same sources), but still -- FYI.
> 

Can you also enable;

CONFIG_DEBUG_INFO
CONFIG_DEBUG_VM

If this works for you, also enable

CONFIG_DEBUG_PAGEALLOC

The last option should work but it'll also slow your machine quite a
bit.

> > I see fuse was loaded. Was it being heavily used at the time? If so,
> > what sort of workload was exercising it?
> 
> No, I don't think I was using it. Certainly not heavily.
> 

Ok.

> > I *think* the kernel version is 2.6.38-rc6-wl-65354-geac0466-dirty. I'm
> > not certain because there is a big shine from the camera flash on it.
> 
> Yes, indeed, sorry. I tried w/o flash but that just made it all blurry.
> 

No need to be sorry, a flash is better than blurry.

> > However, I can't see what this corresponds to. eac0466 is not a commit I
> > can identify and the "dirty" implies that it's patched. How does this
> > kernel differ from mainline?
> 
> The "-wl" indicates that it's a wireless-testing kernel (John Linville's
> repository), but I'm using iwlwifi-2.6 right now. The -dirty indicates
> that I've played with it, but only in the wireless code; the diffstat
> between this and rc6 indicates that only wireless, bluetooth and some
> tiny arch/arm changes are in here.
> 

There is a chance this is a driver bug that is corrupting memory. With
the debug options above, it would be worth trying to stress the machine
with network traffic with mainline, the wireless testing tree and
iwlwifi-2.6 (out of tree driver?) and see does each behave differently.

I'll poke around and see can I spot a situation where those PFNs can be
invalid.

Thanks

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
