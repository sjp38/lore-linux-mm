Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.9 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 90665C43218
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 07:32:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 432F52084F
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 07:32:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 432F52084F
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8FFCA6B026A; Fri, 26 Apr 2019 03:31:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3C0C76B0270; Fri, 26 Apr 2019 03:31:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 08D5A6B026D; Fri, 26 Apr 2019 03:31:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id A984F6B026F
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 03:31:49 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id w9so1438369plz.11
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 00:31:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version;
        bh=FbRVtA2o2v3UWbAlXvOdnbyNDEqG2rBMqLF6HOTpV1U=;
        b=Z3u5wIwIBnB6ljuegUedpWsH3t7W3hBMpGduIIPtrOyRcvx7Vuy4cafuVBzU7ch+go
         kWbfpAiqmsl1skOC8hsUHJfTveAQv8MeRD0lm4HLXvjQkuf2sK3fXrNtpWJLkGtmg0fH
         35LSIK2fgWYVNOczL3pZgTPvNOxB8rMZB/8ceNiK3BQmqzWMPC5Vhmu6lChch1e1mQQN
         uT0lws0vJ1oZrBYwX3z9ULvISKwQFLjiss1C21kXVLC+r/kFkM51EbrYFPqBD3di1Ihi
         U/36Kc3Kwli5wCS9FOCWoRptnuVkNXSvk0Wjv2c6knAx9rNkNSWdSlndMRstRrBClSlt
         CJ6w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=namit@vmware.com;       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
X-Gm-Message-State: APjAAAVPWWUobIfJcTaAXO01BX64lGAD8JpR1ppPbevFETsvXnNeh3nU
	aTduxp2mvNO9Ja3hTnsfK6+1wZTWoGtl9OZc0k4T3ULQWoqTRP6vESYm77xHNQCFE6xFwBiuLHg
	Eu4pnNQXHR/H5tbJeGUEPUAlhAa1ipE5J5uX5q7jCYG9nkGueUD7m1sxG0dYnELvqNQ==
X-Received: by 2002:a17:902:3183:: with SMTP id x3mr44271753plb.170.1556263909317;
        Fri, 26 Apr 2019 00:31:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz+olJwuJJKGfoagbm7Kix/nVhOeGf+kuu2frF5QRzp6oSNzLb9fV4Nuzlgolap9v50YJS9
X-Received: by 2002:a17:902:3183:: with SMTP id x3mr44271679plb.170.1556263908323;
        Fri, 26 Apr 2019 00:31:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556263908; cv=none;
        d=google.com; s=arc-20160816;
        b=ds9fLNlEtNYEvRHrUVuT2jIWzODiFEFXnfTw+Msyjz+wzo5mbp8S6t/eIepgya5uIV
         1BTEV1Oy8CeO9luOZaC0dNwqMYTza8POM1xNa2coMQYnP/V8T7VFY9UzpzviSgiLdndS
         JtyTqSHwYNqnSB5Y/UPX2AyS5dX12off0RuZJZHmYgs/55NYBGlQ7fQVge5ZD7ePzcQo
         JqXdsViSbX1b1N7i8S0Fr5/PykE31X/Us8Gij/Ydehv8uSYmRpxBNuZ/XWrvmFlR4VmB
         eYOYsG7MiE3EeIV+HB3PCDVOAWLNv+dGRXQ3bqS42mxHLHta5q7QC9WqX+xuU9Ctjly3
         MZFw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from;
        bh=FbRVtA2o2v3UWbAlXvOdnbyNDEqG2rBMqLF6HOTpV1U=;
        b=iwKv2GKmk46z3ivRqgWRuly/IzbrN0aEAzqGYds/xf+diZq1slSTwnw4qZqbmV7Ttq
         bTGnxwcnHpRBk21x62qUXzwXtmmjdlfD/DP36jBtJ2ld8dULYY/pe4ozUIFyXmvkR2N+
         LH61SoqiZdmwRrtn/JnMHZ+mYCTC1du3Juob4IanVzVNCaehmGMG+KjDs+pJQuDvpZd/
         N25WMK5iz1knT3NYl0xwblR/iUnTrcl93XZ/nP9EXD3iRlqFIzw89HxnXbA3zYiFz+Hi
         C5TJYs2kU22jHTmpdMCcRZRZOwh/WCmswfnnWhbozew7KK7ZMNMZu7OAEPJ276GDu+Km
         BNtg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from EX13-EDG-OU-002.vmware.com (ex13-edg-ou-002.vmware.com. [208.91.0.190])
        by mx.google.com with ESMTPS id f9si22844507pgq.347.2019.04.26.00.31.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 26 Apr 2019 00:31:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) client-ip=208.91.0.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from sc9-mailhost3.vmware.com (10.113.161.73) by
 EX13-EDG-OU-002.vmware.com (10.113.208.156) with Microsoft SMTP Server id
 15.0.1156.6; Fri, 26 Apr 2019 00:31:44 -0700
Received: from sc2-haas01-esx0118.eng.vmware.com (sc2-haas01-esx0118.eng.vmware.com [10.172.44.118])
	by sc9-mailhost3.vmware.com (Postfix) with ESMTP id F2B3F41225;
	Fri, 26 Apr 2019 00:31:45 -0700 (PDT)
From: Nadav Amit <namit@vmware.com>
To: Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>
CC: <linux-kernel@vger.kernel.org>, <x86@kernel.org>, <hpa@zytor.com>, Thomas
 Gleixner <tglx@linutronix.de>, Nadav Amit <nadav.amit@gmail.com>, Dave Hansen
	<dave.hansen@linux.intel.com>, <linux_dti@icloud.com>,
	<linux-integrity@vger.kernel.org>, <linux-security-module@vger.kernel.org>,
	<akpm@linux-foundation.org>, <kernel-hardening@lists.openwall.com>,
	<linux-mm@kvack.org>, <will.deacon@arm.com>, <ard.biesheuvel@linaro.org>,
	<kristen@linux.intel.com>, <deneen.t.dock@intel.com>, Rick Edgecombe
	<rick.p.edgecombe@intel.com>, Jessica Yu <jeyu@kernel.org>, Steven Rostedt
	<rostedt@goodmis.org>
Subject: [PATCH v5 17/23] modules: Use vmalloc special flag
Date: Thu, 25 Apr 2019 17:11:37 -0700
Message-ID: <20190426001143.4983-18-namit@vmware.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190426001143.4983-1-namit@vmware.com>
References: <20190426001143.4983-1-namit@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain
Received-SPF: None (EX13-EDG-OU-002.vmware.com: namit@vmware.com does not
 designate permitted sender hosts)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Rick Edgecombe <rick.p.edgecombe@intel.com>

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
index 2b2845ae983e..a9020bdd4cf6 100644
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
 
@@ -3420,17 +3405,34 @@ static void do_mod_ctors(struct module *mod)
 
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
@@ -3507,7 +3509,6 @@ static noinline int do_init_module(struct module *mod)
 #endif
 	module_enable_ro(mod, true);
 	mod_tree_remove_init(mod);
-	disable_ro_nx(&mod->init_layout);
 	module_arch_freeing_init(mod);
 	mod->init_layout.base = NULL;
 	mod->init_layout.size = 0;
@@ -3518,14 +3519,18 @@ static noinline int do_init_module(struct module *mod)
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
 
@@ -3822,10 +3827,6 @@ static int load_module(struct load_info *info, const char __user *uargs,
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

