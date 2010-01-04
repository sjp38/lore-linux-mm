Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id DE458600068
	for <linux-mm@kvack.org>; Sun,  3 Jan 2010 20:06:12 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0416ANw011823
	for <linux-mm@kvack.org> (envelope-from d.hatayama@jp.fujitsu.com);
	Mon, 4 Jan 2010 10:06:10 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id BC8FE45DE55
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 10:06:09 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 91B7F45DE51
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 10:06:09 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6D79B1DB803B
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 10:06:09 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 131DC1DB8038
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 10:06:09 +0900 (JST)
Date: Mon, 04 Jan 2010 10:06:07 +0900 (JST)
Message-Id: <20100104.100607.189714443.d.hatayama@jp.fujitsu.com>
Subject: [RESEND][mmotm][PATCH v2, 0/5] elf coredump: Add extended
 numbering support
From: Daisuke HATAYAMA <d.hatayama@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mhiramat@redhat.com, xiyou.wangcong@gmail.com, andi@firstfloor.org, jdike@addtoit.com, tony.luck@intel.com
List-ID: <linux-mm.kvack.org>

I resend this serise of patches because in the previous post I didn't
get any reply.

The changes from v1 to v2:
 * fix binfmt_elf_fdpic.c and binfmt_aout.c, too
 * move dump_write() and dump_seek() into a header file
 * fix some style issues
 * correct confusing part of the patch descriptions
===
Summary
=======

The current ELF dumper can produce broken corefiles if program headers
exceed 65535. In particular, the program in 64-bit environment often
demands more than 65535 mmaps. If you google max_map_count, then you
can find many users facing this problem.

Solaris has already dealt with this issue, and other OSes have also
adopted the same method as in Solaris. Currently, Sun's document and
AMD 64 ABI include the description for the extension, where they call
the extension Extended Numbering. See Reference for further information.

I believe that linux kernel should adopt the same way as they did, so
I've written this patch.

I am also preparing for patches of GDB and binutils.

How to fix
==========

In new dumping process, there are two cases according to weather or
not the number of program headers is equal to or more than 65535.

 - if less than 65535, the produced corefile format is exactly the
   same as the ordinary one.

 - if equal to or more than 65535, then e_phnum field is set to newly
   introduced constant PN_XNUM(0xffff) and the actual number of
   program headers is set to sh_info field of the section header at
   index 0.

Compatibility Concern
=====================

 * As already mentioned in Summary, Sun and AMD64 has already adopted
   this. See Reference.

 * There are four combinations according to whether kernel and
   userland tools are respectively modified or not. The next table
   summarizes shortly for each combination.

                  ---------------------------------------------
                     Original Kernel    |   Modified Kernel   
                  ---------------------------------------------
    	            < 65535  | >= 65535 | < 65535  | >= 65535 
  -------------------------------------------------------------
   Original Tools |    OK    |  broken  |   OK     | broken (#)
  -------------------------------------------------------------
   Modified Tools |    OK    |  broken  |   OK     |    OK
  -------------------------------------------------------------

  Note that there is no case that `OK' changes to `broken'.

  (#) Although this case remains broken, O-M behaves better than
  O-O. That is, while in O-O case e_phnum field would be extremely
  small due to integer overflow, in O-M case it is guaranteed to be at
  least 65535 by being set to PN_XNUM(0xFFFF), much closer to the
  actual correct value than the O-O case.

Test Program
============

Here is a test program mkmmaps.c that is useful to produce the
corefile with many mmaps. To use this, please take the following
steps:

$ ulimit -c unlimited
$ sysctl vm.max_map_count=70000 # default 65530 is too small
$ sysctl fs.file-max=70000
$ mkmmaps 65535

Then, the program will abort and a corefile will be generated.

If failed, there are two cases according to the error message
displayed.

 * ``out of memory'' means vm.max_map_count is still smaller

 * ``too many open files'' means fs.file-max is still smaller

So, please change it to a larger value, and then retry it.

mkmmaps.c
==
#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <unistd.h>
int main(int argc, char **argv)
{ 
	int maps_num;
	if (argc < 2) {
		fprintf(stderr, "mkmmaps [number of maps to be created]\n");
		exit(1);
	}
	if (sscanf(argv[1], "%d", &maps_num) == EOF) {
		perror("sscanf");
		exit(2);
	}
	if (maps_num < 0) {
		fprintf(stderr, "%d is invalid\n", maps_num);
		exit(3);
	}
	for (; maps_num > 0; --maps_num) {
		if (MAP_FAILED == mmap((void *)NULL, (size_t) 1, PROT_READ,
					MAP_SHARED | MAP_ANONYMOUS, (int) -1,
					(off_t) NULL)) {
			perror("mmap");
			exit(4);
		}    
	}
	abort();
	{
		char buffer[128];
		sprintf(buffer, "wc -l /proc/%u/maps", getpid());
		system(buffer);
	}
	return 0;
}

Patches
=======

Tested on i386, ia64 and um/sys-i386.
Built on sh4 (which covers fs/binfmt_elf_fdpic.c)

diffstat output:

 arch/ia64/ia32/binfmt_elf32.c |    1 +
 arch/ia64/ia32/elfcore32.h    |   18 +++++
 arch/ia64/include/asm/elf.h   |   48 ------------
 arch/ia64/kernel/Makefile     |    2 +
 arch/ia64/kernel/elfcore.c    |   80 +++++++++++++++++++
 arch/um/sys-i386/Makefile     |    2 +
 arch/um/sys-i386/asm/elf.h    |   43 ----------
 arch/um/sys-i386/elfcore.c    |   83 ++++++++++++++++++++
 fs/binfmt_aout.c              |   36 +++------
 fs/binfmt_elf.c               |  141 +++++++++++++++++++++-------------
 fs/binfmt_elf_fdpic.c         |  171 ++++++++++++++++++++++++++--------------
 include/linux/coredump.h      |   41 ++++++++++
 include/linux/elf.h           |   28 +++++++-
 include/linux/elfcore.h       |   17 ++++
 kernel/Makefile               |    2 +
 kernel/elfcore.c              |   28 +++++++
 16 files changed, 512 insertions(+), 229 deletions(-)

Reference
=========

 - Sun microsystems: Linker and Libraries.
   Part No: 817-1984-17, September 2008.
   URL: http://docs.sun.com/app/docs/doc/817-1984

 - System V ABI AMD64 Architecture Processor Supplement
   Draft Version 0.99., May 11, 2009.
   URL: http://www.x86-64.org/

Signed-off-by: Daisuke HATAYAMA <d.hatayama@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
