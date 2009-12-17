Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id C63AC6B0089
	for <linux-mm@kvack.org>; Thu, 17 Dec 2009 07:29:11 -0500 (EST)
Message-ID: <4B2A22C0.8080001@redhat.com>
Date: Thu, 17 Dec 2009 07:23:28 -0500
From: Larry Woodman <lwoodman@redhat.com>
Reply-To: lwoodman@redhat.com
MIME-Version: 1.0
Subject: FWD:  [PATCH v2] vmscan: limit concurrent reclaimers in shrink_zone
References: <20091211164651.036f5340@annuminas.surriel.com> <1260810481.6666.13.camel@dhcp-100-19-198.bos.redhat.com> <20091217193818.9FA9.A69D9226@jp.fujitsu.com>
In-Reply-To: <20091217193818.9FA9.A69D9226@jp.fujitsu.com>
Content-Type: multipart/mixed;
 boundary="------------060208050503010206050303"
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, akpm@linux-foundation.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------060208050503010206050303
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

KOSAKI Motohiro wrote:
> (offlist)
>
> Larry, May I ask current status of following your issue?
> I don't reproduce it. and I don't hope to keep lots patch are up in the air.
>   

Yes, sorry for the delay but I dont have direct or exclusive access to 
these large systems
and workloads.  As far as I can tell this patch series does help prevent 
total system
hangs running AIM7.  I did have trouble with the early postings mostly 
due to using sleep_on()
and wakeup() but those appear to be fixed. 

However, I did add more debug code and see ~10000 processes blocked in 
shrink_zone_begin().
This is expected but bothersome, practically all of the processes remain 
runnable for the entire
duration of these AIM runs.  Collectively all these runnable processes 
overwhelm the VM system. 
There are many more runnable processes now than were ever seen before, 
~10000 now versus
~100 on RHEL5(2.6.18 based).  So, we have also been experimenting around 
with some of the
CFS scheduler tunables to see of this is responsible... 
> plus, I integrated page_referenced() improvement patch series and
> limit concurrent reclaimers patch series privately. I plan to post it
> to lkml at this week end. comments are welcome.
>   

The only problem I noticed with the page_referenced patch was an 
increase in the
try_to_unmap() failures which causes more re-activations.  This is very 
obvious with
the using tracepoints I have posted over the past few months but they 
were never
included. I  didnt get a chance to figure out the exact cause due to 
access to the hardware
and workload.  This patch series also seems to help the overall stalls 
in the VM system.
>
> changelog from last post:
>  - remake limit concurrent reclaimers series and sort out its patch order
>  - change default max concurrent reclaimers from 8 to num_online_cpu().
>    it mean, Andi only talked negative feeling comment in last post. 
>    he dislike constant default value. plus, over num_online_cpu() is
>    really silly. iow, it is really low risk.
>    (probably we might change default value. as far as I mesure, small
>     value makes better benchmark result. but I'm not sure small value
>     don't make regression)
>  - Improve OOM and SIGKILL behavior.
>    (because RHEL5's vmscan has TIF_MEMDIE recovering logic, but
>     current mainline doesn't. I don't hope RHEL6 has regression)
>
>
>
>   
>> On Fri, 2009-12-11 at 16:46 -0500, Rik van Riel wrote:
>>
>> Rik, the latest patch appears to have a problem although I dont know
>> what the problem is yet.  When the system ran out of memory we see
>> thousands of runnable processes and 100% system time:
>>
>>
>>  9420  2  29824  79856  62676  19564    0    0     0     0 8054  379  0 
>> 100  0  0  0
>> 9420  2  29824  79368  62292  19564    0    0     0     0 8691  413  0 
>> 100  0  0  0
>> 9421  1  29824  79780  61780  19820    0    0     0     0 8928  408  0 
>> 100  0  0  0
>>
>> The system would not respond so I dont know whats going on yet.  I'll
>> add debug code to figure out why its in that state as soon as I get
>> access to the hardware.
>>     

This was in response to Rik's first patch and seems to be fixed by the 
latest path set.

Finally, having said all that, the system still struggles reclaiming 
memory with
~10000 processes trying at the same time, you fix one bottleneck and it 
moves
somewhere else.  The latest run showed all but one running process 
spinning in
page_lock_anon_vma() trying for the anon_vma_lock.  I noticed that there 
are
~5000 vma's linked to one anon_vma, this seems excessive!!!

I changed the anon_vma->lock to a rwlock_t and page_lock_anon_vma() to use
read_lock() so multiple callers could execute the page_reference_anon code.
This seems to help quite a bit.


>> Larry


--------------060208050503010206050303
Content-Type: text/x-patch;
 name="aim.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="aim.patch"

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index cb0ba70..6b32ecf 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -25,7 +25,7 @@
  * pointing to this anon_vma once its vma list is empty.
  */
 struct anon_vma {
-	spinlock_t lock;	/* Serialize access to vma list */
+	rwlock_t lock;	/* Serialize access to vma list */
 	/*
 	 * NOTE: the LSB of the head.next is set by
 	 * mm_take_all_locks() _after_ taking the above lock. So the
@@ -43,14 +43,14 @@ static inline void anon_vma_lock(struct vm_area_struct *vma)
 {
 	struct anon_vma *anon_vma = vma->anon_vma;
 	if (anon_vma)
-		spin_lock(&anon_vma->lock);
+		write_lock(&anon_vma->lock);
 }
 
 static inline void anon_vma_unlock(struct vm_area_struct *vma)
 {
 	struct anon_vma *anon_vma = vma->anon_vma;
 	if (anon_vma)
-		spin_unlock(&anon_vma->lock);
+		write_unlock(&anon_vma->lock);
 }
 
 /*
diff --git a/mm/migrate.c b/mm/migrate.c
index 7dbcb22..3f0305b 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -183,12 +183,12 @@ static void remove_anon_migration_ptes(struct page *old, struct page *new)
 	 * We hold the mmap_sem lock. So no need to call page_lock_anon_vma.
 	 */
 	anon_vma = (struct anon_vma *) (mapping - PAGE_MAPPING_ANON);
-	spin_lock(&anon_vma->lock);
+	write_lock(&anon_vma->lock);
 
 	list_for_each_entry(vma, &anon_vma->head, anon_vma_node)
 		remove_migration_pte(vma, old, new);
 
-	spin_unlock(&anon_vma->lock);
+	write_unlock(&anon_vma->lock);
 }
 
 /*
diff --git a/mm/mmap.c b/mm/mmap.c
index 814b95f..42324cb 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -592,7 +592,7 @@ again:			remove_next = 1 + (end > next->vm_end);
 	if (vma->anon_vma && (insert || importer || start != vma->vm_start))
 		anon_vma = vma->anon_vma;
 	if (anon_vma) {
-		spin_lock(&anon_vma->lock);
+		write_lock(&anon_vma->lock);
 		/*
 		 * Easily overlooked: when mprotect shifts the boundary,
 		 * make sure the expanding vma has anon_vma set if the
@@ -646,7 +646,7 @@ again:			remove_next = 1 + (end > next->vm_end);
 	}
 
 	if (anon_vma)
-		spin_unlock(&anon_vma->lock);
+		write_unlock(&anon_vma->lock);
 	if (mapping)
 		spin_unlock(&mapping->i_mmap_lock);
 
@@ -2442,7 +2442,7 @@ static void vm_lock_anon_vma(struct mm_struct *mm, struct anon_vma *anon_vma)
 		 * The LSB of head.next can't change from under us
 		 * because we hold the mm_all_locks_mutex.
 		 */
-		spin_lock_nest_lock(&anon_vma->lock, &mm->mmap_sem);
+		write_lock(&anon_vma->lock);
 		/*
 		 * We can safely modify head.next after taking the
 		 * anon_vma->lock. If some other vma in this mm shares
@@ -2558,7 +2558,7 @@ static void vm_unlock_anon_vma(struct anon_vma *anon_vma)
 		if (!__test_and_clear_bit(0, (unsigned long *)
 					  &anon_vma->head.next))
 			BUG();
-		spin_unlock(&anon_vma->lock);
+		write_unlock(&anon_vma->lock);
 	}
 }
 
diff --git a/mm/rmap.c b/mm/rmap.c
index dd43373..abddf95 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -116,7 +116,7 @@ int anon_vma_prepare(struct vm_area_struct *vma)
 				return -ENOMEM;
 			allocated = anon_vma;
 		}
-		spin_lock(&anon_vma->lock);
+		write_lock(&anon_vma->lock);
 
 		/* page_table_lock to protect against threads */
 		spin_lock(&mm->page_table_lock);
@@ -127,7 +127,7 @@ int anon_vma_prepare(struct vm_area_struct *vma)
 		}
 		spin_unlock(&mm->page_table_lock);
 
