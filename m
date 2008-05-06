Date: Tue, 06 May 2008 20:02:44 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH] mm/cgroup.c add error check
Message-Id: <20080506195216.4A6D.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

on heavy workload, call_usermodehelper() may failure
because it use kzmalloc(GFP_ATOMIC).

but userland want receive release notificcation even heavy workload.

thus, We should retry if -ENOMEM happend.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: "Paul Menage" <menage@google.com>
CC: Li Zefan <lizf@cn.fujitsu.com>

---
 kernel/cgroup.c |   10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

Index: b/kernel/cgroup.c
===================================================================
--- a/kernel/cgroup.c   2008-04-29 18:00:53.000000000 +0900
+++ b/kernel/cgroup.c   2008-05-06 20:28:23.000000000 +0900
@@ -3072,6 +3072,8 @@ void __css_put(struct cgroup_subsys_stat
  */
 static void cgroup_release_agent(struct work_struct *work)
 {
+       int err;
+
        BUG_ON(work != &release_agent_work);
        mutex_lock(&cgroup_mutex);
        spin_lock(&release_list_lock);
@@ -3111,7 +3113,13 @@ static void cgroup_release_agent(struct
                 * since the exec could involve hitting disk and hence
                 * be a slow process */
                mutex_unlock(&cgroup_mutex);
-               call_usermodehelper(argv[0], argv, envp, UMH_WAIT_EXEC);
+
+retry:
+               err = call_usermodehelper(argv[0], argv, envp, UMH_WAIT_EXEC);
+               if (err == -ENOMEM) {
+                       schedule();
+                       goto retry;
+               }
                kfree(pathbuf);
                mutex_lock(&cgroup_mutex);
                spin_lock(&release_list_lock);



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
