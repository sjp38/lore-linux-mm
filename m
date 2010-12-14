Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 58FB96B0088
	for <linux-mm@kvack.org>; Tue, 14 Dec 2010 12:39:55 -0500 (EST)
Date: Tue, 14 Dec 2010 18:38:24 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 39 of 66] memcg huge memory
Message-ID: <20101214173824.GJ5638@random.random>
References: <patchbomb.1288798055@v2.random>
 <877d2f205026b0463450.1288798094@v2.random>
 <20101119101938.2edf889f.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101119101938.2edf889f.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

On Fri, Nov 19, 2010 at 10:19:38AM +0900, KAMEZAWA Hiroyuki wrote:
> On Wed, 03 Nov 2010 16:28:14 +0100
> Andrea Arcangeli <aarcange@redhat.com> wrote:
> > @@ -402,9 +408,15 @@ static int do_huge_pmd_wp_page_fallback(
> >  	for (i = 0; i < HPAGE_PMD_NR; i++) {
> >  		pages[i] = alloc_page_vma(GFP_HIGHUSER_MOVABLE,
> >  					  vma, address);
> > -		if (unlikely(!pages[i])) {
> > -			while (--i >= 0)
> > +		if (unlikely(!pages[i] ||
> > +			     mem_cgroup_newpage_charge(pages[i], mm,
> > +						       GFP_KERNEL))) {
> > +			if (pages[i])
> >  				put_page(pages[i]);
> > +			while (--i >= 0) {
> > +				mem_cgroup_uncharge_page(pages[i]);
> > +				put_page(pages[i]);
> > +			}
> 
> Maybe you can use batched-uncharge here.
> ==
> mem_cgroup_uncharge_start()
> {
> 	do loop;
> }
> mem_cgroup_uncharge_end();
> ==
> Then, many atomic ops can be reduced.

Cute!

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -413,10 +413,12 @@ static int do_huge_pmd_wp_page_fallback(
 						       GFP_KERNEL))) {
 			if (pages[i])
 				put_page(pages[i]);
+			mem_cgroup_uncharge_start();
 			while (--i >= 0) {
 				mem_cgroup_uncharge_page(pages[i]);
 				put_page(pages[i]);
 			}
+			mem_cgroup_uncharge_end();
 			kfree(pages);
 			ret |= VM_FAULT_OOM;
 			goto out;


> 
> 
> >  			kfree(pages);
> >  			ret |= VM_FAULT_OOM;
> >  			goto out;
> > @@ -455,8 +467,10 @@ out:
> >  
> >  out_free_pages:
> >  	spin_unlock(&mm->page_table_lock);
> > -	for (i = 0; i < HPAGE_PMD_NR; i++)
> > +	for (i = 0; i < HPAGE_PMD_NR; i++) {
> > +		mem_cgroup_uncharge_page(pages[i]);
> >  		put_page(pages[i]);
> > +	}
> 
> here, too.

This is actually a very unlikely path handling a thread race
condition, but I'll add it any way.

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -469,10 +469,12 @@ out:
 
 out_free_pages:
 	spin_unlock(&mm->page_table_lock);
+	mem_cgroup_uncharge_start();
 	for (i = 0; i < HPAGE_PMD_NR; i++) {
 		mem_cgroup_uncharge_page(pages[i]);
 		put_page(pages[i]);
 	}
+	mem_cgroup_uncharge_end();
 	kfree(pages);
 	goto out;
 }


> Hmm...it seems there are no codes for move_account() hugepage in series.
> I think it needs some complicated work to walk page table.

Agreed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
