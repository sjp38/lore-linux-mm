Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 75DD36B0253
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 19:05:12 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id h186so297894383pfg.2
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 16:05:12 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 19si37282961pft.165.2016.08.01.16.05.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Aug 2016 16:05:11 -0700 (PDT)
Date: Mon, 1 Aug 2016 16:05:10 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] fs: fix a bug when new_insert_key is not initialization
Message-Id: <20160801160510.4a48a02d68aa5d89a0435b52@linux-foundation.org>
In-Reply-To: <1469850669-64815-1-git-send-email-zhongjiang@huawei.com>
References: <1469850669-64815-1-git-send-email-zhongjiang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhongjiang <zhongjiang@huawei.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, 30 Jul 2016 11:51:09 +0800 zhongjiang <zhongjiang@huawei.com> wrote:

> From: zhong jiang <zhongjiang@huawei.com>
> 
> when compile the kenrel code, I happens to the following warn.
> fs/reiserfs/ibalance.c:1156:2: warning: ___new_insert_key___ may be used
> uninitialized in this function.
> memcpy(new_insert_key_addr, &new_insert_key, KEY_SIZE);
> 
> The patch fix it by check the new_insert_ptr. if new_insert_ptr is not
> NULL, we ensure that new_insert_key is assigned. therefore, memcpy will
> saftly exec the operatetion.
> 
> --- a/fs/reiserfs/ibalance.c
> +++ b/fs/reiserfs/ibalance.c
> @@ -1153,8 +1153,10 @@ int balance_internal(struct tree_balance *tb,
>  				       insert_ptr);
>  	}
>  
> -	memcpy(new_insert_key_addr, &new_insert_key, KEY_SIZE);
> -	insert_ptr[0] = new_insert_ptr;
> +	if (new_insert_ptr) {
> +		memcpy(new_insert_key_addr, &new_insert_key, KEY_SIZE);
> +		insert_ptr[0] = new_insert_ptr;
> +	}
>  
>  	return order;

Jeff has aleady fixed this with an equivalent patch.  It's in -mm at
present.

From: Jeff Mahoney <jeffm@suse.com>
Subject: reiserfs: fix "new_insert_key may be used uninitialized ..."

new_insert_key only makes any sense when it's associated with a
new_insert_ptr, which is initialized to NULL and changed to a buffer_head
when we also initialize new_insert_key.  We can key off of that to avoid
the uninitialized warning.

Link: http://lkml.kernel.org/r/5eca5ffb-2155-8df2-b4a2-f162f105efed@suse.com
Signed-off-by: Jeff Mahoney <jeffm@suse.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Jan Kara <jack@suse.cz>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 fs/reiserfs/ibalance.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff -puN fs/reiserfs/ibalance.c~reiserfs-fix-new_insert_key-may-be-used-uninitialized fs/reiserfs/ibalance.c
--- a/fs/reiserfs/ibalance.c~reiserfs-fix-new_insert_key-may-be-used-uninitialized
+++ a/fs/reiserfs/ibalance.c
@@ -1153,8 +1153,9 @@ int balance_internal(struct tree_balance
 				       insert_ptr);
 	}
 
-	memcpy(new_insert_key_addr, &new_insert_key, KEY_SIZE);
 	insert_ptr[0] = new_insert_ptr;
+	if (new_insert_ptr)
+		memcpy(new_insert_key_addr, &new_insert_key, KEY_SIZE);
 
 	return order;
 }
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
