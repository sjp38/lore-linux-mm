Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id B6C186B0003
	for <linux-mm@kvack.org>; Mon,  4 Jun 2018 11:08:16 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id p12-v6so6465651oti.6
        for <linux-mm@kvack.org>; Mon, 04 Jun 2018 08:08:16 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id v102-v6si2452027ota.144.2018.06.04.08.08.13
        for <linux-mm@kvack.org>;
        Mon, 04 Jun 2018 08:08:13 -0700 (PDT)
Date: Mon, 4 Jun 2018 16:08:08 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH] kmemleak: don't use __GFP_NOFAIL
Message-ID: <20180604150808.g75xxjya5npr6sh3@armageddon.cambridge.arm.com>
References: <1730157334.5467848.1527672937617.JavaMail.zimbra@redhat.com>
 <20180530104637.GC27180@dhcp22.suse.cz>
 <1684479370.5483281.1527680579781.JavaMail.zimbra@redhat.com>
 <20180530123826.GF27180@dhcp22.suse.cz>
 <20180531152225.2ck6ach4lma4zeim@armageddon.cambridge.arm.com>
 <20180531184104.GT15278@dhcp22.suse.cz>
 <1390612460.6539623.1527817820286.JavaMail.zimbra@redhat.com>
 <57176788.6562837.1527828823442.JavaMail.zimbra@redhat.com>
 <CACT4Y+ZE_qbnqzjnhbrk=vhLqijKZ5x1QbtbJSyNuqA3htFgFA@mail.gmail.com>
 <20180604124210.GQ19202@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180604124210.GQ19202@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Chunyu Hu <chuhu@redhat.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, malat@debian.org, Linux-MM <linux-mm@kvack.org>, Akinobu Mita <akinobu.mita@gmail.com>

On Mon, Jun 04, 2018 at 02:42:10PM +0200, Michal Hocko wrote:
> On Mon 04-06-18 10:41:39, Dmitry Vyukov wrote:
> [...]
> > FWIW this problem is traditionally solved in dynamic analysis tools by
> > embedding meta info right in headers of heap blocks. All of KASAN,
> > KMSAN, slub debug, LeakSanitizer, asan, valgrind work this way. Then
> > an object is either allocated or not. If caller has something to
> > prevent allocations from failing in any context, then the same will be
> > true for KMEMLEAK meta data.
> 
> This makes much more sense, of course. I thought there were some
> fundamental reasons why kmemleak needs to have an off-object tracking
> which makes the whole thing much more complicated of course.

Kmemleak needs to track all memory blocks that may contain pointers
(otherwise the dependency graph cannot be correctly tracked leading to
lots of false positives). Not all these objects come from the slab
allocator, for example it tracks certain alloc_pages() blocks, all of
memblock_alloc().

An option would be to use separate metadata only for non-slab objects,
though I'd have to see how intrusive this is for mm/sl*b.c. Also there
is RCU freeing for the kmemleak metadata to avoid locking when
traversing the internal lists. If the metadata is in the slab object
itself, we'd have to either defer its freeing or add some bigger lock to
kmemleak.

-- 
Catalin
