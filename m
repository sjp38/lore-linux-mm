Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 92517C4360F
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 23:51:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4C29220818
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 23:51:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4C29220818
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B34B88E00D5; Thu, 21 Feb 2019 18:51:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B0B7F8E00CD; Thu, 21 Feb 2019 18:51:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 986598E00D5; Thu, 21 Feb 2019 18:51:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 510E38E00CD
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 18:51:11 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id i5so365794pfi.1
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 15:51:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=spn5iYpcMMQcbIoRMSyV5W8LqHdI1+8JkLDgWezzEzY=;
        b=DQ9zY7OjIL2ZBw5BO0LAINE/X8fMIQ8dzYyhOm0ymUmFMskiwq0EAEP6v6oE2L3IcW
         IU78b5t51ZEa8IIxJVqumeSNtwSepsiEAYbxGISPBNFL2L/Gia7o158jY9iN5cH8ggEl
         v558CW+4IoXL4Ra65oOZMvYQBf/SBZA78dQJakDVdk+pX8/5MEcvuJKrkR1qhvOhDjGF
         CFikuXoH/tlmwQ7YH4aqIuap4rlYbyqX9iGebeoALykWO+iRbUeeFw+L9/cWmn6fAq+W
         M1MG0t7ILL+Zm7TwabeLPOMNBcm64Jbs8hM0g8ZqxeWgHXC2Pt4QV/9aaPeu6fb0Jgph
         ybEA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuY9WidCEeW24sF5pzMkjUNTydc74ziyuQMPwnF5aRx8ubAeOIlM
	7XWz1ifQKoXDIdoesiLZT8TUOhaIRVyjQlPDa8x3lk56muuRzW//HCgwORUEk6pY6Fn9HMJB7NO
	D4ZHbCb41bu0Y20NtrEq+7Fs+biG6Xn3UjB+E5gN37/En/fdTqfTvZ/N3h6OoZEOr4Q==
X-Received: by 2002:a17:902:765:: with SMTP id 92mr18755pli.95.1550793070859;
        Thu, 21 Feb 2019 15:51:10 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYPUQU+tCVgqcG6JLVxBGy2G8Z6K0YEq2o2u7+5hbTC/9AqfCRhm+76QILmo4lL9egC4Ac0
X-Received: by 2002:a17:902:765:: with SMTP id 92mr18679pli.95.1550793069202;
        Thu, 21 Feb 2019 15:51:09 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550793069; cv=none;
        d=google.com; s=arc-20160816;
        b=HiKjyXUWkWGTtTM8/wOKsRWNjtjm+dSRzAMlV7/l5A+RLERklukB+B+h1A9IXyO9Ce
         FNos5TUXneuv63ZivExU4s4dyIam0+PaLfZLdUabLA7eV064kCg9tE4fSTYAAI+o60Kd
         +qPVgXmLsWuQzc7JJFPpyEI+ND9C94eOPx/Mhuf8qxE3IaaZdrqqxU9iRPfuzY27EVbM
         MZQUUGeJf9MN2h4+QNcYFm94KMNxjagbIE7G348ukTTqd5HEco7o92LHIaav0PSAxEwz
         dNKb36D8MUaBp3LCQ7sSKJMs7ZZSQ3Y+0LMFMxYTTg+nEpPxVxWiMOVs7lRGU1URp5Yb
         fKVA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=spn5iYpcMMQcbIoRMSyV5W8LqHdI1+8JkLDgWezzEzY=;
        b=oKpyMka73aDBxvZRPzC2H4d5+hc7Nq9Zh3mKSHVFxw3aqqLu3zpMPIceQlgMBqN4xM
         x5a5PVba/O4ME2CsKHIyToE3tmrEIKwLA311R3nCDzLi6DPl7Vp7AIIffksByUWy9hQj
         yYRR96RUtFnnlxhEck1k6vqBN8q0EsTa4ZctO/D6wSNjMksyFIFwF+O/a0wIiUUjAQVc
         V8b5Gq28XSKZIPS0NQjFn7F25iebNwd8FfV1KLZ+gfEQAyaBfe+PEJIjDUSc9iXlZDAx
         8iVnf9TJsNHd4MlENZeD/8jJ0yZpj28c0Cn0Gq4z+Qww4BZLaW1z4o6gYKHq1hW0BOTk
         hWkA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id c4si238494pfn.83.2019.02.21.15.51.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 15:51:09 -0800 (PST)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 21 Feb 2019 15:51:08 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,397,1544515200"; 
   d="scan'208";a="322394943"
