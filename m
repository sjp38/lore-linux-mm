Date: Sat, 4 Aug 2007 22:00:38 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
Message-ID: <20070804200038.GA31017@elte.hu>
References: <20070804070737.GA940@elte.hu> <20070804103347.GA1956@elte.hu> <alpine.LFD.0.999.0708040915360.5037@woody.linux-foundation.org> <20070804163733.GA31001@elte.hu> <alpine.LFD.0.999.0708041030040.5037@woody.linux-foundation.org> <46B4C0A8.1000902@garzik.org> <20070804191205.GA24723@lazybastard.org> <20070804192130.GA25346@elte.hu> <20070804192615.GA25600@lazybastard.org> <alpine.LFD.0.999.0708041246530.5037@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.0.999.0708041246530.5037@woody.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: =?iso-8859-1?Q?J=F6rn?= Engel <joern@logfs.org>, Jeff Garzik <jeff@garzik.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, david@lang.hm
List-ID: <linux-mm.kvack.org>

* Linus Torvalds <torvalds@linux-foundation.org> wrote:

> Well, we could make it the default for the kernel (possibly under a 
> "fast-atime" config option), and then people can add "atime" or 
> "noatime" as they wish, since mount has supported _those_ options for 
> a long time.

the patch below implements this, but there's a problem: we only have 
MNT_NOATIME, we have no MNT_ATIME option AFAICS. So there's no good way 
to detect it when a user _does_ want to have atime :-( Perhaps a boot 
option to turn this off? [sucks a bit but keeps the solution within the 
kernel.]

	Ingo

--------------------------------->
Subject: [patch] add CONFIG_FASTATIME
From: Ingo Molnar <mingo@elte.hu>

add the CONFIG_FASTATIME kernel option, which makes "relatime" the
default for all mounts.

Signed-off-by: Ingo Molnar <mingo@elte.hu>
---
 fs/Kconfig     |   10 ++++++++++
 fs/namespace.c |    4 ++++
 2 files changed, 14 insertions(+)

Index: linux/fs/Kconfig
===================================================================
--- linux.orig/fs/Kconfig
+++ linux/fs/Kconfig
@@ -2060,6 +2060,16 @@ config 9P_FS
 
 endmenu
 
+config FASTATIME
+	bool "Fast atime support by default"
+	default y
+	help
+	  If you say Y here, all your filesystems that do not have
+	  the "noatime" or "atime" mount option specified will get
+	  the "relatime" option by default, which speeds up atime
+	  updates. (atime will only be updated if ctime or mtime
+	  is more recent than atime)
+
 if BLOCK
 menu "Partition Types"
 
Index: linux/fs/namespace.c
===================================================================
--- linux.orig/fs/namespace.c
+++ linux/fs/namespace.c
@@ -1409,6 +1409,10 @@ long do_mount(char *dev_name, char *dir_
 		mnt_flags |= MNT_NODIRATIME;
 	if (flags & MS_RELATIME)
 		mnt_flags |= MNT_RELATIME;
+#ifdef CONFIG_FASTATIME
+	if (!(flags & (MNT_NOATIME | MNT_NODIRATIME)))
+		mnt_flags |= MNT_RELATIME;
+#endif
 
 	flags &= ~(MS_NOSUID | MS_NOEXEC | MS_NODEV | MS_ACTIVE |
 		   MS_NOATIME | MS_NODIRATIME | MS_RELATIME);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