-		spin_unlock(&anon_vma->lock);
+		write_unlock(&anon_vma->lock);
 		if (unlikely(allocated))
 			anon_vma_free(allocated);
 	}
@@ -153,9 +153,9 @@ void anon_vma_link(struct vm_area_struct *vma)
 	struct anon_vma *anon_vma = vma->anon_vma;
 
 	if (anon_vma) {
-		spin_lock(&anon_vma->lock);
+		write_lock(&anon_vma->lock);
 		list_add_tail(&vma->anon_vma_node, &anon_vma->head);
-		spin_unlock(&anon_vma->lock);
+		write_unlock(&anon_vma->lock);
 	}
 }
 
@@ -167,12 +167,12 @@ void anon_vma_unlink(struct vm_area_struct *vma)
 	if (!anon_vma)
 		return;
 
-	spin_lock(&anon_vma->lock);
+	write_lock(&anon_vma->lock);
 	list_del(&vma->anon_vma_node);
 
 	/* We must garbage collect the anon_vma if it's empty */
 	empty = list_empty(&anon_vma->head);
-	spin_unlock(&anon_vma->lock);
+	write_unlock(&anon_vma->lock);
 
 	if (empty)
 		anon_vma_free(anon_vma);
@@ -182,7 +182,7 @@ static void anon_vma_ctor(void *data)
 {
 	struct anon_vma *anon_vma = data;
 
-	spin_lock_init(&anon_vma->lock);
+	rwlock_init(&anon_vma->lock);
 	INIT_LIST_HEAD(&anon_vma->head);
 }
 
@@ -209,7 +209,7 @@ struct anon_vma *page_lock_anon_vma(struct page *page)
 		goto out;
 
 	anon_vma = (struct anon_vma *) (anon_mapping - PAGE_MAPPING_ANON);
-	spin_lock(&anon_vma->lock);
+	read_lock(&anon_vma->lock);
 	return anon_vma;
 out:
 	rcu_read_unlock();
@@ -218,7 +218,7 @@ out:
 
 void page_unlock_anon_vma(struct anon_vma *anon_vma)
 {
-	spin_unlock(&anon_vma->lock);
+	read_unlock(&anon_vma->lock);
 	rcu_read_unlock();
 }
 

--------------060208050503010206050303--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
