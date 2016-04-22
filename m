Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f72.google.com (mail-qg0-f72.google.com [209.85.192.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4A2D16B007E
	for <linux-mm@kvack.org>; Fri, 22 Apr 2016 12:09:37 -0400 (EDT)
Received: by mail-qg0-f72.google.com with SMTP id c6so164166553qga.0
        for <linux-mm@kvack.org>; Fri, 22 Apr 2016 09:09:37 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j11si3956027qgd.1.2016.04.22.09.09.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Apr 2016 09:09:36 -0700 (PDT)
Message-ID: <1461341373.13397.23.camel@redhat.com>
Subject: notes from LSF/MM 2016 memory management track
From: Rik van Riel <riel@redhat.com>
Date: Fri, 22 Apr 2016 12:09:33 -0400
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-feNGMzNii1y4dZgWPPoY"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf <lsf@lists.linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>


--=-feNGMzNii1y4dZgWPPoY
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Here are my notes from the LSF/MM 2016 MM track.
I expect LWN.net to have nicely readable articles
on most of these discussions.


LSF/MM 2016

Memory Management track notes


Transparent Huge Pages

=C2=A0=C2=A0=C2=A0=C2=A0Kirill & Hugh have different implementations of tmp=
fs transparent
huge pages

=C2=A0=C2=A0=C2=A0=C2=A0Kirill can split 4k pages out of huge pages, to avo=
id splits
(refcounting implementation, compound pages)

=C2=A0=C2=A0=C2=A0=C2=A0Hugh's implementation: get it up and running quickl=
y and
unobtrusively (team pages)

=C2=A0=C2=A0=C2=A0=C2=A0Kirill's implementation can dirty 4kB inside a huge=
 page on write()

=C2=A0=C2=A0=C2=A0=C2=A0Kirill wants to get huge pages in page cache to wor=
k for ext4

=C2=A0=C2=A0=C2=A0=C2=A0cannot be transparent to the filesystem

=C2=A0=C2=A0=C2=A0=C2=A0Hugh: what about small files? huge pages would be w=
asted space

=C2=A0=C2=A0=C2=A0=C2=A0Kirill: madvise/madvise for THP, or file size based=
 policy

=C2=A0=C2=A0=C2=A0=C2=A0at write time allocate 4kB pages, khugepaged can co=
llapse them

=C2=A0=C2=A0=C2=A0=C2=A0Andrea: what is the advantage of using huge pages f=
or small files?

=C2=A0=C2=A0=C2=A0=C2=A0Hugh: 2MB initial allocation is shrinkable, not cha=
rged to memcg

=C2=A0=C2=A0=C2=A0=C2=A0Kirill: for tmpfs, also need to check against tmpfs=
 filesystem size
when deciding what page size to allocate

=C2=A0=C2=A0=C2=A0=C2=A0Kirill: does not like how tmpfs is growing more and=
 more special
cases (radix tree exception entries, etc)

=C2=A0=C2=A0=C2=A0=C2=A0Aneesh,Andrea: also not happy that kernel would gro=
w yet another
kind of huge page

=C2=A0=C2=A0=C2=A0=C2=A0Hugh: Kirill can probably use the same mlock logic =
my code uses

=C2=A0=C2=A0=C2=A0=C2=A0Kirill: I do not mlock pages, just VMAs, prevent pa=
geout that way

=C2=A0=C2=A0=C2=A0=C2=A0Hugh: Kirill has some stuff working better than I r=
ealized, maybe
can still use some of my code

=C2=A0=C2=A0=C2=A0=C2=A0Kirill: on split hugepmd Hugh has a split with ptes=
, Kirill just
blows away PMD and lets faults fill in PTEs

=C2=A0=C2=A0=C2=A0=C2=A0Hugh: what Kirill's code does is not quite correct =
for mlock

=C2=A0=C2=A0=C2=A0=C2=A0Kirill: mlock does not guarantee lack of minor faul=
ts

=C2=A0=C2=A0=C2=A0=C2=A0Aneesh: PPC64 needs deposited page tables

=C2=A0=C2=A0=C2=A0=C2=A0hardware page table hashed on actual page size, hug=
e page is only
logical not HW supported

=C2=A0=C2=A0=C2=A0=C2=A0last level page table stores slot/hash information

=C2=A0=C2=A0=C2=A0=C2=A0Andrea: do not worry too much about memory consumpt=
ion with THP

=C2=A0=C2=A0=C2=A0=C2=A0if worried, do small allocations and let khugepaged=
 collapse them

=C2=A0=C2=A0=C2=A0=C2=A0use same model for THP file cache as used for THP a=
nonymous memory

=C2=A0=C2=A0=C2=A0=C2=A0Andrea/Kirill/Hugh:

=C2=A0=C2=A0=C2=A0=C2=A0no need to use special radix tree entries for huge =
pages, in
general

=C2=A0=C2=A0=C2=A0=C2=A0at hole punch time could be useful later, as an opt=
imization

=C2=A0=C2=A0=C2=A0=C2=A0might want a way to mark 4kB pages dirty on radix t=
ree side, inside
a compound page (or use page flags on tail page struct)

=C2=A0=C2=A0=C2=A0=C2=A0Hugh: how about two radix trees?

=C2=A0=C2=A0=C2=A0=C2=A0Everybody else: yuck :)

=C2=A0=C2=A0=C2=A0=C2=A0Andrea: with the compound model, I see no benefit t=
o multiple radix
trees

=C2=A0=C2=A0=C2=A0=C2=A0First preparation series (by Hugh) already went ups=
tream

=C2=A0=C2=A0=C2=A0=C2=A0Kirill can use some of Hugh's code

=C2=A0=C2=A0=C2=A0=C2=A0DAX needs some of the same code, too

=C2=A0=C2=A0=C2=A0=C2=A0Hugh: compount pages could be extended to offer my =
functionality,
would like to integrate what he has

=C2=A0=C2=A0=C2=A0=C2=A0settling on sysfs/mount options before freezing

=C2=A0=C2=A0=C2=A0=C2=A0then add compount pages on top

=C2=A0=C2=A0=C2=A0=C2=A0Hugh: current show stopper with Kirill's code:

=C2=A0=C2=A0=C2=A0=C2=A0small files, hole punching


=C2=A0=C2=A0=C2=A0=C2=A0khugepaged -> task_work

=C2=A0=C2=A0=C2=A0=C2=A0Advantage: concentrate thp on tasks that use most C=
PU and could
benefit from them the most

=C2=A0=C2=A0=C2=A0=C2=A0Hugh: having one single scanner/compacter might hav=
e advantages

=C2=A0=C2=A0=C2=A0=C2=A0When to trigger scanning?

=C2=A0=C2=A0=C2=A0=C2=A0Hugh: observe at page fault time? Vlastimil: if the=
re are no faults
because the memory is already present, there would not be an
observation event

=C2=A0=C2=A0=C2=A0=C2=A0Johannes: wait for someone to free a THP?

=C2=A0=C2=A0=C2=A0=C2=A0maybe background scanning still best?


=C2=A0=C2=A0=C2=A0=C2=A0merge plans

=C2=A0=C2=A0=C2=A0=C2=A0Hugh would like to merge team pages now, switch to =
compound pages
later

=C2=A0=C2=A0=C2=A0=C2=A0Kirill would like to get compound pages into shape =
first, then
merge things

=C2=A0=C2=A0=C2=A0=C2=A0Andrea: if we go with team pages, we should ensure =
it is the right
solution for both anonymous memory and ext4

=C2=A0=C2=A0=C2=A0=C2=A0Andrea: can we integrate the best parts of both cod=
e bases and
merge that?

=C2=A0=C2=A0=C2=A0=C2=A0Mel: one of my patch series is heavily colliding wi=
th team pages
(moving accounting from zones to nodes)

=C2=A0=C2=A0=C2=A0=C2=A0Andrew: need a decision on team pages vs compound p=
ages

=C2=A0=C2=A0=C2=A0=C2=A0Hugh: if compound pages went in first, we would not=
 replace it with
team pages later - but the other way around might happen

=C2=A0=C2=A0=C2=A0=C2=A0merge blockers

=C2=A0=C2=A0=C2=A0=C2=A0Compound pages issues: small files memory waste,=C2=
=A0=C2=A0fast recovery for
small files, get khugepaged into shape, maybe deposit/withdrawal,
demonstrate recovery, demonstrate robustness (or Hugh demonstrates
brokenness)

=C2=A0=C2=A0=C2=A0=C2=A0Team page issues: recovery (khugepaged cannot colla=
pse team pages),
anonymous memory support (Hugh: pretty sure it is possible), API
compatible to test compound, don't use page->private, path forward for
other filesystems

=C2=A0=C2=A0=C2=A0=C2=A0revert team page patches from MMOTM util blockers a=
ddressed




GFP flags

=C2=A0=C2=A0=C2=A0=C2=A0__GFP_REPEAT

=C2=A0=C2=A0=C2=A0=C2=A0fuzzy semantics, keep retrying until an allocation =
succeeds

=C2=A0=C2=A0=C2=A0=C2=A0for higher order allocations

=C2=A0=C2=A0=C2=A0=C2=A0but most used for order 0... (not useful)

=C2=A0=C2=A0=C2=A0=C2=A0can be cleaned up, and get a useful semantic for hi=
gher order
allocations

=C2=A0=C2=A0=C2=A0=C2=A0"can fail, try hard to be successful, but could sti=
ll fail in the
end"

=C2=A0=C2=A0=C2=A0=C2=A0__GFP_NORETRY - fail after single attempt to reclai=
m something, not
very helpful except for optimistic/opportunistic allocations

=C2=A0=C2=A0=C2=A0=C2=A0maybe have __GFP_BEST_EFFORT, try until a certain p=
oint then give
up?=C2=A0=C2=A0(retry until OOM, then fail?)

=C2=A0=C2=A0=C2=A0=C2=A0remove __GFP_REPEAT from non-costly allocations

=C2=A0=C2=A0=C2=A0=C2=A0introduce new flag, use it where useful

=C2=A0=C2=A0=C2=A0=C2=A0can the allocator know compaction was deferred?

=C2=A0=C2=A0=C2=A0=C2=A0more explicit flags? NORECLAIM NOKSWAPD NOCOMPACT N=
O_OOM etc...

=C2=A0=C2=A0=C2=A0=C2=A0use explicit flags to switch stuff off

=C2=A0=C2=A0=C2=A0=C2=A0clameter: have default definitions with all the "no=
rmal stuff"
enabled

=C2=A0=C2=A0=C2=A0=C2=A0flags inconsistent - sometimes positive, sometimes =
negative,
sometimes for common things, sometimes for uncommon things

=C2=A0=C2=A0=C2=A0=C2=A0THP allocation not explicit, but inferred from cert=
ain flags

=C2=A0=C2=A0=C2=A0=C2=A0concensus on cleaning up GFP usage



CMA

=C2=A0=C2=A0=C2=A0=C2=A0KVM on PPC64 runs into a strange hardware requireme=
nts

=C2=A0=C2=A0=C2=A0=C2=A0needs contiguous memory for certain data structures

=C2=A0=C2=A0=C2=A0=C2=A0tried to reduce fragmentation/allocation issues wit=
h ZONE_CMA

=C2=A0=C2=A0=C2=A0=C2=A0atomic 0 order allocations fail early, due to kswap=
d not kicking in
on time

=C2=A0=C2=A0=C2=A0=C2=A0taking pages out of CMA zone first

=C2=A0=C2=A0=C2=A0=C2=A0compaction does not move movable compound pages (eg=
. THP), breaking
CMA in ZONE_CMA

=C2=A0=C2=A0=C2=A0=C2=A0mlock and other things pinning allocated-as-movable=
 pages also
break CMA

=C2=A0=C2=A0=C2=A0=C2=A0what to do instead of ZONE_CMA?

=C2=A0=C2=A0=C2=A0=C2=A0how to keep things movable? sticky MIGRATE_MOVABLE =
zones?

=C2=A0=C2=A0=C2=A0=C2=A0do not allow reclaimable & unmovable allocations in=
 sticky
MIGRATE_MOVABLE zones

=C2=A0=C2=A0=C2=A0=C2=A0memory hotplug has similar requirements to CMA, no =
need for a new
name

=C2=A0=C2=A0=C2=A0=C2=A0need something like physical memory linear reclaim,=
 finding sticky
MIGRATE_MOVABLE zones and reclaiming everything inside

=C2=A0=C2=A0=C2=A0=C2=A0Mel: would like to see ZONE_CMA and ZONE_MOVABLE go=
 away

=C2=A0=C2=A0=C2=A0=C2=A0FOLL_MIGRATE get_user_pages flag to move pages away=
 from movable
region when being pinned

=C2=A0=C2=A0=C2=A0=C2=A0should be handled by core code, get_user_pages



Compaction, higher order allocations

=C2=A0=C2=A0=C2=A0=C2=A0compaction not invoked from THP allocations with de=
layed
fragmentation patch set

=C2=A0=C2=A0=C2=A0=C2=A0kcompactd daemon for background compaction

=C2=A0=C2=A0=C2=A0=C2=A0should kcompactd do fast direct reclaim?=C2=A0=C2=
=A0lets see

=C2=A0=C2=A0=C2=A0=C2=A0cooperation with OOM

=C2=A0=C2=A0=C2=A0=C2=A0compaction - hard to get useful feedback about

=C2=A0=C2=A0=C2=A0=C2=A0compaction "does random things, returns with random=
 answer"

=C2=A0=C2=A0=C2=A0=C2=A0no notion of "costly allocations"

=C2=A0=C2=A0=C2=A0=C2=A0compaction can keep indefinitely deferring action, =
even for smaller
allocations (eg. order 2)

=C2=A0=C2=A0=C2=A0=C2=A0sometimes compaction finds too many page blocks wit=
h the skip bit
set

=C2=A0=C2=A0=C2=A0=C2=A0success rate of compaction skyrocketed with skip bi=
ts ignored
(stale skip bits?)

=C2=A0=C2=A0=C2=A0=C2=A0migrate skips over MIGRATE_UNMOVABLE page blocks fo=
und during order
9 compaction

=C2=A0=C2=A0=C2=A0=C2=A0page block may be perfectly suitable for smaller or=
der compaction

=C2=A0=C2=A0=C2=A0=C2=A0have THP skip more aggressively, while order 2 scan=
s inside more
page blocks

=C2=A0=C2=A0=C2=A0=C2=A0priority for compaction code?=C2=A0=C2=A0aggressive=
ness of diving into blocks
vs skipping

=C2=A0=C2=A0=C2=A0=C2=A0order 9 allocators:

=C2=A0=C2=A0=C2=A0=C2=A0THP - wants allocation to fail quickyl if no order =
9 available

=C2=A0=C2=A0=C2=A0=C2=A0hugetlbfs - really wants allocations to succeed


VM containers

=C2=A0=C2=A0=C2=A0=C2=A0VM imply more memory consumption than what applicat=
ion that runs in
it need

=C2=A0=C2=A0=C2=A0=C2=A0How to pressure guest to give back memory to host ?

=C2=A0=C2=A0=C2=A0=C2=A0Adding new shrinker did not seem to perform well

=C2=A0=C2=A0=C2=A0=C2=A0Move page cache to the host so it would be easier t=
o reclaim memory
for all guest

=C2=A0=C2=A0=C2=A0=C2=A0Move memory management from guest kernel to host, s=
ome kind of
memory controller

=C2=A0=C2=A0=C2=A0=C2=A0Have the guest tell the host how to reclaim, sharin=
g LRU for
instance

=C2=A0=C2=A0=C2=A0=C2=A0mmu_notifier is already sharing some informations w=
ith access bit
(young), but mmu_notifier is to coarse

=C2=A0=C2=A0=C2=A0=C2=A0DAX (in the guest) should be fine to solve filesyst=
em memory

=C2=A0=C2=A0=C2=A0=C2=A0if not DAX backed on the host, needs new mechanism =
for IO barriers,
etc

=C2=A0=C2=A0=C2=A0=C2=A0FUSE driver in the guest and move filesystem to the=
 host

=C2=A0=C2=A0=C2=A0=C2=A0Exchange memory pressure btw guest and host so that=
 host can ask
guest to adjust its pressure depending on overall situation of the host



Generic page-pool recycle facility

=C2=A0=C2=A0=C2=A0=C2=A0found bottlenecks in both page allocator and DMA AP=
Is

=C2=A0=C2=A0=C2=A0=C2=A0"packet-page" / explicit data path API

=C2=A0=C2=A0=C2=A0=C2=A0make it generic across multiple use cases

=C2=A0=C2=A0=C2=A0=C2=A0get rid of open coded driver approaches

=C2=A0=C2=A0=C2=A0=C2=A0Mel: make per-cpu allocator fast enough to act as t=
he page pool

=C2=A0=C2=A0=C2=A0=C2=A0gets NUMA locality, shrinking, etc all for free

=C2=A0=C2=A0=C2=A0=C2=A0needs pool sizing for used pool items, too - can't =
keep collecting
incoming packets without handling them

=C2=A0=C2=A0=C2=A0=C2=A0allow page allocator to reclaim memory



Address Space Mirroring


=C2=A0=C2=A0=C2=A0=C2=A0Haswell-EX allows memory mirroring, partial or all =
memory

=C2=A0=C2=A0=C2=A0=C2=A0goal: improve high availability by avoiding uncorre=
ctable errors in
kernel memory

=C2=A0=C2=A0=C2=A0=C2=A0partial has higher remaining memory capacity, but n=
ot software
transparent

=C2=A0=C2=A0=C2=A0=C2=A0some memory mirrored, some not

=C2=A0=C2=A0=C2=A0=C2=A0mirrored memory set up in BIOS, amount in each NUMA=
 node
proportional to amount of memory in each node

=C2=A0=C2=A0=C2=A0=C2=A0mirror range info in EFI memory map

=C2=A0=C2=A0=C2=A0=C2=A0avoid kernel allocations from non-mirrored memory r=
anges, avoid
ZONE_MOVABLE allocations

=C2=A0=C2=A0=C2=A0=C2=A0put user allocations in non-mirrored memory, avoid =
ZONE_NORMAL
allocations

=C2=A0=C2=A0=C2=A0=C2=A0MADV_MIRROR to put certain user memory in mirrored =
memory

=C2=A0=C2=A0=C2=A0=C2=A0problem: to put a whole program in mirrored memory,=
 need to
relocate libraries into mirrored memory

=C2=A0=C2=A0=C2=A0=C2=A0what is the value proposition of mirroring user spa=
ce memory?

=C2=A0=C2=A0=C2=A0=C2=A0policy: when mirrored memory is requested, do not f=
all back to non-
mirrored memory

=C2=A0=C2=A0=C2=A0=C2=A0Michal: is this desired?

=C2=A0=C2=A0=C2=A0=C2=A0Aneesh: how should we represent mirrored memory? zo=
nes? something
else?

=C2=A0=C2=A0=C2=A0=C2=A0Michal: we are back to highmem problem

=C2=A0=C2=A0=C2=A0=C2=A0lesson from highmem era: keep ratio of kernel to no=
n-kernel memory
low enough, below 1:4

=C2=A0=C2=A0=C2=A0=C2=A0how much userspace needs to be in mirrored memory, =
in order to be
able to restart applications?

=C2=A0=C2=A0=C2=A0=C2=A0should we have opt-out for mirrored instead of opt-=
in?

=C2=A0=C2=A0=C2=A0=C2=A0proposed interface: prctl

=C2=A0=C2=A0=C2=A0=C2=A0kcore mirror code upstream already

=C2=A0=C2=A0=C2=A0=C2=A0Mel: systems using lots of ZONE_MOVABLE have proble=
ms, and are
often unstable

=C2=A0=C2=A0=C2=A0=C2=A0Mel: assuming userspace can figure out the right th=
ing to choose
what needs to be mirrored is not safe

=C2=A0=C2=A0=C2=A0=C2=A0Vlastimil: use non-mirrored memory as frontswap onl=
y, put all
managed memory in mirrored memory

=C2=A0=C2=A0=C2=A0=C2=A0dwmw2: for workload of "guest we care about, guests=
 we don't care
about", we can allocate only guest memory for unimportant guests in
non-mirrored memory

=C2=A0=C2=A0=C2=A0=C2=A0Mel: even in that scenario a non-important guest's =
kernel
allocations could exhaust mirrored memory

=C2=A0=C2=A0=C2=A0=C2=A0Mel: partial mirroring makes a promise of reliabili=
ty that it
cannot deliver on

=C2=A0=C2=A0=C2=A0=C2=A0false hope

=C2=A0=C2=A0=C2=A0=C2=A0complex configuration makes the system less reliabl=
e

=C2=A0=C2=A0=C2=A0=C2=A0Andrea: memory hotplug & other zone_movable users a=
lready cause the
same problems today



Heterogenious Memory Management

=C2=A0=C2=A0=C2=A0=C2=A0used for GPU, CAPI, other kinds of offload engines

=C2=A0=C2=A0=C2=A0=C2=A0GPU has much faster memory than system RAM

=C2=A0=C2=A0=C2=A0=C2=A0to get performance, GPU offload data needs to sit i=
n VRAM

=C2=A0=C2=A0=C2=A0=C2=A0shared address space creates an easier programming =
model

=C2=A0=C2=A0=C2=A0=C2=A0needs ability to migrate memory between system RAM =
and VRAM

=C2=A0=C2=A0=C2=A0=C2=A0CPU cannot access VRAM

=C2=A0=C2=A0=C2=A0=C2=A0GPU can access system RAM ... very very slowly

=C2=A0=C2=A0=C2=A0=C2=A0hardware is coming up real soon (this year)

=C2=A0=C2=A0=C2=A0=C2=A0without HMM

=C2=A0=C2=A0=C2=A0=C2=A0GPU stuff running 10/100x slower

=C2=A0=C2=A0=C2=A0=C2=A0need to pin lots of system memory (16GB per device?=
)

=C2=A0=C2=A0=C2=A0=C2=A0use of mmu_notifier spreading to device drivers, in=
stead of one
common solution

=C2=A0=C2=A0=C2=A0=C2=A0special swap type to handle migration

=C2=A0=C2=A0=C2=A0=C2=A0future openCL API wants address space sharing

=C2=A0=C2=A0=C2=A0=C2=A0HMM has some core VM impact, but relatively contain=
ed

=C2=A0=C2=A0=C2=A0=C2=A0how to get HMM upstream?=C2=A0=C2=A0does anybody ha=
ve objections to anything
in HMM?

=C2=A0=C2=A0=C2=A0=C2=A0split up in several series

=C2=A0=C2=A0=C2=A0=C2=A0Andrew: put more info in the changelogs

=C2=A0=C2=A0=C2=A0=C2=A0space for future optimizations

=C2=A0=C2=A0=C2=A0=C2=A0dwmw2: svm API, should move to a generic API

=C2=A0=C2=A0=C2=A0=C2=A0intel_svm_bind_mm - bind the current process to a P=
ASID



MM validation & debugging

=C2=A0=C2=A0=C2=A0=C2=A0Sasha using KASAN on locking, trap missed locks

=C2=A0=C2=A0=C2=A0=C2=A0requires annotation of what memory is locked by a l=
ock

=C2=A0=C2=A0=C2=A0=C2=A0how to annotate what memory is protected by a lock?

=C2=A0=C2=A0=C2=A0=C2=A0Kirill: what about a struct with a lock inside?

=C2=A0=C2=A0=C2=A0=C2=A0annotate struct members with which lock protects it=
?

=C2=A0=C2=A0=C2=A0=C2=A0too much work

=C2=A0=C2=A0=C2=A0=C2=A0trying to improve hugepage testing

=C2=A0=C2=A0=C2=A0=C2=A0split_all_huge_pages

=C2=A0=C2=A0=C2=A0=C2=A0expose list of huge pages through debugfs, allow sp=
litting
arbirarily chosen ones

=C2=A0=C2=A0=C2=A0=C2=A0fuzzer to open, close, read & write random files in=
 sysfs & debugfs

=C2=A0=C2=A0=C2=A0=C2=A0how to coordinate security(?) issues with zero-day =
security folks?



Memory cgroups

=C2=A0=C2=A0=C2=A0=C2=A0how to figure out the memory a cgroup needs (as opp=
osed to
currently used)?

=C2=A0=C2=A0=C2=A0=C2=A0memory pressure is not enough to determine the need=
s of a cgroup

=C2=A0=C2=A0=C2=A0=C2=A0cgroups scanned in equal portion

=C2=A0=C2=A0=C2=A0=C2=A0unfair, streaming file IO can result in using lots =
of memory, even
when the cgroup has mostly inactive file pages

=C2=A0=C2=A0=C2=A0=C2=A0potential solution:

=C2=A0=C2=A0=C2=A0=C2=A0dynamically balance the cgroups

=C2=A0=C2=A0=C2=A0=C2=A0adjust limits dynamically, based on their memory pr=
essure

=C2=A0=C2=A0=C2=A0=C2=A0problem: how to detect memory pressure?

=C2=A0=C2=A0=C2=A0=C2=A0when to increase memory? when to decrease memory?

=C2=A0=C2=A0=C2=A0=C2=A0real time aging of various LRU lists

=C2=A0=C2=A0=C2=A0=C2=A0only for active / anon lists, not inactine file lis=
t

=C2=A0=C2=A0=C2=A0=C2=A0"keep cgroup data in memory if its working set is y=
ounger than X
seconds"

=C2=A0=C2=A0=C2=A0=C2=A0refault info: distinguish between refaults (working=
 set faulted
back in), and evictions of data that is only used once

=C2=A0=C2=A0=C2=A0=C2=A0can be used to know when to grow a cgroup, but not =
when to shrink
it

=C2=A0=C2=A0=C2=A0=C2=A0vmpressure API: does not work well on very large sy=
stems, only on
smaller ones

=C2=A0=C2=A0=C2=A0=C2=A0quickly reaches "critical" levels on large systems,=
 that are not
even that busy

=C2=A0=C2=A0=C2=A0=C2=A0Johannes: time-based statistic to measure how much =
time processes
wait for IO

=C2=A0=C2=A0=C2=A0=C2=A0not iowait, which measures how long the _system_ wa=
its, but per-
task

=C2=A0=C2=A0=C2=A0=C2=A0add refault info in, only count time spent on refau=
lts

=C2=A0=C2=A0=C2=A0=C2=A0wait time above threshold? grow cgroup

=C2=A0=C2=A0=C2=A0=C2=A0wait time under threshold? shrink cgroup, but not b=
elow lower limit

=C2=A0=C2=A0=C2=A0=C2=A0Larry: Docker people want per-cgroup vmstat info



TLB flush optimizations

=C2=A0=C2=A0=C2=A0=C2=A0mmu_gather side of tlb flush

=C2=A0=C2=A0=C2=A0=C2=A0collect invalidations, gather items to flush

=C2=A0=C2=A0=C2=A0=C2=A0patch: increase size of mmu_gather, and try to flus=
h more at once

=C2=A0=C2=A0=C2=A0=C2=A0Andrea - rmap length scalability issues

=C2=A0=C2=A0=C2=A0=C2=A0too many KSM pages merged together, rmap chain beco=
mes too long

=C2=A0=C2=A0=C2=A0=C2=A0put upper limit on number of shares of a KSM page (=
256 share limit)

=C2=A0=C2=A0=C2=A0=C2=A0mmu_notifiers batch flush interface?

=C2=A0=C2=A0=C2=A0=C2=A0limit max_page_sharing to reduce KSM rmap chain len=
gth



OOM killer

=C2=A0=C2=A0=C2=A0=C2=A0goal: make OOM invocation more deterministic

=C2=A0=C2=A0=C2=A0=C2=A0currently: reclaim until there is nothing left to r=
eclaim, then
invoke OOM killer

=C2=A0=C2=A0=C2=A0=C2=A0problem: sometimes reclaim gets stuck, and OOM kill=
er is not
invoked when it should

=C2=A0=C2=A0=C2=A0=C2=A0one single page free resets the OOM counter, causin=
g livelock

=C2=A0=C2=A0=C2=A0=C2=A0thrashing not detected, on the contrary helps thras=
hing happen

=C2=A0=C2=A0=C2=A0=C2=A0make things more conservative?

=C2=A0=C2=A0=C2=A0=C2=A0OOM killer invoked on heavy thrashing and no progre=
ss made in the
VM

=C2=A0=C2=A0=C2=A0=C2=A0OOM reaper - to free resources before OOM killed ta=
sk can exit by
itself

=C2=A0=C2=A0=C2=A0=C2=A0timeout based solution is not trivial, doable, but =
not preferred by
Michal

=C2=A0=C2=A0=C2=A0=C2=A0if Johannes can make a timeout scheme deterministic=
, Michal has no
objections

=C2=A0=C2=A0=C2=A0=C2=A0Michal: I think we can do better without a timer so=
lution

=C2=A0=C2=A0=C2=A0=C2=A0need deterministic way to put system into a consist=
ent state

=C2=A0=C2=A0=C2=A0=C2=A0tmpfs vs OOM killer

=C2=A0=C2=A0=C2=A0=C2=A0OOM killer cannot discard tmpfs files

=C2=A0=C2=A0=C2=A0=C2=A0with cgroups, reap giant tmpfs file anyway in speci=
al cases at
Google

=C2=A0=C2=A0=C2=A0=C2=A0restart whole container, dump container's tmpfs con=
tents



MM tree workflow

=C2=A0=C2=A0=C2=A0=C2=A0most of Andrew's job: sollicit feedback from people

=C2=A0=C2=A0=C2=A0=C2=A0-mm git tree helps many people

=C2=A0=C2=A0=C2=A0=C2=A0Michal: would like email message IDs references in =
patches, both
for original patches and fixes

=C2=A0=C2=A0=C2=A0=C2=A0the value of -fix patches is that previous reviews =
do not need to
get re-done

=C2=A0=C2=A0=C2=A0=C2=A0sometimes a replacement patch is easier

=C2=A0=C2=A0=C2=A0=C2=A0Kirill: sometimes difficult to get patch sets revie=
wed

=C2=A0=C2=A0=C2=A0=C2=A0generally adds acked-by and reviewed-by lines by ha=
nd

=C2=A0=C2=A0=C2=A0=C2=A0Michal: -mm tree is maintainer tree of last resort

=C2=A0=C2=A0=C2=A0=C2=A0Andrew: carrying those extra patches isn't too much=
 work



SLUB optimizations lightning talk

=C2=A0=C2=A0=C2=A0=C2=A0bulk APIs for SLUB + SLAB

=C2=A0=C2=A0=C2=A0=C2=A0kmem_cache_{alloc,free}_bulk()

=C2=A0=C2=A0=C2=A0=C2=A0kfree_bulk()

=C2=A0=C2=A0=C2=A0=C2=A060%speedup measured

=C2=A0=C2=A0=C2=A0=C2=A0can be used from network, rcu free, ...

=C2=A0=C2=A0=C2=A0=C2=A0per CPU freelist per page

=C2=A0=C2=A0=C2=A0=C2=A0nice speedup, but still suffers from a race conditi=
on
--=-feNGMzNii1y4dZgWPPoY
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJXGky9AAoJEM553pKExN6DYasH/jvPrZdDIrwi9gh+s8uGgeSg
BwvExFT4xokIX6Hes8ovQTc3eTaVzrgnak0qv6Ley5mmjsrSJaRkyrY3YA7fmegz
UEI9+lXr/kDvmiWNV8kPQUsszcuCv3Sh9XmiJtZ9bVAkLSdQjNE2Tpjdyx31kgb2
EZW5b/TD5PRZDf3yUBFBMFNIY9j+jGMIRolbvgoRzqsxtI7M7eiyMEylkE/MV/8e
86wVgKX9SXi+uqY446jBcsbP1/5AN37ILsLZWakEFFvLFAWcMbxNq2Peo4GPAEYo
MIP2Ye144UROaJouyLtFLbJacNNoPP5KuS/l3s/fNgStbYr91u4XQ7GuBvWW6E8=
=cxCJ
-----END PGP SIGNATURE-----

--=-feNGMzNii1y4dZgWPPoY--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
