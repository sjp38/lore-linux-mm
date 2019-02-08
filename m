Return-Path: <SRS0=ikTF=QP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 873CDC169C4
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 22:44:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3637521908
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 22:44:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chrisdown.name header.i=@chrisdown.name header.b="XqsDTNDB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3637521908
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chrisdown.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CD2F48E00A6; Fri,  8 Feb 2019 17:44:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C83448E00A1; Fri,  8 Feb 2019 17:44:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B73518E00A6; Fri,  8 Feb 2019 17:44:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 605F08E00A1
	for <linux-mm@kvack.org>; Fri,  8 Feb 2019 17:44:23 -0500 (EST)
Received: by mail-wm1-f71.google.com with SMTP id b12so1699045wme.5
        for <linux-mm@kvack.org>; Fri, 08 Feb 2019 14:44:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:in-reply-to:user-agent;
        bh=mjddCA9wdnVApIjl0ZZ2ZUbqGTtZyeVvjAgYguybxu8=;
        b=Fu3JiG3y0DHL39luxoGrhiQ44k40LKHXk0oNjr2iZkrLeZcFd3a8TgbMgBjTCGwVxH
         LO4K2f0dbLqA/X9sq20NCYXXcoNd+GeEdFiLDCpjWpARdXhE1CoGEke9KCTmaRLPj0zu
         TEpAfA8SjgefaoY8GgyMbvzyMP2lbXnX4tPuhloH31JRXUleOSscPMPXSWk35LNlzVfA
         up9dCgWpQ8Qkiyha3yi4/kr4QH7ZKV3OC0BNBlJuk8ce57B4/9OEHnfg8X9aLPXpQbl/
         yfVxpKiC42lI5E/qFQEM8jTkHcs4y7gfYe2z0+vQ1MJFi78+Ka6MkGP0rSJ5sCaq2VGF
         fPHw==
X-Gm-Message-State: AHQUAuYeeD8MuGwkgk1YqFJdoQ8hlDLXHJlRudaaisrswxZxr1l6hKXQ
	pyfBuhktFlx6n/AtW2MxTuIsIur/9WAg6bPzhTfkmCnajPX4CbsiOeDHdSLhWqcD4mgp/SAM+6K
	WV6+kOK2RIR5Yi6gJQ1ru7eMkAM4vcnTXlFqn8tVJaB1BNvQCueu8FYYXEGTeqs5U0fWRDyjzsH
	WRWQk1Owej+PV5mtB+B++6Dd6cScoeNM3qIXeUP5ur3/opQtsFxDR0MfF2OSu/IjXb2psDEPgcB
	pLxnJC2PPJyU/MbjuC+Fvpn1GiqLYfWQXBB3Z2lh/ZpZy8zzMKeYAHMnk9eW7JQUbljv+ePQE5s
	nfjrULRrpV42re5e4DzUpqz12hEhUIVi/7DnQINln6M0Nn434bVKBTcnHNYDPVxsHoETdLXvzw5
	Y
X-Received: by 2002:a1c:2457:: with SMTP id k84mr545727wmk.139.1549665862865;
        Fri, 08 Feb 2019 14:44:22 -0800 (PST)
X-Received: by 2002:a1c:2457:: with SMTP id k84mr545684wmk.139.1549665861875;
        Fri, 08 Feb 2019 14:44:21 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549665861; cv=none;
        d=google.com; s=arc-20160816;
        b=BEOdbGvnSk4JkzfAM/gFDh0IaKPhoWiQS3sqDxsMnV2m2nTyF0fJ9BqXOGygeuRcCc
         8NfyR44bmzIidLxgitRKQYdlJn0RhPRo6yR13NDGm6no4rRu6bbRNGJmYq1e1psQHJHc
         E9f6YBWX34oFwiyxeYB2J8wwVBlNN7OSCBwntWu/z9wfYdWK3kW1w9Sc1SdoGUubLtxk
         MHP9KCJpA1PFn2mwc5KqQqsB5IlayNHul+aj67fNRrM8snvHiSkPR2NjYccmTZpt0lnn
         SE7HEYBMod1wVIX1nlsaN+tdndFKRamEWsYVXOrz2gDJVdSXO78Is09lMGBSjfVFmoSO
         SSVw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=mjddCA9wdnVApIjl0ZZ2ZUbqGTtZyeVvjAgYguybxu8=;
        b=OoQiITqWiD/X+tVd9803W1dKOTM2VqtFvXHVZX0ivPlOqGoQUMarNXjNasv0d5o7FN
         FGckP4GTTqcsXRrHQAjeTvOy5HKEoRyHAyPWO3jB2O8jKbGDU/VLX3rO6rIWg7+/DtvO
         siapQl7pglYLVOwUmpu8T1N9XttT/UTAiMpS5NgdpFeQUEU3PdFIeBOAmRhFqDRbKzXp
         R1s329q6Si8TA7n+q72rp7pcUMqZ1JW7wZCPw+pDqknemGQ4Z2a6WqA4bIobqYmaZJNd
         9fDttfG28XMwk8tVl/TYly7gCgnWUwfUoqE6wwZixR+CEWOO0M073oQxBWUmoYfoGR3a
         F8sw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=XqsDTNDB;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v18sor2297282wrs.5.2019.02.08.14.44.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 08 Feb 2019 14:44:21 -0800 (PST)
