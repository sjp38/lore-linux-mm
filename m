Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 4968C6B0044
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 16:15:46 -0400 (EDT)
Date: Wed, 25 Apr 2012 16:15:40 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: NULL-ptr deref in mmput via sys_migrate_pages in 3.4-rc4 (proly
 missing mm==NULL check)
Message-ID: <20120425201540.GA1560@redhat.com>
References: <CAP145pgsaAN7uvj29Di6Qwtgrr54WvGL6X4rqU-fre8z_zJh4Q@mail.gmail.com>
 <CAP145pjuQ=Ja6bQLBFdOptzRG29qL2BRvMw=Qz7ub1TOjOn2XQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAP145pjuQ=Ja6bQLBFdOptzRG29qL2BRvMw=Qz7ub1TOjOn2XQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robert =?utf-8?B?xZp3acSZY2tp?= <robert@swiecki.net>
Cc: linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org

Commit 3268c63eded4612a3d07b56d1e02ce7731e6608e introduced two potential NULL dereferences.
Move the mmput calls into the if arms that have already tested for a valid mm.

Reported-by: Robert A?wiA?cki <robert@swiecki.net>
Cc: Christoph Lameter <cl@linux.com>
Signed-off-by: Dave Jones <davej@redhat.com>

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index cfb6c86..6de4850 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1361,13 +1361,12 @@ SYSCALL_DEFINE4(migrate_pages, pid_t, pid, unsigned long, maxnode,
 
 	mm = get_task_mm(task);
 	put_task_struct(task);
-	if (mm)
+	if (mm) {
 		err = do_migrate_pages(mm, old, new,
 			capable(CAP_SYS_NICE) ? MPOL_MF_MOVE_ALL : MPOL_MF_MOVE);
-	else
+		mmput(mm);
+	} else
 		err = -EINVAL;
-
-	mmput(mm);
 out:
 	NODEMASK_SCRATCH_FREE(scratch);
 
diff --git a/mm/migrate.c b/mm/migrate.c
index 51c08a0..d73d860 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1389,15 +1389,15 @@ SYSCALL_DEFINE6(move_pages, pid_t, pid, unsigned long, nr_pages,
 	put_task_struct(task);
 
 	if (mm) {
-		if (nodes)
+		if (nodes) {
 			err = do_pages_move(mm, task_nodes, nr_pages, pages,
 					    nodes, status, flags);
-		else
+			mmput(mm);
+		} else
 			err = do_pages_stat(mm, nr_pages, pages, status);
 	} else
 		err = -EINVAL;
 
-	mmput(mm);
 	return err;
 
 out:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
