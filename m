Message-ID: <4521C79A.6090102@oracle.com>
Date: Mon, 02 Oct 2006 22:14:50 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Reply-To: chuck.lever@oracle.com
MIME-Version: 1.0
Subject: Re: Checking page_count(page) in invalidate_complete_page
References: <4518333E.2060101@oracle.com>	<45185D7E.6070104@yahoo.com.au>	<451862C5.1010900@oracle.com>	<45186481.1090306@yahoo.com.au>	<45186DC3.7000902@oracle.com>	<451870C6.6050008@yahoo.com.au>	<4518835D.3080702@oracle.com>	<451886FB.50306@yahoo.com.au>	<451BF7BC.1040807@oracle.com>	<20060928093640.14ecb1b1.akpm@osdl.org>	<20060928094023.e888d533.akpm@osdl.org>	<451BFB84.5070903@oracle.com>	<20060928100306.0b58f3c7.akpm@osdl.org>	<451C01C8.7020104@oracle.com>	<451C6AAC.1080203@yahoo.com.au>	<451D8371.2070101@oracle.com>	<1159562724.13651.39.camel@lappy>	<451D89E7.7020307@oracle.com>	<1159564637.13651.44.camel@lappy>	<20060929144421.48f9f1bd.akpm@osdl.org>	<451D94A7.9060905@oracle.com>	<20060929152951.0b763f6a.akpm@osdl.org>	<451F425F.8030609@oracle.com>	<4520FFB6.3040801@RedHat.com>	<1159795522.6143.7.camel@lade.trondhjem.org>	<20061002095727.05cd052f.akpm@osdl.org>	<4521460B.8000504@RedHat.com> <20061002112005.d02f84f7.akpm@osdl.o! rg> <45216233.5010602@RedHat.com>
In-Reply-To: <45216233.5010602@RedHat.com>
Content-Type: multipart/mixed;
 boundary="------------050905020009020807090108"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Steve Dickson <SteveD@redhat.com>
Cc: Andrew Morton <akpm@osdl.org>, Trond Myklebust <Trond.Myklebust@netapp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------050905020009020807090108
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Steve Dickson wrote:
> Andrew Morton wrote:
>>
>> This is our user's data we're talking about here.
> Point...
> 
>>
>> If that printk comes out then we need to fix the kernel so that it no
>> longer wants to print that printk.  We don't want to just hide it.
 >
> I'm concern about the printk popping when we are flushing the
> readdir cache (i.e. stale data) and either flooding the console
> to a ton a messages (basically bring a system to its knees for
> no good reason) or scaring the hell out people by saying we have a
> major problem when in reality we are just flushing stale data...
> 
> So I definitely agree the printk should be there and be on by default,
> but I so think it would be a good idea to have way to turn it off
> if need be...

[ Sorry for the attachment... anyone know how to include a diff inline 
with Thunderbird? ]

The attached patch is my suggestion for reporting the cache invalidation 
failure from within the NFS client.  Please review and comment.  My 
testing with this patch applied has not triggered a single message, but 
I haven't tried any memory exhaustion scenarios.

I honestly doubt that we will see log floods.  The original problem that 
was causing stale data to remain cached has been addressed.  The reclaim 
race will almost certainly be rare.

--------------050905020009020807090108
Content-Type: text/plain; x-mac-type="0"; x-mac-creator="0";
 name="nfs-check-return-codes.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="nfs-check-return-codes.diff"

NFS: Add return code checks for page invalidation

Print a warning if the page invalidation functions don't behave as
expected.  A BUG is probably overkill here since the client's internal data
structures will remain consistent.

We're trying to catch cases where invaliding an inode's page cache races
with vmscan or direct I/O, resulting in stale data remaining in the page
cache.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/dir.c           |   34 +++++++++++++++++++++++++++++-----
 fs/nfs/direct.c        |    2 +-
 fs/nfs/inode.c         |   25 +++++++++++++++++++++++--
 fs/nfs/iostat.h        |    1 +
 include/linux/nfs_fs.h |    1 +
 5 files changed, 55 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 7432f1a..0bb1a42 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -156,6 +156,32 @@ typedef struct {
 	int		error;
 } nfs_readdir_descriptor_t;
 
