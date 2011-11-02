Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 0B2836B0069
	for <linux-mm@kvack.org>; Tue,  1 Nov 2011 21:31:41 -0400 (EDT)
Date: Wed, 2 Nov 2011 02:31:22 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [GIT PULL] mm: frontswap (for 3.2 window)
Message-ID: <20111102013122.GA18879@redhat.com>
References: <b2fa75b6-f49c-4399-ba94-7ddf08d8db6e@default>
 <75efb251-7a5e-4aca-91e2-f85627090363@default>
 <20111027215243.GA31644@infradead.org>
 <1319785956.3235.7.camel@lappy>
 <CAOzbF4fnD=CGR-nizZoBxmFSuAjFC3uAHf3wDj5RLneJvJhrOQ@mail.gmail.comCAOJsxLGOTw7rtFnqeHvzFxifA0QgPVDHZzrEo=-uB2Gkrvp=JQ@mail.gmail.com>
 <552d2067-474d-4aef-a9a4-89e5fd8ef84f@default20111031181651.GF3466@redhat.com>
 <60592afd-97aa-4eaf-b86b-f6695d31c7f1@default20111031223717.GI3466@redhat.com>
 <1b2e4f74-7058-4712-85a7-84198723e3ee@default20111101012017.GJ3466@redhat.com>
 <6a9db6d9-6f13-4855-b026-ba668c29ddfa@default20111101180702.GL3466@redhat.com>
 <b8a0ca71-a31b-488a-9a92-2502d4a6e9bf@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b8a0ca71-a31b-488a-9a92-2502d4a6e9bf@default>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Pekka Enberg <penberg@kernel.org>, Cyclonus J <cyclonusj@gmail.com>, Sasha Levin <levinsasha928@gmail.com>, Christoph Hellwig <hch@infradead.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Wilk <konrad.wilk@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, ngupta@vflare.org, Chris Mason <chris.mason@oracle.com>, JBeulich@novell.com, Dave Hansen <dave@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>

Hi Dan.

On Tue, Nov 01, 2011 at 02:00:34PM -0700, Dan Magenheimer wrote:
> Pardon me for complaining about my typing fingers, but it seems
> like you are making statements and asking questions as if you
> are not reading the whole reply before you start responding
> to the first parts.  So it's going to be hard to answer each
> sub-thread in order.  So let me hit a couple of the high
> points first.

I'm actually reading all your reply, if I skip some part it may be
because the email is too long already :). I'm just trying to
understand it and I wish I had more time to dedicate to this too but
I've other pending stuff too.

> Let me emphasize and repeat: Many of your comments
> here are addressing zcache, which is a staging driver.
> You are commenting on intra-zcache APIs only, _not_ on the
> tmem ABI.  I realize there is some potential confusion here
> since the file in the zcache directory is called tmem.c;
> but it is NOT defining or implementing the tmem ABI/API used

So where exactly is the tmem API if it's not in tmem.c in
staging/zcache? I read what is in the kernel and I comment on it.

> by the kernel.  The ONLY kernel API that need be debated here
> is the code in the frontswap patchset, which provides

That code is calling into zcache that calls into tmem.. so I'm not
sure how you can pretend we focus only in forntswap. Also I don't care
if zcache is already merged in staging, I may still like to see
changes happening there.

> registration for a set of function pointers (see the
> struct frontswap_ops in frontswap.h in the patch) and
> provides the function calls (API) between the frontswap
> (and cleancache) "frontends" and the "backends" in
> the driver directory.  The zcache file "tmem.c" is simply
> a very early attempt to tease out core operations and
> data structures that are likely to be common to multiple
> tmem users.

It's a little hard to follow, so that tmem.c is not the real tmem and
tries to mirror the real tmem.c that people will really use trying to
be compatible when the real tmem.c will be used instead?

It looks even more weird than I thought, why isn't the real tmem.c in
the zcache directory instead of an attempt to tease out core
operations and data structures? Maybe I just misunderstood what tmem.c
is about in zcache.