Received: from linksys13920.jf.intel.com (HELO rpedgeco-DESK5.jf.intel.com) ([10.54.75.11])
  by fmsmga005.fm.intel.com with ESMTP; 21 Feb 2019 15:51:07 -0800
From: Rick Edgecombe <rick.p.edgecombe@intel.com>
To: Andy Lutomirski <luto@kernel.org>,
	Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org,
	x86@kernel.org,
	hpa@zytor.com,
	Thomas Gleixner <tglx@linutronix.de>,
	Borislav Petkov <bp@alien8.de>,
	Nadav Amit <nadav.amit@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	linux_dti@icloud.com,
	linux-integrity@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	akpm@linux-foundation.org,
	kernel-hardening@lists.openwall.com,
	linux-mm@kvack.org,
	will.deacon@arm.com,
	ard.biesheuvel@linaro.org,
	kristen@linux.intel.com,
	deneen.t.dock@intel.com,
	Rick Edgecombe <rick.p.edgecombe@intel.com>,
	Jessica Yu <jeyu@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>
Subject: [PATCH v3 16/20] modules: Use vmalloc special flag
Date: Thu, 21 Feb 2019 15:44:47 -0800
Message-Id: <20190221234451.17632-17-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190221234451.17632-1-rick.p.edgecombe@intel.com>
References: <20190221234451.17632-1-rick.p.edgecombe@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Use new flag for handling freeing of special permissioned memory in vmalloc
and remove places where memory was set RW before freeing which is no longer
needed.

Since freeing of VM_FLUSH_RESET_PERMS memory is not supported in an
interrupt by vmalloc, the freeing of init sections is moved to a work
queue. Instead of call_rcu it now uses synchronize_rcu() in the work
queue.

Lastly, there is now a WARN_ON in module_memfree since it should not be
called in an interrupt with special memory as is required for
VM_FLUSH_RESET_PERMS.

Cc: Jessica Yu <jeyu@kernel.org>
Cc: Steven Rostedt <rostedt@goodmis.org>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 kernel/module.c | 77 +++++++++++++++++++++++++------------------------
 1 file changed, 39 insertions(+), 38 deletions(-)

diff --git a/kernel/module.c b/kernel/module.c
index ae1b77da6a20..3b97dfb47afb 100644
--- a/kernel/module.c
+++ b/kernel/module.c
@@ -98,6 +98,10 @@ DEFINE_MUTEX(module_mutex);
 EXPORT_SYMBOL_GPL(module_mutex);
 static LIST_HEAD(modules);
 
+/* Work queue for freeing init sections in success case */
+static struct work_struct init_free_wq;
+static struct llist_head init_free_list;
+
 #ifdef CONFIG_MODULES_TREE_LOOKUP
 
 /*
@@ -1949,6 +1953,8 @@ void module_enable_ro(const struct module *mod, bool after_init)
 	if (!rodata_enabled)
 		return;
 
+	set_vm_flush_reset_perms(mod->core_layout.base);
+	set_vm_flush_reset_perms(mod->init_layout.base);
 	frob_text(&mod->core_layout, set_memory_ro);
 	frob_text(&mod->core_layout, set_memory_x);
 
@@ -1972,15 +1978,6 @@ static void module_enable_nx(const struct module *mod)
 	frob_writable_data(&mod->init_layout, set_memory_nx);
 }
 
-static void module_disable_nx(const struct module *mod)
-{
-	frob_rodata(&mod->core_layout, set_memory_x);
-	frob_ro_after_init(&mod->core_layout, set_memory_x);
-	frob_writable_data(&mod->core_layout, set_memory_x);
-	frob_rodata(&mod->init_layout, set_memory_x);
-	frob_writable_data(&mod->init_layout, set_memory_x);
-}
-
 /* Iterate through all modules and set each module's text as RW */
 void set_all_modules_text_rw(void)
 {
@@ -2024,23 +2021,8 @@ void set_all_modules_text_ro(void)
 	}
 	mutex_unlock(&module_mutex);
 }
-
-static void disable_ro_nx(const struct module_layout *layout)
-{
-	if (rodata_enabled) {
-		frob_text(layout, set_memory_rw);
-		frob_rodata(layout, set_memory_rw);
-		frob_ro_after_init(layout, set_memory_rw);
-	}
-	frob_rodata(layout, set_memory_x);
-	frob_ro_after_init(layout, set_memory_x);
-	frob_writable_data(layout, set_memory_x);
-}
-
 #else
