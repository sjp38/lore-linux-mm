Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f170.google.com (mail-we0-f170.google.com [74.125.82.170])
	by kanga.kvack.org (Postfix) with ESMTP id 923EF6B0035
	for <linux-mm@kvack.org>; Mon, 29 Sep 2014 21:47:49 -0400 (EDT)
Received: by mail-we0-f170.google.com with SMTP id q58so4604663wes.29
        for <linux-mm@kvack.org>; Mon, 29 Sep 2014 18:47:48 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id cl3si14617715wib.53.2014.09.29.18.47.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 29 Sep 2014 18:47:48 -0700 (PDT)
Message-ID: <542A0B61.1020500@huawei.com>
Date: Tue, 30 Sep 2014 09:46:09 +0800
From: Joseph Qi <joseph.qi@huawei.com>
MIME-Version: 1.0
Subject: Re: [kbuild] [mmotm:master 57/427] fs/ocfs2/journal.c:2204:9: sparse:
 context imbalance in 'ocfs2_recover_orphans' - different lock contexts for
 basic block
References: <20140926143636.GA3414@mwanda> <20140929140834.99ceb99a2bb2e0503e750ea7@linux-foundation.org>
In-Reply-To: <20140929140834.99ceb99a2bb2e0503e750ea7@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dan Carpenter <dan.carpenter@oracle.com>, kbuild@01.org, WeiWei Wang <wangww631@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux Memory
 Management List <linux-mm@kvack.org>

On 2014/9/30 5:08, Andrew Morton wrote:
> On Fri, 26 Sep 2014 17:36:37 +0300 Dan Carpenter <dan.carpenter@oracle.com> wrote:
> 
>> commit: 8a09937cacc099da21313223443237cbc84d5876 [57/427] ocfs2: add orphan recovery types in ocfs2_recover_orphans
>>
>> ...
>>
>>>> fs/ocfs2/journal.c:2204:9: sparse: context imbalance in 'ocfs2_recover_orphans' - different lock contexts for basic block
>>
> 
> this?

I think there is another deadlock case in ocfs2_recover_orphans.

*spin_lock(&oi->ip_lock)*
	ocfs2_inode_lock
		ocfs2_inode_lock_full_nested
			ocfs2_inode_lock_update
				*spin_lock(&oi->ip_lock)*

Since ip_lock only wants to protect ip_flags and the added new logic
ocfs2_del_inode_from_orphan has nothing to do with it, distinguish
them.

> 
> --- a/fs/ocfs2/journal.c~ocfs2-add-orphan-recovery-types-in-ocfs2_recover_orphans-fix
> +++ a/fs/ocfs2/journal.c
> @@ -2160,8 +2160,7 @@ static int ocfs2_recover_orphans(struct
>  			ret = ocfs2_inode_lock(inode, &di_bh, 1);
>  			if (ret) {
>  				mlog_errno(ret);
> -				spin_unlock(&oi->ip_lock);
> -				goto out;
> +				goto out_unlock;
>  			}
>  			ocfs2_truncate_file(inode, di_bh, i_size_read(inode));
>  			ocfs2_inode_unlock(inode, 1);
> @@ -2173,14 +2172,13 @@ static int ocfs2_recover_orphans(struct
>  					OCFS2_INODE_DEL_FROM_ORPHAN_CREDITS);
>  			if (IS_ERR(handle)) {
>  				ret = PTR_ERR(handle);
> -				goto out;
> +				goto out_unlock;
>  			}
>  			ret = ocfs2_del_inode_from_orphan(osb, handle, inode);
>  			if (ret) {
>  				mlog_errno(ret);
>  				ocfs2_commit_trans(osb, handle);
> -				spin_unlock(&oi->ip_lock);
> -				goto out;
> +				goto out_unlock;
>  			}
>  			ocfs2_commit_trans(osb, handle);
>  		}
> @@ -2200,7 +2198,10 @@ static int ocfs2_recover_orphans(struct
>  		inode = iter;
>  	}
>  
> -out:
> +	return ret;
> +
> +out_unlock:
> +	spin_unlock(&oi->ip_lock);
>  	return ret;
>  }
>  
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
