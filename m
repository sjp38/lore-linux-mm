Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 894356B00AA
	for <linux-mm@kvack.org>; Mon, 17 Mar 2014 14:18:39 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id y10so5913930pdj.13
        for <linux-mm@kvack.org>; Mon, 17 Mar 2014 11:18:39 -0700 (PDT)
Received: from collaborate-mta1.arm.com (fw-tnat.austin.arm.com. [217.140.110.23])
        by mx.google.com with ESMTP id bo2si15332165pbc.231.2014.03.17.11.18.38
        for <linux-mm@kvack.org>;
        Mon, 17 Mar 2014 11:18:38 -0700 (PDT)
Date: Mon, 17 Mar 2014 18:18:13 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: Recent 3.x kernels: Memory leak causing OOMs
Message-ID: <20140317181813.GA24144@arm.com>
References: <20140216200503.GN30257@n2100.arm.linux.org.uk>
 <alpine.DEB.2.02.1402161406120.26926@chino.kir.corp.google.com>
 <20140216225000.GO30257@n2100.arm.linux.org.uk>
 <1392670951.24429.10.camel@sakura.staff.proxad.net>
 <20140217210954.GA21483@n2100.arm.linux.org.uk>
 <20140315101952.GT21483@n2100.arm.linux.org.uk>
 <20140317180748.644d30e2@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140317180748.644d30e2@notabene.brown>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.de>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>, linux-raid@vger.kernel.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Maxime Bizon <mbizon@freebox.fr>, Linus Torvalds <torvalds@linux-foundation.org>, linux-arm-kernel@lists.infradead.org

On Mon, Mar 17, 2014 at 06:07:48PM +1100, NeilBrown wrote:
> On Sat, 15 Mar 2014 10:19:52 +0000 Russell King - ARM Linux
> <linux@arm.linux.org.uk> wrote:
> > unreferenced object 0xc3c3f880 (size 256):
> >   comm "md2_resync", pid 4680, jiffies 638245 (age 8615.570s)
> >   hex dump (first 32 bytes):
> >     00 00 00 00 00 00 00 00 00 00 00 00 01 00 00 f0  ................
> >     00 00 00 00 10 00 00 00 00 00 00 00 00 00 00 00  ................
> >   backtrace:
> >     [<c008d4f0>] __save_stack_trace+0x34/0x40
> >     [<c008d5f0>] create_object+0xf4/0x214
> >     [<c02da114>] kmemleak_alloc+0x3c/0x6c
> >     [<c008c0d4>] __kmalloc+0xd0/0x124
> >     [<c00bb124>] bio_alloc_bioset+0x4c/0x1a4
> >     [<c021206c>] r1buf_pool_alloc+0x40/0x148
> >     [<c0061160>] mempool_alloc+0x54/0xfc
> >     [<c0211938>] sync_request+0x168/0x85c
> >     [<c021addc>] md_do_sync+0x75c/0xbc0
> >     [<c021b594>] md_thread+0x138/0x154
> >     [<c0037b48>] kthread+0xb0/0xbc
> >     [<c0013190>] ret_from_fork+0x14/0x24
> >     [<ffffffff>] 0xffffffff
> > 
> > with 3077 of these in the debug file.  3075 are for "md2_resync" and
> > two are for "md4_resync".
> > 
> > /proc/slabinfo shows for this bucket:
> > kmalloc-256         3237   3450    256   15    1 : tunables  120   60    0 : slabdata    230    230      0
> > 
> > but this would only account for about 800kB of memory usage, which itself
> > is insignificant - so this is not the whole story.
> > 
> > It seems that this is the culpret for the allocations:
> >         for (j = pi->raid_disks ; j-- ; ) {
> >                 bio = bio_kmalloc(gfp_flags, RESYNC_PAGES);
> > 
> > Since RESYNC_PAGES will be 64K/4K=16, each struct bio_vec is 12 bytes
> > (12 * 16 = 192) plus the size of struct bio, which would fall into this
> > bucket.
> > 
> > I don't see anything obvious - it looks like it isn't every raid check
> > which loses bios.  Not quite sure what to make of this right now.
> 
> I can't see anything obvious either.
> 
> The bios allocated there are stored in a r1_bio and those pointers are never
> changed.
> If the r1_bio wasn't freed then when the data-check finished, mempool_destroy
> would complain that the pool wasn't completely freed.
> And when the r1_bio is freed, all the bios are put as well.

It could be a false positive, there are areas that kmemleak doesn't scan
like page allocations and the pointer reference graph it tries to build
would fail.

What's interesting to see is the first few leaks reported as they are
always reported in the order of allocation. In this case, the
bio_kmalloc() returned pointer is stored in r1_bio. Is the r1_bio
reported as a leak as well?

The sync_request() function eventually gets rid of the r1_bio as it is a
variable on the stack. But it is stored in a bio->bi_private variable
and that's where I lost track of where pointers are referenced from.

A simple way to check whether it's a false positive is to do a:

echo dump=<unref obj addr> > /sys/kernel/debug/kmemleak

If an object was reported as a leak but later on kmemleak doesn't know
about it, it means that it was freed and hence a false positive (maybe I
should add this as a warning in kmemleak if certain amount of leaked
objects freeing is detected).

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
