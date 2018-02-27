Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 58FEB6B0006
	for <linux-mm@kvack.org>; Tue, 27 Feb 2018 11:54:54 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id v8so7162865pgs.9
        for <linux-mm@kvack.org>; Tue, 27 Feb 2018 08:54:54 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 9-v6si8742560ple.367.2018.02.27.08.54.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 27 Feb 2018 08:54:53 -0800 (PST)
Date: Tue, 27 Feb 2018 17:54:49 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v4 02/12] dax: introduce IS_DEVDAX() and IS_FSDAX()
Message-ID: <20180227165449.abbhpu7gwqpxcqst@quack2.suse.cz>
References: <151970519370.26729.1011551137381425076.stgit@dwillia2-desk3.amr.corp.intel.com>
 <151970520551.26729.12707678649514382892.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <151970520551.26729.12707678649514382892.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm@lists.01.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J. Wong" <darrick.wong@oracle.com>, Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, stable@vger.kernel.org, "supporter:XFS FILESYSTEM" <linux-xfs@vger.kernel.org>, linux-mm@kvack.org, Andreas Dilger <adilger.kernel@dilger.ca>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Jan Kara <jack@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Mon 26-02-18 20:20:05, Dan Williams wrote:
> The current IS_DAX() helper that checks the S_DAX inode flag is
> ambiguous, and currently has the broken assumption that the S_DAX flag

I don't think S_DAX flag is really ambiguous. It is just that in
CONFIG_FS_DAX=n + CONFIG_DEV_DAX=y case, the compiler is not able to figure
out some calls behind IS_DAX() are dead code and so the kernel won't
compile / link. Or is there any other problem I'm missing?

If I'm indeed right, then please tell this in the changelog and don't talk
about abstract ambiguity of S_DAX flag.

As much as I'd prefer to solve link-time problems with stubs instead of
relying on dead-code elimination, I can live with split macros so once the
changelog is settled, feel free to add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> is only non-zero in the CONFIG_FS_DAX=y case. In preparation for
> defining S_DAX to non-zero in the  CONFIG_FS_DAX=n + CONFIG_DEV_DAX=y
> case, introduce two explicit helpers to replace IS_DAX().
> 
> Cc: "Theodore Ts'o" <tytso@mit.edu>
> Cc: Andreas Dilger <adilger.kernel@dilger.ca>
> Cc: Alexander Viro <viro@zeniv.linux.org.uk>
> Cc: "Darrick J. Wong" <darrick.wong@oracle.com>
> Cc: linux-xfs@vger.kernel.org (supporter:XFS FILESYSTEM)
> Cc: Matthew Wilcox <mawilcox@microsoft.com>
> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
> Cc: <stable@vger.kernel.org>
> Fixes: dee410792419 ("/dev/dax, core: file operations and dax-mmap")
> Reported-by: Jan Kara <jack@suse.cz>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
>  include/linux/fs.h |   22 ++++++++++++++++++++++
>  1 file changed, 22 insertions(+)
> 
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 79c413985305..bd0c46880572 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -1909,6 +1909,28 @@ static inline bool sb_rdonly(const struct super_block *sb) { return sb->s_flags
>  #define IS_WHITEOUT(inode)	(S_ISCHR(inode->i_mode) && \
>  				 (inode)->i_rdev == WHITEOUT_DEV)
>  
> +static inline bool IS_DEVDAX(struct inode *inode)
> +{
> +	if (!IS_ENABLED(CONFIG_DEV_DAX))
> +		return false;
> +	if ((inode->i_flags & S_DAX) == 0)
> +		return false;
> +	if (!S_ISCHR(inode->i_mode))
> +		return false;
> +	return true;
> +}
> +
> +static inline bool IS_FSDAX(struct inode *inode)
> +{
> +	if (!IS_ENABLED(CONFIG_FS_DAX))
> +		return false;
> +	if ((inode->i_flags & S_DAX) == 0)
> +		return false;
> +	if (S_ISCHR(inode->i_mode))
> +		return false;
> +	return true;
> +}
> +
>  static inline bool HAS_UNMAPPED_ID(struct inode *inode)
>  {
>  	return !uid_valid(inode->i_uid) || !gid_valid(inode->i_gid);
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
