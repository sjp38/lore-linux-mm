Date: Fri, 18 Apr 2003 02:26:06 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.67-mm4
Message-Id: <20030418022606.56357df4.akpm@digeo.com>
In-Reply-To: <Pine.LNX.4.50L0.0304181216180.1931-200000@webdev.ines.ro>
References: <20030418014536.79d16076.akpm@digeo.com>
	<Pine.LNX.4.50L0.0304181216180.1931-200000@webdev.ines.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrei Ivanov <andrei.ivanov@ines.ro>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@lst.de>
List-ID: <linux-mm.kvack.org>

Andrei Ivanov <andrei.ivanov@ines.ro> wrote:
>
> 
> :(
> 
> make -f scripts/Makefile.build obj=fs/devfs
>   gcc -Wp,-MD,fs/devfs/.base.o.d -D__KERNEL__ -Iinclude -Wall 
> -Wstrict-prototypes -Wno-trigraphs -O2 -fno-strict-aliasing -fno-common 
> -pipe -mpreferred-stack-boundary=2 -march=athlon 
> -Iinclude/asm-i386/mach-default -nostdinc -iwithprefix include    
> -DKBUILD_BASENAME=base -DKBUILD_MODNAME=devfs -c -o fs/devfs/base.o 
> fs/devfs/base.c
> fs/devfs/base.c: In function `devfsd_notify':
> fs/devfs/base.c:1426: too many arguments to function `devfsd_notify_de'
> fs/devfs/base.c: In function `devfs_register':
> fs/devfs/base.c:1460: warning: too few arguments for format
> make[2]: *** [fs/devfs/base.o] Error 1
> make[1]: *** [fs/devfs] Error 2
> make: *** [fs] Error 2

Like this I guess.


diff -puN fs/devfs/base.c~devfs-build-fix fs/devfs/base.c
--- 25/fs/devfs/base.c~devfs-build-fix	2003-04-18 02:21:47.000000000 -0700
+++ 25-akpm/fs/devfs/base.c	2003-04-18 02:22:11.000000000 -0700
@@ -1423,7 +1423,7 @@ static int devfsd_notify_de (struct devf
 static void devfsd_notify (struct devfs_entry *de,unsigned short type)
 {
 	devfsd_notify_de(de, type, de->mode, current->euid,
-			 current->egid, &fs_info, 0);
+			 current->egid, &fs_info);
 } 
 
 
@@ -1457,7 +1457,8 @@ devfs_handle_t devfs_register (devfs_han
     struct devfs_entry *de;
 
     if (flags)
-	printk(KERN_ERR "%s called with flags != 0, please fix!\n");
+	printk(KERN_ERR "%s called with flags != 0, please fix!\n",
+			__FUNCTION__);
 
     if (name == NULL)
     {

_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
