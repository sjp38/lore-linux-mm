Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5AF906B0003
	for <linux-mm@kvack.org>; Mon,  4 Jun 2018 12:41:09 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id p41-v6so18168596oth.5
        for <linux-mm@kvack.org>; Mon, 04 Jun 2018 09:41:09 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id d46-v6si618841ote.57.2018.06.04.09.41.07
        for <linux-mm@kvack.org>;
        Mon, 04 Jun 2018 09:41:07 -0700 (PDT)
Date: Mon, 4 Jun 2018 17:41:03 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH] kmemleak: don't use __GFP_NOFAIL
Message-ID: <20180604164102.vemn3htz6qgmonjq@armageddon.cambridge.arm.com>
References: <1684479370.5483281.1527680579781.JavaMail.zimbra@redhat.com>
 <20180530123826.GF27180@dhcp22.suse.cz>
 <20180531152225.2ck6ach4lma4zeim@armageddon.cambridge.arm.com>
 <20180531184104.GT15278@dhcp22.suse.cz>
 <1390612460.6539623.1527817820286.JavaMail.zimbra@redhat.com>
 <57176788.6562837.1527828823442.JavaMail.zimbra@redhat.com>
 <CACT4Y+ZE_qbnqzjnhbrk=vhLqijKZ5x1QbtbJSyNuqA3htFgFA@mail.gmail.com>
 <20180604124210.GQ19202@dhcp22.suse.cz>
 <20180604150808.g75xxjya5npr6sh3@armageddon.cambridge.arm.com>
 <CACT4Y+YzaFeBD2nBmv5BGv6Cq_-4RK+D9MhUTjwOUuc4jN5pYQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+YzaFeBD2nBmv5BGv6Cq_-4RK+D9MhUTjwOUuc4jN5pYQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Michal Hocko <mhocko@suse.com>, Chunyu Hu <chuhu@redhat.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, malat@debian.org, Linux-MM <linux-mm@kvack.org>, Akinobu Mita <akinobu.mita@gmail.com>

On Mon, Jun 04, 2018 at 05:36:31PM +0200, Dmitry Vyukov wrote:
> On Mon, Jun 4, 2018 at 5:08 PM, Catalin Marinas <catalin.marinas@arm.com> wrote:
> > On Mon, Jun 04, 2018 at 02:42:10PM +0200, Michal Hocko wrote:
> >> On Mon 04-06-18 10:41:39, Dmitry Vyukov wrote:
> >> [...]
> >> > FWIW this problem is traditionally solved in dynamic analysis tools by
> >> > embedding meta info right in headers of heap blocks. All of KASAN,
> >> > KMSAN, slub debug, LeakSanitizer, asan, valgrind work this way. Then
> >> > an object is either allocated or not. If caller has something to
> >> > prevent allocations from failing in any context, then the same will be
> >> > true for KMEMLEAK meta data.
> >>
> >> This makes much more sense, of course. I thought there were some
> >> fundamental reasons why kmemleak needs to have an off-object tracking
> >> which makes the whole thing much more complicated of course.
> >
> > Kmemleak needs to track all memory blocks that may contain pointers
> > (otherwise the dependency graph cannot be correctly tracked leading to
> > lots of false positives). Not all these objects come from the slab
> > allocator, for example it tracks certain alloc_pages() blocks, all of
> > memblock_alloc().
> 
> I understand that this will make KMEMLEAK tracking non-uniform, but
> heap objects are the most important class of allocations.
> page struct already contains stackdepot id if CONFIG_PAGE_OWNER is
> enabled. Do we need anything else other than stack trace for pages?
> I don't know about memblock's.

Well, it needs most of the other stuff that's in struct kmemleak_object
(list_head, rb_node, some counters, spinlock_t).

> > An option would be to use separate metadata only for non-slab objects,
> > though I'd have to see how intrusive this is for mm/sl*b.c. Also there
> > is RCU freeing for the kmemleak metadata to avoid locking when
> > traversing the internal lists. If the metadata is in the slab object
> > itself, we'd have to either defer its freeing or add some bigger lock to
> > kmemleak.
> 
> This relates to scanning without slopped world, right?

Initially the RCU mechanism was added to defer kmemleak freeing its
metadata with another recursive call into the slab freeing routine
(since it does this when the tracked object is freed). This came in
handy for other lists traversal in kmemleak. For the actual memory
scanning, there is some fine-grained locking per metadata object as we
want to block the freeing until the scanning of the specific object
completes (e.g. vfree() must not unmap the object during scanning).

> In our
> experience with large-scale systematic testing any tool with false
> positives can't be used in practice in systematic way. KMEMLEAK false
> positives do not allow to enable it on syzbot. We know there are tons
> of leaks, we have the tool, but we are not detecting leaks. I don't
> know who/how uses KMEMLEAK in non-stop-the-world mode, but
> stop-the-world is pretty much a requirement for deployment for us. And
> it would also solve the problem with disappearing under our feet heap
> blocks, right?

A hard requirement during the early kmemleak development was not to
actually stop the world (as it can even take minutes to complete the
scanning). It employs various heuristics to deal with false positives
like checksumming, delaying the actual reporting, waiting for an object
to be detected as a leak in two successive scans while its checksum is
the same. While not ideal, it works most of the time.

Now, there was indeed a recent requirement to implement stop-the-world
scanning via a "stopscan" command to /sys/kernel/debug/kmemleak (using
stop_machine()) but I never got around to implementing it. This would be
very useful for non-interactive sessions like automated testing.

> FWIW In LeakSanitizer we don't specifically keep track of heap blocks.
> Instead we stop the world and then ask memory allocator for metainfo.
> I would expect that sl*b also have all required info, maybe in not
> O(1) accessible form, so it may require some preprocessing (e.g.
> collecting all free objects in a slab and then subtracting it from set
> of all objects in the slab to get set of allocated objects).
> But I understand that all of this turns this from "add a flag" to
> almost a complete rewrite of the tool...

As I said above, background scanning is still a requirement but we could
add a stopscan command on top, should be too hard.

-- 
Catalin
