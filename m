Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8ACD4C282D8
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 18:53:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4B7912184D
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 18:53:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4B7912184D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 03A168E000A; Wed, 30 Jan 2019 13:53:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EDAB38E0001; Wed, 30 Jan 2019 13:53:16 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D56DE8E000A; Wed, 30 Jan 2019 13:53:16 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9CF478E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 13:53:16 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id k66so591803qkf.1
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 10:53:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=Zvr/25sjUglqOodKIBI93iej4LJQYQuAUckPFhdAqQ8=;
        b=aoEDAHN7w2CX9W3cVfN3Za8AtDJTnljvEN7oIKwr9EdMzb8lJgQ7XCjJKZkzToeS1N
         jRDweTohJ4zjRSYHnyhGaLSvUn5PbipbO4ukLdLUlS5/BDs+/E4caeLCZeq0Zzj+rZXR
         RB5dPCUkCCtZpFipm9MMFwhkiP4L3jUvRErHdaiWgfPYKouvuSjN72U31VL3PlX7LwjR
         Zf34houL7usgWcXCq8b5CXmP+Gnn+YuUEzwguNF/Pl/JeR7yEJr1BjL/H6rClzyPlF2n
         pYScHLjfdYWIaZA7i2Vj33OyypWnuFoDIo2Sm20UGGwdi8uwtJEnsc/2BhoGdd4R98jv
         +nmg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukc5o9XjF6T0aOMfxA8xOE2OR/kZSAgXyOdPOj5VmfUfKaA0yQpt
	96qK1DZCr8hprUCSYIt2C1i2K/iwh1Jv5BczG91ae6mV0LxhLSGxd1K/lbNKSVsoRl+qw72PZ+9
	Vfx/vaW4Q5/vOSKQ91XEawSu/vgCd0ggw5eY3uRvr0ADkRsanZsVDT+OHQd8I9sewTQ==
X-Received: by 2002:a0c:d124:: with SMTP id a33mr29211995qvh.19.1548874396292;
        Wed, 30 Jan 2019 10:53:16 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6Ru0uO+js9w6LWvcXEjeUTc6tT8RFNswE+4/KGU5tyiFjrNwLtRh4lTcoZVfDcBKNWuQV9
X-Received: by 2002:a0c:d124:: with SMTP id a33mr29211953qvh.19.1548874395413;
        Wed, 30 Jan 2019 10:53:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548874395; cv=none;
        d=google.com; s=arc-20160816;
        b=Hok2dcUUpU4ilkBvozrbNBZLkmWHvQL+oiOt+U34ZBDiCzo8A3JQ8mlcbIMU4TkhGk
         HttHLlmTWNnq4fMqdyMwQ+0c06fniZQm5/jS68Tu8eLYXkBNX55np0WEx4ZwfVohyS51
         fOXeEwskqg/v76j2uIFXQ6OU3pnxytSl8GcQOyw55HhDifELd51oYVNhaBFSzUh+yZhc
         jpJ4u6r00cX2Mjk7eoznHu+i/coZYpmZ2u14W66OrCE5UcPpRr4hBMnl8XrnXJCHdu0z
         jRcAgvY4Z4TdLqdJmzCi3WQNVKvUojK+GcgDTbRenqrHG4I5Ic8Z3zucPcqE4USRDkQ4
         CQuQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=Zvr/25sjUglqOodKIBI93iej4LJQYQuAUckPFhdAqQ8=;
        b=J3tpuWuuL2aGifkAu8/GlTfroJCPF9h5qHrClQNHbB5HCoDcxL+D2ilA73EllnSEI4
         d8hrNGF1AoYeFMw5j28oAjD1KIzEh/JxhembjY1EHCVqluObdL0hBLph9dHP3O4FClqA
         CQCULqIqbQffDjlYO9DyY3OiqfIJD9fIsUorhNw4KZFXcHbSbImUqksTB3frp34dntl6
         RAE+RgemWZSd9jFa/budGHM2Hkmqi46I0jwIkDTaaIIE0xyocm/Lr3ApknOxtCwW4Aju
         PINry3u7AE9GCynygrZ1oBvPXW14HjeW40rcW2U8Fz3zsZ2q8/gE0eXY0ZNDk346O40w
         Y/QQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u37si1563940qtu.230.2019.01.30.10.53.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 10:53:15 -0800 (PST)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 30B8388E62;
	Wed, 30 Jan 2019 18:53:14 +0000 (UTC)
Received: from llong.com (dhcp-17-59.bos.redhat.com [10.18.17.59])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 57FBD5D6A6;
	Wed, 30 Jan 2019 18:53:12 +0000 (UTC)