> Everything in zcache (including tmem.c) is completely open
> to evolution as needed (by KVM or other users) and this
> will need to happen before zcache is promoted out of staging.
> So your comments will be very useful when "we" work
> on that promotion process.

Again I don't care frontswap out-of-tree, zcache-in-tree
tmem-of-zcache-not-real-tmem-in-tree, I will comment on any of
those. I understand your focus is to get frontswap merged, but on my
side to review frontswap I am forced to read zcache and if I don't
like something there, it's unlikely I can like the _caller_ of zcache
code either (i.e. frontswap_put).

I don't see this as a showstopper on your side, if you agree why don't
you start fixing what is _in_tree_ first, and then submit frontswap
again?

I mean if you proof what you're pushing in (and what you already
pushed in staging) is the way to go, you shouldn't be so worried about
frontswap being merged immediately. I think the merge of frontswap
it's going to work much better if you convince the whole VM camp what
is in tree (zcache/tmem.c) is the way to go, then there won't be much
opposition to merge frontswap and make the core VM add hooks for
something already proven _worthwhile_.

I believe if all the reviewers and commenters would think the zcache
directory is the way to go to store swapcache before it hits swap, you
wouldn't have much problem to add changes to the core VM to put
swapcache into it.

But when things gets merged they never go out of tree, or rarely go
out of tree, and the maintenance is then upon us and the whole
community. So before adding dependencies on the core VM to
zcache/tmem.c it'd be nicer to be sure it's the way to go...

I hope this explains why I am "forced" to look into tmem.c while
commenting on frontswap.

> So, I'm going to attempt to ignore the portions of your
> reply that are commenting specifically about zcache coding
> issues and reply to the parts that potentially affect
> acceptance of the frontswap patchset, but if I miss anything
> important to you, please let me know.

So you call the tmem_put getting a char a not a page "zcache coding",
but to me it's not even clear if tmem would equally be happy to use a
page structure. Would that remain compatible with what you call above
"multiple tmem users" or not?

It's a little hard to see where Xen starts and where the kernel ends
here. Can Xen make any use of the kernel code you pushed in staging
yet? Where does the Xen API starts there? I'd like to compare to the
real tmem.c if zcache/tmem.c isn't it.

And no I don't imply the cast of the page to char is a problem at all,
I assume you're perfectly right that it's a coding issue, and may be
very well fixable with a few liner fix, but then why not proof the
point and fix it, instead of keep insisting we review frontswap as a
standalone entity like if it wasn't calling the code I am
commenting? And deferring the (albeit minor) fixage of tmem API for
later after we already are calling tmem_put from the core VM?

Or do you disagree with my proposed changes? I don't think it's
unreasonable to ask you to cleanup and make more proper what is in
tree already before adding more "stuff" that depends on it and would
have to be maintained _forever_ in the VM?

I don't actually ask perfection, but it'd be easier if you cleaned up
what looks "fishy".

> Other than the fact that cleancache_put is called with
> irqs disabled (and, IIRC, sometimes cleancache_flush?)
> and the coding complications that causes, you are correct.
> 
> Preemption does need to be disabled though and, IIRC,
> in some cases, softirqs.

What code runs in softirqs that could race with zcache+frontswap?

BTW, I wonder if the tree_lock is clearing irqs only to avoid getting
interrupted during the critical section as a performance optimization
(normally __delete_from_swap_cache would be way faster than a
page-compression but with page compression in, unless there's real
code running from irqs it's unlikely we want to insist with irqs
disabled, that only is a good optimization for fast code, delaying
irqs 20 times more than normal isn't so good, would be better if those
hooks run outside of the tree_lock).

> Possible I suppose.  But unless you can teach bio to deal
> with dynamically time-and-size varying devices, you are
> not implementing the most important value of the tmem concept,
> you are just re-implementing zram.  And, as I said, Nitin
> supports frontswap because it is better than zram for
> exactly this (dynamicity) reason:  https://lkml.org/lkml/2011/10/28/8 

