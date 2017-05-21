Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id E4E63280850
	for <linux-mm@kvack.org>; Sat, 20 May 2017 22:45:47 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id u206so70026900ywe.9
        for <linux-mm@kvack.org>; Sat, 20 May 2017 19:45:47 -0700 (PDT)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id w6si4546281ywj.277.2017.05.20.19.45.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 20 May 2017 19:45:46 -0700 (PDT)
Date: Sat, 20 May 2017 22:45:44 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH] ext4: handle the rest of ext4_mb_load_buddy() ENOMEM
 errors
Message-ID: <20170521024544.udju6nbsfdanf5pl@thunk.org>
References: <149517779388.33359.16474190951431954772.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <149517779388.33359.16474190951431954772.stgit@buzz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: Andreas Dilger <adilger.kernel@dilger.ca>, linux-ext4@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, May 19, 2017 at 10:09:54AM +0300, Konstantin Khlebnikov wrote:
> I've got another report about breaking ext4 by ENOMEM error returned from
> ext4_mb_load_buddy() caused by memory shortage in memory cgroup.
> This time inside ext4_discard_preallocations().
> 
> This patch replaces ext4_error() with ext4_warning() where errors returned
> from ext4_mb_load_buddy() are not fatal and handled by caller:
> * ext4_mb_discard_group_preallocations() - called before generating ENOSPC,
>   we'll try to discard other group or return ENOSPC into user-space.
> * ext4_trim_all_free() - just stop trimming and return ENOMEM from ioctl.
> 
> Some callers cannot handle errors, thus __GFP_NOFAIL is used for them:
> * ext4_discard_preallocations()
> * ext4_mb_discard_lg_preallocations()
> 
> The only unclear case is ext4_group_add_blocks(), probably ext4_std_error()
> should handle ENOMEM as warning and don't break filesystem.
> 
> Fixes: adb7ef600cc9 ("ext4: use __GFP_NOFAIL in ext4_free_blocks()")
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

Thanks, applied.

					- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
