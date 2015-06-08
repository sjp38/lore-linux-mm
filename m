Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id C16EA6B0032
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 01:57:50 -0400 (EDT)
Received: by pacyx8 with SMTP id yx8so51859772pac.2
        for <linux-mm@kvack.org>; Sun, 07 Jun 2015 22:57:50 -0700 (PDT)
Received: from mail-pd0-x236.google.com (mail-pd0-x236.google.com. [2607:f8b0:400e:c02::236])
        by mx.google.com with ESMTPS id pm11si2467841pdb.55.2015.06.07.22.57.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Jun 2015 22:57:49 -0700 (PDT)
Received: by pdjn11 with SMTP id n11so57885341pdj.0
        for <linux-mm@kvack.org>; Sun, 07 Jun 2015 22:57:49 -0700 (PDT)
Date: Mon, 8 Jun 2015 14:57:31 +0900
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH block/for-4.2-writeback] v9fs: fix error handling in
 v9fs_session_init()
Message-ID: <20150608055731.GD21465@mtj.duckdns.org>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
 <1432329245-5844-17-git-send-email-tj@kernel.org>
 <55739536.5040509@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55739536.5040509@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>, Eric Van Hensbergen <ericvh@gmail.com>, Ron Minnich <rminnich@sandia.gov>, Latchesar Ionkov <lucho@ionkov.net>, v9fs-developer@lists.sourceforge.net
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru

On failure, v9fs_session_init() returns with the v9fs_session_info
struct partially initialized and expects the caller to invoke
v9fs_session_close() to clean it up; however, it doesn't track whether
the bdi is initialized or not and curiously invokes bdi_destroy() in
both vfs_session_init() failure path too.

A. If v9fs_session_init() fails before the bdi is initialized, the
   follow-up v9fs_session_close() will invoke bdi_destroy() on an
   uninitialized bdi.

B. If v9fs_session_init() fails after the bdi is initialized,
   bdi_destroy() will be called twice on the same bdi - once in the
   failure path of v9fs_session_init() and then by
   v9fs_session_close().

