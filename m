Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f51.google.com (mail-ee0-f51.google.com [74.125.83.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9E2DD6B0082
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 12:23:36 -0400 (EDT)
Received: by mail-ee0-f51.google.com with SMTP id c13so9072871eek.38
        for <linux-mm@kvack.org>; Wed, 16 Apr 2014 09:23:35 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id 43si30940444eei.55.2014.04.16.09.23.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 16 Apr 2014 09:23:34 -0700 (PDT)
Date: Wed, 16 Apr 2014 12:23:26 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [3.14+] kernel BUG at mm/filemap.c:1347!
Message-ID: <20140416162326.GA4439@cmpxchg.org>
References: <20140414202059.GA11170@redhat.com>
 <alpine.LSU.2.11.1404141952230.2980@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1404141952230.2980@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

Hi,

On Mon, Apr 14, 2014 at 08:29:09PM -0700, Hugh Dickins wrote:
> On Mon, 14 Apr 2014, Dave Jones wrote:
> 
> > git tree from yesterday afternoon sometime, before Linus cut .15-rc1
> > 
> > kernel BUG at mm/filemap.c:1347!
> > invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> > Modules linked in: 8021q garp bridge stp dlci snd_seq_dummy tun fuse rfcomm ipt_ULOG nfnetlink llc2 af_key scsi_transport_iscsi hidp can_raw bnep can_bcm nfc caif_socket caif af_802154 ieee802154 phonet af_rxrpc can pppoe pppox ppp_generic slhc irda crc_ccitt rds rose x25 atm netrom appletalk ipx p8023 psnap p8022 llc ax25 cfg80211 coretemp hwmon x86_pkg_temp_thermal kvm_intel kvm snd_hda_codec_realtek snd_hda_codec_hdmi snd_hda_codec_generic snd_hda_intel snd_hda_controller btusb snd_hda_codec snd_hwdep bluetooth snd_seq snd_seq_device snd_pcm xfs e1000e snd_timer crct10dif_pclmul snd crc32c_intel libcrc32c ghash_clmulni_intel ptp 6lowpan_iphc rfkill usb_debug shpchp soundcore pps_core microcode pcspkr serio_raw
> > CPU: 1 PID: 5440 Comm: trinity-c16 Not tainted 3.14.0+ #187
> > task: ffff8801efe79ae0 ti: ffff8802082e4000 task.ti: ffff8802082e4000
> > RIP: 0010:[<ffffffffb815aeab>]  [<ffffffffb815aeab>] find_get_pages_tag+0x1cb/0x220
> > RSP: 0000:ffff8802082e5c70  EFLAGS: 00010246
> > RAX: 7fffffffffffffff RBX: 000000000000000e RCX: 000000000000001d
> > RDX: 000000000000001d RSI: ffff880041c7d4f0 RDI: 0000000000000000
> > RBP: ffff8802082e5cd0 R08: 0000000000002600 R09: ffffea00075104dc
> > R10: 0000000000000100 R11: 0000000000000228 R12: ffff8802082e5d08
> > R13: 000000000000000a R14: 0000000000000101 R15: ffff8802082e5d20
> > FS:  00007f97c44f2740(0000) GS:ffff880244200000(0000) knlGS:0000000000000000
> > CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > CR2: 000000000166d000 CR3: 000000016515d000 CR4: 00000000001407e0
> > DR0: 00000000015e9000 DR1: 0000000000842000 DR2: 0000000001da3000
> > DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600
> > Stack:
> >  ffffffffb815ad16 0000000000000000 ffff880067079da8 0000000000002681
> >  00000000000026c0 7fffffffffffffff 000000004110b5bc ffff8802082e5d10
> >  ffffea0007477a80 0000000000000000 ffff8802082e5d90 0000000000002fd6
> > Call Trace:
> >  [<ffffffffb815ad16>] ? find_get_pages_tag+0x36/0x220
> >  [<ffffffffb8168511>] pagevec_lookup_tag+0x21/0x30
> >  [<ffffffffb81595de>] filemap_fdatawait_range+0xbe/0x1e0
> >  [<ffffffffb8159727>] filemap_fdatawait+0x27/0x30
> >  [<ffffffffb81f2fa4>] sync_inodes_sb+0x204/0x2a0
> >  [<ffffffffb874d98f>] ? wait_for_completion+0xff/0x130
> >  [<ffffffffb81fa5b0>] ? vfs_fsync+0x40/0x40
> >  [<ffffffffb81fa5c9>] sync_inodes_one_sb+0x19/0x20
> >  [<ffffffffb81caab2>] iterate_supers+0xb2/0x110
> >  [<ffffffffb81fa864>] sys_sync+0x44/0xb0
> >  [<ffffffffb875c4a9>] ia32_do_call+0x13/0x13
> > Code: 89 c1 85 c9 0f 84 ee fe ff ff 8d 51 01 89 c8 f0 41 0f b1 11 39 c1 0f 84 20 ff ff ff eb e2 66 90 0f 0b 83 e7 01 0f 85 af fe ff ff <0f> 0b 0f 1f 00 e8 ab 23 f1 ff 48 89 75 a8 e8 82 dd 00 00 48 8b 
> > RIP  [<ffffffffb815aeab>] find_get_pages_tag+0x1cb/0x220
> >  RSP <ffff8802082e5c70>
> > ---[ end trace ea01792c1c61cb22 ]---
> > 
> > 
> > 
> > 1343                         /*
> > 1344                          * This function is never used on a shmem/tmpfs
> > 1345                          * mapping, so a swap entry won't be found here.
> > 1346                          */
> > 1347                         BUG();
> 
> Thanks for finding that, Dave.
> 
> Yes, it was me who put in that "shmem/tmpfs" comment and BUG();
> but it's Hannes (Cc'ed) whom I'll blame for not removing the comment,
> in extending the use of radix_tree exceptional entries way beyond
> shmem/tmpfs in v3.15-rc1.  (Of course I should have noticed.)
> 
> As to the BUG(): at first I was aghast that it should have escaped
> all our mmotm/next testing of the last couple of months; but now
> realize that it is truly surprising for a PAGECACHE_TAG_WRITEBACK
> (and probably any other PAGECACHE_TAG_*) to appear on an exceptional
> entry.
> 
> I expect it comes down to an occasional race in RCU lookup of the
> radix_tree: lacking absolute synchronization, we might sometimes
> catch an exceptional entry, with the tag which really belongs
> with the unexceptional entry which was there an instant before.

Indeed, there is a fairly large window for this to happen because tags
are looked up in bulk and stored in the iterator.  There is plenty of
time for page reclaim to take out a page that was already seen tagged.

> (That's actually one of the reasons why I introduced exceptional
> entries, rather than tagging entries as exceptional: it's easier to
> synchonize a word with a bit in, than a word with a bit elsewhere.)
> 
> Or I may be misreading it: whatever, Hannes will have a much surer
> grasp of what to do about it.  It may be as simple as skipping over
> any exceptional entry in find_get_pages_tag() - that would be easy
> to provide as a quick fix if this BUG() starts to get in people's
> way.  But I'd much prefer Hannes to consider the races, whether
> there's more to worry about, and provide a more thoughtful fix.
> 
> (There are a few other "shmem/tmpfs" comments in mm/ that I put on
> exceptional entries in v3.1: again, I'd prefer Hannes to check
> through those, as he'll know best whether just to delete the
> comments now, or rewrite them, or update the code a little.)

All of the above.  Prepare for a roundhouse kick of amendments to
0cd6144aadd2 ("mm + fs: prepare for non-page entries in page cache
radix trees")!

Dave, thanks for your report, and Hugh, thanks for your input.  Would
you guys be okay with the following?

---
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] mm: filemap: update find_get_pages_tag() to deal with shadow
 entries

Dave Jones reports the following crash when find_get_pages_tag() runs
into an exceptional entry:

kernel BUG at mm/filemap.c:1347!
RIP: 0010:[<ffffffffb815aeab>]  [<ffffffffb815aeab>] find_get_pages_tag+0x1cb/0x220
Call Trace:
 [<ffffffffb815ad16>] ? find_get_pages_tag+0x36/0x220
 [<ffffffffb8168511>] pagevec_lookup_tag+0x21/0x30
 [<ffffffffb81595de>] filemap_fdatawait_range+0xbe/0x1e0
 [<ffffffffb8159727>] filemap_fdatawait+0x27/0x30
 [<ffffffffb81f2fa4>] sync_inodes_sb+0x204/0x2a0
 [<ffffffffb874d98f>] ? wait_for_completion+0xff/0x130
 [<ffffffffb81fa5b0>] ? vfs_fsync+0x40/0x40
 [<ffffffffb81fa5c9>] sync_inodes_one_sb+0x19/0x20
 [<ffffffffb81caab2>] iterate_supers+0xb2/0x110
 [<ffffffffb81fa864>] sys_sync+0x44/0xb0
 [<ffffffffb875c4a9>] ia32_do_call+0x13/0x13

1343                         /*
1344                          * This function is never used on a shmem/tmpfs
1345                          * mapping, so a swap entry won't be found here.
1346                          */
1347                         BUG();

After 0cd6144aadd2 ("mm + fs: prepare for non-page entries in page
cache radix trees") this comment and BUG() are out of date because
exceptional entries can now appear in all mappings - as shadows of
recently evicted pages.

However, as Hugh Dickins notes,

  "it is truly surprising for a PAGECACHE_TAG_WRITEBACK (and probably
   any other PAGECACHE_TAG_*) to appear on an exceptional entry.

   I expect it comes down to an occasional race in RCU lookup of the
   radix_tree: lacking absolute synchronization, we might sometimes
   catch an exceptional entry, with the tag which really belongs with
   the unexceptional entry which was there an instant before."

And indeed, not only is the tree walk lockless, the tags are also read
in chunks, one radix tree node at a time.  There is plenty of time for
page reclaim to swoop in and replace a page that was already looked up
as tagged with a shadow entry.

Remove the BUG() and update the comment.  While reviewing all other
lookup sites for whether they properly deal with shadow entries of
evicted pages, update all the comments and fix memcg file charge
moving to not miss shmem/tmpfs swapcache pages.

Reported-by: Dave Jones <davej@redhat.com>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Fixes: 0cd6144aadd2 ("mm + fs: prepare for non-page entries in page cache radix trees")
---
 mm/filemap.c    | 49 ++++++++++++++++++++++++++++---------------------
 mm/memcontrol.c | 20 ++++++++++++--------
 mm/truncate.c   |  8 --------
 3 files changed, 40 insertions(+), 37 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index a82fbe4c9e8e..d92c437a79c4 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -906,8 +906,8 @@ EXPORT_SYMBOL(page_cache_prev_hole);
  * Looks up the page cache slot at @mapping & @offset.  If there is a
  * page cache page, it is returned with an increased refcount.
  *
- * If the slot holds a shadow entry of a previously evicted page, it
- * is returned.
+ * If the slot holds a shadow entry of a previously evicted page, or a
+ * swap entry from shmem/tmpfs, it is returned.
  *
  * Otherwise, %NULL is returned.
  */
@@ -928,9 +928,9 @@ repeat:
 			if (radix_tree_deref_retry(page))
 				goto repeat;
 			/*
-			 * Otherwise, shmem/tmpfs must be storing a swap entry
-			 * here as an exceptional entry: so return it without
-			 * attempting to raise page count.
+			 * A shadow entry of a recently evicted page,
+			 * or a swap entry from shmem/tmpfs.  Return
+			 * it without attempting to raise page count.
 			 */
 			goto out;
 		}