-static void disable_ro_nx(const struct module_layout *layout) { }
 static void module_enable_nx(const struct module *mod) { }
-static void module_disable_nx(const struct module *mod) { }
 #endif
 
 #ifdef CONFIG_LIVEPATCH
@@ -2120,6 +2102,11 @@ static void free_module_elf(struct module *mod)
 
 void __weak module_memfree(void *module_region)
 {
+	/*
+	 * This memory may be RO, and freeing RO memory in an interrupt is not
+	 * supported by vmalloc.
+	 */
+	WARN_ON(in_interrupt());
 	vfree(module_region);
 }
 
@@ -2171,7 +2158,6 @@ static void free_module(struct module *mod)
 	mutex_unlock(&module_mutex);
 
 	/* This may be empty, but that's OK */
-	disable_ro_nx(&mod->init_layout);
 	module_arch_freeing_init(mod);
 	module_memfree(mod->init_layout.base);
 	kfree(mod->args);
@@ -2181,7 +2167,6 @@ static void free_module(struct module *mod)
 	lockdep_free_key_range(mod->core_layout.base, mod->core_layout.size);
 
 	/* Finally, free the core (containing the module structure) */
-	disable_ro_nx(&mod->core_layout);
 	module_memfree(mod->core_layout.base);
 }
 
@@ -3424,17 +3409,34 @@ static void do_mod_ctors(struct module *mod)
 
 /* For freeing module_init on success, in case kallsyms traversing */
 struct mod_initfree {
-	struct rcu_head rcu;
+	struct llist_node node;
 	void *module_init;
 };
 
-static void do_free_init(struct rcu_head *head)
+static void do_free_init(struct work_struct *w)
 {
-	struct mod_initfree *m = container_of(head, struct mod_initfree, rcu);
-	module_memfree(m->module_init);
-	kfree(m);
+	struct llist_node *pos, *n, *list;
+	struct mod_initfree *initfree;
+
+	list = llist_del_all(&init_free_list);
+
+	synchronize_rcu();
+
+	llist_for_each_safe(pos, n, list) {
+		initfree = container_of(pos, struct mod_initfree, node);
+		module_memfree(initfree->module_init);
+		kfree(initfree);
+	}
 }
 
+static int __init modules_wq_init(void)
+{
+	INIT_WORK(&init_free_wq, do_free_init);
+	init_llist_head(&init_free_list);
+	return 0;
+}
+module_init(modules_wq_init);
+
 /*
  * This is where the real work happens.
  *
@@ -3511,7 +3513,6 @@ static noinline int do_init_module(struct module *mod)
 #endif
 	module_enable_ro(mod, true);
 	mod_tree_remove_init(mod);
-	disable_ro_nx(&mod->init_layout);
 	module_arch_freeing_init(mod);
 	mod->init_layout.base = NULL;
 	mod->init_layout.size = 0;
@@ -3522,14 +3523,18 @@ static noinline int do_init_module(struct module *mod)
 	 * We want to free module_init, but be aware that kallsyms may be
 	 * walking this with preempt disabled.  In all the failure paths, we
 	 * call synchronize_rcu(), but we don't want to slow down the success
-	 * path, so use actual RCU here.
+	 * path. module_memfree() cannot be called in an interrupt, so do the
+	 * work and call synchronize_rcu() in a work queue.
+	 *
 	 * Note that module_alloc() on most architectures creates W+X page
 	 * mappings which won't be cleaned up until do_free_init() runs.  Any
 	 * code such as mark_rodata_ro() which depends on those mappings to
 	 * be cleaned up needs to sync with the queued work - ie
 	 * rcu_barrier()
 	 */
-	call_rcu(&freeinit->rcu, do_free_init);
+	if (llist_add(&freeinit->node, &init_free_list))
+		schedule_work(&init_free_wq);
+
 	mutex_unlock(&module_mutex);
 	wake_up_all(&module_wq);
 
@@ -3826,10 +3831,6 @@ static int load_module(struct load_info *info, const char __user *uargs,
 	module_bug_cleanup(mod);
 	mutex_unlock(&module_mutex);
 
-	/* we can't deallocate the module until we clear memory protection */
-	module_disable_ro(mod);
-	module_disable_nx(mod);
-
  ddebug_cleanup:
 	ftrace_release_mod(mod);
 	dynamic_debug_remove(mod, info->debug);
-- 
2.17.1