From: Waiman Long <longman@redhat.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
	Jonathan Corbet <corbet@lwn.net>,
	Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	linux-doc@vger.kernel.org,
	"Luis R. Rodriguez" <mcgrof@kernel.org>,
	Kees Cook <keescook@chromium.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Jan Kara <jack@suse.cz>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Ingo Molnar <mingo@kernel.org>,
	Miklos Szeredi <mszeredi@redhat.com>,
	Matthew Wilcox <willy@infradead.org>,
	Larry Woodman <lwoodman@redhat.com>,
	James Bottomley <James.Bottomley@HansenPartnership.com>,
	"Wangkai (Kevin C)" <wangkai86@huawei.com>,
	Michal Hocko <mhocko@kernel.org>,
	Waiman Long <longman@redhat.com>
Subject: [RESEND PATCH v4 3/3] fs/dcache: Track & report number of negative dentries
Date: Wed, 30 Jan 2019 13:52:38 -0500
Message-Id: <1548874358-6189-4-git-send-email-longman@redhat.com>
In-Reply-To: <1548874358-6189-1-git-send-email-longman@redhat.com>
References: <1548874358-6189-1-git-send-email-longman@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Wed, 30 Jan 2019 18:53:14 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The current dentry number tracking code doesn't distinguish between
positive & negative dentries. It just reports the total number of
dentries in the LRU lists.

As excessive number of negative dentries can have an impact on system
performance, it will be wise to track the number of positive and
negative dentries separately.

This patch adds tracking for the total number of negative dentries
in the system LRU lists and reports it in the 5th field in the
/proc/sys/fs/dentry-state file. The number, however, does not include
negative dentries that are in flight but not in the LRU yet as well
as those in the shrinker lists which are on the way out anyway.

The number of positive dentries in the LRU lists can be roughly found
by subtracting the number of negative dentries from the unused count.

Matthew Wilcox had confirmed that since the introduction of the
dentry_stat structure in 2.1.60, the dummy array was there, probably for
future extension. They were not replacements of pre-existing fields. So
no sane applications that read the value of /proc/sys/fs/dentry-state
will do dummy thing if the last 2 fields of the sysctl parameter are
not zero. IOW, it will be safe to use one of the dummy array entry for
negative dentry count.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 Documentation/sysctl/fs.txt | 26 ++++++++++++++++----------
 fs/dcache.c                 | 32 ++++++++++++++++++++++++++++++++
 include/linux/dcache.h      |  7 ++++---
 3 files changed, 52 insertions(+), 13 deletions(-)

diff --git a/Documentation/sysctl/fs.txt b/Documentation/sysctl/fs.txt
index 819caf8..58649bd 100644
--- a/Documentation/sysctl/fs.txt
+++ b/Documentation/sysctl/fs.txt
@@ -56,26 +56,32 @@ of any kernel data structures.
 
 dentry-state:
 
-From linux/fs/dentry.c:
+From linux/include/linux/dcache.h:
 --------------------------------------------------------------
-struct {
+struct dentry_stat_t dentry_stat {
         int nr_dentry;
         int nr_unused;
         int age_limit;         /* age in seconds */
         int want_pages;        /* pages requested by system */
-        int dummy[2];
-} dentry_stat = {0, 0, 45, 0,};
--------------------------------------------------------------- 
-
-Dentries are dynamically allocated and deallocated, and
-nr_dentry seems to be 0 all the time. Hence it's safe to
-assume that only nr_unused, age_limit and want_pages are
-used. Nr_unused seems to be exactly what its name says.
+        int nr_negative;       /* # of unused negative dentries */
+        int dummy;             /* Reserved for future use */
+};
+--------------------------------------------------------------
+
+Dentries are dynamically allocated and deallocated.
+
+nr_dentry shows the total number of dentries allocated (active
++ unused). nr_unused shows the number of dentries that are not
+actively used, but are saved in the LRU list for future reuse.
+
 Age_limit is the age in seconds after which dcache entries
 can be reclaimed when memory is short and want_pages is
 nonzero when shrink_dcache_pages() has been called and the
 dcache isn't pruned yet.
 
+nr_negative shows the number of unused dentries that are also
+negative dentries which do not mapped to actual files.
+
 ==============================================================
 
 dquot-max & dquot-nr:
diff --git a/fs/dcache.c b/fs/dcache.c
index 44e5652..aac41ad 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -119,6 +119,7 @@ struct dentry_stat_t dentry_stat = {
 
 static DEFINE_PER_CPU(long, nr_dentry);
 static DEFINE_PER_CPU(long, nr_dentry_unused);
+static DEFINE_PER_CPU(long, nr_dentry_negative);
 
 #if defined(CONFIG_SYSCTL) && defined(CONFIG_PROC_FS)
 
@@ -152,11 +153,22 @@ static long get_nr_dentry_unused(void)
 	return sum < 0 ? 0 : sum;
 }
 
