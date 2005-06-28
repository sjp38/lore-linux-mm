Date: Tue, 28 Jun 2005 14:47:50 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [RFC] Fix SMP brokenness for PF_FREEZE and make freezing usable for other purposes
Message-ID: <20050628124750.GB11129@atrey.karlin.mff.cuni.cz>
References: <Pine.LNX.4.62.0506242311220.7971@graphe.net> <20050626023053.GA2871@atrey.karlin.mff.cuni.cz> <Pine.LNX.4.62.0506251954470.26198@graphe.net> <20050626030925.GA4156@atrey.karlin.mff.cuni.cz> <Pine.LNX.4.62.0506261928010.1679@graphe.net> <Pine.LNX.4.58.0506262121070.19755@ppc970.osdl.org> <Pine.LNX.4.62.0506262249080.4374@graphe.net> <20050627141320.GA4945@atrey.karlin.mff.cuni.cz> <Pine.LNX.4.62.0506270804450.17400@graphe.net> <42C0EBAB.8070709@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <42C0EBAB.8070709@sw.ru>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kirill Korotaev <dev@sw.ru>
Cc: Christoph Lameter <christoph@lameter.com>, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, raybry@engr.sgi.com, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
List-ID: <linux-mm.kvack.org>

Hi!

> <<<< look at error path in freeze_processes (on timeout), it is broken 
> as well. You need to wakeup tasks there...
> 

Yep, and I have this in my tree to fix it:

[word-wrap-warning]

--- a/kernel/power/process.c
+++ b/kernel/power/process.c
@@ -60,6 +60,7 @@ int freeze_processes(void)
        int todo;
        unsigned long start_time;
        struct task_struct *g, *p;
+       unsigned long flags;

        printk( "Stopping tasks: " );
        start_time = jiffies;
@@ -67,12 +68,9 @@ int freeze_processes(void)
                todo = 0;
                read_lock(&tasklist_lock);
                do_each_thread(g, p) {
-                       unsigned long flags;
                        if (!freezeable(p))
                                continue;
-                       if ((p->flags & PF_FROZEN) ||
-                           (p->state == TASK_TRACED) ||
-                           (p->state == TASK_STOPPED))
+                       if (p->flags & PF_FROZEN)
                                continue;

                        /* FIXME: smp problem here: we may not access other process' flags
@@ -85,13 +83,28 @@ int freeze_processes(void)
                } while_each_thread(g, p);
                read_unlock(&tasklist_lock);
                yield();                        /* Yield is okay here */
-               if (time_after(jiffies, start_time + TIMEOUT)) {
+               if (todo && time_after(jiffies, start_time + TIMEOUT)) {
                        printk( "\n" );
                        printk(KERN_ERR " stopping tasks failed (%d tasks remaining)\n", todo );
-                       return todo;
+                       break;
                }
        } while(todo);
-
+
+       if (todo) {
+               read_lock(&tasklist_lock);
+               do_each_thread(g, p)
+                       if (p->flags & PF_FREEZE) {
+                               pr_debug("  clean up: %s\n", p->comm);
+                               p->flags &= ~PF_FREEZE;
+                               spin_lock_irqsave(&p->sighand->siglock, flags);
+                               recalc_sigpending_tsk(p);
+                               spin_unlock_irqrestore(&p->sighand->siglock, flags);
+                       }
+               while_each_thread(g, p);
+               read_unlock(&tasklist_lock);
+               return todo;
+       }
+
        printk( "|\n" );
        BUG_ON(in_atomic());
        return 0;

									Pavel

-- 
Boycott Kodak -- for their patent abuse against Java.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
