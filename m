Return-Path: <SRS0=BwCX=U4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 99B78C5B57B
	for <linux-mm@archiver.kernel.org>; Sat, 29 Jun 2019 22:34:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 437D3214DA
	for <linux-mm@archiver.kernel.org>; Sat, 29 Jun 2019 22:34:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 437D3214DA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=zeniv.linux.org.uk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D3C366B0003; Sat, 29 Jun 2019 18:34:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D121D8E0003; Sat, 29 Jun 2019 18:34:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C02738E0002; Sat, 29 Jun 2019 18:34:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f77.google.com (mail-wr1-f77.google.com [209.85.221.77])
	by kanga.kvack.org (Postfix) with ESMTP id 72CE06B0003
	for <linux-mm@kvack.org>; Sat, 29 Jun 2019 18:34:23 -0400 (EDT)
Received: by mail-wr1-f77.google.com with SMTP id e6so3963960wrv.20
        for <linux-mm@kvack.org>; Sat, 29 Jun 2019 15:34:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent:sender;
        bh=rp8j40SoRkzCKQdEcuJO9PM/MWN5Mli3bf34V1KXVGo=;
        b=HtgIH6WykfKgpSSn4c/ZRUKfrMzM0+jZBCZfz68L+wBODJTCtEU8I3cg/v8BhPXcOu
         CvEXE2m+wnmINmFHfdlBVqVd8RHiUmN9ah1dVMk/dk8k4fgL++2rtEhiE9NbgkKo+50q
         3roE9dNkq+3xBURW3VBLQQJT7XB3nSUjhx5vW5s2I9An5UUL/91OuhLKZ3K3D7+krTNS
         1+fJZpLB5jVZr6uCPsx94CSqBZHrEb3RGYIRInf0A24imPnyjqrsxImKgagJvXhmcDK8
         pLEI87Fw2e1E5ldFjOoWdrEqyDSi8HEk2GtsMi4C/55pyE104YkWgZRUZeD+tRmAU5dL
         48gA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) smtp.mailfrom=viro@ftp.linux.org.uk
X-Gm-Message-State: APjAAAWDqnfaw9ELCMomWv8fcW3EPMvaQdTygNV1ePF2btLTWk5CK0fg
	lwWWta1oJJ4uMaCZoUyyRO5yGldjn3ZQmK7G/CnZwfkNlrYKcJtGCtMQ97z8gmMYzmbh4x7dw4y
	K5B98y0MNGOPZI3rocUsQlVQO4NH16xJXRGNsdjUQHAsiOY8xjgxjd2RWfF9ntcGO+Q==
X-Received: by 2002:a05:600c:118a:: with SMTP id i10mr11328661wmf.162.1561847662910;
        Sat, 29 Jun 2019 15:34:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyUPkyq4qFyJYVm4sFoJc8hx2SmmQVqJCaKGhMWIg12fI+EUzIw1cxBMHTJjD2fAJdeWdlG
X-Received: by 2002:a05:600c:118a:: with SMTP id i10mr11328642wmf.162.1561847661936;
        Sat, 29 Jun 2019 15:34:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561847661; cv=none;
        d=google.com; s=arc-20160816;
        b=m9V6aAwxlxHVE5SMvjZkdmdKnqqwSlf4OWz2Dhdx7Jaxg69FxS7UmG4vYy2cuNfBVZ
         lriZiLjfXs6kS4G5wTutP7scWsU2XrbfwUlvT0L+yWl6hFcTkSjaoCdPEDe0beIoeRD1
         gMIoKSOqUIhrUTwSxNB2GzaLvMzGuai5AX7c08h7GjD5ByAhx6j/jppYEattjHdtk97K
         gWRwgDHSY9yP0V/p4TB+qfqLaE/nQfE5k/XLT+NfVsnWzTixrBxDftY2CGAYKr9NHvjQ
         J9pYIhy+Asuit/RZkf7zlqUahxqOGPlPbdAatoQvNzOq216Qslm6afy+HFIpMh3gDPt7
         ORgQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=sender:user-agent:in-reply-to:content-disposition:mime-version
         :references:message-id:subject:cc:to:from:date;
        bh=rp8j40SoRkzCKQdEcuJO9PM/MWN5Mli3bf34V1KXVGo=;
        b=YDe5+GYywjjpG4T6MOFjHI85zIz5NSH0oHYtqq2ny0E+r16VzV7arrblOjOwkRrKrb
         9DHw5hrPUtZeOc4o1GM4nTN5MSPAvTn2Ev7mqIHIDXrlKI6k7it1Z5oA+gDX6agp+tnF
         ERsMv+khf5kHJD14A4h55F8Fc2EqDFYvWXf4hj6Dq1nVv9OGpd8SnKBCnBFlfpIkAIZV
         b6HHdIqOwa8/HfNIsLNTGHkkynFLqGWFbDErNxEY1hFagRNOTBgkSTi18bKxVWAypyDx
         tu2nvrJyqPSJxbiETm6oLA94ReUE7djJD3RWvREm9w9tjvb4At066KdbNxqdfhFrKwEP
         Akxg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) smtp.mailfrom=viro@ftp.linux.org.uk
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id v188si4099886wmg.155.2019.06.29.15.34.21
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sat, 29 Jun 2019 15:34:21 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) client-ip=195.92.253.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) smtp.mailfrom=viro@ftp.linux.org.uk
Received: from viro by ZenIV.linux.org.uk with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hhLv0-00037Q-Th; Sat, 29 Jun 2019 22:34:02 +0000
Date: Sat, 29 Jun 2019 23:34:02 +0100
From: Al Viro <viro@zeniv.linux.org.uk>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Roman Gushchin <guro@fb.com>,
	Alexander Viro <viro@ftp.linux.org.uk>,
	Christoph Hellwig <hch@infradead.org>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Christopher Lameter <cl@linux.com>,
	Matthew Wilcox <willy@infradead.org>,
	Miklos Szeredi <mszeredi@redhat.com>,
	Andreas Dilger <adilger@dilger.ca>,
	Waiman Long <longman@redhat.com>, Tycho Andersen <tycho@tycho.ws>,
	Theodore Ts'o <tytso@mit.edu>, Andi Kleen <ak@linux.intel.com>,
	David Chinner <david@fromorbit.com>,
	Nick Piggin <npiggin@gmail.com>, Rik van Riel <riel@redhat.com>,
	Hugh Dickins <hughd@google.com>, Jonathan Corbet <corbet@lwn.net>,
	linux-mm@kvack.org, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: shrink_dentry_list() logics change (was Re: [RFC PATCH v3 14/15]
 dcache: Implement partial shrink via Slab Movable Objects)
