Return-Path: <SRS0=L4L0=TB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8868C43219
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 14:03:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 639E821670
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 14:03:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 639E821670
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 63B376B000A; Wed,  1 May 2019 10:03:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 577546B000C; Wed,  1 May 2019 10:03:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 465B36B000D; Wed,  1 May 2019 10:03:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1065F6B000A
	for <linux-mm@kvack.org>; Wed,  1 May 2019 10:03:05 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id o1so10937820pgv.15
        for <linux-mm@kvack.org>; Wed, 01 May 2019 07:03:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=7acaSsTP2QALuxWExVoR0p4F9gaaZz2fpAryeyJhftE=;
        b=PsDYwhT6L8CQwPyjyyLpFLCvfKTYTNAJwkXH892RC0NlIVQ3uOplPVJXznIFtw2HYU
         /M4ZXO16dRHwY8NGPSlCv2+LPmP8eDttnQHdEl0uxOCLzEZM5JrfJE5qmP60m9w0Q9UF
         3zXmsK1evSzK/Op9hfJN4xcJLgmT93I+rnp3UVdyE4hxlnA06ZJoQs+/FtT6LDpRJMnq
         6gcQlxtaAgYtoV2/0YQopSOfjISl/obPBeu7eZDZog1r8ywqRdWSAdPabaUc64X/ApJU
         oGE5PIui/643FKE1SeUmT7YHgoRsgAz1b2h+Cb7B7g8angct2Z5nxpPh65bHqDF1YEPy
         YJqg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of brian.welty@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=brian.welty@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUI17kzQjhUPGSMsilZm88ByMATL1VzvuGHLlHFY4X7VycVD1Mu
	mtIjzTPKnLR9Jq7extv2rCy1jtzvII3/lqy9Vid8JzvLTSj5fhkDby9YgaZepAwzdtWp85I4iYa
	17lqSgHQ7f2oxb2CJhoMf7VU1oiqcwL32yis3m8fIOyJzTGZq6wHryoo4aJu5cayKVw==
X-Received: by 2002:a63:f115:: with SMTP id f21mr73297886pgi.65.1556719384623;
        Wed, 01 May 2019 07:03:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwXbRDUbs5VWm7dKBmui270eCJ5kxjVwIkMecfqasEw/FSD5HJd6HUs7MxMqfltq3bcexhU
X-Received: by 2002:a63:f115:: with SMTP id f21mr73297739pgi.65.1556719383307;
        Wed, 01 May 2019 07:03:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556719383; cv=none;
        d=google.com; s=arc-20160816;
        b=ud1EBwvCXOSbfXYQev4bfM9I+bmY778qvgmYuCpN5aWngmK9BAlzclnRMjyRc4cQM3
         PkvnwXWzwrVnwnS85EpNnlA1tbQbA472bjFfnTlH+xMG/mG03jsHKtk29dKRKhWhjEkp
         ijsMIIGRTGwVryeIw6x4AgXpda5xN2I822gkCr7EUKTSrAGtA0HJDz5L4B4dkTBxnd0i
         3Z2sHkWY3nByaKrPeZ1RSPg+O2+auCT0JEclyjTX+teA2PdwkeWeOc0p53nKRnSg1ViM
         edfTMgTqLBXpctFscVClJGzITWpzq7OPQk0uXBL025Ve28dSNM66nWjCNGWOXPTQ+vw/
         rsXQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:to:from;
        bh=7acaSsTP2QALuxWExVoR0p4F9gaaZz2fpAryeyJhftE=;
        b=0hG4H4uDjGFv6ZZos32/7TJl00lAM2jlZt6tsNBUx1uY6Jbp/8Ah9b8FEcUgHr0yPc
         HJdvPuurLq1he7fAZZ01NrSD8VupMKBcBcWFvKhxFnKeKVlTlycuNYDM6O3KQJ1IygCo
         5FmR4N4RKZANQlZoLTcFRAjkCPIzNaxnbFzny/+4IfSTjr9bccKxpR1/oM1f7geo/7lm
         tqvVXFfyBQ2JxREMTrAVGmCbY4WE0c9l1eOf6wrDMQkbho0UccX90iQFUawg+h9qTXHK
         od+iIfjQt4bOIcsrpJgWXAFo/JoLJYungkdoCUozu8S8a8Q9nplcW5ozWR9/UIOONoYV
         bYEg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of brian.welty@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=brian.welty@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id q25si38000486pgv.534.2019.05.01.07.03.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 May 2019 07:03:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of brian.welty@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of brian.welty@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=brian.welty@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga008.fm.intel.com ([10.253.24.58])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 01 May 2019 07:03:02 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,417,1549958400"; 
   d="scan'208";a="145141398"
Received: from nperf12.hd.intel.com ([10.127.88.161])
  by fmsmga008.fm.intel.com with ESMTP; 01 May 2019 07:03:01 -0700
