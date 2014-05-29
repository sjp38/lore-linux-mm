Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id 61A936B0035
	for <linux-mm@kvack.org>; Thu, 29 May 2014 01:10:12 -0400 (EDT)
Received: by mail-pb0-f51.google.com with SMTP id ma3so12492235pbc.10
        for <linux-mm@kvack.org>; Wed, 28 May 2014 22:10:12 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id oq10si26852193pac.48.2014.05.28.22.10.10
        for <linux-mm@kvack.org>;
        Wed, 28 May 2014 22:10:11 -0700 (PDT)
Date: Thu, 29 May 2014 14:10:42 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC 2/2] x86_64: expand kernel stack to 16K
Message-ID: <20140529051042.GF10092@bbox>
References: <1401260039-18189-1-git-send-email-minchan@kernel.org>
 <1401260039-18189-2-git-send-email-minchan@kernel.org>
 <CA+55aFxXdc22dirnE49UbQP_2s2vLQpjQFL+NptuyK7Xry6c=g@mail.gmail.com>
 <20140529034625.GB10092@bbox>
 <CA+55aFyoT1xuM-HsZ4GKt=FfDYs76oD7U-RBkZn-2PErj6ZZVw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFyoT1xuM-HsZ4GKt=FfDYs76oD7U-RBkZn-2PErj6ZZVw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Steven Rostedt <rostedt@goodmis.org>

On Wed, May 28, 2014 at 09:13:15PM -0700, Linus Torvalds wrote:
> On Wed, May 28, 2014 at 8:46 PM, Minchan Kim <minchan@kernel.org> wrote:
> >
> > Yes. For example, with mark __alloc_pages_slowpath noinline_for_stack,
> > we can reduce 176byte.
> 
> Well, but it will then call that __alloc_pages_slowpath() function,
> which has a 176-byte stack frame.. Plus the call frame.
> 
> Now, that only triggers for when the initial "__GFP_HARDWALL" case
> fails, but that's exactly what happens when we do need to do direct
> reclaim.
> 
> That said, I *have* seen cases where the gcc spill code got really
> confused, and simplifying the function (by not inlining excessively)
> actually causes a truly smaller stack overall, despite the actual call
> frames etc.  But I think the gcc people fixed the kinds of things that
> caused *that* kind of stack slot explosion.
> 
> And avoiding inlining can end up resulting in less stack, if the
> really deep parts don't happen to go through that function that got
> inlined (ie any call chain that wouldn't have gone through that
> "slowpath" function at all).
> 
> But in this case, __alloc_pages_slowpath() is where we end up doing
> the actual direct reclaim anyway, so just uninlining doesn't actually
> help. Although it would probably make the asm code more readable ;)