Message-ID: <20190629223402.GX17978@ZenIV.linux.org.uk>
References: <20190411013441.5415-1-tobin@kernel.org>
 <20190411013441.5415-15-tobin@kernel.org>
 <20190411023322.GD2217@ZenIV.linux.org.uk>
 <20190411024821.GB6941@eros.localdomain>
 <20190411044746.GE2217@ZenIV.linux.org.uk>
 <20190411210200.GH2217@ZenIV.linux.org.uk>
 <20190629040844.GS17978@ZenIV.linux.org.uk>
 <20190629043803.GT17978@ZenIV.linux.org.uk>
 <20190629190624.GU17978@ZenIV.linux.org.uk>
 <20190629222945.GW17978@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190629222945.GW17978@ZenIV.linux.org.uk>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jun 29, 2019 at 11:29:45PM +0100, Al Viro wrote:

> Like this (again, only build-tested):
... and with obvious braino fixed,

Teach shrink_dcache_parent() to cope with mixed-filesystem shrink lists

Currently, running into a shrink list that contains dentries from different
filesystems can cause several unpleasant things for shrink_dcache_parent()
and for umount(2).

The first problem is that there's a window during shrink_dentry_list() between
__dentry_kill() takes a victim out and dropping reference to its parent.  During
that window the parent looks like a genuine busy dentry.  shrink_dcache_parent()
(or, worse yet, shrink_dcache_for_umount()) coming at that time will see no
eviction candidates and no indication that it needs to wait for some
shrink_dentry_list() to proceed further.

That applies for any shrink list that might intersect with the subtree we are
trying to shrink; the only reason it does not blow on umount(2) in the mainline
is that we unregister the memory shrinker before hitting shrink_dcache_for_umount().

Another problem happens if something in a mixed-filesystem shrink list gets
be stuck in e.g. iput(), getting umount of unrelated fs to spin waiting for
the stuck shrinker to get around to our dentries.

Solution:
    1) have shrink_dentry_list() decrement the parent's refcount and
make sure it's on a shrink list (ours unless it already had been on some
other) before calling __dentry_kill().  That eliminates the window when
shrink_dcache_parent() would've blown past the entire subtree without
noticing anything with zero refcount not on shrink lists.
    2) when shrink_dcache_parent() has found no eviction candidates,
but some dentries are still sitting on shrink lists, rather than
repeating the scan in hope that shrinkers have progressed, scan looking
for something on shrink lists with zero refcount.  If such a thing is
found, grab rcu_read_lock() and stop the scan, with caller locking
it for eviction, dropping out of RCU and doing __dentry_kill(), with
the same treatment for parent as shrink_dentry_list() would do.

Note that right now mixed-filesystem shrink lists do not occur, so this
is not a mainline bug.  Howevere, there's a bunch of uses for such
beasts (e.g. the "try and evict everything we can out of given page"
patches; there are potential uses in mount-related code, considerably
simplifying the life in fs/namespace.c, etc.)

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---

diff --git a/fs/dcache.c b/fs/dcache.c
index 8136bda27a1f..4b50e09ee950 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -860,6 +860,32 @@ void dput(struct dentry *dentry)
 }
 EXPORT_SYMBOL(dput);
 
