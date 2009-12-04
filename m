Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 9DA766007BA
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 03:29:48 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nB48TjOA020698
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 4 Dec 2009 17:29:46 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0FC5745DE53
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 17:29:45 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D1F7545DE4D
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 17:29:44 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 966421DB8048
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 17:29:44 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id BEB5B1DB8041
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 17:29:43 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH]  [for mmotm-1113] mm: Simplify try_to_unmap_one()
In-Reply-To: <20091119152748.3E37.A69D9226@jp.fujitsu.com>
References: <alpine.DEB.2.00.0911182207530.21028@kernalhack.brc.ubc.ca> <20091119152748.3E37.A69D9226@jp.fujitsu.com>
Message-Id: <20091204172806.588F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri,  4 Dec 2009 17:29:43 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Vincent Li <macli@brc.ubc.ca>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> > 
> > 
> > On Thu, 19 Nov 2009, KOSAKI Motohiro wrote:
> > 
> > > > 
> > > > Hi KOSAKI,
> > > > 
> > > > Thank you for the comment, I am still little confused with the last 
> > > > sentence.
> > > > 
> > > > On Thu, 19 Nov 2009, KOSAKI Motohiro wrote:
> > > > 
> > > > > 
> > > > > +
> > > > > +	/*
> > > > > +	 * We need mmap_sem locking, Otherwise VM_LOCKED check makes
> > > > > +	 * unstable result and race. Plus, We can't wait here because
> > > > > +	 * we now hold anon_vma->lock or mapping->i_mmap_lock.
> > > > > +	 * If trylock failed, The page remain evictable lru and
> > > > > +	 * retry to more unevictable lru by later vmscan.
> > > >            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ I am having 
> > > > trouble to undestand it. Yeah, I should read more code, but the sentence 
> > > > itself make me confused :).
> > > 
> > > Um, this is wrong.
> > > Probably, It should be
> > > 
> > > 	retry to move unevictable lru later.
> > > 
> > > Do you agree this?
> > 
> > Ah, let's see if I understand you correctly, if trylock failed, the page 
> > remain in evictable lru and later vmscan could retry to move the page to 
> > unevictable lru if the page is actually mlocked? 
> 
> Ah, your sentence is better. can you please change code itself?

Fix is here.

------------------------------------------
Subject: [PATCH] try_to_unmap_one() comment fix

Viencent Li pointed out current comment is wrong. This patch fixes it.

Reported-by: Vincent Li <macli@brc.ubc.ca>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/rmap.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index f1a9f7d..278cd27 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -875,8 +875,9 @@ out_mlock:
 	 * We need mmap_sem locking, Otherwise VM_LOCKED check makes
 	 * unstable result and race. Plus, We can't wait here because
 	 * we now hold anon_vma->lock or mapping->i_mmap_lock.
-	 * If trylock failed, The page remain evictable lru and
-	 * retry to more unevictable lru by later vmscan.
+	 * if trylock failed, the page remain in evictable lru and later
+	 * vmscan could retry to move the page to unevictable lru if the
+	 * page is actually mlocked.
 	 */
 	if (down_read_trylock(&vma->vm_mm->mmap_sem)) {
 		if (vma->vm_flags & VM_LOCKED) {
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