A is broken no matter what.  B used to be okay because bdi_destroy()
allowed being invoked multiple times on the same bdi, which BTW was
broken in its own way - if bdi_destroy() was invoked on an initialiezd
but !registered bdi, it'd fail to free percpu counters.  Since
f0054bb1e1f3 ("writeback: move backing_dev_info->wb_lock and
->worklist into bdi_writeback"), this no longer work - bdi_destroy()
on an initialized but not registered bdi works correctly but multiple
invocations of bdi_destroy() is no longer allowed.

The obvious culprit here is v9fs_session_init()'s odd and broken error
behavior.  It should simply clean up after itself on failures.  This
patch makes the following updates to v9fs_session_init().

* @rc -> @retval error return propagation removed.  It didn't serve
  any purpose.  Just use @rc.

* Move addition to v9fs_sessionlist to the end of the function so that
  incomplete sessions are not put on the list or iterated and error
  path doesn't have to worry about it.

* Update error handling so that it cleans up after itself.

Signed-off-by: Tejun Heo <tj@kernel.org>
Reported-by: Sasha Levin <sasha.levin@oracle.com>
---
 fs/9p/v9fs.c      |   50 ++++++++++++++++++++++----------------------------
 fs/9p/vfs_super.c |    8 ++------
 2 files changed, 24 insertions(+), 34 deletions(-)

diff --git a/fs/9p/v9fs.c b/fs/9p/v9fs.c
index 620d934..8aa56bb 100644
--- a/fs/9p/v9fs.c
+++ b/fs/9p/v9fs.c
@@ -320,31 +320,21 @@ static int v9fs_parse_options(struct v9fs_session_info *v9ses, char *opts)
 struct p9_fid *v9fs_session_init(struct v9fs_session_info *v9ses,
 		  const char *dev_name, char *data)
 {
-	int retval = -EINVAL;
 	struct p9_fid *fid;
-	int rc;
+	int rc = -ENOMEM;
 
 	v9ses->uname = kstrdup(V9FS_DEFUSER, GFP_KERNEL);
 	if (!v9ses->uname)
-		return ERR_PTR(-ENOMEM);
+		goto err_names;
 
 	v9ses->aname = kstrdup(V9FS_DEFANAME, GFP_KERNEL);
-	if (!v9ses->aname) {
-		kfree(v9ses->uname);
-		return ERR_PTR(-ENOMEM);
-	}
+	if (!v9ses->aname)
+		goto err_names;
 	init_rwsem(&v9ses->rename_sem);
 
 	rc = bdi_setup_and_register(&v9ses->bdi, "9p");
-	if (rc) {
-		kfree(v9ses->aname);
-		kfree(v9ses->uname);
-		return ERR_PTR(rc);
-	}
-
-	spin_lock(&v9fs_sessionlist_lock);
-	list_add(&v9ses->slist, &v9fs_sessionlist);
-	spin_unlock(&v9fs_sessionlist_lock);
+	if (rc)
+		goto err_names;
 
 	v9ses->uid = INVALID_UID;
 	v9ses->dfltuid = V9FS_DEFUID;
@@ -352,10 +342,9 @@ struct p9_fid *v9fs_session_init(struct v9fs_session_info *v9ses,
 
 	v9ses->clnt = p9_client_create(dev_name, data);
 	if (IS_ERR(v9ses->clnt)) {
-		retval = PTR_ERR(v9ses->clnt);
-		v9ses->clnt = NULL;
+		rc = PTR_ERR(v9ses->clnt);
 		p9_debug(P9_DEBUG_ERROR, "problem initializing 9p client\n");
-		goto error;
+		goto err_bdi;
 	}
 
 	v9ses->flags = V9FS_ACCESS_USER;
@@ -368,10 +357,8 @@ struct p9_fid *v9fs_session_init(struct v9fs_session_info *v9ses,
 	}
 
 	rc = v9fs_parse_options(v9ses, data);
-	if (rc < 0) {
-		retval = rc;
-		goto error;
-	}
+	if (rc < 0)
+		goto err_clnt;
 
 	v9ses->maxdata = v9ses->clnt->msize - P9_IOHDRSZ;
 
@@ -405,10 +392,9 @@ struct p9_fid *v9fs_session_init(struct v9fs_session_info *v9ses,
 	fid = p9_client_attach(v9ses->clnt, NULL, v9ses->uname, INVALID_UID,
 							v9ses->aname);
 	if (IS_ERR(fid)) {
-		retval = PTR_ERR(fid);
-		fid = NULL;
+		rc = PTR_ERR(fid);
 		p9_debug(P9_DEBUG_ERROR, "cannot attach\n");
-		goto error;
+		goto err_clnt;
 	}
 
 	if ((v9ses->flags & V9FS_ACCESS_MASK) == V9FS_ACCESS_SINGLE)
@@ -420,12 +406,20 @@ struct p9_fid *v9fs_session_init(struct v9fs_session_info *v9ses,
 	/* register the session for caching */
 	v9fs_cache_session_get_cookie(v9ses);
 #endif
+	spin_lock(&v9fs_sessionlist_lock);
+	list_add(&v9ses->slist, &v9fs_sessionlist);
+	spin_unlock(&v9fs_sessionlist_lock);
 
 	return fid;
 
-error:
+err_clnt:
+	p9_client_destroy(v9ses->clnt);
+err_bdi:
 	bdi_destroy(&v9ses->bdi);
-	return ERR_PTR(retval);
+err_names:
+	kfree(v9ses->uname);
+	kfree(v9ses->aname);
+	return ERR_PTR(rc);
 }
 
 /**
diff --git a/fs/9p/vfs_super.c b/fs/9p/vfs_super.c
index e99a338..bf495ce 100644
--- a/fs/9p/vfs_super.c
+++ b/fs/9p/vfs_super.c
@@ -130,11 +130,7 @@ static struct dentry *v9fs_mount(struct file_system_type *fs_type, int flags,
 	fid = v9fs_session_init(v9ses, dev_name, data);
 	if (IS_ERR(fid)) {
 		retval = PTR_ERR(fid);
-		/*
-		 * we need to call session_close to tear down some
-		 * of the data structure setup by session_init
-		 */
-		goto close_session;
+		goto free_session;
 	}
 
 	sb = sget(fs_type, NULL, v9fs_set_super, flags, v9ses);
@@ -195,8 +191,8 @@ static struct dentry *v9fs_mount(struct file_system_type *fs_type, int flags,
 
 clunk_fid:
 	p9_client_clunk(fid);
-close_session:
 	v9fs_session_close(v9ses);
+free_session:
 	kfree(v9ses);
 	return ERR_PTR(retval);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
