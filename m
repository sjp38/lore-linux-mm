Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id C2DA06B0387
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 08:46:17 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id o126so3477054pfb.2
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 05:46:17 -0800 (PST)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id r20si78303pgo.110.2017.03.07.05.46.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Mar 2017 05:46:16 -0800 (PST)
Received: by mail-pg0-x241.google.com with SMTP id 187so191706pgb.2
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 05:46:16 -0800 (PST)
Date: Tue, 07 Mar 2017 22:46:12 +0900 (JST)
Message-Id: <20170307.224612.801707040634574055.konishi.ryusuke@lab.ntt.co.jp>
Subject: Re: [PATCH 1/3] nilfs2: set the mapping error when calling
 SetPageError on writeback
From: Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>
In-Reply-To: <20170305133535.6516-2-jlayton@redhat.com>
References: <20170305133535.6516-1-jlayton@redhat.com>
	<20170305133535.6516-2-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-nilfs@vger.kernel.org

On Sun,  5 Mar 2017 08:35:33 -0500, Jeff Layton <jlayton@redhat.com> wrote:
> In a later patch, we're going to want to make the fsync codepath not do
> a TestClearPageError call as that can override the error set in the
> address space. To do that though, we need to ensure that filesystems
> that are relying on the PG_error bit for reporting writeback errors
> also set an error in the address space.
> 
> The only place I've found that looks potentially problematic is this
> spot in nilfs2. Ensure that it sets an error in the mapping in addition
> to setting PageError.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>

Acked-by: Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>

Agreed that nilfs2 needs this if the successive patch is applied.

Thanks,
Ryusuke Konishi

> ---
>  fs/nilfs2/segment.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/fs/nilfs2/segment.c b/fs/nilfs2/segment.c
> index bedcae2c28e6..c1041b07060e 100644
> --- a/fs/nilfs2/segment.c
> +++ b/fs/nilfs2/segment.c
> @@ -1743,6 +1743,7 @@ static void nilfs_end_page_io(struct page *page, int err)
>  	} else {
>  		__set_page_dirty_nobuffers(page);
>  		SetPageError(page);
> +		mapping_set_error(page_mapping(page), err);
>  	}
>  
>  	end_page_writeback(page);
> -- 
> 2.9.3
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
