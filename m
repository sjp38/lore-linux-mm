Return-Path: <SRS0=h8p8=S5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.8 required=3.0 tests=DATE_IN_PAST_06_12,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7FD6AC4321A
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 06:44:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 25E41208C2
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 06:44:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="JIPBw61l"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 25E41208C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EA1F56B0273; Sat, 27 Apr 2019 02:43:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E4FF26B0274; Sat, 27 Apr 2019 02:43:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CF3D16B0275; Sat, 27 Apr 2019 02:43:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 94E9F6B0273
	for <linux-mm@kvack.org>; Sat, 27 Apr 2019 02:43:32 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id o1so3479123pgv.15
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 23:43:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=FbRVtA2o2v3UWbAlXvOdnbyNDEqG2rBMqLF6HOTpV1U=;
        b=gUoRhI3QuTeuaGBO/Q4abzZtEd32oRMYMnQWIZqqKPxOLMvSVDiu/AWUR0F8XfIVv/
         em2VpotUOBZbzn9Aeb/cjHCjc1kESO6h0gZ61eRF1un8syPf0vkTJ+R7uQTnCYaIckDW
         EOF8578BZYbcJyRpXXHoRKMrgGBWC3pMu9Xthuo3xnfva3Tczv9qbvgVUGvAwovhxuH3
         0Jk7kEQvtmlEUlefMCMYkL2Wr3+wYQfNA4edwxESxVEIVaqNR7nVD216DxrO0CTPKPEn
         i/zWDipB29b8qNuSpU9LFOxpRAegOLAR6rmg/BsMkmwFjDiMIINE1bD36WloCw7sVHsf
         7pFw==
X-Gm-Message-State: APjAAAVkobb2TKJurOAb0wwoxr7GS9mMh6acT26udoqPEM2NNTc654Pa
	eeD/c8bB7ytYaOsSYBT7Bc0kHbpXwtUMCXjobjInbeH6nlDzg8AIjl0u1YXbdAS2YJrazEh6ANq
	jNWSw14aNDjkEPUMQ99LZVIWYB5vZACDGQxfmIneOnxmPkL7pkjK5CHVJES03JjH4gQ==
X-Received: by 2002:a65:5304:: with SMTP id m4mr23472570pgq.281.1556347412249;
        Fri, 26 Apr 2019 23:43:32 -0700 (PDT)
X-Received: by 2002:a65:5304:: with SMTP id m4mr23472493pgq.281.1556347410951;
        Fri, 26 Apr 2019 23:43:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556347410; cv=none;
        d=google.com; s=arc-20160816;
        b=kZ+MIXpJdsR3eH73BQ2JbxKb5ylUgMt8kbfsfTXPMBsXYeG27wSkc1uB8Ik1wNf6wG
         JOb2IwghBwZB/X+3tQpjmcsEQO5kWBB1GMrqlBOXxRdSIHbli9fITZAMjXjfaipvpU2f
         GJ8bH4hKYQCSHscCBr8BnQ148tSOykStgYoszKxw9uukLE13VsLaG4gP8m9jzjY6NOuX
         I7fkaQO9o4czqh4Vdm/yhL9twraJ2j5l02xfO+qo6GkUiF3SNYDWYt7hmkWIeb1ftZnq
         wDdswsdzVCU9onOn41vDbf9TsOMeQGR+tatNr8EhLnpdtGoVJZJtO/tGfK6jwvW2nPot
         k+yA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=FbRVtA2o2v3UWbAlXvOdnbyNDEqG2rBMqLF6HOTpV1U=;
        b=lVgIf1v6WwLZlTrxj1oqG7RcmmSUgYnLjcK15P9vOCY14bpH2Jp663O3IcymYGi+Ea
         3nPITejfQX1dYuoMm2llr2heddyRtGoSKU/3P3M3RYyC3bWINdYYaRzbb7YJ6gVsiTUg
         vUnkciUUmBRs2zbTaie54O1Tn5PB4Nf5KLyeU8rxKnKB9i8ltldtk7yvOgOT+2lBRGez
         gNboILEERw+jDv3UsNsY3rvQ8HbFTrxuJw///Z6uQiVoYdeEyv1wbbfcIScsZUTNsgQq
         /lz8EkXaQfsoomg3TLZmApobj/ubyJCjw0Icf6VJnM9ONMTOvXQKRNrex92tzwKSl8bf
         A12Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=JIPBw61l;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a12sor2766182pgw.35.2019.04.26.23.43.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Apr 2019 23:43:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=JIPBw61l;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=FbRVtA2o2v3UWbAlXvOdnbyNDEqG2rBMqLF6HOTpV1U=;
        b=JIPBw61lhFhbsSeNNRCeinW8YzpjhHLS0kAFQAbk6hxmpp9hUg6J0GnYaKJNU0FHKf
         3bqKVJ6C8Tvx6TJOkuOrWJna7fqoUuHizJ+qKiMIA5CS7CEShzqQKK/AW7XLnX200hVn
         h6Uo9w63gy2P9k2VG6r72+XF0lb0lBkXJJXjhuCTEIV+s2i43bDAgsF9azMi0JLNH7ed
         aF+f6J70rXkPNjBlMKsdUnSwpqHyYUKOSX8pNfq8+bcRkjXvPZVggFfZsbJYWh1FzF5C
         WOAREpo4S3btT9Orow8C8eatHDMaItBqA+/J+o0vl9gjb3c0Jf12Oahj1tktHyDbSwU0
         U95A==
X-Google-Smtp-Source: APXvYqym7OynpsRkDmNxinoK0RlpSBEGSXR11tkqmQ4UsD/W+17lELi4duQgGdmbTXOTa0GEeSPAlA==
X-Received: by 2002:a63:df43:: with SMTP id h3mr48430342pgj.294.1556347410385;
        Fri, 26 Apr 2019 23:43:30 -0700 (PDT)
Received: from sc2-haas01-esx0118.eng.vmware.com ([66.170.99.1])
        by smtp.gmail.com with ESMTPSA id j22sm36460145pfn.129.2019.04.26.23.43.29
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 23:43:29 -0700 (PDT)
From: nadav.amit@gmail.com
To: Peter Zijlstra <peterz@infradead.org>,
	Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@kernel.org>,
	Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org,
	x86@kernel.org,
	hpa@zytor.com,
	Thomas Gleixner <tglx@linutronix.de>,
	Nadav Amit <nadav.amit@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
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
Subject: [PATCH v6 18/24] modules: Use vmalloc special flag
Date: Fri, 26 Apr 2019 16:22:57 -0700
Message-Id: <20190426232303.28381-19-nadav.amit@gmail.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190426232303.28381-1-nadav.amit@gmail.com>
References: <20190426232303.28381-1-nadav.amit@gmail.com>
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

