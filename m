Date: Mon, 21 May 2007 14:47:34 +0200
From: Folkert van Heusden <folkert@vanheusden.com>
Subject: Re: signals logged / [RFC] log out-of-virtual-memory events
Message-ID: <20070521124734.GB14802@vanheusden.com>
References: <464C9D82.60105@redhat.com> <Pine.LNX.4.61.0705202235430.13923@yvahk01.tjqt.qr> <20070520205500.GJ22452@vanheusden.com> <200705202314.57758.ak@suse.de> <46517817.1080208@users.sourceforge.net> <20070521110406.GA14802@vanheusden.com> <Pine.LNX.4.61.0705211420100.4452@yvahk01.tjqt.qr>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <Pine.LNX.4.61.0705211420100.4452@yvahk01.tjqt.qr>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jan Engelhardt <jengelh@linux01.gwdg.de>
Cc: Andrea Righi <righiandr@users.sourceforge.net>, Andi Kleen <ak@suse.de>, Stephen Hemminger <shemminger@linux-foundation.org>, Eric Dumazet <dada1@cosmosbay.com>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> >What about the following enhancement: I check with sig_fatal if it would
> >kill the process and only then emit a message. So when an application
> >takes care itself of handling it nothing is printed.
> >+	/* emit some logging for unhandled signals
> >+	 */
> >+	if (sig_fatal(t, sig))
> Not unhandled_signal()?

Can we already use that one in send_signal? As the signal needs to be
send first I think before we know if it was handled or not? sig_fatal
checks if the handler is set to default - which is it is not taken care
of.

> >+	{
> if (sig_fatal(t, sig)) {
> >+		printk(KERN_WARNING "Sig %d send to %d owned by %d.%d (%s)\n",
> s/send/sent/;
> >+		sig, t -> pid, t -> uid, t -> gid, t -> comm);
> t->pid, t->uid, t->gid, t->comm);


Description:
This patch adds code to the signal-sender making it log a message when
an unhandled fatal signal will be delivered.

Signed-off by: Folkert van Heusden <folkert@vanheusden.com>

--- kernel/signal.c.org	2007-05-20 22:47:13.000000000 +0200
+++ kernel/signal.c	2007-05-21 14:46:05.000000000 +0200
@@ -739,6 +739,12 @@
 	struct sigqueue * q = NULL;
 	int ret = 0;
 
+	/* unhandled fatal signals are logged */
+	if (sig_fatal(t, sig)) {
+		printk(KERN_WARNING "Sig %d sent to %d owned by %d.%d (%s)\n",
+		sig, t->pid, t->uid, t->gid, t->comm);
+	}
+
 	/*
 	 * fast-pathed signals for kernel-internal things like SIGSTOP
 	 * or SIGKILL.


Folkert van Heusden

-- 
MultiTail e uno flexible tool per seguire di logfiles e effettuazione
di commissioni. Feltrare, provedere da colore, merge, 'diff-view',
etc. http://www.vanheusden.com/multitail/
----------------------------------------------------------------------
Phone: +31-6-41278122, PGP-key: 1F28D8AE, www.vanheusden.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