@@ -983,8 +983,8 @@ EXPORT_SYMBOL(find_get_page);
  * page cache page, it is returned locked and with an increased
  * refcount.
  *
- * If the slot holds a shadow entry of a previously evicted page, it
- * is returned.
+ * If the slot holds a shadow entry of a previously evicted page, or a
+ * swap entry from shmem/tmpfs, it is returned.
  *
  * Otherwise, %NULL is returned.
  *
@@ -1099,8 +1099,8 @@ EXPORT_SYMBOL(find_or_create_page);
  * with ascending indexes.  There may be holes in the indices due to
  * not-present pages.
  *
- * Any shadow entries of evicted pages are included in the returned
- * array.
+ * Any shadow entries of evicted pages, or swap entries from
+ * shmem/tmpfs, are included in the returned array.
  *
  * find_get_entries() returns the number of pages and shadow entries
  * which were found.
@@ -1128,9 +1128,9 @@ repeat:
 			if (radix_tree_deref_retry(page))
 				goto restart;
 			/*
-			 * Otherwise, we must be storing a swap entry
-			 * here as an exceptional entry: so return it
-			 * without attempting to raise page count.
+			 * A shadow entry of a recently evicted page,
+			 * or a swap entry from shmem/tmpfs.  Return
+			 * it without attempting to raise page count.
 			 */
 			goto export;
 		}