From: Brian Welty <brian.welty@intel.com>
To: cgroups@vger.kernel.org,
	Tejun Heo <tj@kernel.org>,
	Li Zefan <lizefan@huawei.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	linux-mm@kvack.org,
	Michal Hocko <mhocko@kernel.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	dri-devel@lists.freedesktop.org,
	David Airlie <airlied@linux.ie>,
	Daniel Vetter <daniel@ffwll.ch>,
	intel-gfx@lists.freedesktop.org,
	Jani Nikula <jani.nikula@linux.intel.com>,
	Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
	Rodrigo Vivi <rodrigo.vivi@intel.com>,
	=?UTF-8?q?Christian=20K=C3=B6nig?= <christian.koenig@amd.com>,
	Alex Deucher <alexander.deucher@amd.com>,
	ChunMing Zhou <David1.Zhou@amd.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [RFC PATCH 2/5] cgroup: Change kernfs_node for directories to store cgroup_subsys_state
Date: Wed,  1 May 2019 10:04:35 -0400
Message-Id: <20190501140438.9506-3-brian.welty@intel.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190501140438.9506-1-brian.welty@intel.com>
References: <20190501140438.9506-1-brian.welty@intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Change the kernfs_node.priv to store the cgroup_subsys_state (CSS) pointer
for directories, instead of storing cgroup pointer.  This is done in order
to support files within the cgroup associated with devices.  We require
of_css() to return the device-specific CSS pointer for these files.

Cc: cgroups@vger.kernel.org
Signed-off-by: Brian Welty <brian.welty@intel.com>
---
 kernel/cgroup/cgroup-v1.c | 10 ++++----
 kernel/cgroup/cgroup.c    | 48 +++++++++++++++++----------------------
 2 files changed, 27 insertions(+), 31 deletions(-)

