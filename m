Date: Fri, 10 Aug 2007 11:37:13 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: SLUB: Fix dynamic dma kmalloc cache creation
In-Reply-To: <20070810004059.8aa2aadb.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0708101125390.17312@schroedinger.engr.sgi.com>
References: <200708100559.l7A5x3r2019930@hera.kernel.org>
 <20070810004059.8aa2aadb.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > +	schedule_work(&sysfs_add_work);
On Fri, 10 Aug 2007, Andrew Morton wrote:
> sysfs_add_work could be already pending, or running.  boom.

Ok so queue_work serializes with run_workqueue but does not check that the 
entry is already inserted?

static void __queue_work(struct cpu_workqueue_struct *cwq,
                         struct work_struct *work)
{
        unsigned long flags;

        spin_lock_irqsave(&cwq->lock, flags);
        insert_work(cwq, work, 1);
        spin_unlock_irqrestore(&cwq->lock, flags);
}

run_workqueue

static void run_workqueue(struct cpu_workqueue_struct *cwq)
{
        spin_lock_irq(&cwq->lock);
        cwq->run_depth++;
        if (cwq->run_depth > 3) {

...



Then we need this patch?

SLUB dynamic kmalloc cache create: Prevent scheduling sysfs_add_slab workqueue twice.

If another dynamic slab creation is done shortly after an earlier one and 
the sysfs_add_slab function has not been run yet then we may corrupt the
workqueue list since we schedule the work structure twice.

Avoid that by setting a flag indicating that the sysfs add work has 
already been scheduled. sysfs_add_func can handle adding multiple 
dma kmalloc slab in one go so we do not need to schedule it again.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2007-08-10 11:14:28.000000000 -0700
+++ linux-2.6/mm/slub.c	2007-08-10 11:25:13.000000000 -0700
@@ -2279,6 +2279,8 @@ panic:
 
 #ifdef CONFIG_ZONE_DMA
 
+static int sysfs_add_scheduled = 0;
+
 static void sysfs_add_func(struct work_struct *w)
 {
 	struct kmem_cache *s;
@@ -2290,6 +2292,7 @@ static void sysfs_add_func(struct work_s
 			sysfs_slab_add(s);
 		}
 	}
+	sysfs_add_scheduled = 0;
 	up_write(&slub_lock);
 }
 
@@ -2331,7 +2334,10 @@ static noinline struct kmem_cache *dma_k
 	list_add(&s->list, &slab_caches);
 	kmalloc_caches_dma[index] = s;
 
-	schedule_work(&sysfs_add_work);
+	if (!sysfs_add_scheduled) {
+		schedule_work(&sysfs_add_work);
+		sysfs_add_scheduled = 1;
+	}
 
 unlock_out:
 	up_write(&slub_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