Indeed. :(

Actually I found there are other places to opitmize out.
For example, we can unline try_preserve_large_page for __change_page_attr_set_clr.
Although I'm not familiar with that part, I guess large page would be rare
so we could save 112-byte.
    
    before:
    
    ffffffff81042330 <__change_page_attr_set_clr>:
    ffffffff81042330:	e8 4b da 6a 00       	callq  ffffffff816efd80 <__entry_text_start>
    ffffffff81042335:	55                   	push   %rbp
    ffffffff81042336:	48 89 e5             	mov    %rsp,%rbp
    ffffffff81042339:	41 57                	push   %r15
    ffffffff8104233b:	41 56                	push   %r14
    ffffffff8104233d:	41 55                	push   %r13
    ffffffff8104233f:	41 54                	push   %r12
    ffffffff81042341:	49 89 fc             	mov    %rdi,%r12
    ffffffff81042344:	53                   	push   %rbx
    ffffffff81042345:	48 81 ec f8 00 00 00 	sub    $0xf8,%rsp
    ffffffff8104234c:	8b 47 20             	mov    0x20(%rdi),%eax
    ffffffff8104234f:	89 b5 50 ff ff ff    	mov    %esi,-0xb0(%rbp)
    ffffffff81042355:	85 c0                	test   %eax,%eax
    ffffffff81042357:	89 85 5c ff ff ff    	mov    %eax,-0xa4(%rbp)
    ffffffff8104235d:	0f 84 8c 06 00 00    	je     ffffffff810429ef <__change_page_attr_set_clr+0x6bf>
    
    after:
    
    ffffffff81042740 <__change_page_attr_set_clr>:
    ffffffff81042740:	e8 bb d5 6a 00       	callq  ffffffff816efd00 <__entry_text_start>
    ffffffff81042745:	55                   	push   %rbp
    ffffffff81042746:	48 89 e5             	mov    %rsp,%rbp
    ffffffff81042749:	41 57                	push   %r15
    ffffffff8104274b:	41 56                	push   %r14
    ffffffff8104274d:	41 55                	push   %r13
    ffffffff8104274f:	49 89 fd             	mov    %rdi,%r13
    ffffffff81042752:	41 54                	push   %r12
    ffffffff81042754:	53                   	push   %rbx
    ffffffff81042755:	48 81 ec 88 00 00 00 	sub    $0x88,%rsp
    ffffffff8104275c:	8b 47 20             	mov    0x20(%rdi),%eax
    ffffffff8104275f:	89 b5 70 ff ff ff    	mov    %esi,-0x90(%rbp)
    ffffffff81042765:	85 c0                	test   %eax,%eax
    ffffffff81042767:	89 85 74 ff ff ff    	mov    %eax,-0x8c(%rbp)
    ffffffff8104276d:	0f 84 cb 02 00 00    	je     ffffffff81042a3e <__change_page_attr_set_clr+0x2fe>
    

And below patch saves 96-byte from shrink_lruvec.

That would be not all and I am not saying optimization of every functions of VM
is way to go but just want to notice we have rooms to optimize it out.
I will wait more discussions and happy to test it(I can reproduce it in 1~2 hour
if I have a luck)

Thanks!
    
    ffffffff8115b560 <shrink_lruvec>:
    ffffffff8115b560:	e8 db 46 59 00       	callq  ffffffff816efc40 <__entry_text_start>
    ffffffff8115b565:	55                   	push   %rbp
    ffffffff8115b566:	65 48 8b 04 25 40 ba 	mov    %gs:0xba40,%rax
    ffffffff8115b56d:	00 00
    ffffffff8115b56f:	48 89 e5             	mov    %rsp,%rbp
    ffffffff8115b572:	41 57                	push   %r15
    ffffffff8115b574:	41 56                	push   %r14
    ffffffff8115b576:	45 31 f6             	xor    %r14d,%r14d
    ffffffff8115b579:	41 55                	push   %r13
    ffffffff8115b57b:	49 89 fd             	mov    %rdi,%r13
    ffffffff8115b57e:	41 54                	push   %r12
    ffffffff8115b580:	49 89 f4             	mov    %rsi,%r12
    ffffffff8115b583:	49 83 c4 34          	add    $0x34,%r12
    ffffffff8115b587:	53                   	push   %rbx
    ffffffff8115b588:	48 8d 9f c8 fa ff ff 	lea    -0x538(%rdi),%rbx
    ffffffff8115b58f:	48 81 ec f8 00 00 00 	sub    $0xf8,%rsp
    ffffffff8115b596:	f6 40 16 04          	testb  $0x4,0x16(%rax)
    
    after
    
    ffffffff8115b870 <shrink_lruvec>:
    ffffffff8115b870:	e8 8b 43 59 00       	callq  ffffffff816efc00 <__entry_text_start>
    ffffffff8115b875:	55                   	push   %rbp
    ffffffff8115b876:	48 8d 56 34          	lea    0x34(%rsi),%rdx
    ffffffff8115b87a:	48 89 e5             	mov    %rsp,%rbp
    ffffffff8115b87d:	41 57                	push   %r15
    ffffffff8115b87f:	41 bf 20 00 00 00    	mov    $0x20,%r15d
    ffffffff8115b885:	48 8d 4d 90          	lea    -0x70(%rbp),%rcx
    ffffffff8115b889:	41 56                	push   %r14
    ffffffff8115b88b:	49 89 f6             	mov    %rsi,%r14
    ffffffff8115b88e:	48 8d 76 2c          	lea    0x2c(%rsi),%rsi
    ffffffff8115b892:	41 55                	push   %r13
    ffffffff8115b894:	49 89 fd             	mov    %rdi,%r13
    ffffffff8115b897:	41 54                	push   %r12
    ffffffff8115b899:	45 31 e4             	xor    %r12d,%r12d
    ffffffff8115b89c:	53                   	push   %rbx
    ffffffff8115b89d:	48 81 ec 98 00 00 00 	sub    $0x98,%rsp
    ffffffff8115b8a4:	e8 47 df ff ff       	callq  ffffffff811597f0 <get_scan_count.isra.60>
    ffffffff8115b8a9:	48 8b 45 90          	mov    -0x70(%rbp),%rax

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 9b61b9bf81ac..574f9ce838b3 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -165,12 +165,14 @@ enum lru_list {
 	LRU_INACTIVE_FILE = LRU_BASE + LRU_FILE,
 	LRU_ACTIVE_FILE = LRU_BASE + LRU_FILE + LRU_ACTIVE,
 	LRU_UNEVICTABLE,
+	NR_EVICTABLE_LRU_LISTS = LRU_UNEVICTABLE,
 	NR_LRU_LISTS
 };
 
 #define for_each_lru(lru) for (lru = 0; lru < NR_LRU_LISTS; lru++)
 
-#define for_each_evictable_lru(lru) for (lru = 0; lru <= LRU_ACTIVE_FILE; lru++)
+#define for_each_evictable_lru(lru) for (lru = 0; \
+			lru < NR_EVICTABLE_LRU_LISTS; lru++)
 
 static inline int is_file_lru(enum lru_list lru)
 {
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 65cb7758dd09..bb330d1b76ae 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1839,8 +1839,8 @@ enum scan_balance {
  * nr[0] = anon inactive pages to scan; nr[1] = anon active pages to scan
  * nr[2] = file inactive pages to scan; nr[3] = file active pages to scan
  */
-static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
-			   unsigned long *nr)
+static noinline_for_stack void get_scan_count(struct lruvec *lruvec,
+			struct scan_control *sc, unsigned long *nr)
 {
 	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
 	u64 fraction[2];
@@ -2012,12 +2012,11 @@ out:
  */
 static void shrink_lruvec(struct lruvec *lruvec, struct scan_control *sc)
 {
-	unsigned long nr[NR_LRU_LISTS];
-	unsigned long targets[NR_LRU_LISTS];
+	unsigned long nr[NR_EVICTABLE_LRU_LISTS];
+	unsigned long targets[NR_EVICTABLE_LRU_LISTS];
 	unsigned long nr_to_scan;
 	enum lru_list lru;
 	unsigned long nr_reclaimed = 0;
-	unsigned long nr_to_reclaim = sc->nr_to_reclaim;
 	struct blk_plug plug;
 	bool scan_adjusted = false;
 
@@ -2042,7 +2041,7 @@ static void shrink_lruvec(struct lruvec *lruvec, struct scan_control *sc)
 			}
 		}
 
-		if (nr_reclaimed < nr_to_reclaim || scan_adjusted)
+		if (nr_reclaimed < sc->nr_to_reclaim || scan_adjusted)
 			continue;
 
 		/*


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
