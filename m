Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id 1B9812802C8
	for <linux-mm@kvack.org>; Mon,  6 Jul 2015 16:56:04 -0400 (EDT)
Received: by igrv9 with SMTP id v9so125437510igr.1
        for <linux-mm@kvack.org>; Mon, 06 Jul 2015 13:56:03 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id s100si17855916ioe.52.2015.07.06.13.56.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jul 2015 13:56:03 -0700 (PDT)
Date: Mon, 6 Jul 2015 13:56:01 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: kernel/uid16.c:184:2: error: implicit declaration of function
 'groups_alloc'
Message-Id: <20150706135601.bd75127ce72297e70a396bd3@linux-foundation.org>
In-Reply-To: <201507050734.RcWSMvjj%fengguang.wu@intel.com>
References: <201507050734.RcWSMvjj%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Iulia Manda <iulia.manda21@gmail.com>, kbuild-all@01.org, Josh Triplett <josh@joshtriplett.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Linux Memory Management List <linux-mm@kvack.org>

On Sun, 5 Jul 2015 07:30:38 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:

> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
> head:   5c755fe142b421d295e7dd64a9833c12abbfd28e
> commit: 2813893f8b197a14f1e1ddb04d99bce46817c84a kernel: conditionally support non-root users, groups and capabilities
> date:   3 months ago
> config: openrisc-allnoconfig (attached as .config)
> reproduce:
>   wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>   chmod +x ~/bin/make.cross
>   git checkout 2813893f8b197a14f1e1ddb04d99bce46817c84a
>   # save the attached .config to linux build tree
>   make.cross ARCH=openrisc 
> 
> All error/warnings (new ones prefixed by >>):
> 
>    kernel/uid16.c: In function 'SYSC_setgroups16':
> >> kernel/uid16.c:184:2: error: implicit declaration of function 'groups_alloc'
>    kernel/uid16.c:184:13: warning: assignment makes pointer from integer without a cast


Iulia, does the below look corect?  It will make setgroups16() return
-ENOMEM, which seems inappropriate.

From: Andrew Morton <akpm@linux-foundation.org>
Subject: kernel/uid16.c needs cred.h

openrisc-allnoconfig:

kernel/uid16.c: In function 'SYSC_setgroups16':
kernel/uid16.c:184:2: error: implicit declaration of function 'groups_alloc'
kernel/uid16.c:184:13: warning: assignment makes pointer from integer without a cast

Fixes: 2813893f8b197a1 ("kernel: conditionally support non-root users, groups and capabilities")
Reported-by: Fengguang Wu <fengguang.wu@gmail.com>
Cc: Iulia Manda <iulia.manda21@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/linux/cred.h |    9 +++++++--
 kernel/uid16.c       |    1 +
 2 files changed, 8 insertions(+), 2 deletions(-)

diff -puN kernel/uid16.c~kernel-uid16c-needs-credh kernel/uid16.c
--- a/kernel/uid16.c~kernel-uid16c-needs-credh
+++ a/kernel/uid16.c
@@ -9,6 +9,7 @@
 #include <linux/reboot.h>
 #include <linux/prctl.h>
 #include <linux/capability.h>
+#include <linux/cred.h>
 #include <linux/init.h>
 #include <linux/highuid.h>
 #include <linux/security.h>
diff -puN include/linux/cred.h~kernel-uid16c-needs-credh include/linux/cred.h
--- a/include/linux/cred.h~kernel-uid16c-needs-credh
+++ a/include/linux/cred.h
@@ -64,12 +64,17 @@ do {							\
 
 extern struct group_info init_groups;
 #ifdef CONFIG_MULTIUSER
-extern struct group_info *groups_alloc(int);
-extern void groups_free(struct group_info *);
+extern struct group_info *groups_alloc(int gidsetsize);
+extern void groups_free(struct group_info *group_info);
 
 extern int in_group_p(kgid_t);
 extern int in_egroup_p(kgid_t);
 #else
+extern struct group_info *groups_alloc(int gidsetsize)
+{
+	return NULL;
+}
+
 static inline void groups_free(struct group_info *group_info)
 {
 }
_


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