I don't think the bio should deal with that, the bios can write at
hardblocksize granularity, it should be up to an upper layer to find
stuff to compact into tmem and write it out in a compact way, in a way
that the "cookie" returned to swapcache code can still read from it
when tmem is asked a .get operation.

BTW, this swapcache_put/get is a bit misleading with
get_page/put_page, maybe tmem_store/tmem_load are more appropriate
names for the API. Normally we call get on a page when we take a
refcount on it and put when we release it.

> Just like all existing memory management code, zcache depends
> on some heuristics, which can be improved as necessary over time.
> Some of the metrics that feed into the heuristics are in
> debugfs so they can be manipulated as zcache continue to
> develop.  (See zv_page_count_policy_percent for example...
> yes this is still a bit primitive.  And before you start up
> about dynamic sizing, this is only a maximum.)

I wonder how can you tune it without any direct feedback from the VM
pressure, VM pressure changes too fast to poll it. The zcache pool
should shrink fast and be pushed into real disk (ideally without
requiring decompression and regular swapout but by compacting it and
writing it out in a compact way), if there's mlocked memory growing for
example.

> For Xen, there is a "memmax" for each guest, and Xen tmem disallows
> a guest from using a page for swap (tmem calls it a "persistent" pool)
> if it has reached its memmax.  Thus unless a tmem-enabled guest
> is "giving", it can never expect to "get".
> 
> For KVM, you can overcommit in the host, so you could choose a
> different heuristic... if you are willing to accept host swapping
> (which I think is evil :-)

Well host swapping with zcache working on host is going to be
theoretically (modulo implementation issues) faster than anything else
because it won't run into any vmexits. Swapping in guest is forced to
go through vmexits to page out to disk (and now even tmem 4k calls
apparently). Plus we keep the whole system balance in the host VM
without having to try to mix what has been collected by each guest VM.

It's like comparing host I/O vs guest I/O, host I/O is always faster
by definition and we have host swapping fully functional, the mmu
notifier overhead is nothing compared to the regular pte tlb flushing
and VM overhead (that you have to pay in guest anyway to overcommit in
guest).

> Well, you have yet to convince me that an extra copy is
> so damning, especially on a modern many-core CPU where it
> can be done in 256 cycles and especially when the cache-pollution
> for the copy is necessary for the subsequent compression anyway.

I thought we agreed the extra copy (like highmem bounce buffers) that
destroys cpu caches was the worst possible thing, not sure why you
bring it back.

To remove the disable of irqs you've just to check which code could
run from irq, and it's a bit hard to see what... maybe it's fixable.

> Think of zcache as zram PLUS dynamicity PLUS ability to dynamically
> trade off memory utilization against compressed page cache.

It's hard to see how you can obtain dynamicity and no risk of going
OOM prematurely if suddenly if a mlockall() program tries to allocate
all RAM in the system. You need some more hooks in the VM than the one
you have today, and that applies to cleancache too I think.

It starts to look a big hack that works for VM and can fall apart if
exposed to the wrong workload that uses mlockall or similar. I
understand it's corner cases but we can't add cruft to the VM.

You've no idea how many times I hear of people adding hooks here and
there, last time it was to make mremap run with a binary only module
and move 2M pages allocated at boot not visible to the VM. There is no
way we can add hooks all over the place every time somebody invents
something that helps a specific workload. What we had must work 100%
for everything. So mlockall() using all RAM and triggering an OOM with
zcache+cleancache enabled, it's not ok in my view.

I think it can be fixed so I don't mean it's not good but somebody
should work in fixing it, not just leaving the code unchanged and keep
pushing. I mean this thing looks more complicated than it is in the
current implementation if it's claimed to be fully dynamic and it
looks like it can backfire on the wrong workload.

> > And what is the exact reason of the local_irq_save for doing it
> > zerocopy?
> 
> (Answered above I think? If not, let me know.)

No, you didn't actually tell the exact line of code that runs from irq
and that races with the code, and that requires to disable irq. I
still have no clue why irqs must be disabled. You now mentioned
sofitrqs, what is the code running in softirqs that requires disabling
irqs.

