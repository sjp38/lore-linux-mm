Message-ID: <17855236.1109499454066.JavaMail.postfix@mx20.mail.sohu.com>
Date: Sun, 27 Feb 2005 18:17:34 +0800 (CST)
From: <stone_wang@sohu.com>
Subject: [PATCH] Linux-2.6.11-rc5: kernel/sys.c setrlimit() RLIMIT_RSS cleanup
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@redhat.com, akpm@osdl.org
Cc: linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


ulimit dont enforce RLIMIT_RSS now,while sys_setrlimit() pretend it(RLIMIT_RSS) is enforced. 

This may cause confusion to users, and may lead to un-guaranteed dependence on "ulimit -m" to limit users/applications.

The patch fixed the problem. 

-- snip from system run with patched(patch attached) 2.6.11-rc5 kernel
$ ulimit  -a
core file size          (blocks, -c) 0
data seg size           (kbytes, -d) unlimited
file size               (blocks, -f) unlimited
pending signals                 (-i) 1024
max locked memory       (kbytes, -l) 32
max memory size         (kbytes, -m) unlimited
open files                      (-n) 1024
pipe size            (512 bytes, -p) 8
POSIX message queues     (bytes, -q) 819200
stack size              (kbytes, -s) 8192
cpu time               (seconds, -t) unlimited
max user processes              (-u) 4091
virtual memory          (kbytes, -v) unlimited
file locks                      (-x) unlimited

$ ulimit  -m 100000
bash: ulimit: max memory size: cannot modify limit: Function not implemented

-
patch: 2.6.11-rc5 kernel/sys.c setrlimit() RLIMIT_RSS cleanup

Signed-Off-By: Stone Wang  <stone_wang@sohu.com>

diff -urpN linux-2.6.11-rc5-original/kernel/sys.c linux-2.6.11-rc5-cleanup/kernel/sys.c
--- linux-2.6.11-rc5-original/kernel/sys.c      2005-02-26 17:34:38.000000000 -0500
+++ linux-2.6.11-rc5-cleanup/kernel/sys.c       2005-02-27 17:27:20.000000000 -0500
@@ -1488,6 +1488,14 @@ asmlinkage long sys_setrlimit(unsigned i
        if (new_rlim.rlim_cur > new_rlim.rlim_max)
                return -EINVAL;
        old_rlim = current->signal->rlim + resource;
+
+       /* We dont enforce RLIMIT_RSS ulimit yet. But for application
+          compatability, we warn only when asked to change system default value. */
+       if( resource == RLIMIT_RSS &&
+           ((new_rlim.rlim_max != old_rlim->rlim_max)||
+            (new_rlim.rlim_cur != old_rlim->rlim_cur)) )
+               return -ENOSYS;
+
        if ((new_rlim.rlim_max > old_rlim->rlim_max) &&
            !capable(CAP_SYS_RESOURCE))
                return -EPERM;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
