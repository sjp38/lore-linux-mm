Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id A80716B002C
	for <linux-mm@kvack.org>; Thu,  1 Mar 2012 07:25:41 -0500 (EST)
Date: Thu, 1 Mar 2012 07:25:37 -0500
From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 4/9] cifs: Push file_update_time() into
 cifs_page_mkwrite()
Message-ID: <20120301072537.502bd918@tlielax.poochiereds.net>
In-Reply-To: <1330602103-8851-5-git-send-email-jack@suse.cz>
References: <1330602103-8851-1-git-send-email-jack@suse.cz>
	<1330602103-8851-5-git-send-email-jack@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Al Viro <viro@ZenIV.linux.org.uk>, linux-fsdevel@vger.kernel.org, dchinner@redhat.com, Steve French <sfrench@samba.org>, linux-cifs@vger.kernel.org

On Thu,  1 Mar 2012 12:41:38 +0100
Jan Kara <jack@suse.cz> wrote:

> CC: Steve French <sfrench@samba.org>
> CC: linux-cifs@vger.kernel.org
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---
>  fs/cifs/file.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/cifs/file.c b/fs/cifs/file.c
> index 4dd9283..8e3b23b 100644
> --- a/fs/cifs/file.c
> +++ b/fs/cifs/file.c
> @@ -2425,6 +2425,9 @@ cifs_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
>  {
>  	struct page *page = vmf->page;
>  
> +	/* Update file times before taking page lock */
> +	file_update_time(vma->vm_file);
> +
>  	lock_page(page);
>  	return VM_FAULT_LOCKED;
>  }

Sorry, I meant to comment on this earlier...

I think we can probably drop this patch. cifs doesn't currently set
S_NOCMTIME on all inodes (only when MS_NOATIME is set currently), but I
think that it probably should. Timestamps should be the purview of the
server.

-- 
Jeff Layton <jlayton@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
