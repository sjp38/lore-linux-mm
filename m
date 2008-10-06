Received: by nf-out-0910.google.com with SMTP id c10so1339393nfd.6
        for <linux-mm@kvack.org>; Mon, 06 Oct 2008 07:36:53 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: [PATCH, RFC] shmat: introduce flag SHM_MAP_HINT
Date: Mon,  6 Oct 2008 17:37:59 +0300
Message-Id: <1223303879-5555-1-git-send-email-kirill@shutemov.name>
In-Reply-To: <20081006132651.GG3180@one.firstfloor.org>
References: <20081006132651.GG3180@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andi Kleen <andi@firstfloor.org>, Ingo Molnar <mingo@redhat.com>, Arjan van de Ven <arjan@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

It allows interpret attach address as a hint, not as exact address.

Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
Cc: Andi Kleen <andi@firstfloor.org>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Arjan van de Ven <arjan@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 include/linux/shm.h |    1 +
 ipc/shm.c           |    4 ++--
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/linux/shm.h b/include/linux/shm.h
index eca6235..2a637b8 100644
--- a/include/linux/shm.h
+++ b/include/linux/shm.h
@@ -55,6 +55,7 @@ struct shmid_ds {
 #define	SHM_RND		020000	/* round attach address to SHMLBA boundary */
 #define	SHM_REMAP	040000	/* take-over region on attach */
 #define	SHM_EXEC	0100000	/* execution access */
+#define	SHM_MAP_HINT	0200000	/* interpret attach address as a hint */
 
 /* super user shmctl commands */
 #define SHM_LOCK 	11
diff --git a/ipc/shm.c b/ipc/shm.c
index e77ec69..19462bb 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -819,7 +819,7 @@ long do_shmat(int shmid, char __user *shmaddr, int shmflg, ulong *raddr)
 	if (shmid < 0)
 		goto out;
 	else if ((addr = (ulong)shmaddr)) {
-		if (addr & (SHMLBA-1)) {
+		if (!(shmflg & SHM_MAP_HINT) && (addr & (SHMLBA-1))) {
 			if (shmflg & SHM_RND)
 				addr &= ~(SHMLBA-1);	   /* round down */
 			else
@@ -828,7 +828,7 @@ long do_shmat(int shmid, char __user *shmaddr, int shmflg, ulong *raddr)
 #endif
 					goto out;
 		}
-		flags = MAP_SHARED | MAP_FIXED;
+		flags = (shmflg & SHM_MAP_HINT ? 0 : MAP_FIXED) | MAP_SHARED;
 	} else {
 		if ((shmflg & SHM_REMAP))
 			goto out;
-- 
1.5.6.5.GIT

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