> > Would I'd like is a mechanism where you:
> > 
> > 1) add swapcache to zcache (with fallback to swap immediately if zcache
> >    allocation fails)
> 
> Current swap code pre-selects the swap device several layers
> higher in the call chain, so this requires fairly major surgery
> on the swap subsystem... and the long bug-tail that implies.

Well you can still release the swapcache once tmem_put (better
tmem_store) succeeds. Then it's up to the zcache layer to allocate
more swap entries and store it in the swap in a compact way.

> > 2) when some threshold is hit or zcache allocation fails, we write the
> >    compressed data in a compact way to swap (freeing zcache memory),
> >    or swapcache directly to swap if no zcache is present
> 
> Has efficient writing (and reading) of smaller-than-page chunks
> through blkio every been implemented?  I know compression can be
> done "behind the curtain" of many I/O devices, but am unaware
> that the same functionality exists in the kernel.  If it doesn't
> exist, this requires fairly major surgery on the blkio subsystem.
> If it does exist, I doubt the swap subsystem is capable of using
> it without major surgery.

Again I don't think compacting is the task of the I/O subsystem. Quite
obviously not. Even reiser3 writes to disk the tails compacted and
surely doesn't require changes to the storage layer. The algorithm
belongs to tmem or whatever abstraction where we stored the swapcache.

> Yeah, I agree that sounds like a cool high-level design for a
> swap subsystem rewrite.  Problem is it doesn't replace the dynamicity
> to do what frontswap does for virtualization and multiple physical
> machines (RAMster).  Just not as flexible.
> 
> And do you really want to rewrite the swap subsystem anyway
> when a handful of frontswap hooks do the same thing (and more)?

Not a plan to change the swap subsystem, I don't think it requires a
rewrite to just improve it. You are improving the swap subsystem
while adding frontswap. Not me. So I'd like the improvement to go in
the right direction.

If we add frontswap with tmem today, it shall be able tomorrow to
write the compressed data compacted on the swap device, without
requiring nuking frontswap. I mean incremental steps are totally fine,
it doesn't need to do it now, but it must be able to do it
later. Which means tmem must be somehow able to attach its memory to
bios, allocate swap entries with get_swap_page and write the tmem
memory there. I simply wouldn't like something that adds more work to
do later when we want swap to improve further.

> > I'm afraid adding frontswap in this form will still get stuck us in
> > the wrong model and most of it will have to be dropped and rewritten
> > to do just the above 3 points I described to do proper swap
> > compression.
> 
> This is a red herring.  I translate this as "your handful of hooks
> might interfere with some major effort that I've barely begun to
> design".  And even if you DO code that major effort... the
> frontswap hooks are almost trivial and clearly separated from
> most of the core swap code... how do you know those hooks will
> interfere with your grand plan anyway?

Hey this is what I'm asking... I'm asking if these hooks will
interfere or not. If they're tailored for Xen or if they can make the
Linux Kernel VM better for the long run and we can go ahead and swap
the tmem memory to disk compacted later, or not. I guess everything is
possible but the simpler design the better. And I've no clue if this
is the simpler design.

> Do I have to quote Linus's statement from the KS2011 minutes
> again? :-)

Well don't worry it's not my decision if things go in or not, and I
tend to agree it's not huge work to remove frontswap later if needed,
but it is quite apparent you don't want to make changes at all, and
you need it to be merged in this form. Which makes me wonder if this
is because of hidden Xen ABI issues in tmem.c or similar Xen issues or
if it's just because you think the code should change later after it's
all upstream, including frontswap.

> IIUC, you're talking about improvements to host-swapping here.
> That is (IMHO) putting lipstick on a pig.  And, in any case, you
> are talking about significant swap subsystm changes that only help
> a single user, KVM.  You seem to be already measuring non-existent

A single user KVM? You've got to be kidding me.

The whole basis of the KVM design, and why I refuse Xen is: we never
improve KVM, we improve the kernel for non-virt usages! And by
improving the kernel for non-virt usages, we also improve KVM. KVM is
just like firefox or apache or anything that uses anonymous memory.

