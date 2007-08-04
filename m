Date: Sat, 4 Aug 2007 21:42:59 +0200
From: =?utf-8?B?SsO2cm4=?= Engel <joern@logfs.org>
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
Message-ID: <20070804194259.GA25753@lazybastard.org>
References: <20070804063217.GA25069@elte.hu> <20070804070737.GA940@elte.hu> <20070804103347.GA1956@elte.hu> <alpine.LFD.0.999.0708040915360.5037@woody.linux-foundation.org> <20070804163733.GA31001@elte.hu> <alpine.LFD.0.999.0708041030040.5037@woody.linux-foundation.org> <46B4C0A8.1000902@garzik.org> <20070804191205.GA24723@lazybastard.org> <20070804192130.GA25346@elte.hu> <20070804192615.GA25600@lazybastard.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20070804192615.GA25600@lazybastard.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: =?utf-8?B?SsO2cm4=?= Engel <joern@logfs.org>
Cc: Ingo Molnar <mingo@elte.hu>, Jeff Garzik <jeff@garzik.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, david@lang.hm
List-ID: <linux-mm.kvack.org>

On Sat, 4 August 2007 21:26:15 +0200, JA?rn Engel wrote:
> 
> Given the choice between only "atime" and "noatime" I'd agree with you.
> Heck, I use it myself.  But "relatime" seems to combine the best of both
> worlds.  It currently just suffers from mount not supporting it in any
> relevant distro.

And here is a completely untested patch to enable it by default.  Ingo,
can you see how good this fares compared to "atime" and
"noatime,nodiratime"?

JA?rn

-- 
Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it.
-- Brian W. Kernighan

--- linux-2.6.22_relatime/fs/namespace.c~default_relatime	2007-05-16 02:01:39.000000000 +0200
+++ linux-2.6.22_relatime/fs/namespace.c	2007-08-04 21:36:20.000000000 +0200
@@ -1401,6 +1401,10 @@ long do_mount(char *dev_name, char *dir_
 	if (data_page)
 		((char *)data_page)[PAGE_SIZE - 1] = 0;
 
+#ifdef CONFIG_DEFAULT_RELATIME
+	flags |= MS_RELATIME;
+#endif
+
 	/* Separate the per-mountpoint flags */
 	if (flags & MS_NOSUID)
 		mnt_flags |= MNT_NOSUID;
--- linux-2.6.22_relatime/fs/Kconfig~default_relatime	2007-05-16 02:01:38.000000000 +0200
+++ linux-2.6.22_relatime/fs/Kconfig	2007-08-04 21:39:46.000000000 +0200
@@ -6,6 +6,15 @@ menu "File systems"
 
 if BLOCK
 
+config DEFAULT_RELATIME
+	bool "Mount all filesystems with 'relatime' by default"
+	default y
+	help
+	  Relatime only updates atime once after any file has been changed.
+	  Setting this should give a noticeable performance bonus.
+
+	  If unsure, say Y.
+
 config EXT2_FS
 	tristate "Second extended fs support"
 	help

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
