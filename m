Date: Sun, 20 May 2007 02:14:23 +0200
From: Folkert van Heusden <folkert@vanheusden.com>
Subject: Re: signals logged / [RFC] log out-of-virtual-memory events
Message-ID: <20070520001418.GJ14578@vanheusden.com>
References: <464C81B5.8070101@users.sourceforge.net> <464C9D82.60105@redhat.com> <Pine.LNX.4.61.0705180825280.3231@yvahk01.tjqt.qr> <200705181347.14256.ak@suse.de> <Pine.LNX.4.61.0705190946430.9015@yvahk01.tjqt.qr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.61.0705190946430.9015@yvahk01.tjqt.qr>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jan Engelhardt <jengelh@linux01.gwdg.de>
Cc: Andi Kleen <ak@suse.de>, Rik van Riel <riel@redhat.com>, righiandr@users.sourceforge.net, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> >> I do not see such on i386, so why for x86_64?
> >So that you know that one of your programs crashed. That's a feature.
> This feature could be handy for i386 too.

Since 2.6.18.2 I use this patch. With 2.6.21.1 it still applies altough
with a small offsets. Works like a charm.


Signed-off by: Folkert van Heusden <folkert@vanheusden.com>

--- linux-2.6.18.2/kernel/signal.c      2006-11-04 02:33:58.000000000 +0100
+++ linux-2.6.18.2.new/kernel/signal.c  2006-11-17 15:59:13.000000000 +0100
@@ -706,6 +706,15 @@
        struct sigqueue * q = NULL;
        int ret = 0;

+       if (sig == SIGQUIT || sig == SIGILL  || sig == SIGTRAP ||
+           sig == SIGABRT || sig == SIGBUS  || sig == SIGFPE  ||
+           sig == SIGSEGV || sig == SIGXCPU || sig == SIGXFSZ ||
+           sig == SIGSYS  || sig == SIGSTKFLT)
+       {
+               printk(KERN_WARNING "Sig %d send to %d owned by %d.%d (%s)\n",
+                       sig, t -> pid, t -> uid, t -> gid, t -> comm);
+       }
+
        /*
         * fast-pathed signals for kernel-internal things like SIGSTOP
         * or SIGKILL.



Folkert van Heusden

-- 
www.biglumber.com <- site where one can exchange PGP key signatures 
----------------------------------------------------------------------
Phone: +31-6-41278122, PGP-key: 1F28D8AE, www.vanheusden.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
