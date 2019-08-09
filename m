Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E49E3C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 22:59:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 97F7C208C4
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 22:59:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 97F7C208C4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 721546B0271; Fri,  9 Aug 2019 18:59:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6AAD16B0272; Fri,  9 Aug 2019 18:59:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 572D66B0273; Fri,  9 Aug 2019 18:59:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 14AD36B0271
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 18:59:11 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id e25so62414975pfn.5
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 15:59:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=86nnNDFin5NGIDuIbZP6nLJ89Qnmc/o+qzx9kACIDco=;
        b=ElkBeSFK7Hu7D0Vq31glJyJ5FQXZsXhlV0Ybb3tXSUKCxNy04yZZ+DIpFF2cVmn752
         BJ48nT0V86TWNXZR+bBegtlF6SYI55zCahrKyMww9ZskxTeKUc0Sk4HB6W//HskMfedN
         Y5n+vaF392zCFfACEl1J1uJq8wZXLKuiVcnhHhDNDR8iJ/6ozIGuWwQ2sG/2l6EnRxSS
         7Qg4O2K7l2N2MYS2xo1d9hHoin59r5UcexYDtACqa2wYMniBuyw+TGq1FV6H0jzPEbOY
         6HqQ12EPkMCMrHCAdbh9+jMEMWKQG2jG+TXP96Y37xDRTgPwZwYiuL4iIH1YC8kwg5wS
         1utA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXc/6SwwJ38y1djw4lveMwUSwF/bO0OkdwL6iIlTgcL9ctPNHg4
	p3RGOFflbUX5ZLCxhwYSINJoqicWM3/JW/RFO0ZqCUwiGDs1tdg9nos58ggXI88PxqnQYZgisWn
	8C28qrYlpAaNrMGKNvAwN013cwRWqeCvVC7WtvtWPZl+F0chZUvc2e/FMGBxz5nJjDw==
X-Received: by 2002:a63:fe15:: with SMTP id p21mr13506393pgh.149.1565391550625;
        Fri, 09 Aug 2019 15:59:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzbaF/ogLgoAnPb5Ga6H+p8GfIyz5pxJYrpu5TKeFuTybG96thFXwBSNmC5jFik6WDRu+hx
X-Received: by 2002:a63:fe15:: with SMTP id p21mr13506339pgh.149.1565391549240;
        Fri, 09 Aug 2019 15:59:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565391549; cv=none;
        d=google.com; s=arc-20160816;
        b=g/1OftbS6Odj6jAHt6SY9CDHM3scTMTK4wT41s5g58ZrxyVv1/zE0/+7bhSLT7Z9ne
         RD6ICpj1G3jFBvDphIdP7afR0Q2AhH2++LL8DzmSktkZ5Kr3VCLCokxdsOLy+SH+laRE
         qDxrAcJRL/ni+qGgrIrV/VMKNcuy8njR8Yfhfgt072O5mxfA1u9rX30D4I0V67AQ8NOo
         Q77bYv+piX/5cKCbPRLReH0WocyF+/ze3ed1QtzQYxS4n8c0AsPz562HFJx9tE49Qlab
         9BVus9/kK+HaioSDmuGkdEKanuqym2pR0FZE0b9ojlJ/5qXd/F91C7QVVozql24bXBLp
         yhDw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=86nnNDFin5NGIDuIbZP6nLJ89Qnmc/o+qzx9kACIDco=;
        b=QpdTq4/IS1SYOyjs5HQ0MiP9g3TbwJHAmpCIG9b4Q2HcHQl5FxJGf25v+SQhQB3qV0
         AfMmv1Zim8lnARTUTDV+WGy2idpg+iSC3d55TA3X2mbWlBl/Q3nGiCMgiOsA778UDJOy
         rv3cDGCkJwY1Y1gissnx2oo1qe6ujNFkPr/HLv93TkIqffLhtPy3yVTeDCU1+t+nPQIr
         HpW7EqTns3w56askWtoreqirMt2fFxqEzo4jaCLxxt5C2+44Y9gjuPRrtUR3b8UaaNfO
         9F68qmPcvh5EuBEiHTXRF/PBBZfW8DGbZSXBTN9uvQhkbE7QQ2gpWtL1Un882hKso0Z6
         0PfA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id g7si49662014plp.171.2019.08.09.15.59.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 15:59:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga004.fm.intel.com ([10.253.24.48])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 Aug 2019 15:59:08 -0700
X-IronPort-AV: E=Sophos;i="5.64,367,1559545200"; 
   d="scan'208";a="199539307"
Received: from iweiny-desk2.sc.intel.com (HELO localhost) ([10.3.52.157])
  by fmsmga004-auth.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 Aug 2019 15:59:08 -0700
