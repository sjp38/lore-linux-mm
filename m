Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5286D6B0006
	for <linux-mm@kvack.org>; Fri,  2 Mar 2018 14:58:19 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id g2so9726638ioj.18
        for <linux-mm@kvack.org>; Fri, 02 Mar 2018 11:58:19 -0800 (PST)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id b73si1363771iob.51.2018.03.02.11.58.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Mar 2018 11:58:18 -0800 (PST)
Date: Fri, 2 Mar 2018 11:58:11 -0800
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH v6] dax: introduce IS_DEVDAX() and IS_FSDAX()
Message-ID: <20180302195811.GA18989@magnolia>
References: <CAPcyv4iu32ja_vPiN=E0DP7_PFaj887XQ48EOMupE0Q4p1dCkQ@mail.gmail.com>
 <152001757529.22146.17936438768625217740.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <152001757529.22146.17936438768625217740.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm@lists.01.org, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-xfs@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, stable@vger.kernel.org, Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Mar 02, 2018 at 11:06:36AM -0800, Dan Williams wrote:
> The current IS_DAX() helper that checks if a file is in DAX mode serves
> two purposes. It is a control flow branch condition for DAX vs
> non-DAX paths and it is a mechanism to perform dead code elimination. The
> dead code elimination is required in the CONFIG_FS_DAX=n case since
> there are symbols in fs/dax.c that will be elided. While the
> dead code elimination can be addressed with nop stubs for the fs/dax.c
> symbols that does not address the need for a DAX control flow helper
> where fs/dax.c symbols are not involved.
> 
> Moreover, the control flow changes, in some cases, need to be cognizant
> of whether the DAX file is a typical file or a Device-DAX special file.
> Introduce IS_DEVDAX() and IS_FSDAX() to simultaneously address the
> file-type control flow and dead-code elimination use cases. IS_DAX()
> will be deleted after all sites are converted to use the file-type
> specific helper.
> 
> Note, this change is also a pre-requisite for fixing the definition of
> the S_DAX inode flag in the CONFIG_FS_DAX=n + CONFIG_DEV_DAX=y case.
> The flag needs to be defined, non-zero, if either DAX facility is
> enabled.
> 
> Cc: "Theodore Ts'o" <tytso@mit.edu>
> Cc: Andreas Dilger <adilger.kernel@dilger.ca>
> Cc: Alexander Viro <viro@zeniv.linux.org.uk>
> Cc: "Darrick J. Wong" <darrick.wong@oracle.com>
> Cc: linux-xfs@vger.kernel.org
> Cc: Matthew Wilcox <mawilcox@microsoft.com>
> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
> Cc: <stable@vger.kernel.org>
> Fixes: dee410792419 ("/dev/dax, core: file operations and dax-mmap")
> Reported-by: Jan Kara <jack@suse.cz>
> Reviewed-by: Jan Kara <jack@suse.cz>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
> Changes since v5:
> * add comments to clarify the S_ISCHR() checks (Darrick)

Looks ok,
Reviewed-by: Darrick J. Wong <darrick.wong@oracle.com>

--D

> 
>  include/linux/fs.h |   24 ++++++++++++++++++++++++
>  1 file changed, 24 insertions(+)
> 
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 79c413985305..751975b8b29b 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -1909,6 +1909,30 @@ static inline bool sb_rdonly(const struct super_block *sb) { return sb->s_flags
>  #define IS_WHITEOUT(inode)	(S_ISCHR(inode->i_mode) && \
>  				 (inode)->i_rdev == WHITEOUT_DEV)
>  
> +static inline bool IS_DEVDAX(struct inode *inode)
> +{
> +	if (!IS_ENABLED(CONFIG_DEV_DAX))
> +		return false;
> +	if ((inode->i_flags & S_DAX) == 0)
> +		return false;
> +	/* regular files with S_DAX are filesystem-dax instances */
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
> +	/* character devices with S_DAX are device-dax instances */
> +	if (S_ISCHR(inode->i_mode))
> +		return false;
> +	return true;
> +}
> +
>  static inline bool HAS_UNMAPPED_ID(struct inode *inode)
>  {
>  	return !uid_valid(inode->i_uid) || !gid_valid(inode->i_gid);
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-xfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
