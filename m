Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 093606B0253
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 22:27:35 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id o124so308660074pfg.1
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 19:27:35 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id r8si282223pax.279.2016.08.01.19.27.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 01 Aug 2016 19:27:34 -0700 (PDT)
Message-ID: <57A004C7.10307@huawei.com>
Date: Tue, 2 Aug 2016 10:26:15 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] fs: fix a bug when new_insert_key is not initialization
References: <1469850669-64815-1-git-send-email-zhongjiang@huawei.com> <20160801160510.4a48a02d68aa5d89a0435b52@linux-foundation.org>
In-Reply-To: <20160801160510.4a48a02d68aa5d89a0435b52@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2016/8/2 7:05, Andrew Morton wrote:
> On Sat, 30 Jul 2016 11:51:09 +0800 zhongjiang <zhongjiang@huawei.com> wrote:
>
>> From: zhong jiang <zhongjiang@huawei.com>
>>
>> when compile the kenrel code, I happens to the following warn.
>> fs/reiserfs/ibalance.c:1156:2: warning: ___new_insert_key___ may be used
>> uninitialized in this function.
>> memcpy(new_insert_key_addr, &new_insert_key, KEY_SIZE);
>>
>> The patch fix it by check the new_insert_ptr. if new_insert_ptr is not
>> NULL, we ensure that new_insert_key is assigned. therefore, memcpy will
>> saftly exec the operatetion.
>>
>> --- a/fs/reiserfs/ibalance.c
>> +++ b/fs/reiserfs/ibalance.c
>> @@ -1153,8 +1153,10 @@ int balance_internal(struct tree_balance *tb,
>>  				       insert_ptr);
>>  	}
>>  
>> -	memcpy(new_insert_key_addr, &new_insert_key, KEY_SIZE);
>> -	insert_ptr[0] = new_insert_ptr;
>> +	if (new_insert_ptr) {
>> +		memcpy(new_insert_key_addr, &new_insert_key, KEY_SIZE);
>> +		insert_ptr[0] = new_insert_ptr;
>> +	}
>>  
>>  	return order;
> Jeff has aleady fixed this with an equivalent patch.  It's in -mm at
> present.
>
> From: Jeff Mahoney <jeffm@suse.com>
> Subject: reiserfs: fix "new_insert_key may be used uninitialized ..."
>
> new_insert_key only makes any sense when it's associated with a
> new_insert_ptr, which is initialized to NULL and changed to a buffer_head
> when we also initialize new_insert_key.  We can key off of that to avoid
> the uninitialized warning.
>
> Link: http://lkml.kernel.org/r/5eca5ffb-2155-8df2-b4a2-f162f105efed@suse.com
> Signed-off-by: Jeff Mahoney <jeffm@suse.com>
> Cc: Arnd Bergmann <arnd@arndb.de>
> Cc: Jan Kara <jack@suse.cz>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
>
>  fs/reiserfs/ibalance.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff -puN fs/reiserfs/ibalance.c~reiserfs-fix-new_insert_key-may-be-used-uninitialized fs/reiserfs/ibalance.c
> --- a/fs/reiserfs/ibalance.c~reiserfs-fix-new_insert_key-may-be-used-uninitialized
> +++ a/fs/reiserfs/ibalance.c
> @@ -1153,8 +1153,9 @@ int balance_internal(struct tree_balance
>  				       insert_ptr);
>  	}
>  
> -	memcpy(new_insert_key_addr, &new_insert_key, KEY_SIZE);
>  	insert_ptr[0] = new_insert_ptr;
> +	if (new_insert_ptr)
> +		memcpy(new_insert_key_addr, &new_insert_key, KEY_SIZE);
>  
>  	return order;
>  }
> _
>
>
> .
>
 ok ,  I did not notice.  thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