From: ira.weiny@intel.com
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jason Gunthorpe <jgg@ziepe.ca>,
	Dan Williams <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	Jan Kara <jack@suse.cz>,
	"Theodore Ts'o" <tytso@mit.edu>,
	John Hubbard <jhubbard@nvidia.com>,
	Michal Hocko <mhocko@suse.com>,
	Dave Chinner <david@fromorbit.com>,
	linux-xfs@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-nvdimm@lists.01.org,
	linux-ext4@vger.kernel.org,
	linux-mm@kvack.org,
	Ira Weiny <ira.weiny@intel.com>
Subject: [RFC PATCH v2 18/19] {mm,procfs}: Add display file_pins proc
Date: Fri,  9 Aug 2019 15:58:32 -0700
Message-Id: <20190809225833.6657-19-ira.weiny@intel.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190809225833.6657-1-ira.weiny@intel.com>
References: <20190809225833.6657-1-ira.weiny@intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Ira Weiny <ira.weiny@intel.com>

Now that we have the file pins information stored add a new procfs entry
to display them to the user.

NOTE output will be dependant on where the file pin is tied to.  Some
processes may have the pin associated with a file descriptor in which
case that file is reported as well.

Others are associated directly with the process mm and are reported as
such.

For example of a file pinned to an RDMA open context (fd 4) and a file
pinned to the mm of that process:

4: /dev/infiniband/uverbs0
   /mnt/pmem/foo
/mnt/pmem/bar

