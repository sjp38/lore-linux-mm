Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id UAA16739
	for <linux-mm@kvack.org>; Tue, 24 Sep 2002 20:13:51 -0700 (PDT)
Message-ID: <3D9129EE.796E1B3F@digeo.com>
Date: Tue, 24 Sep 2002 20:13:50 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: 2.5.38-mm2 pdflush_list
References: <20020925022324.GP6070@holomorphy.com> <3D912577.160421F8@digeo.com> <20020925025510.GQ6070@holomorphy.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
> 
> William Lee Irwin III wrote:
> >> There's a NULL in this circular list:
> 
> On Tue, Sep 24, 2002 at 07:54:47PM -0700, Andrew Morton wrote:
> > The only way I can see this happen is if someone sprayed out
> > a bogus wakeup.  Are you using preempt (or software suspend??)
> 
> Nope. Just SMP. Happened on the NUMA-Q's. I couldn't figure out
> what was going on from this. It's still up for postmortem, though.
> 

Don't know.

I tightened up the locking in there, added some paranoia and a
couple of printks for when it happens again.


--- 2.5.38/mm/pdflush.c~pdflush-tightening	Tue Sep 24 19:55:10 2002
+++ 2.5.38-akpm/mm/pdflush.c	Tue Sep 24 20:01:19 2002
@@ -79,9 +79,9 @@ static unsigned long last_empty_jifs;
  */
 struct pdflush_work {
 	struct task_struct *who;	/* The thread */
-	void (*fn)(unsigned long);	/* A callback function for pdflush to work on */
-	unsigned long arg0;		/* An argument to the callback function */
-	struct list_head list;		/* On pdflush_list, when the thread is idle */
+	void (*fn)(unsigned long);	/* A callback function */
+	unsigned long arg0;		/* An argument to the callback */
+	struct list_head list;		/* On pdflush_list, when idle */
 	unsigned long when_i_went_to_sleep;
 };
 
@@ -99,24 +99,35 @@ static int __pdflush(struct pdflush_work
 	current->flags |= PF_FLUSHER;
 	my_work->fn = NULL;
 	my_work->who = current;
+	INIT_LIST_HEAD(&my_work->list);
 
 	spin_lock_irq(&pdflush_lock);
 	nr_pdflush_threads++;
-//	printk("pdflush %d [%d] starts\n", nr_pdflush_threads, current->pid);
 	for ( ; ; ) {
 		struct pdflush_work *pdf;
 
-		list_add(&my_work->list, &pdflush_list);
-		my_work->when_i_went_to_sleep = jiffies;
 		set_current_state(TASK_INTERRUPTIBLE);
+		list_move(&my_work->list, &pdflush_list);
+		my_work->when_i_went_to_sleep = jiffies;
 		spin_unlock_irq(&pdflush_lock);
 
 		if (current->flags & PF_FREEZE)
 			refrigerator(PF_IOTHREAD);
 		schedule();
 
-		if (my_work->fn)
-			(*my_work->fn)(my_work->arg0);
+		spin_lock_irq(&pdflush_lock);
+		if (!list_empty(&my_work->list)) {
+			printk("pdflush: bogus wakeup!\n");
+			my_work->fn = NULL;
+			continue;
+		}
+		if (my_work->fn == NULL) {
+			printk("pdflush: NULL work function\n");
+			continue;
+		}
+		spin_unlock_irq(&pdflush_lock);
+
+		(*my_work->fn)(my_work->arg0);
 
 		/*
 		 * Thread creation: For how long have there been zero
@@ -132,6 +143,7 @@ static int __pdflush(struct pdflush_work
 		}
 
 		spin_lock_irq(&pdflush_lock);
+		my_work->fn = NULL;
 
 		/*
 		 * Thread destruction: For how long has the sleepiest
@@ -143,13 +155,12 @@ static int __pdflush(struct pdflush_work
 			continue;
 		pdf = list_entry(pdflush_list.prev, struct pdflush_work, list);
 		if (jiffies - pdf->when_i_went_to_sleep > 1 * HZ) {
-			pdf->when_i_went_to_sleep = jiffies;	/* Limit exit rate */
+			/* Limit exit rate */
+			pdf->when_i_went_to_sleep = jiffies;
 			break;					/* exeunt */
 		}
-		my_work->fn = NULL;
 	}
 	nr_pdflush_threads--;
-//	printk("pdflush %d [%d] ends\n", nr_pdflush_threads, current->pid);
 	spin_unlock_irq(&pdflush_lock);
 	return 0;
 }
@@ -191,11 +202,10 @@ int pdflush_operation(void (*fn)(unsigne
 		list_del_init(&pdf->list);
 		if (list_empty(&pdflush_list))
 			last_empty_jifs = jiffies;
-		spin_unlock_irqrestore(&pdflush_lock, flags);
 		pdf->fn = fn;
 		pdf->arg0 = arg0;
-		wmb();			/* ? */
 		wake_up_process(pdf->who);
+		spin_unlock_irqrestore(&pdflush_lock, flags);
 	}
 	return ret;
 }

.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
