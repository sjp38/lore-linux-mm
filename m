Date: Sun, 8 Jun 2008 12:06:45 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 20/21] fs: check for statfs overflow
Message-Id: <20080608120645.270bc581.akpm@linux-foundation.org>
In-Reply-To: <20080604113113.523542750@amd.local0.net>
References: <20080604112939.789444496@amd.local0.net>
	<20080604113113.523542750@amd.local0.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 04 Jun 2008 21:29:59 +1000 npiggin@suse.de wrote:

> Adds a check for an overflow in the filesystem size so if someone is
> checking with statfs() on a 16G hugetlbfs in a 32bit binary that it
> will report back EOVERFLOW instead of a size of 0.

-ENOUNDERSTAND.

Why won't a 16G filesystem work on a 32-bit binary?

> Acked-by: Nishanth Aravamudan <nacc@us.ibm.com>
> Signed-off-by: Jon Tollefson <kniht@linux.vnet.ibm.com>
> Signed-off-by: Nick Piggin <npiggin@suse.de>
> ---
> 
>  fs/compat.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> 
> Index: linux-2.6/fs/compat.c
> ===================================================================
> --- linux-2.6.orig/fs/compat.c	2008-06-04 20:47:31.000000000 +1000
> +++ linux-2.6/fs/compat.c	2008-06-04 20:51:28.000000000 +1000
> @@ -197,8 +197,8 @@ static int put_compat_statfs(struct comp
>  {
>  	
>  	if (sizeof ubuf->f_blocks == 4) {
> -		if ((kbuf->f_blocks | kbuf->f_bfree | kbuf->f_bavail) &
> -		    0xffffffff00000000ULL)
> +		if ((kbuf->f_blocks | kbuf->f_bfree | kbuf->f_bavail |
> +		     kbuf->f_bsize | kbuf->f_frsize) & 0xffffffff00000000ULL)
>  			return -EOVERFLOW;
>  		/* f_files and f_ffree may be -1; it's okay
>  		 * to stuff that into 32 bits */
> @@ -271,8 +271,8 @@ out:
>  static int put_compat_statfs64(struct compat_statfs64 __user *ubuf, struct kstatfs *kbuf)
>  {
>  	if (sizeof ubuf->f_blocks == 4) {
> -		if ((kbuf->f_blocks | kbuf->f_bfree | kbuf->f_bavail) &
> -		    0xffffffff00000000ULL)
> +		if ((kbuf->f_blocks | kbuf->f_bfree | kbuf->f_bavail |
> +		     kbuf->f_bsize | kbuf->f_frsize) & 0xffffffff00000000ULL)
>  			return -EOVERFLOW;
>  		/* f_files and f_ffree may be -1; it's okay
>  		 * to stuff that into 32 bits */
> Index: linux-2.6/fs/open.c
> ===================================================================
> --- linux-2.6.orig/fs/open.c	2008-06-04 20:47:31.000000000 +1000
> +++ linux-2.6/fs/open.c	2008-06-04 20:51:28.000000000 +1000
> @@ -63,7 +63,8 @@ static int vfs_statfs_native(struct dent
>  		memcpy(buf, &st, sizeof(st));
>  	else {
>  		if (sizeof buf->f_blocks == 4) {
> -			if ((st.f_blocks | st.f_bfree | st.f_bavail) &
> +			if ((st.f_blocks | st.f_bfree | st.f_bavail |
> +			     st.f_bsize | st.f_frsize) &
>  			    0xffffffff00000000ULL)
>  				return -EOVERFLOW;
>  			/*
> 
> -- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
