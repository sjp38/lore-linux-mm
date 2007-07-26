Date: Thu, 26 Jul 2007 12:24:06 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: RFT: updatedb "morning after" problem [was: Re: -mm merge
	plans for 2.6.23]
Message-ID: <20070726102406.GA30165@elte.hu>
References: <2c0942db0707232153j3670ef31kae3907dff1a24cb7@mail.gmail.com> <46A58B49.3050508@yahoo.com.au> <2c0942db0707240915h56e007e3l9110e24a065f2e73@mail.gmail.com> <46A6CC56.6040307@yahoo.com.au> <p73abtkrz37.fsf@bingen.suse.de> <46A85D95.509@kingswood-consulting.co.uk> <20070726092025.GA9157@elte.hu> <20070726023401.f6a2fbdf.akpm@linux-foundation.org> <20070726094024.GA15583@elte.hu> <20070726030902.02f5eab0.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070726030902.02f5eab0.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Frank Kingswood <frank@kingswood-consulting.co.uk>, Andi Kleen <andi@firstfloor.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Ray Lee <ray-lk@madrabbit.org>, Jesper Juhl <jesper.juhl@gmail.com>, ck list <ck@vds.kolivas.org>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Andrew Morton <akpm@linux-foundation.org> wrote:

> Setting it to zero will maximise the preservation of the vfs caches.  
> You wanted 10000 there.

ok, updated patch below :-)

> <bets that nobody will test this>

wrong, it's active on three of my boxes already :) But then again, i 
never had these hangover problems. (not really expected with gigs of RAM 
anyway)

	Ingo

--- /etc/cron.daily/mlocate.cron.orig
+++ /etc/cron.daily/mlocate.cron
@@ -1,4 +1,7 @@
 #!/bin/sh
 nodevs=$(< /proc/filesystems awk '$1 == "nodev" { print $2 }')
 renice +19 -p $$ >/dev/null 2>&1
+PREV=`cat /proc/sys/vm/vfs_cache_pressure 2>/dev/null`
+echo 10000 > /proc/sys/vm/vfs_cache_pressure 2>/dev/null
 /usr/bin/updatedb -f "$nodevs"
+[ "$PREV" != "" ] && echo $PREV > /proc/sys/vm/vfs_cache_pressure 2>/dev/null

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
