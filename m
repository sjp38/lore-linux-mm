Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 2C3958D0039
	for <linux-mm@kvack.org>; Tue,  8 Feb 2011 20:04:44 -0500 (EST)
MIME-Version: 1.0
Message-ID: <1ddd01a8-591a-42bc-8bb3-561843b31acb@default>
Date: Tue, 8 Feb 2011 17:03:24 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH V2 0/3] drivers/staging: zcache: dynamic page cache/swap
 compression
References: <20110207032407.GA27404@ca-server1.us.oracle.com>
In-Reply-To: <20110207032407.GA27404@ca-server1.us.oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@suse.de, Chris Mason <chris.mason@oracle.com>, akpm@linux-foundation.org, torvalds@linux-foundation.org, matthew@wil.cx, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, jeremy@goop.org, Kurt Hackel <kurt.hackel@oracle.com>, npiggin@kernel.dk, riel@redhat.com, Konrad Wilk <konrad.wilk@oracle.com>, mel@csn.ul.ie, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, sfr@canb.auug.org.au, wfg@mail.ustc.edu.cn, tytso@mit.edu, viro@ZenIV.linux.org.uk, hughd@google.com, hannes@cmpxchg.org, Matt <jackdachef@gmail.com>

> (Historical note: This "new" zcache patchset supercedes both the
> kztmem patchset and the "old" zcache patchset as described in:
> http://lkml.org/lkml/2011/2/5/148)

(In order to move discussion from the old kztmem patchset to
the new zcache patchset, I am replying here to Matt's email
sent at: https://lkml.org/lkml/2011/2/4/199 )

> From: Matt [mailto:jackdachef@gmail.com]

Hi Matt --

Thanks for all the thoughtful work and questions!  Sorry it
took me a few days to reply...

> This finally makes Cleancache's functionality usable for desktop and
> other small device (non-enterprise) users (especially regarding
> frontswap) :)

> 2) feedback
>=20
> WARNING: at kernel/softirq.c:159 local_bh_enable+0xba/0x110()

These should be gone in V2.

> I also observed that it takes some time until volumes (which use
> kztmem's ephemeral nodes) are unmounted - probably due to emptying
> slub/slab taking longer - so this should be normal.

If "some time" becomes a problem, I have a design in my
head how to fix this.  But I'll consider it lower priority
for now.

> 2.2) a user (32bit box) who's running a pretty similar kernel to mine
> (details later) has had some assert_spinlocks thrown while

The specific sequence of asserts indicates a race, but I think
a harmless one.  I haven't been able to reproduce it and stared
at various race possibilities for a couple of hours without
luck. (Aha! There it is!  Oops, no that's not it.  Repeat.)
Hopefully getting broader exposure to more experienced
kernel developers will help find/fix this one.

> 2.3) rsync-operations seemed to speed up quite noticably to say the
> least (significantly)
>  :
> so job (2) could be cut by 1-2 minutes. Unmounting the drive/partition
>  :
> So kztmem also seems to help where low latency needs to be met, e.g.
> pro-audio.
>  :
> So productivity is improved quite a lot.

Thanks for running some performance tests on a broader set of
test cases!  The numbers look very nice!

> Questions:
> =E2=80=A2 What exactly is kztmem?
> =E2=88=98 is it a tmem similar functionality like provided in the project
> "Xen's Transcent Memory"
> =E2=88=98 and zmem is simply a "plugin" for memory compression support to=
 tmem
> ? (is that what zcache does ?)
> =E2=80=A2 so simplified (superficially without taking into account advant=
ages
> or certain unique characteristics) some equivalents:
> =E2=88=98 frontswap =3D=3D ramzswap
> =E2=88=98 kztmem =3D=3D zcache
> =E2=88=98 cleancache =3D=3D is the "core", "mastermind" or "hypervisor" b=
ehind all
> this, making frontswap and kztmem kind of "plugins" for it ?

This is best described in the "Academic Overview" section
of PATCH V2 0/3: https://lkml.org/lkml/2011/2/6/346
Cleancache and frontswap are "data sources" for page-oriented
data that can easily be stored in "transcendent memory"
(aka "tmem").  Once pages of data are accessible only via tmem,
lots of things can be done to the data, including compression,
deduplication, being sent to the hypervisor, etc.

> So kztmem (or more accurately: cleancache) is open for adding more
> functionality in the future ?

Very definitely...  I'm working on another interesting use
model right now!

