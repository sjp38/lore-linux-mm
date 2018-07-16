Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9F6C06B0005
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 09:39:57 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id c12-v6so8754058wrd.14
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 06:39:57 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h45-v6sor1277321wrh.8.2018.07.16.06.39.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 16 Jul 2018 06:39:56 -0700 (PDT)
Date: Mon, 16 Jul 2018 15:39:54 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: Instability in current -git tree
Message-ID: <20180716133954.GA14710@techadventures.net>
References: <9b93d48c-b997-01f7-2fd6-6e35301ef263@oracle.com>
 <CA+55aFxFw2-1BD2UBf_QJ2=faQES_8q==yUjwj4mGJ6Ub4uX7w@mail.gmail.com>
 <5edf2d71-f548-98f9-16dd-b7fed29f4869@oracle.com>
 <CA+55aFwPAwczHS3XKkEnjY02PaDf2mWrcqx_hket4Ce3nScsSg@mail.gmail.com>
 <CAGM2rebeo3UUo2bL6kXCMGhuM36wjF5CfvqGG_3rpCfBs5S2wA@mail.gmail.com>
 <CA+55aFxetyCqX2EzFBDdHtriwt6UDYcm0chHGQUdPX20qNHb4Q@mail.gmail.com>
 <CAGM2reb2Zk6t=QJtJZPRGwovKKR9bdm+fzgmA_7CDVfDTjSgKA@mail.gmail.com>
 <20180716120642.GN17280@dhcp22.suse.cz>
 <fc5cfff3-0000-41da-e4d9-3e91ef9d0792@oracle.com>
 <20180716122918.GO17280@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180716122918.GO17280@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, tglx@linutronix.de, willy@infradead.org, mingo@redhat.com, axboe@kernel.dk, gregkh@linuxfoundation.org, davem@davemloft.net, viro@zeniv.linux.org.uk, Dave Airlie <airlied@gmail.com>, Tejun Heo <tj@kernel.org>, Theodore Tso <tytso@google.com>, snitzer@redhat.com, Linux Memory Management List <linux-mm@kvack.org>, neelx@redhat.com, mgorman@techsingularity.net

On Mon, Jul 16, 2018 at 02:29:18PM +0200, Michal Hocko wrote:
> On Mon 16-07-18 08:09:19, Pavel Tatashin wrote:
> > 
> > 
> > On 07/16/2018 08:06 AM, Michal Hocko wrote:
> > > On Sat 14-07-18 09:39:29, Pavel Tatashin wrote:
> > > [...]
> > >> From 95259841ef79cc17c734a994affa3714479753e3 Mon Sep 17 00:00:00 2001
> > >> From: Pavel Tatashin <pasha.tatashin@oracle.com>
> > >> Date: Sat, 14 Jul 2018 09:15:07 -0400
> > >> Subject: [PATCH] mm: zero unavailable pages before memmap init
> > >>
> > >> We must zero struct pages for memory that is not backed by physical memory,
> > >> or kernel does not have access to.
> > >>
> > >> Recently, there was a change which zeroed all memmap for all holes in e820.
> > >> Unfortunately, it introduced a bug that is discussed here:
> > >>
> > >> https://www.spinics.net/lists/linux-mm/msg156764.html
> > >>
> > >> Linus, also saw this bug on his machine, and confirmed that pulling
> > >> commit 124049decbb1 ("x86/e820: put !E820_TYPE_RAM regions into memblock.reserved")
> > >> fixes the issue.
> > >>
> > >> The problem is that we incorrectly zero some struct pages after they were
> > >> setup.
> > > 
> > > I am sorry but I simply do not see it. zero_resv_unavail should be
> > > touching only reserved memory ranges and those are not initialized
> > > anywhere. So who has reused them and put them to normal available
> > > memory to be initialized by free_area_init_node[s]?
> > > 
> > > The patch itself should be safe because reserved and available memory
> > > ranges should be disjoint so the ordering shouldn't matter. The fact
> > > that it matters is the crux thing to understand and document. So the
> > > change looks good to me but I do not understand _why_ it makes any
> > > difference. There must be somebody to put (memblock) reserved memory
> > > available to the page allocator behind our backs.
> > 
> > Thats exactly right, and I am also not sure why this is happening,
> > there must be some overlapping happening that just should not. I will
> > study it later.
> 
> Maybe a stupid question, but I do not see it from the code (this init
> code is just to complex to keep it cached in head so I always have to
> study the code again and again, sigh). So what exactly prevents
> memmap_init_zone to stumble over reserved regions? We do play some ugly
> games to find a first !reserved pfn in the node but I do not really see
> anything in the init path to properly skip over reserved holes inside
> the node.

I think we are not really skiping reserved regions in memmap_init_zone().
memmap_init_zone() gets just called being size the subtract of zone_end_pfn - zone_start_pfn, and I don't see that we're checking if those pfn's fall in reserved regions.

To get a better insight, I just put a couple of printk's:


kernel: zero_resv_unavail: start-end: 0x9f000-0x100000
kernel: zero_resv_unavail: pfn: 0x9f
kernel: zero_resv_unavail: pfn: 0xa0
kernel: zero_resv_unavail: pfn: 0xa1
kernel: zero_resv_unavail: pfn: 0xa2
kernel: zero_resv_unavail: pfn: 0xa3
kernel: zero_resv_unavail: pfn: 0xa4
kernel: zero_resv_unavail: pfn: 0xa5
kernel: zero_resv_unavail: pfn: 0xa6
kernel: zero_resv_unavail: pfn: 0xa7
kernel: zero_resv_unavail: pfn: 0xa8
kernel: zero_resv_unavail: pfn: 0xa9
...
...
kernel: memmap_init_zone: pfn: 9f
kernel: memmap_init_zone: pfn: a0
kernel: memmap_init_zone: pfn: a1
kernel: memmap_init_zone: pfn: a2
kernel: memmap_init_zone: pfn: a3
kernel: memmap_init_zone: pfn: a4
kernel: memmap_init_zone: pfn: a5
kernel: memmap_init_zone: pfn: a6
kernel: memmap_init_zone: pfn: a7
kernel: memmap_init_zone: pfn: a8
kernel: memmap_init_zone: pfn: a9
kernel: memmap_init_zone: pfn: aa
kernel: memmap_init_zone: pfn: ab
kernel: memmap_init_zone: pfn: ac
kernel: memmap_init_zone: pfn: ad
kernel: memmap_init_zone: pfn: ae
kernel: memmap_init_zone: pfn: af
kernel: memmap_init_zone: pfn: b0
kernel: memmap_init_zone: pfn: b1
kernel: memmap_init_zone: pfn: b2

The printk from memmap_init_zone has already passed the checks about early_pfn_ etc.

So, reverting Pavel's fix would twist this, and we'd end up zeroing pages that are already set up in memmap_init_zone() 
(as we already had).
-- 
Oscar Salvador
SUSE L3
