Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 04C396B0032
	for <linux-mm@kvack.org>; Sun, 21 Apr 2013 02:09:18 -0400 (EDT)
Received: by mail-wi0-f180.google.com with SMTP id h11so2693942wiv.1
        for <linux-mm@kvack.org>; Sat, 20 Apr 2013 23:09:17 -0700 (PDT)
Message-ID: <5173828A.2030809@suse.cz>
Date: Sun, 21 Apr 2013 08:09:14 +0200
From: Jiri Slaby <jslaby@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] ext4: mark metadata blocks using bh flags
References: <20130421000522.GA5054@thunk.org> <1366502828-7793-1-git-send-email-tytso@mit.edu> <1366502828-7793-3-git-send-email-tytso@mit.edu>
In-Reply-To: <1366502828-7793-3-git-send-email-tytso@mit.edu>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Ext4 Developers List <linux-ext4@vger.kernel.org>
Cc: linux-mm@kvack.org, Linux Kernel Developers List <linux-kernel@vger.kernel.org>, mgorman@suse.de

On 04/21/2013 02:07 AM, Theodore Ts'o wrote:
> This allows metadata writebacks which are issued via block device
> writeback to be sent with the current write request flags.

Hi, where do these come from?
fs/ext4/ext4_jbd2.c: In function a??__ext4_handle_dirty_metadataa??:
fs/ext4/ext4_jbd2.c:218:2: error: implicit declaration of function
a??mark_buffer_metaa?? [-Werror=implicit-function-declaration]
fs/ext4/ext4_jbd2.c:219:2: error: implicit declaration of function
a??mark_buffer_prioa?? [-Werror=implicit-function-declaration]
cc1: some warnings being treated as errors

> Signed-off-by: "Theodore Ts'o" <tytso@mit.edu>
> ---
>  fs/ext4/ext4_jbd2.c | 2 ++
>  fs/ext4/inode.c     | 6 +++++-
>  2 files changed, 7 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/ext4/ext4_jbd2.c b/fs/ext4/ext4_jbd2.c
> index 0e1dc9e..fd97b81 100644
> --- a/fs/ext4/ext4_jbd2.c
> +++ b/fs/ext4/ext4_jbd2.c
> @@ -215,6 +215,8 @@ int __ext4_handle_dirty_metadata(const char *where, unsigned int line,
>  
>  	might_sleep();
>  
> +	mark_buffer_meta(bh);
> +	mark_buffer_prio(bh);
>  	if (ext4_handle_valid(handle)) {
>  		err = jbd2_journal_dirty_metadata(handle, bh);
>  		if (err) {
> diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
> index 62492e9..d7518e2 100644
> --- a/fs/ext4/inode.c
> +++ b/fs/ext4/inode.c
> @@ -1080,10 +1080,14 @@ retry_journal:
>  /* For write_end() in data=journal mode */
>  static int write_end_fn(handle_t *handle, struct buffer_head *bh)
>  {
> +	int ret;
>  	if (!buffer_mapped(bh) || buffer_freed(bh))
>  		return 0;
>  	set_buffer_uptodate(bh);
> -	return ext4_handle_dirty_metadata(handle, NULL, bh);
> +	ret = ext4_handle_dirty_metadata(handle, NULL, bh);
> +	clear_buffer_meta(bh);
> +	clear_buffer_prio(bh);
> +	return ret;
>  }
>  
>  /*
> 


-- 
js
suse labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