> =E2=80=A2 What are advantages of kztmem compared to ramzswap ("compcache"=
) &
> zcache ? From what I understood - it's more dynamic in it's nature
> than compcache & zcache: they need to preallocate predetermined amount
> of memory, several "ram-drives" would be needed for SMP-scalability
> =E2=88=98 whereas this (pre-allocated RAM and multiple "ram-drives" aren'=
t
> needed for kztmem, cleancache and frontswap since cleancache,
> frontswap & kztmem are concurrency-safe and dynamic (according to
> documentation) ?

Yes, that's a good overview of the differences.

> =E2=80=A2 Coming back to usage of compcache - how about the problem of 60=
%
> memory fragmentation (according to compcache/zcache wiki,
> http://code.google.com/p/compcache/wiki/Fragmentation) ?
> Could the situation be improved with in-kernel "memory compaction" ?
> I'm not a developer so I don't know exactly how lumpy reclaim/memory
> compaction and xvmalloc would interact with each other

Nitin is the expert on compcache and xvmalloc, so I will leave
this question unanswered for now.

> =E2=80=A2 According to the Documentation you posted "e.g. a ram-based FS =
such
> as tmpfs should not enable cleancache" - so it's not using block i/o
> layer ? what are the performance or other advantages of that approach
> ?

Correct, no block i/o layer involved.  The block i/o layer is
optimized for disks (though it is slowly becoming adapted to
faster devices).  The real "advantage" is that EVERY put/get
has immediate feedback and this is very important to making
things as dynamic as possible.

> =E2=80=A2 Is there support for XFS or reiserfs - how difficult would it b=
e to
> add that ?

I'm not familiar with either, but most filesystems are easy to
add... I'm just not able to do the testing.  If zcache moves
into upstream, other filesystem experts should be able to try
zcache easily on other filesystems.

> =E2=80=A2 Very interesting would be: support for FUSE (taking into accoun=
t zfs
> and ntfs3g, etc.) - would that be possible ?

I don't know enough about those to feel comfortable answering,
but would be happy to consult if someone else wants to try it.

> =E2=80=A2 Was there testing done on 32bit boxes ? How about alternative
> architectures such as ARM, PPC, etc. ?
> =E2=88=98 I'm especially interested in ARM since surely a lot on the

Sadly, I haven't done any testing on 32-bit boxes.  All the code
is designed to be entirely architecture-independent though I'm
sure a bug or three will be found on other architectures.

> be / Is there a port of cleancache, kztmem and frontswap available for
> 2.6.32* kernels ? (most android devices are currently running those)

I've found porting cleancache and frontswap to other recent
Linux versions to be straightforward.  And zcache is just a
staging driver so should also port easily.

> =E2=80=A2 Considerung UP boxes - is the usage even beneficial on those ?
> =E2=88=98 If not - why not (written in the documentation) - due to missin=
g raw
> CPU power ?

Should work fine on a UP box.  The majority of the performance
advantage is "converting" disk seek wait time into CPU compress/
decompress time.

> =E2=80=A2 How is the scaling ? In case of Multiprocessors  - are the
> operations/parallelism or concurrency, how it's called, realized
> through "work queues" - (there have been lots of changes recently in
> the kernel [2.6.37, 2.6.38]).  ?

Good questions.  The concurrency should be pretty good, but in
the current version, interrupts are disabled during compression,
which could lead to some problems in a more real-time load.
This design is fixable but will take some work.

> =E2=80=A2 Are there higher latencies during high memory pressure or high =
CPU
> load situations, e.g. where the latencies would even go down below
> without usage of kztmem ?

Theoretically, if there is no disk wait time (e.g. CPUs are always
loaded even during disk reads) AND there is high disk demand,
zcache could cause a reduction in performance.

> =E2=80=A2 The compression algorithm in use seems to be lzo. Are any addit=
ional
> selectable compressions planned such as lzf, gzip - maybe even bzip2 ?
> - Would they be selectable via Kconfig ?
> =E2=88=98 are these threaded / scaling with multiple processors - e.g. li=
ke pcrypt ?

Good ideas for future enhancements!

> =E2=80=A2 "Exactly how much memory it provides is entirely dynamic and
> random." - can maximum limits be set ? ("watermarks" ? - if that is
> the correct term)
> How efficient is the algorithm ? What is it based on ?

For cleancache pages, all can be reclaimed so no maximum needs
to be set as long as the kernel reclaim mechanism is working properly.
For frontswap pages, there is a maximum currently hardcoded,
but this could be changed to be handled through a /sys fs file.

> =E2=80=A2 Can the operations be sped up even more using spice() system ca=
ll or
> something similar (if existant) - if even applicable ?

Sorry, I don't know the answer to this.

> =E2=80=A2 Are userland hooks planned ? e.g. for other virtualization solu=
tions
> such as KVM, qemu, etc.

We've thought of userland hooks, but haven't tried them yet.

KVM should be able to take advantage of zcache with a little effort.

> =E2=80=A2 How about deduplication support for the ephemeral (filesystem) =
pools?
> =E2=88=98 in my (humble) opinion this might be really useful - since in t=
he
> future there will be more and more CPU power but due to available RAM
> not growing as linear (or fast) as CPU's power this could be a kind of
> compensation to gain more memory
> =E2=88=98 would that work with "Kernel Samepage Merging"?
> =E2=88=98 is KSM even similar to tmem's deduplication functionality (tmem=
 -
> which is used or planned for Xen)
> Referring to http://marc.info/?l=3Dlinux-kernel&m=3D129683713531791&w=3D2
> slides 20 to 21 on the presentation deduplication would seem much more
> efficient than KSM.

Deduplication support could be added.

> Kztmem seems to be quite useful on memory constrained devices:

You have suggested several interesting possibilities!

If I've missed anything important, please let me know!

Thanks again!
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
