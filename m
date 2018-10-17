Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id AAC3D6B0273
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 04:33:59 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id h76-v6so26214834pfd.10
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 01:33:59 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id n26-v6si16975283pfk.14.2018.10.17.01.33.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Oct 2018 01:33:58 -0700 (PDT)
Date: Wed, 17 Oct 2018 01:33:55 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 13/26] vfs: create generic_remap_file_range_touch to
 update inode metadata
Message-ID: <20181017083355.GE16896@infradead.org>
References: <153965939489.1256.7400115244528045860.stgit@magnolia>
 <153965996673.3607.133184523000924340.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <153965996673.3607.133184523000924340.stgit@magnolia>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: david@fromorbit.com, sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, Amir Goldstein <amir73il@gmail.com>, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, ocfs2-devel@oss.oracle.com

On Mon, Oct 15, 2018 at 08:19:26PM -0700, Darrick J. Wong wrote:
> From: Darrick J. Wong <darrick.wong@oracle.com>
> 
> Create a new VFS helper to handle inode metadata updates when remapping
> into a file.  If the operation can possibly alter the file contents, we
> must update the ctime and mtime and remove security privileges, just
> like we do for regular file writes.  Wire up ocfs2 to ensure consistent
> behavior.

Subject line doesn't match the actual function name..

> +/* Update inode timestamps and remove security privileges when remapping. */
> +static int generic_remap_file_range_target(struct file *file,
> +					   unsigned int remap_flags)
> +{
> +	int ret;
> +
> +	/* If can't alter the file contents, we're done. */
> +	if (remap_flags & REMAP_FILE_DEDUP)
> +		return 0;
> +
> +	/* Update the timestamps, since we can alter file contents. */
> +	if (!(file->f_mode & FMODE_NOCMTIME)) {
> +		ret = file_update_time(file);
> +		if (ret)
> +			return ret;
> +	}
> +
> +	/*
> +	 * Clear the security bits if the process is not being run by root.
> +	 * This keeps people from modifying setuid and setgid binaries.
> +	 */
> +	return file_remove_privs(file);
> +}
> +
>  /*
>   * Check that the two inodes are eligible for cloning, the ranges make
>   * sense, and then flush all dirty data.  Caller must ensure that the
> @@ -1820,6 +1844,10 @@ int generic_remap_file_range_prep(struct file *file_in, loff_t pos_in,
>  	if (ret)
>  		return ret;
>  
> +	ret = generic_remap_file_range_target(file_out, remap_flags);
> +	if (ret)
> +		return ret;
> +

Also I find the name still somewhat odd.  Why don't we side-step that
issue by moving the code directly into generic_remap_file_range_prep?

Something like this folded in:

diff --git a/fs/read_write.c b/fs/read_write.c
index 37a7d3fe35d8..6de813cf9e63 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -1752,30 +1752,6 @@ static int generic_remap_check_len(struct inode *inode_in,
 	return (remap_flags & REMAP_FILE_DEDUP) ? -EBADE : -EINVAL;
 }
 
-/* Update inode timestamps and remove security privileges when remapping. */
-static int generic_remap_file_range_target(struct file *file,
-					   unsigned int remap_flags)
-{
-	int ret;
-
-	/* If can't alter the file contents, we're done. */
-	if (remap_flags & REMAP_FILE_DEDUP)
-		return 0;
-
-	/* Update the timestamps, since we can alter file contents. */
-	if (!(file->f_mode & FMODE_NOCMTIME)) {
-		ret = file_update_time(file);
-		if (ret)
-			return ret;
-	}
-
-	/*
-	 * Clear the security bits if the process is not being run by root.
-	 * This keeps people from modifying setuid and setgid binaries.
-	 */
-	return file_remove_privs(file);
-}
-
 /*
  * Read a page's worth of file data into the page cache.  Return the page
  * locked.
@@ -1950,9 +1926,25 @@ int generic_remap_file_range_prep(struct file *file_in, loff_t pos_in,
 	if (ret)
 		return ret;
 
-	ret = generic_remap_file_range_target(file_out, remap_flags);
-	if (ret)
-		return ret;
+	if (!(remap_flags & REMAP_FILE_DEDUP)) {
+		/*
+		 * Update the timestamps, since we can alter file contents.
+		 */
+		if (!(file_out->f_mode & FMODE_NOCMTIME)) {
+			ret = file_update_time(file_out);
+			if (ret)
+				return ret;
+		}
+
+		/*
+		 * Clear the security bits if the process is not being run by
+		 * root.  This keeps people from modifying setuid and setgid
+		 * binaries.
+		 */
+		ret = file_remove_privs(file_out);
+		if (ret)
+			return ret;
+	}
 
 	return 0;
 }