diff --git a/kernel/cgroup/cgroup-v1.c b/kernel/cgroup/cgroup-v1.c
index c126b34fd4ff..4fa56cc2b99c 100644
--- a/kernel/cgroup/cgroup-v1.c
+++ b/kernel/cgroup/cgroup-v1.c
@@ -723,6 +723,7 @@ int proc_cgroupstats_show(struct seq_file *m, void *v)
 int cgroupstats_build(struct cgroupstats *stats, struct dentry *dentry)
 {
 	struct kernfs_node *kn = kernfs_node_from_dentry(dentry);
+	struct cgroup_subsys_state *css;
 	struct cgroup *cgrp;
 	struct css_task_iter it;
 	struct task_struct *tsk;
@@ -740,12 +741,13 @@ int cgroupstats_build(struct cgroupstats *stats, struct dentry *dentry)
 	 * @kn->priv is RCU safe.  Let's do the RCU dancing.
 	 */
 	rcu_read_lock();
-	cgrp = rcu_dereference(*(void __rcu __force **)&kn->priv);
-	if (!cgrp || cgroup_is_dead(cgrp)) {
+	css = rcu_dereference(*(void __rcu __force **)&kn->priv);
+	if (!css || cgroup_is_dead(css->cgroup)) {
 		rcu_read_unlock();
 		mutex_unlock(&cgroup_mutex);
 		return -ENOENT;
 	}
+	cgrp = css->cgroup;
 	rcu_read_unlock();
 
 	css_task_iter_start(&cgrp->self, 0, &it);
@@ -851,7 +853,7 @@ void cgroup1_release_agent(struct work_struct *work)
 static int cgroup1_rename(struct kernfs_node *kn, struct kernfs_node *new_parent,
 			  const char *new_name_str)
 {
-	struct cgroup *cgrp = kn->priv;
+	struct cgroup_subsys_state *css = kn->priv;
 	int ret;
 
 	if (kernfs_type(kn) != KERNFS_DIR)
@@ -871,7 +873,7 @@ static int cgroup1_rename(struct kernfs_node *kn, struct kernfs_node *new_parent
 
 	ret = kernfs_rename(kn, new_parent, new_name_str);
 	if (!ret)
-		TRACE_CGROUP_PATH(rename, cgrp);
+		TRACE_CGROUP_PATH(rename, css->cgroup);
 
 	mutex_unlock(&cgroup_mutex);
 
diff --git a/kernel/cgroup/cgroup.c b/kernel/cgroup/cgroup.c
index 9b035e728941..1fe4fee502ea 100644
--- a/kernel/cgroup/cgroup.c
+++ b/kernel/cgroup/cgroup.c
@@ -595,12 +595,13 @@ static void cgroup_get_live(struct cgroup *cgrp)
 
 struct cgroup_subsys_state *of_css(struct kernfs_open_file *of)
 {
-	struct cgroup *cgrp = of->kn->parent->priv;
+	struct cgroup_subsys_state *css = of->kn->parent->priv;
 	struct cftype *cft = of_cft(of);
 
-	/* FIXME this needs updating to lookup device-specific CSS */
-
 	/*
+	 * If the cft specifies a subsys and this is not a device file,
+	 * then lookup the css, otherwise it is already correct.
+	 *
 	 * This is open and unprotected implementation of cgroup_css().
 	 * seq_css() is only called from a kernfs file operation which has
 	 * an active reference on the file.  Because all the subsystem
@@ -608,10 +609,9 @@ struct cgroup_subsys_state *of_css(struct kernfs_open_file *of)
 	 * the matching css from the cgroup's subsys table is guaranteed to
 	 * be and stay valid until the enclosing operation is complete.
 	 */
-	if (cft->ss)
-		return rcu_dereference_raw(cgrp->subsys[cft->ss->id]);
-	else
-		return &cgrp->self;
+	if (cft->ss && !css->device)
+		css = rcu_dereference_raw(css->cgroup->subsys[cft->ss->id]);
+	return css;
 }
 EXPORT_SYMBOL_GPL(of_css);
 
@@ -1524,12 +1524,14 @@ static u16 cgroup_calc_subtree_ss_mask(u16 subtree_control, u16 this_ss_mask)
  */
 void cgroup_kn_unlock(struct kernfs_node *kn)
 {
+	struct cgroup_subsys_state *css;
 	struct cgroup *cgrp;
 
 	if (kernfs_type(kn) == KERNFS_DIR)
-		cgrp = kn->priv;
+		css = kn->priv;
 	else
-		cgrp = kn->parent->priv;
+		css = kn->parent->priv;
+	cgrp = css->cgroup;
 
 	mutex_unlock(&cgroup_mutex);
 
@@ -1556,12 +1558,14 @@ void cgroup_kn_unlock(struct kernfs_node *kn)
  */
 struct cgroup *cgroup_kn_lock_live(struct kernfs_node *kn, bool drain_offline)
 {
+	struct cgroup_subsys_state *css;
 	struct cgroup *cgrp;
 
 	if (kernfs_type(kn) == KERNFS_DIR)
-		cgrp = kn->priv;
+		css = kn->priv;
 	else
-		cgrp = kn->parent->priv;
+		css = kn->parent->priv;
+	cgrp = css->cgroup;
 
 	/*
 	 * We're gonna grab cgroup_mutex which nests outside kernfs
@@ -1652,7 +1656,7 @@ static int cgroup_device_mkdir(struct cgroup_subsys_state *css)
 	if (WARN_ON_ONCE(ret >= CGROUP_FILE_NAME_MAX))
 		return 0;
 
-	kn = kernfs_create_dir(cgrp->kn, name, cgrp->kn->mode, cgrp);
+	kn = kernfs_create_dir(cgrp->kn, name, cgrp->kn->mode, css);
 	if (IS_ERR(kn))
 		return PTR_ERR(kn);
 	css->device_kn = kn;
@@ -1662,7 +1666,7 @@ static int cgroup_device_mkdir(struct cgroup_subsys_state *css)
 		/* FIXME: prefix dev_name with bus_name for uniqueness? */
 		kn = kernfs_create_dir(css->device_kn,
 				       dev_name(device_css->device),
-				       cgrp->kn->mode, cgrp);
+				       cgrp->kn->mode, device_css);
 		if (IS_ERR(kn))
 			return PTR_ERR(kn);
 		/* FIXME: kernfs_get needed here? */
@@ -2025,7 +2029,7 @@ int cgroup_setup_root(struct cgroup_root *root, u16 ss_mask)
 	root->kf_root = kernfs_create_root(kf_sops,
 					   KERNFS_ROOT_CREATE_DEACTIVATED |
 					   KERNFS_ROOT_SUPPORT_EXPORTOP,
-					   root_cgrp);
+					   &root_cgrp->self);
 	if (IS_ERR(root->kf_root)) {
 		ret = PTR_ERR(root->kf_root);
 		goto exit_root_id;
@@ -3579,9 +3583,9 @@ static ssize_t cgroup_file_write(struct kernfs_open_file *of, char *buf,
 				 size_t nbytes, loff_t off)
 {
 	struct cgroup_namespace *ns = current->nsproxy->cgroup_ns;
-	struct cgroup *cgrp = of->kn->parent->priv;
+	struct cgroup_subsys_state *css = of_css(of);
 	struct cftype *cft = of->kn->priv;
-	struct cgroup_subsys_state *css;
+	struct cgroup *cgrp = css->cgroup;
 	int ret;
 
 	/*
@@ -3598,16 +3602,6 @@ static ssize_t cgroup_file_write(struct kernfs_open_file *of, char *buf,
 	if (cft->write)
 		return cft->write(of, buf, nbytes, off);
 
-	/*
-	 * kernfs guarantees that a file isn't deleted with operations in
-	 * flight, which means that the matching css is and stays alive and
-	 * doesn't need to be pinned.  The RCU locking is not necessary
-	 * either.  It's just for the convenience of using cgroup_css().
-	 */
-	rcu_read_lock();
-	css = cgroup_css(cgrp, cft->ss);
-	rcu_read_unlock();
-
 	if (cft->write_u64) {
 		unsigned long long v;
 		ret = kstrtoull(buf, 0, &v);
@@ -5262,7 +5256,7 @@ int cgroup_mkdir(struct kernfs_node *parent_kn, const char *name, umode_t mode)
 	}
 
 	/* create the directory */
-	kn = kernfs_create_dir(parent->kn, name, mode, cgrp);
+	kn = kernfs_create_dir(parent->kn, name, mode, &cgrp->self);
 	if (IS_ERR(kn)) {
 		ret = PTR_ERR(kn);
 		goto out_destroy;
-- 
2.21.0