I never thought of KVM in the context of the changes to the swap
logic. Sure they'll improve KVM too if we do those, but that'd be the
side effect of having improved the desktop swap behavior in general.

We improve the kernel for non-virt usage to benchmark-beat Xen/vmware
etc... There's nothing I'm doing in the VM that improves only KVM
(even the mmu notifier are used by GRU and stuff, more recently a new
pci card doing remote DMA from AMD is using mmu notifier too,
infiniband could do that too).

In fact it can't actually recall a single kernel change I did over the
last few years that would improve only KVM :).

> KVM patches by a different/easier standard than you are applying
> to a simple frontswap patchset that's been public for nearly
> three years.

I'm perfectly fine if frontswap gets in.... as long as it is the way
to go for the future of the Linux VM. Ignore virt here please, no KVM,
no Xen (even no cgroups just in case they could matter). Just tmem and
bare metal.

> There is no tmem dependency on zcache.  Feel free to rewrite
> zcache entirely.  It still needs the hooks in the frontswap
> patch, or something at least very similar.

That I agree, the hooks probably would be similar.

> Then feel free to rewrite that code.. or wait until it gets
> fixed.  I agree that it's unlikely that zcache will be promoted
> out of staging with that hack.  That's all still unrelated to
> merging frontswap.

frontswap don't go in staging so the moment you add a dependency on
staging/zcache code from the core VM code, we've to look into what is
being called too... Otherwise again we get hook requests every year
from whatever new user that does something a little weird. Not saying
this is the case, but just reading the hooks and pretending they're
non-intrusive and quite similar to what would have to be done anyway,
isn't the convincing method. I will like it if I'm convinced that tmem
that is being called is the future way for the VM to handle
compression dynamically with direct control of the Linux VM (that is
needed or it can't shrink when mlockall program grows). And not some
Xen hack that can't be modified or Xen ABI breaks. You see there's a
whole lot of difference... Once it'll be proven that tmem is the
future way for the VM to go to do dynamic compression and compaction
of the data + writing it to disk when VM pressure increases, I don't
think anybody will argue on the frontswap hooks.

> Zcache doesn't need to pass through tmem.c.  RAMster is using tmem.c
> but isn't even in staging yet.

That's what I had the feeling in fact, it looked like zcache could
work by its own without calling in tmem. But I guess tmem is still
needed to manage the memory pooling using by zcache?

> > The whole logic deciding the size of the frontswap zcache is going to
> > be messy.
> 
> It's not messy, and is entirely dynamic.  Finding the ideal
> heuristics for the maximum size, and when and how much to
> decompress pages back out of zcache back into the swap cache,
> I agree, is messy and will take some time.

That's what I intended to be messy... the heuristic to find the
maximum zcache size. And that requires feedback from the VM to shrink
fast if we're squeezed by mlocked RAM.

And yes it's better than zram without any doubt, there's no way to
squeeze zram out... :) But the tradeoff is you lose a fixed amount of
RAM with zram and overall it should help and it's non intrusive. It
doesn't require a magic heuristic to size it dynamically etc...

The major benefit of zcache should be:

1) dynamic sizing (but adding complexity)
2) ability later to compact the compressed memory and write it to disk
   compacted when a shrink is requested by the VM pressure (and by the
   core VM code)

> Still not sure how this is related to the proposed frontswap
> patch now (which just provides some mechanism for the heuristics
> to drive).
> 
> > But to do the real swapout you should not pull the memory
> > out of frontswap zcache, you should write it to disk compacted and
> > compressed compared to how it was inserted in frontswap... That would
> > be the ideal.
> 
> Agreed, that would be cool... and very difficult to implement.

Glad we agree :).

> Dynamic.  Pulled out with frontswap_shrink, see above.

Got it now.

