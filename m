Subject: Re: [PATCH] shm fs v2 against 2.3.41
From: GOTO Masanori <gotom@debian.or.jp>
In-Reply-To: <qwwemazzj8u.fsf@sap.com>
References: <qwwemazzj8u.fsf@sap.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <20000201190720E.gotom@fe.dis.titech.ac.jp>
Date: Tue, 01 Feb 2000 19:07:20 +0900
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: hans-christoph.rohland@sap.com
Cc: linux-kernel@vger.rutgers.edu, linux-MM@kvack.org, Linus Torvalds <torvalds@transmeta.com>, gotom@debian.or.jp
List-ID: <linux-mm.kvack.org>

Calling shmget( key, size, shmflg ) with size = 0,
I got an error EINVAL. The below patch fix it,
please apply into 2.3.41+shmfs14 patch.

---------------------
--- linux-2.3.41_shmfs14/ipc/shm.c      Tue Feb  1 18:49:02 2000
+++ linux-2.3.41_shmfs14_fixed/ipc/shm.c        Tue Feb  1 18:57:52 2000
@@ -660,7 +660,7 @@
                return -EINVAL;
        }
 
-       if (size < SHMMIN)
+       if ((size != 0) && (size < SHMMIN))
                return -EINVAL;
 
        down(&shm_ids.sem);
---------------------

And now I have a question:
I guess almost all users have no shmpath (default: /var/shm),
and they maybe make a dir and have to mount it.
IMHO, it is better to change that sysv shared memory works
samely, whenever shmfs is not mounted. Is it feasible, 
or only my mistaken ?


From: Christoph Rohland <hans-christoph.rohland@sap.com>
Subject: [PATCH] shm fs v2 against 2.3.41
> Hi Folks,
> 
> Here is my newest version of shm over a filesystem:
> 
> Changes to the previous versio:
> 
> - It does not try to autodetect the path any more. Per default it
>   expects to be mounted at /var/shm. If you mount it somewhere else,
>   put the new path into /proc/sys/kernel/shmpath
> - No more /proc/sys/kernel/{shmall,shmmni}. Use mount options
>   nr_blocks and nr_pages. You can change these parameters with remount.
> - You can set the initial mode of the directory with mount option 'mode'.
> - It frees all objects on umount.
> 
> I tested the shm fs heavily on 2.3.40+some patches to make smp and
> page_cache stable. It survived one day swap test.

Regards,
-- GOTO Masanori
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