+/*
+ * Trim off all pages past page zero.  This ensures consistent page
+ * alignment of cached data.
+ *
+ * NB: This assumes we have exclusive access to this mapping either
+ *     through inode->i_mutex or some other mechanism.
+ */
+static void nfs_truncate_directory_cache(struct inode *inode)
+{
+	int result;
+
+	dfprintk(DIRCACHE, "NFS: %s: truncating directory (%s/%Ld)\n",
+			__FUNCTION__, inode->i_sb->s_id,
+			(long long)NFS_FILEID(inode));
+
+	result = invalidate_inode_pages2_range(inode->i_mapping,
+							PAGE_CACHE_SIZE, -1);
+	if (unlikely(result < 0)) {
+		nfs_inc_stats(inode, NFSIOS_INVALIDATEFAILED);
+		printk(KERN_ERR
+			"NFS: error %d invalidating cache for dir (%s/%Ld)\n",
+				result, inode->i_sb->s_id,
+				(long long)NFS_FILEID(inode));
+	}
+}
+
 /* Now we cache directories properly, by stuffing the dirent
  * data directly in the page cache.
  *
@@ -199,12 +225,10 @@ int nfs_readdir_filler(nfs_readdir_descr
 	spin_lock(&inode->i_lock);
 	NFS_I(inode)->cache_validity |= NFS_INO_INVALID_ATIME;
 	spin_unlock(&inode->i_lock);
-	/* Ensure consistent page alignment of the data.
-	 * Note: assumes we have exclusive access to this mapping either
-	 *	 through inode->i_mutex or some other mechanism.
-	 */
+
 	if (page->index == 0)
-		invalidate_inode_pages2_range(inode->i_mapping, PAGE_CACHE_SIZE, -1);
+		nfs_truncate_directory_cache(inode);
+
 	unlock_page(page);
 	return 0;
  error:
diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 377839b..fe69c39 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -823,7 +823,7 @@ ssize_t nfs_file_direct_write(struct kio
 	 *      occur before the writes complete.  Kind of racey.
 	 */
 	if (mapping->nrpages)
-		invalidate_inode_pages2(mapping);
+		nfs_invalidate_mapping(mapping->host, mapping);
 
 	if (retval > 0)
 		iocb->ki_pos = pos + retval;
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index bc9376c..e1cf978 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -657,6 +657,27 @@ int nfs_revalidate_inode(struct nfs_serv
 }
 
 /**
+ * nfs_invalidate_mapping - Invalidate the inode's page cache
+ * @inode - pointer to host inode
+ * @mapping - pointer to mapping
+ */
+void nfs_invalidate_mapping(struct inode *inode, struct address_space *mapping)
+{
+	int result;
+
+	nfs_inc_stats(inode, NFSIOS_DATAINVALIDATE);
+
+	result = invalidate_inode_pages2(mapping);
+	if (unlikely(result) < 0) {
+		nfs_inc_stats(inode, NFSIOS_INVALIDATEFAILED);
+		printk(KERN_ERR
+			"NFS: error %d invalidating pages for inode (%s/%Ld)\n",
+				result, inode->i_sb->s_id,
+				(long long)NFS_FILEID(inode));
+	}
+}
+
+/**
  * nfs_revalidate_mapping - Revalidate the pagecache
  * @inode - pointer to host inode
  * @mapping - pointer to mapping
@@ -673,10 +694,10 @@ int nfs_revalidate_mapping(struct inode 
 		ret = __nfs_revalidate_inode(NFS_SERVER(inode), inode);
 
 	if (nfsi->cache_validity & NFS_INO_INVALID_DATA) {
-		nfs_inc_stats(inode, NFSIOS_DATAINVALIDATE);
 		if (S_ISREG(inode->i_mode))
 			nfs_sync_mapping(mapping);
-		invalidate_inode_pages2(mapping);
+
+		nfs_invalidate_mapping(inode, mapping);
 
 		spin_lock(&inode->i_lock);
 		nfsi->cache_validity &= ~NFS_INO_INVALID_DATA;
diff --git a/fs/nfs/iostat.h b/fs/nfs/iostat.h
index 6350ecb..df41150 100644
--- a/fs/nfs/iostat.h
+++ b/fs/nfs/iostat.h
@@ -104,6 +104,7 @@ enum nfs_stat_eventcounters {
 	NFSIOS_SHORTREAD,
 	NFSIOS_SHORTWRITE,
 	NFSIOS_DELAY,
+	NFSIOS_INVALIDATEFAILED,
 	__NFSIOS_COUNTSMAX,
 };
 
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 98c9b9f..dc3cac3 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -306,6 +306,7 @@ extern int nfs_attribute_timeout(struct 
 extern int nfs_revalidate_inode(struct nfs_server *server, struct inode *inode);
 extern int __nfs_revalidate_inode(struct nfs_server *, struct inode *);
 extern int nfs_revalidate_mapping(struct inode *inode, struct address_space *mapping);
+extern void nfs_invalidate_mapping(struct inode *inode, struct address_space *mapping);
 extern int nfs_setattr(struct dentry *, struct iattr *);
 extern void nfs_setattr_update_inode(struct inode *inode, struct iattr *attr);
 extern void nfs_begin_attr_update(struct inode *);

--------------050905020009020807090108--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
