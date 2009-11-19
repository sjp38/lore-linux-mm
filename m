Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 0822A6B004D
	for <linux-mm@kvack.org>; Wed, 18 Nov 2009 20:23:19 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAJ1NHo0022244
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 19 Nov 2009 10:23:17 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 40C4B45DE70
	for <linux-mm@kvack.org>; Thu, 19 Nov 2009 10:23:17 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 21DC345DE6F
	for <linux-mm@kvack.org>; Thu, 19 Nov 2009 10:23:17 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0B8491DB803A
	for <linux-mm@kvack.org>; Thu, 19 Nov 2009 10:23:17 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B20451DB803B
	for <linux-mm@kvack.org>; Thu, 19 Nov 2009 10:23:16 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH]  [for mmotm-1113] mm: Simplify try_to_unmap_one()
In-Reply-To: <20091118151803.35f55ca3.akpm@linux-foundation.org>
References: <20091117173759.3DF6.A69D9226@jp.fujitsu.com> <20091118151803.35f55ca3.akpm@linux-foundation.org>
Message-Id: <20091119100525.3E2B.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 19 Nov 2009 10:23:16 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> On Tue, 17 Nov 2009 17:39:27 +0900 (JST)
> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
> > +out_mlock:
> > +	pte_unmap_unlock(pte, ptl);
> > +
> > +	if (down_read_trylock(&vma->vm_mm->mmap_sem)) {
> > +		if (vma->vm_flags & VM_LOCKED) {
> > +			mlock_vma_page(page);
> > +			ret = SWAP_MLOCK;
> >  		}
> > +		up_read(&vma->vm_mm->mmap_sem);
> 
> It's somewhat unobvious why we're using a trylock here.  Ranking versus
> lock_page(), perhaps?
> 
> In general I think a trylock should have an associated comment which explains
> 
> a) why it is being used at this site and
> 
> b) what happens when the trylock fails - why this isn't a
>    bug, how the kernel recovers from the inconsistency, what its
>    overall effect is, etc.
> 
> <wonders why we need to take mmap_sem here at all>

This mmap_sem is needed certainenaly. Following comment is sufficient?


---
 mm/rmap.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index 70dec01..b1c9342 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -860,6 +860,14 @@ out:
 out_mlock:
 	pte_unmap_unlock(pte, ptl);
 
+
+	/*
+	 * We need mmap_sem locking, Otherwise VM_LOCKED check makes
+	 * unstable result and race. Plus, We can't wait here because
+	 * we now hold anon_vma->lock or mapping->i_mmap_lock.
+	 * If trylock failed, The page remain evictable lru and
+	 * retry to more unevictable lru by later vmscan.
+	 */
 	if (down_read_trylock(&vma->vm_mm->mmap_sem)) {
 		if (vma->vm_flags & VM_LOCKED) {
 			mlock_vma_page(page);
-- 
1.6.2.5



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
