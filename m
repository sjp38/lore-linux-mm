Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id 5E25E6B0256
	for <linux-mm@kvack.org>; Sun, 28 Feb 2016 17:32:20 -0500 (EST)
Received: by mail-qg0-f48.google.com with SMTP id d32so47576576qgd.0
        for <linux-mm@kvack.org>; Sun, 28 Feb 2016 14:32:20 -0800 (PST)
Received: from sasl.smtp.pobox.com (pb-smtp0.int.icgroup.com. [208.72.237.35])
        by mx.google.com with ESMTPS id f189si23482928qhc.12.2016.02.28.14.32.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Feb 2016 14:32:19 -0800 (PST)
Date: Sun, 28 Feb 2016 17:32:17 -0500 (EST)
From: Geoffrey Thomas <geofft@ldpreload.com>
Subject: [PATCH] mm/hugetlb: hugetlb_no_page: Rate-limit warning message
Message-ID: <alpine.DEB.2.11.1602281708490.32312@titan.ldpreload.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>

The warning message "killed due to inadequate hugepage pool" simply 
indicates that SIGBUS was sent, not that the process was forcibly killed. 
If the process has a signal handler installed does not fix the problem, 
this message can rapidly spam the kernel log.

Signed-off-by: Geoffrey Thomas <geofft@ldpreload.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
On my amd64 dev machine that does not have hugepages configured, I can 
reproduce the repeated warnings easily by setting vm.nr_hugepages=2 (i.e., 
4 megabytes of huge pages) and running something that sets a signal 
handler and forks, like

#include <sys/mman.h>
#include <signal.h>
#include <stdlib.h>
#include <unistd.h>

sig_atomic_t counter = 10;
void handler(int signal) {
 	if (counter-- == 0)
 		exit(0);
}

int main(void) {
 	int status;
 	char *addr = mmap(NULL, 4 * 1048576, PROT_READ | PROT_WRITE,
 			  MAP_PRIVATE | MAP_ANONYMOUS | MAP_HUGETLB, -1, 0);
 	if (addr == MAP_FAILED) {perror("mmap"); return 1;}
 	*addr = 'x';
 	switch (fork()) {
 		case -1:
 			perror("fork"); return 1;
 		case 0:
 			signal(SIGBUS, handler);
 			*addr = 'x';
 			break;
 		default:
 			*addr = 'x';
 			wait(&status);
 			if (WIFSIGNALED(status)) {
 				psignal(WTERMSIG(status), "child");
 			}
 			break;
 	}
}

  mm/hugetlb.c | 2 +-
  1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 01f2b48..0e27a9d 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3502,7 +3502,7 @@ static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
  	 * COW. Warn that such a situation has occurred as it may not be obvious
  	 */
  	if (is_vma_resv_set(vma, HPAGE_RESV_UNMAPPED)) {
-		pr_warning("PID %d killed due to inadequate hugepage pool\n",
+		pr_warn_ratelimited("PID %d killed due to inadequate hugepage pool\n",
  			   current->pid);
  		return ret;
  	}
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
