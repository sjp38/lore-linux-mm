Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id EE3886B002C
	for <linux-mm@kvack.org>; Thu,  9 Feb 2012 07:11:48 -0500 (EST)
Received: by wera13 with SMTP id a13so1474149wer.14
        for <linux-mm@kvack.org>; Thu, 09 Feb 2012 04:11:47 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120206090841.GF5938@suse.de>
References: <20120206090841.GF5938@suse.de>
Date: Thu, 9 Feb 2012 20:11:47 +0800
Message-ID: <CAJd=RBCUjp_=7rRGfHa+4M+F3s1c+zupXj7x+PGm=bstfVvxFg@mail.gmail.com>
Subject: Re: mm: compaction: Check for overlapping nodes during isolation for migration
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Feb 6, 2012 at 5:08 PM, Mel Gorman <mgorman@suse.de> wrote:
> When isolating pages for migration, migration starts at the start of a
> zone while the free scanner starts at the end of the zone. Migration
> avoids entering a new zone by never going beyond the free scanned.
> Unfortunately, in very rare cases nodes can overlap. When this happens,
> migration isolates pages without the LRU lock held, corrupting lists
> which will trigger errors in reclaim or during page free such as in the
> following oops
>
> [ 8739.994311] BUG: unable to handle kernel NULL pointer dereference at 0=
000000000000008
> [ 8739.994331] IP: [<ffffffff810f795c>] free_pcppages_bulk+0xcc/0x450
> [ 8739.994344] PGD 1dda554067 PUD 1e1cb58067 PMD 0
> [ 8739.994350] Oops: 0000 [#1] SMP
> [ 8739.994357] CPU 37
> [ 8739.994359] Modules linked in: veth(X) <SNIPPED>
> [ 8739.994457] Supported: Yes
> [ 8739.994461]
> [ 8739.994465] Pid: 17088, comm: memcg_process_s Tainted: G =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0X
> [ 8739.994477] RIP: 0010:[<ffffffff810f795c>] =C2=A0[<ffffffff810f795c>] =
free_pcppages_bulk+0xcc/0x450
> [ 8739.994483] RSP: 0000:ffff881c2926f7a8 =C2=A0EFLAGS: 00010082
> [ 8739.994488] RAX: 0000000000000010 RBX: 0000000000000000 RCX: ffff881e7=
f4546c8
> [ 8739.994491] RDX: ffff881e7f4546b0 RSI: 0000000000000000 RDI: 000000000=
0000167
> [ 8739.994498] RBP: 0000000000000000 R08: 0000000000000000 R09: 000000000=
0000000
> [ 8739.994502] R10: 0000000000000166 R11: ffffea0060ea0e50 R12: fffffffff=
fffffd8
> [ 8739.994506] R13: 0000000000000001 R14: ffff881c7ffd9e00 R15: 000000000=
0000000
> [ 8739.994511] FS: =C2=A000007f5072690700(0000) GS:ffff881e7f440000(0000)=
 knlGS:0000000000000000
> [ 8739.994517] CS: =C2=A00010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [ 8739.994522] CR2: 0000000000000008 CR3: 0000001e1f1f9000 CR4: 000000000=
00006e0
> [ 8739.994525] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 000000000=
0000000
> [ 8739.994530] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 000000000=
0000400
> [ 8739.994535] Process memcg_process_s (pid: 17088, threadinfo ffff881c29=
26e000, task ffff881c2926c0c0)
> [ 8739.994539] Stack:
> [ 8739.994541] =C2=A00000000000000000 ffff881e7f4546c8 0000000000000010 f=
fff881c7ffd9e60
> [ 8739.994557] =C2=A0ffff881e7f4546b0 0000001f814498ee 0000000000000000 0=
000001d81245255
> [ 8739.994565] =C2=A0ffff881e7f4546c0 ffffea005ecd2f40 ffff881e7f4546b0 0=
020000000200010
> [ 8739.994573] Call Trace:
> [ 8739.994590] =C2=A0[<ffffffff810f8bfe>] free_hot_cold_page+0x17e/0x1f0
> [ 8739.994600] =C2=A0[<ffffffff810f8ff0>] __pagevec_free+0x90/0xb0
> [ 8739.994610] =C2=A0[<ffffffff810fc08a>] release_pages+0x22a/0x260
> [ 8739.994617] =C2=A0[<ffffffff810fc1b3>] pagevec_lru_move_fn+0xf3/0x110
> [ 8739.994627] =C2=A0[<ffffffff81101e76>] putback_lru_page+0x66/0xe0
> [ 8739.994639] =C2=A0[<ffffffff8113fde6>] unmap_and_move+0x156/0x180
> [ 8739.994647] =C2=A0[<ffffffff8113feae>] migrate_pages+0x9e/0x1b0
> [ 8739.994656] =C2=A0[<ffffffff81136313>] compact_zone+0x1f3/0x2f0
> [ 8739.994665] =C2=A0[<ffffffff81136672>] compact_zone_order+0xa2/0xe0
> [ 8739.994672] =C2=A0[<ffffffff8113678f>] try_to_compact_pages+0xdf/0x110
> [ 8739.994678] =C2=A0[<ffffffff810f7eae>] __alloc_pages_direct_compact+0x=
ee/0x1c0
> [ 8739.994686] =C2=A0[<ffffffff810f82f0>] __alloc_pages_slowpath+0x370/0x=
830
> [ 8739.994694] =C2=A0[<ffffffff810f8961>] __alloc_pages_nodemask+0x1b1/0x=
1c0
> [ 8739.994701] =C2=A0[<ffffffff81134d2b>] alloc_pages_vma+0x9b/0x160
> [ 8739.994712] =C2=A0[<ffffffff811449a0>] do_huge_pmd_anonymous_page+0x16=
0/0x270
> [ 8739.994725] =C2=A0[<ffffffff81444ba7>] do_page_fault+0x207/0x4c0
> [ 8739.994735] =C2=A0[<ffffffff814418e5>] page_fault+0x25/0x30
> [ 8739.994748] =C2=A0[<0000000000400997>] 0x400996
>
> The "X" in the taint flag means that external modules were loaded but
> but is unrelated to the bug triggering. The real problem was because
> the PFN layout looks like this
>
> [ =C2=A0 =C2=A00.000000] Zone PFN ranges:
> [ =C2=A0 =C2=A00.000000] =C2=A0 DMA =C2=A0 =C2=A0 =C2=A00x00000010 -> 0x0=
0001000
> [ =C2=A0 =C2=A00.000000] =C2=A0 DMA32 =C2=A0 =C2=A00x00001000 -> 0x001000=
00
> [ =C2=A0 =C2=A00.000000] =C2=A0 Normal =C2=A0 0x00100000 -> 0x01e80000
> [ =C2=A0 =C2=A00.000000] Movable zone start PFN for each node
> [ =C2=A0 =C2=A00.000000] early_node_map[14] active PFN ranges
> [ =C2=A0 =C2=A00.000000] =C2=A0 =C2=A0 0: 0x00000010 -> 0x0000009b
> [ =C2=A0 =C2=A00.000000] =C2=A0 =C2=A0 0: 0x00000100 -> 0x0007a1ec
> [ =C2=A0 =C2=A00.000000] =C2=A0 =C2=A0 0: 0x0007a354 -> 0x0007a379
> [ =C2=A0 =C2=A00.000000] =C2=A0 =C2=A0 0: 0x0007f7ff -> 0x0007f800
> [ =C2=A0 =C2=A00.000000] =C2=A0 =C2=A0 0: 0x00100000 -> 0x00680000
> [ =C2=A0 =C2=A00.000000] =C2=A0 =C2=A0 1: 0x00680000 -> 0x00e80000
> [ =C2=A0 =C2=A00.000000] =C2=A0 =C2=A0 0: 0x00e80000 -> 0x01080000
> [ =C2=A0 =C2=A00.000000] =C2=A0 =C2=A0 1: 0x01080000 -> 0x01280000
> [ =C2=A0 =C2=A00.000000] =C2=A0 =C2=A0 0: 0x01280000 -> 0x01480000
> [ =C2=A0 =C2=A00.000000] =C2=A0 =C2=A0 1: 0x01480000 -> 0x01680000
> [ =C2=A0 =C2=A00.000000] =C2=A0 =C2=A0 0: 0x01680000 -> 0x01880000
> [ =C2=A0 =C2=A00.000000] =C2=A0 =C2=A0 1: 0x01880000 -> 0x01a80000
> [ =C2=A0 =C2=A00.000000] =C2=A0 =C2=A0 0: 0x01a80000 -> 0x01c80000
> [ =C2=A0 =C2=A00.000000] =C2=A0 =C2=A0 1: 0x01c80000 -> 0x01e80000
>
> The fix is straight-forward. isolate_migratepages() has to make a
> similar check to isolate_freepage to ensure that it never isolates
> pages from a zone it does not hold the LRU lock for.
>
> This was discovered in a 3.0-based kernel but it affects 3.1.x, 3.2.x
> and current mainline.
>
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> Cc: <stable@vger.kernel.org>

Acked-by: Hillf Danton <dhillf@gmail.com>

> ---
> =C2=A0mm/compaction.c | =C2=A0 11 ++++++++++-
> =C2=A01 files changed, 10 insertions(+), 1 deletions(-)
>
> diff --git a/mm/compaction.c b/mm/compaction.c
> index bd6e739..6042644 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -330,8 +330,17 @@ static isolate_migrate_t isolate_migratepages(struct=
 zone *zone,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0continue;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0nr_scanned++;
>
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Get the page and sk=
ip if free */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* Get the page a=
nd ensure the page is within the same zone.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* See the commen=
t in isolate_freepages about overlapping
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* nodes. It is d=
eliberate that the new zone lock is not taken
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* as memory comp=
action should not move pages between nodes.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0page =3D pfn_to_pa=
ge(low_pfn);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (page_zone(page) !=
=3D zone)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 continue;
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Skip if free */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (PageBuddy(page=
))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0continue;
>
>
> --
> Mel Gorman
> SUSE Labs
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" i=
n
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =C2=A0http://www.tux.org/lkml/
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