@@ -1198,9 +1198,9 @@ repeat:
 				goto restart;
 			}
 			/*
-			 * Otherwise, shmem/tmpfs must be storing a swap entry
-			 * here as an exceptional entry: so skip over it -
-			 * we only reach this from invalidate_mapping_pages().
+			 * A shadow entry of a recently evicted page,
+			 * or a swap entry from shmem/tmpfs.  Skip
+			 * over it.
 			 */
 			continue;
 		}
@@ -1265,9 +1265,9 @@ repeat:
 				goto restart;
 			}
 			/*
-			 * Otherwise, shmem/tmpfs must be storing a swap entry
-			 * here as an exceptional entry: so stop looking for
-			 * contiguous pages.
+			 * A shadow entry of a recently evicted page,
+			 * or a swap entry from shmem/tmpfs.  Stop
+			 * looking for contiguous pages.
 			 */
 			break;
 		}
@@ -1341,10 +1341,17 @@ repeat:
 				goto restart;
 			}
 			/*
-			 * This function is never used on a shmem/tmpfs
-			 * mapping, so a swap entry won't be found here.
+			 * A shadow entry of a recently evicted page.
+			 *
+			 * Those entries should never be tagged, but
+			 * this tree walk is lockless and the tags are
+			 * looked up in bulk, one radix tree node at a
+			 * time, so there is a sizable window for page
+			 * reclaim to evict a page we saw tagged.
+			 *
+			 * Skip over it.
 			 */
