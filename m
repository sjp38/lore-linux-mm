Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 6B4216B00D5
	for <linux-mm@kvack.org>; Thu, 13 Nov 2014 08:27:40 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id y10so14490640pdj.28
        for <linux-mm@kvack.org>; Thu, 13 Nov 2014 05:27:40 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id mm5si25504721pbc.212.2014.11.13.05.27.38
        for <linux-mm@kvack.org>;
        Thu, 13 Nov 2014 05:27:38 -0800 (PST)
Date: Thu, 13 Nov 2014 21:26:56 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [next:master 6416/6487] fs/exec.c:1507:53: sparse: incorrect type in
 argument 2 (different address spaces)
Message-ID: <201411132154.tkbVS9yt%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Drysdale <drysdale@google.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
head:   bbdef57970d5e1887de755474ff1562baa17ef11
commit: ed9af7d027e2f211e782631dcd6740323a6f26f9 [6416/6487] syscalls,x86: implement execveat() system call
reproduce:
  # apt-get install sparse
  git checkout ed9af7d027e2f211e782631dcd6740323a6f26f9
  make ARCH=x86_64 allmodconfig
  make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

   fs/exec.c:407:39: sparse: incorrect type in return expression (different address spaces)
   fs/exec.c:407:39:    expected char const [noderef] <asn:1>*
   fs/exec.c:407:39:    got void *
   fs/exec.c:414:31: sparse: incorrect type in return expression (different address spaces)
   fs/exec.c:414:31:    expected char const [noderef] <asn:1>*
   fs/exec.c:414:31:    got void *
   fs/exec.c:986:56: sparse: incorrect type in argument 2 (different address spaces)
   fs/exec.c:986:56:    expected struct task_struct *parent
   fs/exec.c:986:56:    got struct task_struct [noderef] <asn:4>*parent
   fs/exec.c:1019:17: sparse: incorrect type in assignment (different address spaces)
   fs/exec.c:1019:17:    expected struct sighand_struct *volatile <noident>
   fs/exec.c:1019:17:    got struct sighand_struct [noderef] <asn:4>*<noident>
   fs/exec.c:1421:70: sparse: incorrect type in argument 1 (different address spaces)
   fs/exec.c:1421:70:    expected struct task_struct *tsk
   fs/exec.c:1421:70:    got struct task_struct [noderef] <asn:4>*parent
>> fs/exec.c:1507:53: sparse: incorrect type in argument 2 (different address spaces)
   fs/exec.c:1507:53:    expected struct fdtable const *fdt
   fs/exec.c:1507:53:    got struct fdtable [noderef] <asn:4>*fdt

vim +1507 fs/exec.c

  1491		bprm->file = file;
  1492		if (fd == AT_FDCWD || filename->name[0] == '/') {
  1493			bprm->filename = filename->name;
  1494		} else {
  1495			if (filename->name[0] == '\0')
  1496				pathbuf = kasprintf(GFP_TEMPORARY, "/dev/fd/%d", fd);
  1497			else
  1498				pathbuf = kasprintf(GFP_TEMPORARY, "/dev/fd/%d/%s",
  1499						    fd, filename->name);
  1500			if (!pathbuf) {
  1501				retval = -ENOMEM;
  1502				goto out_unmark;
  1503			}
  1504			/* Record that a name derived from an O_CLOEXEC fd will be
  1505			 * inaccessible after exec. Relies on having exclusive access to
  1506			 * current->files (due to unshare_files above). */
> 1507			if (close_on_exec(fd, current->files->fdt))
  1508				bprm->interp_flags |= BINPRM_FLAGS_PATH_INACCESSIBLE;
  1509			bprm->filename = pathbuf;
  1510		}
  1511		bprm->interp = bprm->filename;
  1512	
  1513		retval = bprm_mm_init(bprm);
  1514		if (retval)
  1515			goto out_unmark;

---
0-DAY kernel test infrastructure                Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