Received-SPF: pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=XqsDTNDB;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chrisdown.name; s=google;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=mjddCA9wdnVApIjl0ZZ2ZUbqGTtZyeVvjAgYguybxu8=;
        b=XqsDTNDBEVx/mbh2ors4k2T4HQm+KlJh5iPPedK9W1L3xXjwkynI8mquKSDUWUkZFU
         5crlPxrdHaBR8UCng3p+GwZoGlMLK+gfEhV45GVwmIN89dTq78TdfNpmODXiy0NeRSI3
         +mYQPXQABF7Fe4il0jUCr/qbgyJX7HR0XRiuc=
X-Google-Smtp-Source: AHgI3IZrIz22DHsEm5og7JU9ItbxvH87IOn6+aZPQV5DDYMo6CRHGcmeabBZbmORw18mnqG32olfDg==
X-Received: by 2002:adf:e68c:: with SMTP id r12mr18140699wrm.163.1549665861446;
        Fri, 08 Feb 2019 14:44:21 -0800 (PST)
Received: from localhost (host-92-23-118-117.as13285.net. [92.23.118.117])
        by smtp.gmail.com with ESMTPSA id j24sm5394080wrd.86.2019.02.08.14.44.20
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 08 Feb 2019 14:44:20 -0800 (PST)
Date: Fri, 8 Feb 2019 22:44:19 +0000
From: Chris Down <chris@chrisdown.name>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>,
	Tejun Heo <tj@kernel.org>, Roman Gushchin <guro@fb.com>,
	Dennis Zhou <dennis@kernel.org>, linux-kernel@vger.kernel.org,
	cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com
Subject: [PATCH v2 2/2] mm: Consider subtrees in memory.events
Message-ID: <20190208224419.GA24772@chrisdown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190208224319.GA23801@chrisdown.name>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

memory.stat and other files already consider subtrees in their output,
and we should too in order to not present an inconsistent interface.

The current situation is fairly confusing, because people interacting
with cgroups expect hierarchical behaviour in the vein of memory.stat,
cgroup.events, and other files. For example, this causes confusion when
debugging reclaim events under low, as currently these always read "0"
at non-leaf memcg nodes, which frequently causes people to misdiagnose
breach behaviour. The same confusion applies to other counters in this
file when debugging issues.

Aggregation is done at write time instead of at read-time since these
counters aren't hot (unlike memory.stat which is per-page, so it does it
at read time), and it makes sense to bundle this with the file
notifications.

After this patch, events are propagated up the hierarchy:

    [root@ktst ~]# cat /sys/fs/cgroup/system.slice/memory.events
    low 0
    high 0
    max 0
    oom 0
    oom_kill 0
    [root@ktst ~]# systemd-run -p MemoryMax=1 true
    Running as unit: run-r251162a189fb4562b9dabfdc9b0422f5.service
    [root@ktst ~]# cat /sys/fs/cgroup/system.slice/memory.events
    low 0
    high 0
    max 7
    oom 1
    oom_kill 1

As this is a change in behaviour, this can be reverted to the old
behaviour by mounting with the `memory_localevents` flag set. However,
we use the new behaviour by default as there's a lack of evidence that
there are any current users of memory.events that would find this change
undesirable.

Signed-off-by: Chris Down <chris@chrisdown.name>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Roman Gushchin <guro@fb.com>
Cc: Dennis Zhou <dennis@kernel.org>
Cc: linux-kernel@vger.kernel.org
Cc: cgroups@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: kernel-team@fb.com
---
 Documentation/admin-guide/cgroup-v2.rst |  9 +++++++++
 include/linux/cgroup-defs.h             |  5 +++++
 include/linux/memcontrol.h              | 10 ++++++++--
 kernel/cgroup/cgroup.c                  | 16 ++++++++++++++--
 4 files changed, 36 insertions(+), 4 deletions(-)

diff --git a/Documentation/admin-guide/cgroup-v2.rst b/Documentation/admin-guide/cgroup-v2.rst
index ab9f3ee4ca33..841eb80f32d2 100644
--- a/Documentation/admin-guide/cgroup-v2.rst
+++ b/Documentation/admin-guide/cgroup-v2.rst
@@ -177,6 +177,15 @@ cgroup v2 currently supports the following mount options.
 	ignored on non-init namespace mounts.  Please refer to the
 	Delegation section for details.
 
