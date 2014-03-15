Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f174.google.com (mail-we0-f174.google.com [74.125.82.174])
	by kanga.kvack.org (Postfix) with ESMTP id 783F16B003B
	for <linux-mm@kvack.org>; Sat, 15 Mar 2014 06:20:08 -0400 (EDT)
Received: by mail-we0-f174.google.com with SMTP id t60so3014249wes.33
        for <linux-mm@kvack.org>; Sat, 15 Mar 2014 03:20:07 -0700 (PDT)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id en20si1060553wic.72.2014.03.15.03.20.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 15 Mar 2014 03:20:05 -0700 (PDT)
Date: Sat, 15 Mar 2014 10:19:52 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: Recent 3.x kernels: Memory leak causing OOMs
Message-ID: <20140315101952.GT21483@n2100.arm.linux.org.uk>
References: <20140216200503.GN30257@n2100.arm.linux.org.uk> <alpine.DEB.2.02.1402161406120.26926@chino.kir.corp.google.com> <20140216225000.GO30257@n2100.arm.linux.org.uk> <1392670951.24429.10.camel@sakura.staff.proxad.net> <20140217210954.GA21483@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140217210954.GA21483@n2100.arm.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Neil Brown <neilb@suse.de>, linux-raid@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Maxime Bizon <mbizon@freebox.fr>, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, David Rientjes <rientjes@google.com>

On Mon, Feb 17, 2014 at 09:09:54PM +0000, Russell King - ARM Linux wrote:
> On Mon, Feb 17, 2014 at 10:02:31PM +0100, Maxime Bizon wrote:
> > 
> > On Sun, 2014-02-16 at 22:50 +0000, Russell King - ARM Linux wrote:
> > 
> > > http://www.home.arm.linux.org.uk/~rmk/misc/log-20140208.txt
> > 
> > [<c0064ce0>] (__alloc_pages_nodemask+0x0/0x694) from [<c022273c>] (sk_page_frag_refill+0x78/0x108)
> > [<c02226c4>] (sk_page_frag_refill+0x0/0x108) from [<c026a3a4>] (tcp_sendmsg+0x654/0xd1c)  r6:00000520 r5:c277bae0 r4:c68f37c0
> > [<c0269d50>] (tcp_sendmsg+0x0/0xd1c) from [<c028ca9c>] (inet_sendmsg+0x64/0x70)
> > 
> > FWIW I had OOMs with the exact same backtrace on kirkwood platform
> > (512MB RAM), but sorry I don't have the full dump anymore.
> > 
> > I found a slow leaking process, and since I fixed that leak I now have
> > uptime better than 7 days, *but* there was definitely some memory left
> > when the OOM happened, so it appears to be related to fragmentation.
> 
> However, that's a side effect, not the cause - and a patch has been
> merged to fix that OOM - but that doesn't explain where most of the
> memory has gone!
> 
> I'm presently waiting for the machine to OOM again (it's probably going
> to be something like another month) at which point I'll grab the files
> people have been mentioning (/proc/meminfo, /proc/vmallocinfo,
> /proc/slabinfo etc.)

For those new to this report, this is a 3.12.6+ kernel, and I'm seeing
OOMs after a month or two of uptime.

Last night, it OOM'd severely again at around 5am... and rebooted soon
after so we've lost any hope of recovering anything useful from the
machine.

However, the new kernel re-ran the raid check, and...

