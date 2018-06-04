Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 034D36B0003
	for <linux-mm@kvack.org>; Mon,  4 Jun 2018 11:36:54 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id z16-v6so9534708pge.21
        for <linux-mm@kvack.org>; Mon, 04 Jun 2018 08:36:53 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q12-v6sor1543870pll.11.2018.06.04.08.36.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 04 Jun 2018 08:36:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180604150808.g75xxjya5npr6sh3@armageddon.cambridge.arm.com>
References: <1730157334.5467848.1527672937617.JavaMail.zimbra@redhat.com>
 <20180530104637.GC27180@dhcp22.suse.cz> <1684479370.5483281.1527680579781.JavaMail.zimbra@redhat.com>
 <20180530123826.GF27180@dhcp22.suse.cz> <20180531152225.2ck6ach4lma4zeim@armageddon.cambridge.arm.com>
 <20180531184104.GT15278@dhcp22.suse.cz> <1390612460.6539623.1527817820286.JavaMail.zimbra@redhat.com>
 <57176788.6562837.1527828823442.JavaMail.zimbra@redhat.com>
 <CACT4Y+ZE_qbnqzjnhbrk=vhLqijKZ5x1QbtbJSyNuqA3htFgFA@mail.gmail.com>
 <20180604124210.GQ19202@dhcp22.suse.cz> <20180604150808.g75xxjya5npr6sh3@armageddon.cambridge.arm.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 4 Jun 2018 17:36:31 +0200
Message-ID: <CACT4Y+YzaFeBD2nBmv5BGv6Cq_-4RK+D9MhUTjwOUuc4jN5pYQ@mail.gmail.com>
Subject: Re: [PATCH] kmemleak: don't use __GFP_NOFAIL
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Michal Hocko <mhocko@suse.com>, Chunyu Hu <chuhu@redhat.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, malat@debian.org, Linux-MM <linux-mm@kvack.org>, Akinobu Mita <akinobu.mita@gmail.com>

On Mon, Jun 4, 2018 at 5:08 PM, Catalin Marinas <catalin.marinas@arm.com> wrote:
> On Mon, Jun 04, 2018 at 02:42:10PM +0200, Michal Hocko wrote:
>> On Mon 04-06-18 10:41:39, Dmitry Vyukov wrote:
>> [...]
>> > FWIW this problem is traditionally solved in dynamic analysis tools by
>> > embedding meta info right in headers of heap blocks. All of KASAN,
>> > KMSAN, slub debug, LeakSanitizer, asan, valgrind work this way. Then
>> > an object is either allocated or not. If caller has something to
>> > prevent allocations from failing in any context, then the same will be
>> > true for KMEMLEAK meta data.
>>
>> This makes much more sense, of course. I thought there were some
>> fundamental reasons why kmemleak needs to have an off-object tracking
>> which makes the whole thing much more complicated of course.
>
> Kmemleak needs to track all memory blocks that may contain pointers
> (otherwise the dependency graph cannot be correctly tracked leading to
> lots of false positives). Not all these objects come from the slab
> allocator, for example it tracks certain alloc_pages() blocks, all of
> memblock_alloc().

I understand that this will make KMEMLEAK tracking non-uniform, but
heap objects are the most important class of allocations.
page struct already contains stackdepot id if CONFIG_PAGE_OWNER is
enabled. Do we need anything else other than stack trace for pages?
I don't know about memblock's.

> An option would be to use separate metadata only for non-slab objects,
> though I'd have to see how intrusive this is for mm/sl*b.c. Also there
> is RCU freeing for the kmemleak metadata to avoid locking when
> traversing the internal lists. If the metadata is in the slab object
> itself, we'd have to either defer its freeing or add some bigger lock to
> kmemleak.

This relates to scanning without slopped world, right? In our
experience with large-scale systematic testing any tool with false
positives can't be used in practice in systematic way. KMEMLEAK false
positives do not allow to enable it on syzbot. We know there are tons
of leaks, we have the tool, but we are not detecting leaks. I don't
know who/how uses KMEMLEAK in non-stop-the-world mode, but
stop-the-world is pretty much a requirement for deployment for us. And
it would also solve the problem with disappearing under our feet heap
blocks, right?
FWIW In LeakSanitizer we don't specifically keep track of heap blocks.
Instead we stop the world and then ask memory allocator for metainfo.
I would expect that sl*b also have all required info, maybe in not
O(1) accessible form, so it may require some preprocessing (e.g.
collecting all free objects in a slab and then subtracting it from set
of all objects in the slab to get set of allocated objects).
But I understand that all of this turns this from "add a flag" to
almost a complete rewrite of the tool...