+  memory_localevents
+
+        Only populate memory.events with data for the current cgroup,
+        and not any subtrees. This is legacy behaviour, the default
+        behaviour without this option is to include subtree counts.
+        This option is system wide and can only be set on mount or
+        modified through remount from the init namespace. The mount
+        option is ignored on non-init namespace mounts.
+
 
 Organizing Processes and Threads
 --------------------------------
diff --git a/include/linux/cgroup-defs.h b/include/linux/cgroup-defs.h
index 1c70803e9f77..53669fdd5fad 100644
--- a/include/linux/cgroup-defs.h
+++ b/include/linux/cgroup-defs.h
@@ -83,6 +83,11 @@ enum {
 	 * Enable cpuset controller in v1 cgroup to use v2 behavior.
 	 */
 	CGRP_ROOT_CPUSET_V2_MODE = (1 << 4),
+
+	/*
+	 * Enable legacy local memory.events.
+	 */
+	CGRP_ROOT_MEMORY_LOCAL_EVENTS = (1 << 5),
 };
 
 /* cftype->flags */
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 94f9c5bc26ff..534267947664 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -789,8 +789,14 @@ static inline void count_memcg_event_mm(struct mm_struct *mm,
 static inline void memcg_memory_event(struct mem_cgroup *memcg,
 				      enum memcg_memory_event event)
 {
-	atomic_long_inc(&memcg->memory_events[event]);
-	cgroup_file_notify(&memcg->events_file);
+	do {
+		atomic_long_inc(&memcg->memory_events[event]);
+		cgroup_file_notify(&memcg->events_file);
+
+		if (cgrp_dfl_root.flags & CGRP_ROOT_MEMORY_LOCAL_EVENTS)
+			break;
+	} while ((memcg = parent_mem_cgroup(memcg)) &&
+		 !mem_cgroup_is_root(memcg));
 }
 
 static inline void memcg_memory_event_mm(struct mm_struct *mm,
diff --git a/kernel/cgroup/cgroup.c b/kernel/cgroup/cgroup.c
index 3f2b4bde0f9c..46e3bce3c7bc 100644
--- a/kernel/cgroup/cgroup.c
+++ b/kernel/cgroup/cgroup.c
@@ -1775,11 +1775,13 @@ int cgroup_show_path(struct seq_file *sf, struct kernfs_node *kf_node,
 
 enum cgroup2_param {
 	Opt_nsdelegate,
+	Opt_memory_localevents,
 	nr__cgroup2_params
 };
 
 static const struct fs_parameter_spec cgroup2_param_specs[] = {
-	fsparam_flag  ("nsdelegate",		Opt_nsdelegate),
+	fsparam_flag("nsdelegate",		Opt_nsdelegate),
+	fsparam_flag("memory_localevents",	Opt_memory_localevents),
 	{}
 };
 
@@ -1802,6 +1804,9 @@ static int cgroup2_parse_param(struct fs_context *fc, struct fs_parameter *param
 	case Opt_nsdelegate:
 		ctx->flags |= CGRP_ROOT_NS_DELEGATE;
 		return 0;
+	case Opt_memory_localevents:
+		ctx->flags |= CGRP_ROOT_MEMORY_LOCAL_EVENTS;
+		return 0;
 	}
 	return -EINVAL;
 }
@@ -1813,6 +1818,11 @@ static void apply_cgroup_root_flags(unsigned int root_flags)
 			cgrp_dfl_root.flags |= CGRP_ROOT_NS_DELEGATE;
 		else
 			cgrp_dfl_root.flags &= ~CGRP_ROOT_NS_DELEGATE;
+
+		if (root_flags & CGRP_ROOT_MEMORY_LOCAL_EVENTS)
+			cgrp_dfl_root.flags |= CGRP_ROOT_MEMORY_LOCAL_EVENTS;
+		else
+			cgrp_dfl_root.flags &= ~CGRP_ROOT_MEMORY_LOCAL_EVENTS;
 	}
 }
 
@@ -1820,6 +1830,8 @@ static int cgroup_show_options(struct seq_file *seq, struct kernfs_root *kf_root
 {
 	if (cgrp_dfl_root.flags & CGRP_ROOT_NS_DELEGATE)
 		seq_puts(seq, ",nsdelegate");
+	if (cgrp_dfl_root.flags & CGRP_ROOT_MEMORY_LOCAL_EVENTS)
+		seq_puts(seq, ",memory_localevents");
 	return 0;
 }
 
@@ -6116,7 +6128,7 @@ static struct kobj_attribute cgroup_delegate_attr = __ATTR_RO(delegate);
 static ssize_t features_show(struct kobject *kobj, struct kobj_attribute *attr,
 			     char *buf)
 {
-	return snprintf(buf, PAGE_SIZE, "nsdelegate\n");
+	return snprintf(buf, PAGE_SIZE, "nsdelegate\nmemory_localevents\n");
 }
 static struct kobj_attribute cgroup_features_attr = __ATTR_RO(features);
 
-- 
2.20.1