md: data-check of RAID array md2
md: minimum _guaranteed_  speed: 1000 KB/sec/disk.
md: using maximum available idle IO bandwidth (but not more than 200000 KB/sec)
for data-check.
md: using 128k window, over a total of 4194688k.
md: delaying data-check of md3 until md2 has finished (they share one or more physical units)
md: delaying data-check of md4 until md2 has finished (they share one or more physical units)
md: delaying data-check of md3 until md2 has finished (they share one or more physical units)
md: delaying data-check of md5 until md2 has finished (they share one or more physical units)
md: delaying data-check of md3 until md2 has finished (they share one or more physical units)
md: delaying data-check of md4 until md2 has finished (they share one or more physical units)
md: delaying data-check of md6 until md2 has finished (they share one or more physical units)
md: delaying data-check of md4 until md2 has finished (they share one or more physical units)
md: delaying data-check of md3 until md2 has finished (they share one or more physical units)
md: delaying data-check of md5 until md2 has finished (they share one or more physical units)
md: md2: data-check done.
md: delaying data-check of md5 until md3 has finished (they share one or more physical units)
md: data-check of RAID array md3
md: minimum _guaranteed_  speed: 1000 KB/sec/disk.
md: using maximum available idle IO bandwidth (but not more than 200000 KB/sec)
for data-check.
md: using 128k window, over a total of 524544k.
md: delaying data-check of md4 until md3 has finished (they share one or more physical units)
md: delaying data-check of md6 until md3 has finished (they share one or more physical units)
kmemleak: 836 new suspected memory leaks (see /sys/kernel/debug/kmemleak)
md: md3: data-check done.
md: delaying data-check of md6 until md4 has finished (they share one or more physical units)
md: delaying data-check of md4 until md5 has finished (they share one or more physical units)
md: data-check of RAID array md5
md: minimum _guaranteed_  speed: 1000 KB/sec/disk.
md: using maximum available idle IO bandwidth (but not more than 200000 KB/sec)
for data-check.
md: using 128k window, over a total of 10486080k.
kmemleak: 2235 new suspected memory leaks (see /sys/kernel/debug/kmemleak)
md: md5: data-check done.
md: data-check of RAID array md4
md: minimum _guaranteed_  speed: 1000 KB/sec/disk.
md: using maximum available idle IO bandwidth (but not more than 200000 KB/sec)
for data-check.
md: using 128k window, over a total of 10486080k.
md: delaying data-check of md6 until md4 has finished (they share one or more physical units)
kmemleak: 1 new suspected memory leaks (see /sys/kernel/debug/kmemleak)
md: md4: data-check done.
md: data-check of RAID array md6
md: minimum _guaranteed_  speed: 1000 KB/sec/disk.
md: using maximum available idle IO bandwidth (but not more than 200000 KB/sec)
for data-check.
md: using 128k window, over a total of 10409472k.
kmemleak: 1 new suspected memory leaks (see /sys/kernel/debug/kmemleak)
kmemleak: 3 new suspected memory leaks (see /sys/kernel/debug/kmemleak)
md: md6: data-check done.
kmemleak: 1 new suspected memory leaks (see /sys/kernel/debug/kmemleak)

which totals 3077 of leaks.  So we have a memory leak.  Looking at
the kmemleak file:

unreferenced object 0xc3c3f880 (size 256):
  comm "md2_resync", pid 4680, jiffies 638245 (age 8615.570s)
  hex dump (first 32 bytes):
    00 00 00 00 00 00 00 00 00 00 00 00 01 00 00 f0  ................
    00 00 00 00 10 00 00 00 00 00 00 00 00 00 00 00  ................
  backtrace:
    [<c008d4f0>] __save_stack_trace+0x34/0x40
    [<c008d5f0>] create_object+0xf4/0x214
    [<c02da114>] kmemleak_alloc+0x3c/0x6c
    [<c008c0d4>] __kmalloc+0xd0/0x124
    [<c00bb124>] bio_alloc_bioset+0x4c/0x1a4
    [<c021206c>] r1buf_pool_alloc+0x40/0x148
    [<c0061160>] mempool_alloc+0x54/0xfc
    [<c0211938>] sync_request+0x168/0x85c
    [<c021addc>] md_do_sync+0x75c/0xbc0
    [<c021b594>] md_thread+0x138/0x154
    [<c0037b48>] kthread+0xb0/0xbc
    [<c0013190>] ret_from_fork+0x14/0x24
    [<ffffffff>] 0xffffffff

with 3077 of these in the debug file.  3075 are for "md2_resync" and
two are for "md4_resync".

/proc/slabinfo shows for this bucket:
kmalloc-256         3237   3450    256   15    1 : tunables  120   60    0 : slabdata    230    230      0

but this would only account for about 800kB of memory usage, which itself
is insignificant - so this is not the whole story.

It seems that this is the culpret for the allocations:
        for (j = pi->raid_disks ; j-- ; ) {
                bio = bio_kmalloc(gfp_flags, RESYNC_PAGES);

Since RESYNC_PAGES will be 64K/4K=16, each struct bio_vec is 12 bytes
(12 * 16 = 192) plus the size of struct bio, which would fall into this
bucket.

I don't see anything obvious - it looks like it isn't every raid check
which loses bios.  Not quite sure what to make of this right now.

-- 
FTTC broadband for 0.8mile line: now at 9.7Mbps down 460kbps up... slowly
improving, and getting towards what was expected from it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
