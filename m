Date: Sun, 5 Aug 2007 14:58:47 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
Message-ID: <20070805125847.GC22060@elte.hu>
References: <20070803123712.987126000@chello.nl> <46B4E161.9080100@garzik.org> <20070804224706.617500a0@the-village.bc.nu> <200708050051.40758.ctpm@ist.utl.pt> <20070805014926.400d0608@the-village.bc.nu> <20070805072805.GB4414@elte.hu> <20070805134640.2c7d1140@the-village.bc.nu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070805134640.2c7d1140@the-village.bc.nu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Claudio Martins <ctpm@ist.utl.pt>, Jeff Garzik <jeff@garzik.org>, =?iso-8859-1?Q?J=F6rn?= Engel <joern@logfs.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, david@lang.hm
List-ID: <linux-mm.kvack.org>

* Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:

> > The only remotely valid compatibility argument would be Mutt - but even 
> > that handles it just fine. (we broke way more software via noexec)
> 
> And went through a sensible process of resolving it.
>
> And its not just mutt. HSM stuff stops working which is a big deal as 
> stuff clogs up. The /tmp/ cleaning tools go wrong as well.

what OSS HSM software stops working and what is its failure mode? /tmp 
cleaning tools will work _just fine_ if we report back max(mtime,ctime) 
as atime - they'll zap more /tmp stuff as they used to. There's no 
guarantee for /tmp contents anyway if tmpwatch is running. Or the patch 
below.

	Ingo

--- /etc/cron.daily/tmpwatch.orig	2007-08-05 14:44:25.000000000 +0200
+++ /etc/cron.daily/tmpwatch	2007-08-05 14:45:10.000000000 +0200
@@ -1,9 +1,9 @@
 #! /bin/sh
-/usr/sbin/tmpwatch -x /tmp/.X11-unix -x /tmp/.XIM-unix -x /tmp/.font-unix \
+/usr/sbin/tmpwatch --mtime -x /tmp/.X11-unix -x /tmp/.XIM-unix -x /tmp/.font-unix \
 	-x /tmp/.ICE-unix -x /tmp/.Test-unix 10d /tmp
-/usr/sbin/tmpwatch 30d /var/tmp
+/usr/sbin/tmpwatch --mtime 30d /var/tmp
 for d in /var/{cache/man,catman}/{cat?,X11R6/cat?,local/cat?}; do
     if [ -d "$d" ]; then
-	/usr/sbin/tmpwatch -f 30d "$d"
+	/usr/sbin/tmpwatch --mtime -f 30d "$d"
     fi
 done

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