+static long get_nr_dentry_negative(void)
+{
+	int i;
+	long sum = 0;
+
+	for_each_possible_cpu(i)
+		sum += per_cpu(nr_dentry_negative, i);
+	return sum < 0 ? 0 : sum;
+}
+
 int proc_nr_dentry(struct ctl_table *table, int write, void __user *buffer,
 		   size_t *lenp, loff_t *ppos)
 {
 	dentry_stat.nr_dentry = get_nr_dentry();
 	dentry_stat.nr_unused = get_nr_dentry_unused();
+	dentry_stat.nr_negative = get_nr_dentry_negative();
 	return proc_doulongvec_minmax(table, write, buffer, lenp, ppos);
 }
 #endif
@@ -317,6 +329,8 @@ static inline void __d_clear_type_and_inode(struct dentry *dentry)
 	flags &= ~(DCACHE_ENTRY_TYPE | DCACHE_FALLTHRU);
 	WRITE_ONCE(dentry->d_flags, flags);
 	dentry->d_inode = NULL;
+	if (dentry->d_flags & DCACHE_LRU_LIST)
+		this_cpu_inc(nr_dentry_negative);
 }
 
 static void dentry_free(struct dentry *dentry)
@@ -371,6 +385,11 @@ static void dentry_unlink_inode(struct dentry * dentry)
  * The per-cpu "nr_dentry_unused" counters are updated with
  * the DCACHE_LRU_LIST bit.
  *
+ * The per-cpu "nr_dentry_negative" counters are only updated
+ * when deleted from or added to the per-superblock LRU list, not
+ * from/to the shrink list. That is to avoid an unneeded dec/inc
+ * pair when moving from LRU to shrink list in select_collect().
+ *
  * These helper functions make sure we always follow the
  * rules. d_lock must be held by the caller.
  */
@@ -380,6 +399,8 @@ static void d_lru_add(struct dentry *dentry)
 	D_FLAG_VERIFY(dentry, 0);
 	dentry->d_flags |= DCACHE_LRU_LIST;
 	this_cpu_inc(nr_dentry_unused);
+	if (d_is_negative(dentry))
+		this_cpu_inc(nr_dentry_negative);
 	WARN_ON_ONCE(!list_lru_add(&dentry->d_sb->s_dentry_lru, &dentry->d_lru));
 }
 
@@ -388,6 +409,8 @@ static void d_lru_del(struct dentry *dentry)
 	D_FLAG_VERIFY(dentry, DCACHE_LRU_LIST);
 	dentry->d_flags &= ~DCACHE_LRU_LIST;
 	this_cpu_dec(nr_dentry_unused);
+	if (d_is_negative(dentry))
+		this_cpu_dec(nr_dentry_negative);
 	WARN_ON_ONCE(!list_lru_del(&dentry->d_sb->s_dentry_lru, &dentry->d_lru));
 }
 
@@ -418,6 +441,8 @@ static void d_lru_isolate(struct list_lru_one *lru, struct dentry *dentry)
 	D_FLAG_VERIFY(dentry, DCACHE_LRU_LIST);
 	dentry->d_flags &= ~DCACHE_LRU_LIST;
 	this_cpu_dec(nr_dentry_unused);
+	if (d_is_negative(dentry))
+		this_cpu_dec(nr_dentry_negative);
 	list_lru_isolate(lru, &dentry->d_lru);
 }
 
@@ -426,6 +451,8 @@ static void d_lru_shrink_move(struct list_lru_one *lru, struct dentry *dentry,
 {
 	D_FLAG_VERIFY(dentry, DCACHE_LRU_LIST);
 	dentry->d_flags |= DCACHE_SHRINK_LIST;
+	if (d_is_negative(dentry))
+		this_cpu_dec(nr_dentry_negative);
 	list_lru_isolate_move(lru, &dentry->d_lru, list);
 }
 
@@ -1816,6 +1843,11 @@ static void __d_instantiate(struct dentry *dentry, struct inode *inode)
 	WARN_ON(d_in_lookup(dentry));
 
 	spin_lock(&dentry->d_lock);
+	/*
+	 * Decrement negative dentry count if it was in the LRU list.
+	 */
+	if (dentry->d_flags & DCACHE_LRU_LIST)
+		this_cpu_dec(nr_dentry_negative);
 	hlist_add_head(&dentry->d_u.d_alias, &inode->i_dentry);
 	raw_write_seqcount_begin(&dentry->d_seq);
 	__d_set_inode_and_type(dentry, inode, add_flags);
diff --git a/include/linux/dcache.h b/include/linux/dcache.h
index ef4b70f..60996e6 100644
--- a/include/linux/dcache.h
+++ b/include/linux/dcache.h
@@ -62,9 +62,10 @@ struct qstr {
 struct dentry_stat_t {
 	long nr_dentry;
 	long nr_unused;
-	long age_limit;          /* age in seconds */
-	long want_pages;         /* pages requested by system */
-	long dummy[2];
+	long age_limit;		/* age in seconds */
+	long want_pages;	/* pages requested by system */
+	long nr_negative;	/* # of unused negative dentries */
+	long dummy;		/* Reserved for future use */
 };
 extern struct dentry_stat_t dentry_stat;
 
-- 
1.8.3.1