+static void __dput_to_list(struct dentry *dentry, struct list_head *list)
+__must_hold(&dentry->d_lock)
+{
+	if (dentry->d_flags & DCACHE_SHRINK_LIST) {
+		/* let the owner of the list it's on deal with it */
+		--dentry->d_lockref.count;
+	} else {
+		if (dentry->d_flags & DCACHE_LRU_LIST)
+			d_lru_del(dentry);
+		if (!--dentry->d_lockref.count)
+			d_shrink_add(dentry, list);
+	}
+}
+
+void dput_to_list(struct dentry *dentry, struct list_head *list)
+{
+	rcu_read_lock();
+	if (likely(fast_dput(dentry))) {
+		rcu_read_unlock();
+		return;
+	}
+	rcu_read_unlock();
+	if (!retain_dentry(dentry))
+		__dput_to_list(dentry, list);
+	spin_unlock(&dentry->d_lock);
+}
 
 /* This must be called with d_lock held */
 static inline void __dget_dlock(struct dentry *dentry)
@@ -1088,18 +1114,9 @@ static void shrink_dentry_list(struct list_head *list)
 		rcu_read_unlock();
 		d_shrink_del(dentry);
 		parent = dentry->d_parent;
+		if (parent != dentry)
+			__dput_to_list(parent, list);
 		__dentry_kill(dentry);
-		if (parent == dentry)
-			continue;
-		/*
-		 * We need to prune ancestors too. This is necessary to prevent
-		 * quadratic behavior of shrink_dcache_parent(), but is also
-		 * expected to be beneficial in reducing dentry cache
-		 * fragmentation.
-		 */
-		dentry = parent;
-		while (dentry && !lockref_put_or_lock(&dentry->d_lockref))
-			dentry = dentry_kill(dentry);
 	}
 }
 
@@ -1444,8 +1461,11 @@ int d_set_mounted(struct dentry *dentry)
 
 struct select_data {
 	struct dentry *start;
+	union {
+		long found;
+		struct dentry *victim;
+	};
 	struct list_head dispose;
-	int found;
 };
 
 static enum d_walk_ret select_collect(void *_data, struct dentry *dentry)
@@ -1477,6 +1497,37 @@ static enum d_walk_ret select_collect(void *_data, struct dentry *dentry)
 	return ret;
 }
 
+static enum d_walk_ret select_collect2(void *_data, struct dentry *dentry)
+{
+	struct select_data *data = _data;
+	enum d_walk_ret ret = D_WALK_CONTINUE;
+
+	if (data->start == dentry)
+		goto out;
+
+	if (dentry->d_flags & DCACHE_SHRINK_LIST) {
+		if (!dentry->d_lockref.count) {
+			rcu_read_lock();
+			data->victim = dentry;
+			return D_WALK_QUIT;
+		}
+	} else {
+		if (dentry->d_flags & DCACHE_LRU_LIST)
+			d_lru_del(dentry);
+		if (!dentry->d_lockref.count)
+			d_shrink_add(dentry, &data->dispose);
+	}
+	/*
+	 * We can return to the caller if we have found some (this
+	 * ensures forward progress). We'll be coming back to find
+	 * the rest.
+	 */
+	if (!list_empty(&data->dispose))
+		ret = need_resched() ? D_WALK_QUIT : D_WALK_NORETRY;
+out:
+	return ret;
+}
+
 /**
  * shrink_dcache_parent - prune dcache
  * @parent: parent of entries to prune
@@ -1486,12 +1537,9 @@ static enum d_walk_ret select_collect(void *_data, struct dentry *dentry)
 void shrink_dcache_parent(struct dentry *parent)
 {
 	for (;;) {
-		struct select_data data;
+		struct select_data data = {.start = parent};
 
 		INIT_LIST_HEAD(&data.dispose);
-		data.start = parent;
-		data.found = 0;
-
 		d_walk(parent, &data, select_collect);
 
 		if (!list_empty(&data.dispose)) {
@@ -1502,6 +1550,22 @@ void shrink_dcache_parent(struct dentry *parent)
 		cond_resched();
 		if (!data.found)
 			break;
+		data.victim = NULL;
+		d_walk(parent, &data, select_collect2);
+		if (data.victim) {
+			struct dentry *parent;
+			if (!shrink_lock_dentry(data.victim)) {
+				rcu_read_unlock();
+			} else {
+				rcu_read_unlock();
+				parent = data.victim->d_parent;
+				if (parent != data.victim)
+					__dput_to_list(parent, &data.dispose);
+				__dentry_kill(data.victim);
+			}
+		}
+		if (!list_empty(&data.dispose))
+			shrink_dentry_list(&data.dispose);
 	}
 }
 EXPORT_SYMBOL(shrink_dcache_parent);
diff --git a/fs/internal.h b/fs/internal.h
index 0010889f2e85..68f132cf2664 100644
--- a/fs/internal.h
+++ b/fs/internal.h
@@ -160,6 +160,7 @@ extern int d_set_mounted(struct dentry *dentry);
 extern long prune_dcache_sb(struct super_block *sb, struct shrink_control *sc);
 extern struct dentry *d_alloc_cursor(struct dentry *);
 extern struct dentry * d_alloc_pseudo(struct super_block *, const struct qstr *);
+extern void dput_to_list(struct dentry *, struct list_head *);
 
 /*
  * read_write.c


