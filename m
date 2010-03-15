Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id BF1426B01A0
	for <linux-mm@kvack.org>; Mon, 15 Mar 2010 01:38:04 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2F5c2uk013280
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 15 Mar 2010 14:38:02 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id DEE9945DE4D
	for <linux-mm@kvack.org>; Mon, 15 Mar 2010 14:38:01 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A3A9345DE79
	for <linux-mm@kvack.org>; Mon, 15 Mar 2010 14:38:01 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6DB43E18003
	for <linux-mm@kvack.org>; Mon, 15 Mar 2010 14:38:01 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 088AB1DB8037
	for <linux-mm@kvack.org>; Mon, 15 Mar 2010 14:38:01 +0900 (JST)
Date: Mon, 15 Mar 2010 14:34:20 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 02/11] mm,migration: Do not try to migrate unmapped
 anonymous pages
Message-Id: <20100315143420.6ec3bdf9.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <28c262361003141728g4aa40901hb040144c5a4aeeed@mail.gmail.com>
References: <1268412087-13536-1-git-send-email-mel@csn.ul.ie>
	<1268412087-13536-3-git-send-email-mel@csn.ul.ie>
	<28c262361003141728g4aa40901hb040144c5a4aeeed@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 15 Mar 2010 09:28:08 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> Hi, Mel.
> On Sat, Mar 13, 2010 at 1:41 AM, Mel Gorman <mel@csn.ul.ie> wrote:
> > rmap_walk_anon() was triggering errors in memory compaction that looks like
> > use-after-free errors in anon_vma. The problem appears to be that between
> > the page being isolated from the LRU and rcu_read_lock() being taken, the
> > mapcount of the page dropped to 0 and the anon_vma was freed. This patch
> > skips the migration of anon pages that are not mapped by anyone.
> >
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > Acked-by: Rik van Riel <riel@redhat.com>
> > ---
> > A mm/migrate.c | A  10 ++++++++++
> > A 1 files changed, 10 insertions(+), 0 deletions(-)
> >
> > diff --git a/mm/migrate.c b/mm/migrate.c
> > index 98eaaf2..3c491e3 100644
> > --- a/mm/migrate.c
> > +++ b/mm/migrate.c
> > @@ -602,6 +602,16 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
> > A  A  A  A  * just care Anon page here.
> > A  A  A  A  */
> > A  A  A  A if (PageAnon(page)) {
> > + A  A  A  A  A  A  A  /*
> > + A  A  A  A  A  A  A  A * If the page has no mappings any more, just bail. An
> > + A  A  A  A  A  A  A  A * unmapped anon page is likely to be freed soon but worse,
> > + A  A  A  A  A  A  A  A * it's possible its anon_vma disappeared between when
> > + A  A  A  A  A  A  A  A * the page was isolated and when we reached here while
> > + A  A  A  A  A  A  A  A * the RCU lock was not held
> > + A  A  A  A  A  A  A  A */
> > + A  A  A  A  A  A  A  if (!page_mapcount(page))
> 
> As looking code about mapcount of page, I got confused.
> I think mapcount of page is protected by pte lock.
> But I can't find pte lock in unmap_and_move.
There is no pte_lock.

> If I am right, what protects race between this condition check and
> rcu_read_lock?
> This patch makes race window very small but It can't remove race totally.
> 
> I think I am missing something.
> Pz, point me out. :)
> 

Hmm. This is my understanding of old story.

At migration.
  1. we increase page_count().
  2. isolate it from LRU.
  3. call try_to_unmap() under rcu_read_lock(). Then, 
  4. replace pte with swp_entry_t made by PFN. under pte_lock.
  5. do migarate 
  6. remap new pages. under pte_lock()>
  7. release rcu_read_lock().

Here, we don't care whether page->mapping holds valid anon_vma or not.

Assume a racy threads which calls zap_pte_range() (or some other)

a) When the thread finds valid pte under pte_lock and successfully call
   page_remove_rmap().
   In this case, migration thread finds try_to_unmap doesn't unmap any pte.
   Then, at 6, remap pte will not work.
b) When the thread finds migrateion PTE(as swap entry) in zap_page_range().
   In this case, migration doesn't find migrateion PTE and remap fails.

Why rcu_read_lock() is necessary..
 - When page_mapcount() goes to 0, we shouldn't trust page->mapping is valid.
 - Possible cases are
	i) anon_vma (= page->mapping) is freed and used for other object.
 	ii) anon_vma (= page->mapping) is freed
	iii) anon_vma (= page->mapping) is freed and used as anon_vma again.

Here, anon_vma_cachep is created  by SLAB_DESTROY_BY_RCU. Then, possible cases
are only ii) and iii). While anon_vma is anon_vma, try_to_unmap and remap_page
can work well because of the list of vmas and address check. IOW, remap routine
just do nothing if anon_vma is freed.

I'm not sure by what logic "use-after-free anon_vma" is caught. But yes,
there will be case, "anon_vma is touched after freed.", I think.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