-			BUG();
+			continue;
 		}
 
 		if (!page_cache_get_speculative(page))
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 29501f040568..c47dffdcb246 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -6686,16 +6686,20 @@ static struct page *mc_handle_file_pte(struct vm_area_struct *vma,
 		pgoff = pte_to_pgoff(ptent);
 
 	/* page is moved even if it's not RSS of this task(page-faulted). */
-	page = find_get_page(mapping, pgoff);
-
 #ifdef CONFIG_SWAP
 	/* shmem/tmpfs may report page out on swap: account for that too. */
-	if (radix_tree_exceptional_entry(page)) {
-		swp_entry_t swap = radix_to_swp_entry(page);
-		if (do_swap_account)
-			*entry = swap;
-		page = find_get_page(swap_address_space(swap), swap.val);
-	}
+	if (shmem_mapping(mapping)) {
+		page = find_get_entry(mapping, pgoff);
+		if (radix_tree_exceptional_entry(page)) {
+			swp_entry_t swp = radix_to_swp_entry(page);
+			if (do_swap_account)
+				*entry = swp;
+			page = find_get_page(swap_address_space(swp), swp.val);
+		}
+	} else
+		page = find_get_page(mapping, pgoff);
+#else
+	page = find_get_page(mapping, pgoff);
 #endif
 	return page;
 }
diff --git a/mm/truncate.c b/mm/truncate.c
index e5cc39ab0751..6a78c814bebf 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -484,14 +484,6 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
 	unsigned long count = 0;
 	int i;
 
-	/*
-	 * Note: this function may get called on a shmem/tmpfs mapping:
-	 * pagevec_lookup() might then return 0 prematurely (because it
-	 * got a gangful of swap entries); but it's hardly worth worrying
-	 * about - it can rarely have anything to free from such a mapping
-	 * (most pages are dirty), and already skips over any difficulties.
-	 */
-
 	pagevec_init(&pvec, 0);
 	while (index <= end && pagevec_lookup_entries(&pvec, mapping, index,
 			min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1,
-- 
1.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