> I guess you are missing the key magic for RAMster, or really
> for tmem.  Because everything in tmem is entirely dynamic (e.g.
> any attempt to put a page can be rejected), the "remote" machine
> has complete control over how many pages to accept from whom,
> and can manage its own needs as higher priority.  Think of
> a machine in RAMster as a KVM/Xen "host" for a bunch of
> virtual-machines-that-are-really-physical-machines.  And it
> is all peer-to-peer, so each machine can act as a host when
> necessary.  None of this is possible through anything that
> exists today in the swap subsystem or blkio subsystem.
> And RAMster runs on the same cleancache and frontswap hooks
> as Xen and zcache and, potentially, KVM.
> 
> Yeah, the heuristics may be even harder for RAMster.  But
> the first response to this thread (from Christoph) said
> that this stuff isn't sexy.  Personally I can't think of
> anything sexier than the first CROSS-MACHINE memory management
> subsystem in a mainstream OS.  Again... NO additional core
> VM changes.

I see the point. And well this discussion certainly helps to clarify
this further (at least for me).

Another question is if you can stack these things on top of each
other. Like ramster over zcache. Because if that's possible you'd need
to write a backend to write out the tmem memory to disk and allowing
tmem to swap that way. And then you could also use ramster on
compressed pagecache. A system with little RAM could want compression
and if we're out of pagecache to share it through ramster but once we
have it compressed why not to send it compressed to other tmem in the
cloud?

> Is that answered clearly now?

Yep :).

> Think RAMster.  Think a version of RAMster with a "memory server"
> (where the RAM expandability is in one server in a rack).  Think
> fast SSDs that can be attached to one machine and shared by other
> machines.  Think phase-change (or other future limited-write-cycle)
> RAM without a separate processor counting how many times a cell
> has been written.  This WAS all about Xen a year or two ago.
> I haven't written a line of Xen in over a year because I am
> excited about the FULL value of tmem.

I understand this. I'd just like to know how much this is hackable, or
if the Xen dependency (that still remains) is a limitation for future
extension or development. I mean the value of the Xen part is zero in
my view, so if we add something like this it should be hackable and
free to evolve for the benefit of the core VM regardless of
whatever Xen API/ABI. That in short is my concern. No much
else... doesn't need to be perfect as long as it's hackable and there
is no resistence to fix things like below:

> Yep, let's fix that problem in zcache.  That is a stupid
> coding error by me and irrelevant to frontswap and the bigger
> transcendent memory picture.

Ok! Glad to hear.

> Zram required exactly ONE change to the VM, and Nitin placed it
> there AFTER he looked at how frontswap worked.  Then he was forced
> down the "gotta do it as a device" path which lost a lot of the
> value.  Then, when he wanted to do compression on page cache, he
> found that the cleancache interface was perfect for it.  Why
> does everyone keep telling me to "do it like zram" when the author
> of zram has seen the light?  Did I mention Nitin's support for
> frontswap already?   https://lkml.org/lkml/2011/10/28/8 
> 
> So, I repeat, where are we now?  Have I sufficiently answered
> your concerns and questions?  Or are you going to go start
> coding to prove me wrong with a swap subsystem rewrite? :-)

My argument about zram is currently frontswap+zcache provides very
little value addition to zram (considering you said before there's no
shrinker being called and whatever heuristic you're using today won't
be able to react in a timely fascion to a mlockall growing fast). So
if we add hooks on the core VM to depend on it, we need to be sure
it's hackable and allowed to improve without worrying about breaking
Xen later. I mean Xen may still work if modified for it, but there
shall be no such thing as an API or ABI that cannot be
broken. Otherwise again it's better you add a few Xen specific hacks
and then we evolve tmem separately from it.

And I still see the real value I would see from zcache+frontswap is if
we can add into zcache/tmem the code to compact the fragments and
write them into swap pages, kind of like tail packing in the
filesystem in fs/ (absolutely unrelated to blkdev layer).

If you confirm it's free to go and there's no ABI/API we get stuck
into, I'm fairly positive about it, it's clearly "alpha" feature
behavior (almost no improvement with zram today) but it could very
well be in the right direction and give huge benefit compared to zram
in the future. I definitely don't pretend things to be perfect... but
they must be in the right design direction for me to be sold off on
those. Just like KVM in virt space.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
