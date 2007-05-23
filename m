Date: Wed, 23 May 2007 20:45:35 +0200
From: Folkert van Heusden <folkert@vanheusden.com>
Subject: Re: signals logged / [RFC] log out-of-virtual-memory events
Message-ID: <20070523184535.GE21655@vanheusden.com>
References: <464C9D82.60105@redhat.com> <Pine.LNX.4.61.0705202235430.13923@yvahk01.tjqt.qr> <20070520205500.GJ22452@vanheusden.com> <200705202314.57758.ak@suse.de> <46517817.1080208@users.sourceforge.net> <20070521110406.GA14802@vanheusden.com> <Pine.LNX.4.61.0705211420100.4452@yvahk01.tjqt.qr> <20070521124734.GB14802@vanheusden.com> <a781481a0705231100q333a589at6c025eb1292019cd@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a781481a0705231100q333a589at6c025eb1292019cd@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Satyam Sharma <satyam.sharma@gmail.com>
Cc: Jan Engelhardt <jengelh@linux01.gwdg.de>, Andrea Righi <righiandr@users.sourceforge.net>, Andi Kleen <ak@suse.de>, Stephen Hemminger <shemminger@linux-foundation.org>, Eric Dumazet <dada1@cosmosbay.com>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> >> >+    {
> >> if (sig_fatal(t, sig)) {
> >> >+            printk(KERN_WARNING "Sig %d send to %d owned by %d.%d 
> >(%s)\n",
> >> s/send/sent/;
> >> >+            sig, t -> pid, t -> uid, t -> gid, t -> comm);
> >> t->pid, t->uid, t->gid, t->comm);
> >
> 
> Gargh ... why does this want to be in the *kernel*'s logs? In any case, can
> you please make this KERN_INFO (or lower) instead of KERN_WARNING.

Description:
This patch adds code to the signal-sender making it log a message when
an unhandled fatal signal will be delivered.

Signed-of by: Folkert van Heusden <folkert@vanheusden.com

--- kernel/signal.c.org	2007-05-20 22:47:13.000000000 +0200
+++ kernel/signal.c	2007-05-21 14:46:05.000000000 +0200
@@ -739,6 +739,12 @@
 	struct sigqueue * q = NULL;
 	int ret = 0;
 
+	/* unhandled fatal signals are logged */
+	if (sig_fatal(t, sig)) {
+		printk(KERN_INFO "Sig %d sent to %d owned by %d.%d (%s)\n",
+		sig, t->pid, t->uid, t->gid, t->comm);
+	}
+
 	/*
 	 * fast-pathed signals for kernel-internal things like SIGSTOP
 	 * or SIGKILL.


Folkert van Heusden

-- 
Temperature outside:    21.437500, temperature livingroom: 
----------------------------------------------------------------------
Phone: +31-6-41278122, PGP-key: 1F28D8AE, www.vanheusden.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
