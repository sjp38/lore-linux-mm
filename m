Date: Mon, 21 May 2007 13:04:06 +0200
From: Folkert van Heusden <folkert@vanheusden.com>
Subject: Re: signals logged / [RFC] log out-of-virtual-memory events
Message-ID: <20070521110406.GA14802@vanheusden.com>
References: <464C9D82.60105@redhat.com> <Pine.LNX.4.61.0705202235430.13923@yvahk01.tjqt.qr> <20070520205500.GJ22452@vanheusden.com> <200705202314.57758.ak@suse.de> <46517817.1080208@users.sourceforge.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <46517817.1080208@users.sourceforge.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Righi <righiandr@users.sourceforge.net>
Cc: Andi Kleen <ak@suse.de>, Jan Engelhardt <jengelh@linux01.gwdg.de>, Stephen Hemminger <shemminger@linux-foundation.org>, Eric Dumazet <dada1@cosmosbay.com>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> >> +	switch(sig) {
> >> +	case SIGQUIT: 
...
> >> +	case SIGSTKFLT:
> > 
> > Unconditional? That's definitely a very bad idea. If anything only unhandled
> > signals should be printed this way because some programs use them internally. 
> > But I think your list is far too long anyways.
> 
> Maybe you could use somthing similar to unhandled_signal() in
> arch/x86_64/mm/fault.c, but I agree that the list seems a bit too long...

What about the following enhancement: I check with sig_fatal if it would
kill the process and only then emit a message. So when an application
takes care itself of handling it nothing is printed.

Signed-off by: Folkert van Heusden <folkert@vanheusden.com>

--- kernel/signal.c.org	2007-05-20 22:47:13.000000000 +0200
+++ kernel/signal.c	2007-05-21 12:59:52.000000000 +0200
@@ -739,6 +739,8 @@
 	struct sigqueue * q = NULL;
 	int ret = 0;
 
+	/* emit some logging for unhandled signals
+	 */
+	if (sig_fatal(t, sig))
+	{
+		printk(KERN_WARNING "Sig %d send to %d owned by %d.%d (%s)\n",
+		sig, t -> pid, t -> uid, t -> gid, t -> comm);
+	}
+
 	/*
 	 * fast-pathed signals for kernel-internal things like SIGSTOP
 	 * or SIGKILL.

of course, this can also be limited to only the interesting signals:

Signed-off by: Folkert van Heusden <folkert@vanheusden.com>

--- kernel/signal.c.org	2007-05-20 22:47:13.000000000 +0200
+++ kernel/signal.c	2007-05-21 12:59:52.000000000 +0200
@@ -739,6 +739,28 @@
 	struct sigqueue * q = NULL;
 	int ret = 0;
 
+	/* emit some logging for nasty signals
+	 * especially SIGSEGV and friends aught to be looked at when happening
+	 */
+	switch(sig) {
+	case SIGQUIT: 
+	case SIGILL: 
+	case SIGTRAP:
+	case SIGABRT: 
+	case SIGBUS: 
+	case SIGFPE:
+	case SIGSEGV: 
+	case SIGXCPU: 
+	case SIGXFSZ:
+	case SIGSYS: 
+	case SIGSTKFLT:
+		if (sig_fatal(t, sig))
+		{
+			printk(KERN_WARNING "Sig %d send to %d owned by %d.%d (%s)\n",
+			sig, t -> pid, t -> uid, t -> gid, t -> comm);
+		}
+	}
+
 	/*
 	 * fast-pathed signals for kernel-internal things like SIGSTOP
 	 * or SIGKILL.


Folkert van Heusden

-- 

Multitail - gibkaja utilita po sledovaniju log-fajlov i vyvoda
kommand. Fil'trovanie, raskra?ivanie, slijanie, vizual'noe sravnenie,
i t.d.  http://www.vanheusden.com/multitail/
----------------------------------------------------------------------
Phone: +31-6-41278122, PGP-key: 1F28D8AE, www.vanheusden.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
