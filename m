Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id DD1A06B000C
	for <linux-mm@kvack.org>; Fri,  2 Mar 2018 12:45:40 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id v3so2189425pfm.21
        for <linux-mm@kvack.org>; Fri, 02 Mar 2018 09:45:40 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id t8-v6si5030586plz.780.2018.03.02.09.45.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Mar 2018 09:45:39 -0800 (PST)
Date: Fri, 2 Mar 2018 09:45:30 -0800
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH v5 02/12] dax: introduce IS_DEVDAX() and IS_FSDAX()
Message-ID: <20180302174530.GV19312@magnolia>
References: <151996281307.28483.12343847096989509127.stgit@dwillia2-desk3.amr.corp.intel.com>
 <151996282448.28483.10415125852182473579.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <151996282448.28483.10415125852182473579.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm@lists.01.org, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-xfs@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, stable@vger.kernel.org, Jan Kara <jack@suse.cz>, hch@lst.de, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Mar 01, 2018 at 07:53:44PM -0800, Dan Williams wrote:
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

I echo Jan's complaint from the last round that the dead code
elimination here is subtle, as compared to:

#if IS_ENABLED(CONFIG_FS_DAX)
static inline bool IS_FSDAX(struct inode *inode) { ... }
#else
# define IS_FSDAX(inode) (false)
#endif

But I guess even with that we're relying on dead code elimination higher
up in the call stack...

> +	if ((inode->i_flags & S_DAX) == 0)
> +		return false;
> +	if (S_ISCHR(inode->i_mode))
> +		return false;

I'm curious, do we have character devices with S_DAX set?

I /think/ we're expecting that only block/char devices and files will
ever have S_DAX set, so IS_FSDAX is only true for block devices and
files.  Right?

(A comment here about why S_ISCHR->false here would be helpful.)

--D

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