Signed-off-by: Ira Weiny <ira.weiny@intel.com>
---
 fs/proc/base.c | 214 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 214 insertions(+)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index ebea9501afb8..f4d219172235 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -2995,6 +2995,7 @@ static int proc_stack_depth(struct seq_file *m, struct pid_namespace *ns,
  */
 static const struct file_operations proc_task_operations;
 static const struct inode_operations proc_task_inode_operations;
+static const struct file_operations proc_pid_file_pins_operations;
 
 static const struct pid_entry tgid_base_stuff[] = {
 	DIR("task",       S_IRUGO|S_IXUGO, proc_task_inode_operations, proc_task_operations),
@@ -3024,6 +3025,7 @@ static const struct pid_entry tgid_base_stuff[] = {
 	ONE("stat",       S_IRUGO, proc_tgid_stat),
 	ONE("statm",      S_IRUGO, proc_pid_statm),
 	REG("maps",       S_IRUGO, proc_pid_maps_operations),
+	REG("file_pins",  S_IRUGO, proc_pid_file_pins_operations),
 #ifdef CONFIG_NUMA
 	REG("numa_maps",  S_IRUGO, proc_pid_numa_maps_operations),
 #endif
@@ -3422,6 +3424,7 @@ static const struct pid_entry tid_base_stuff[] = {
 	ONE("stat",      S_IRUGO, proc_tid_stat),
 	ONE("statm",     S_IRUGO, proc_pid_statm),
 	REG("maps",      S_IRUGO, proc_pid_maps_operations),
+	REG("file_pins", S_IRUGO, proc_pid_file_pins_operations),
 #ifdef CONFIG_PROC_CHILDREN
 	REG("children",  S_IRUGO, proc_tid_children_operations),
 #endif
@@ -3718,3 +3721,214 @@ void __init set_proc_pid_nlink(void)
 	nlink_tid = pid_entry_nlink(tid_base_stuff, ARRAY_SIZE(tid_base_stuff));
 	nlink_tgid = pid_entry_nlink(tgid_base_stuff, ARRAY_SIZE(tgid_base_stuff));
 }
+
+/**
+ * file_pin information below.
+ */
+
+struct proc_file_pins_private {
+	struct inode *inode;
+	struct task_struct *task;
+	struct mm_struct *mm;
+	struct files_struct *files;
+	unsigned int nr_pins;
+	struct xarray fps;
+} __randomize_layout;
+
+static void release_fp(struct proc_file_pins_private *priv)
+{
+	up_read(&priv->mm->mmap_sem);
+	mmput(priv->mm);
+}
+
+static void print_fd_file_pin(struct seq_file *m, struct file *file,
+			    unsigned long i)
+{
+	struct file_file_pin *fp;
+	struct file_file_pin *tmp;
+
+	if (list_empty_careful(&file->file_pins))
+		return;
+
+	seq_printf(m, "%lu: ", i);
+	seq_file_path(m, file, "\n");
+	seq_putc(m, '\n');
+
+	list_for_each_entry_safe(fp, tmp, &file->file_pins, list) {
+		seq_puts(m, "   ");
+		seq_file_path(m, fp->file, "\n");
+		seq_putc(m, '\n');
+	}
+}
+
+/* We are storing the index's within the FD table for later retrieval */
+static int store_fd(const void *priv , struct file *file, unsigned i)
+{
+	struct proc_file_pins_private *fp_priv;
+
+	/* cast away const... */
+	fp_priv = (struct proc_file_pins_private *)priv;
+
+	if (list_empty_careful(&file->file_pins))
+		return 0;
+
+	/* can't sleep in the iterate of the fd table */
+	xa_store(&fp_priv->fps, fp_priv->nr_pins, xa_mk_value(i), GFP_ATOMIC);
+	fp_priv->nr_pins++;
+
+	return 0;
+}
+
+static void store_mm_pins(struct proc_file_pins_private *priv)
+{
+	struct mm_file_pin *fp;
+	struct mm_file_pin *tmp;
+
+	list_for_each_entry_safe(fp, tmp, &priv->mm->file_pins, list) {
+		xa_store(&priv->fps, priv->nr_pins, fp, GFP_KERNEL);
+		priv->nr_pins++;
+	}
+}
+
+
+static void *fp_start(struct seq_file *m, loff_t *ppos)
+{
+	struct proc_file_pins_private *priv = m->private;
+	unsigned int pos = *ppos;
+
+	priv->task = get_proc_task(priv->inode);
+	if (!priv->task)
+		return ERR_PTR(-ESRCH);
+
+	if (!priv->mm || !mmget_not_zero(priv->mm))
+		return NULL;
+
+	priv->files = get_files_struct(priv->task);
+	down_read(&priv->mm->mmap_sem);
+
+	xa_destroy(&priv->fps);
+	priv->nr_pins = 0;
+
+	/* grab fds of "files" which have pins and store as xa values */
+	if (priv->files)
+		iterate_fd(priv->files, 0, store_fd, priv);
+
+	/* store mm_file_pins as xa entries */
+	store_mm_pins(priv);
+
+	if (pos >= priv->nr_pins) {
+		release_fp(priv);
+		return NULL;
+	}
+
+	return xa_load(&priv->fps, pos);
+}
+
+static void *fp_next(struct seq_file *m, void *v, loff_t *pos)
+{
+	struct proc_file_pins_private *priv = m->private;
+
+	(*pos)++;
+	if ((*pos) >= priv->nr_pins) {
+		release_fp(priv);
+		return NULL;
+	}
+
+	return xa_load(&priv->fps, *pos);
+}
+
+static void fp_stop(struct seq_file *m, void *v)
+{
+	struct proc_file_pins_private *priv = m->private;
+
+	if (v)
+		release_fp(priv);
+
+	if (priv->task) {
+		put_task_struct(priv->task);
+		priv->task = NULL;
+	}
+
+	if (priv->files) {
+		put_files_struct(priv->files);
+		priv->files = NULL;
+	}
+}
+
+static int show_fp(struct seq_file *m, void *v)
+{
+	struct proc_file_pins_private *priv = m->private;
+
+	if (xa_is_value(v)) {
+		struct file *file;
+		unsigned long fd = xa_to_value(v);
+
+		rcu_read_lock();
+		file = fcheck_files(priv->files, fd);
+		if (file)
+			print_fd_file_pin(m, file, fd);
+		rcu_read_unlock();
+	} else {
+		struct mm_file_pin *fp = v;
+
+		seq_puts(m, "mm: ");
+		seq_file_path(m, fp->file, "\n");
+	}
+
+	return 0;
+}
+
+static const struct seq_operations proc_pid_file_pins_op = {
+	.start	= fp_start,
+	.next	= fp_next,
+	.stop	= fp_stop,
+	.show	= show_fp
+};
+
+static int proc_file_pins_open(struct inode *inode, struct file *file)
+{
+	struct proc_file_pins_private *priv = __seq_open_private(file,
+						&proc_pid_file_pins_op,
+						sizeof(*priv));
+
+	if (!priv)
+		return -ENOMEM;
+
+	xa_init(&priv->fps);
+	priv->inode = inode;
+	priv->mm = proc_mem_open(inode, PTRACE_MODE_READ);
+	priv->task = NULL;
+	if (IS_ERR(priv->mm)) {
+		int err = PTR_ERR(priv->mm);
+
+		seq_release_private(inode, file);
+		return err;
+	}
+
+	return 0;
+}
+
+static int proc_file_pins_release(struct inode *inode, struct file *file)
+{
+	struct seq_file *seq = file->private_data;
+	struct proc_file_pins_private *priv = seq->private;
+
+	/* This is for "protection" not sure when these may end up not being
+	 * NULL here... */
+	WARN_ON(priv->files);
+	WARN_ON(priv->task);
+
+	if (priv->mm)
+		mmdrop(priv->mm);
+
+	xa_destroy(&priv->fps);
+
+	return seq_release_private(inode, file);
+}
+
+static const struct file_operations proc_pid_file_pins_operations = {
+	.open		= proc_file_pins_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= proc_file_pins_release,
+};
-- 
2.20.1

