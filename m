Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f53.google.com (mail-yh0-f53.google.com [209.85.213.53])
	by kanga.kvack.org (Postfix) with ESMTP id 97C7D6B0035
	for <linux-mm@kvack.org>; Mon, 25 Nov 2013 18:33:25 -0500 (EST)
Received: by mail-yh0-f53.google.com with SMTP id b20so3472527yha.12
        for <linux-mm@kvack.org>; Mon, 25 Nov 2013 15:33:25 -0800 (PST)
Received: from mail-yh0-x233.google.com (mail-yh0-x233.google.com [2607:f8b0:4002:c01::233])
        by mx.google.com with ESMTPS id e2si22117000yhm.100.2013.11.25.15.33.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 25 Nov 2013 15:33:24 -0800 (PST)
Received: by mail-yh0-f51.google.com with SMTP id c41so1895115yho.38
        for <linux-mm@kvack.org>; Mon, 25 Nov 2013 15:33:24 -0800 (PST)
Date: Mon, 25 Nov 2013 15:33:22 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, mempolicy: remove unneeded functions for UMA configs
In-Reply-To: <alpine.DEB.2.02.1311251529260.5495@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.02.1311251530550.5495@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1311121811310.29891@chino.kir.corp.google.com> <20131120141534.06ea091ca53b1dec60ace63d@linux-foundation.org> <CAHGf_=ooNHx=2HeUDGxrZFma-6YRvL42ViDMkSOqLOffk8MVsw@mail.gmail.com> <20131125123108.79c80eb59c2b1bc41c879d9e@linux-foundation.org>
 <alpine.DEB.2.02.1311251529260.5495@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Fengguang Wu <fengguang.wu@intel.com>, Kees Cook <keescook@chromium.org>, Rik van Riel <riel@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Mempolicies only exist for CONFIG_NUMA configurations.  Therefore, a 
certain class of functions are unneeded in configurations where 
CONFIG_NUMA is disabled such as functions that duplicate existing 
mempolicies, lookup existing policies, set certain mempolicy traits, or 
test mempolicies for certain attributes.

Remove the unneeded functions so that any future callers get a compile-
time error and protect their code with CONFIG_NUMA as required.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/mempolicy.h | 32 --------------------------------
 1 file changed, 32 deletions(-)

diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
--- a/include/linux/mempolicy.h
+++ b/include/linux/mempolicy.h
@@ -211,20 +211,8 @@ static inline void mpol_get(struct mempolicy *pol)
 {
 }
 
-static inline struct mempolicy *mpol_dup(struct mempolicy *old)
-{
-	return NULL;
-}
-
 struct shared_policy {};
 
-static inline int mpol_set_shared_policy(struct shared_policy *info,
-					struct vm_area_struct *vma,
-					struct mempolicy *new)
-{
-	return -EINVAL;
-}
-
 static inline void mpol_shared_policy_init(struct shared_policy *sp,
 						struct mempolicy *mpol)
 {
@@ -234,12 +222,6 @@ static inline void mpol_free_shared_policy(struct shared_policy *p)
 {
 }
 
-static inline struct mempolicy *
-mpol_shared_policy_lookup(struct shared_policy *sp, unsigned long idx)
-{
-	return NULL;
-}
-
 #define vma_policy(vma) NULL
 
 static inline int
@@ -266,10 +248,6 @@ static inline void mpol_rebind_mm(struct mm_struct *mm, nodemask_t *new)
 {
 }
 
-static inline void mpol_fix_fork_child_flag(struct task_struct *p)
-{
-}
-
 static inline struct zonelist *huge_zonelist(struct vm_area_struct *vma,
 				unsigned long addr, gfp_t gfp_flags,
 				struct mempolicy **mpol, nodemask_t **nodemask)
@@ -284,12 +262,6 @@ static inline bool init_nodemask_of_mempolicy(nodemask_t *m)
 	return false;
 }
 
-static inline bool mempolicy_nodemask_intersects(struct task_struct *tsk,
-			const nodemask_t *mask)
-{
-	return false;
-}
-
 static inline int do_migrate_pages(struct mm_struct *mm, const nodemask_t *from,
 				   const nodemask_t *to, int flags)
 {
@@ -307,10 +279,6 @@ static inline int mpol_parse_str(char *str, struct mempolicy **mpol)
 }
 #endif
 
-static inline void mpol_to_str(char *buffer, int maxlen, struct mempolicy *pol)
-{
-}
-
 static inline int mpol_misplaced(struct page *page, struct vm_area_struct *vma,
 				 unsigned long address)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
