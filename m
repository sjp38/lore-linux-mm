Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 9CD876B0031
	for <linux-mm@kvack.org>; Fri,  7 Jun 2013 14:35:57 -0400 (EDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v8 9/9] vmcore: support mmap() on /proc/vmcore
Date: Fri, 7 Jun 2013 20:34:58 +0200
References: <20130523052421.13864.83978.stgit@localhost6.localdomain6> <10307835.fkACLi6FUD@wuerfel> <51B130F9.8070408@jp.fujitsu.com>
In-Reply-To: <51B130F9.8070408@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201306072034.58817.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
Cc: vgoyal@redhat.com, ebiederm@xmission.com, akpm@linux-foundation.org, cpw@sgi.com, kumagai-atsushi@mxc.nes.nec.co.jp, lisa.mitchell@hp.com, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, zhangyanfei@cn.fujitsu.com, jingbai.ma@hp.com, linux-mm@kvack.org, riel@redhat.com, walken@google.com, hughd@google.com, kosaki.motohiro@jp.fujitsu.com

On Friday 07 June 2013, HATAYAMA Daisuke wrote:
> Thanks for trying the build and your report!
> 
> OTOH, I don't have no-MMU architectures; x86 box only. I cannot reproduce this build error. 
> Could you give me your build log? I want to use it to detect what part depends on CONFIG_MMU.

What I get is a link-time error:

fs/built-in.o: In function `mmap_vmcore':
:(.text+0x4bc18): undefined reference to `remap_vmalloc_range_partial'
fs/built-in.o: In function `merge_note_headers_elf32.constprop.4':
:(.init.text+0x142c): undefined reference to `find_vm_area'

and I used this patch to temporarily work around the problem, effectively disabling all
of /proc/vmcore on non-MMU kernels.

diff --git a/include/linux/crash_dump.h b/include/linux/crash_dump.h
index 37e4f8d..9a078ef 100644
--- a/include/linux/crash_dump.h
+++ b/include/linux/crash_dump.h
@@ -55,7 +55,7 @@ static inline int is_kdump_kernel(void)
 
 static inline int is_vmcore_usable(void)
 {
-	return is_kdump_kernel() && elfcorehdr_addr != ELFCORE_ADDR_ERR ? 1 : 0;
+	return IS_ENABLED(CONFIG_MMU) && is_kdump_kernel() && elfcorehdr_addr != ELFCORE_ADDR_ERR ? 1 : 0;
 }
 
 /* vmcore_unusable() marks the vmcore as unusable,


For testing, I used ARM at91x40_defconfig and manually turned on VMCORE support in
menuconfig, but it happened before using "randconfig". On most distros you can
these days install an arm cross compiler using yum or apt-get and build
the kernel yourself with 'make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi-'

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
