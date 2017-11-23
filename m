Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9D76B6B0281
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 06:26:58 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id k100so11877275wrc.9
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 03:26:58 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 59si549028edf.284.2017.11.23.03.26.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 23 Nov 2017 03:26:57 -0800 (PST)
Date: Thu, 23 Nov 2017 12:26:54 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: general protection fault in __list_del_entry_valid (2)
Message-ID: <20171123112654.4yjlj5vbtk3lzyl3@dhcp22.suse.cz>
References: <001a113f996099503a055e793dd3@google.com>
 <0e1109ef-6d4a-e873-a809-6548776a00f9@I-love.SAKURA.ne.jp>
 <20171121140500.bgkpwcdk2dxesao4@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171121140500.bgkpwcdk2dxesao4@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: syzbot <bot+065a25551da6c9ab4283b7ae889c707a37ab2de3@syzkaller.appspotmail.com>, akpm@linux-foundation.org, hannes@cmpxchg.org, hillf.zj@alibaba-inc.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mgorman@techsingularity.net, minchan@kernel.org, shli@fb.com, syzkaller-bugs@googlegroups.com, ying.huang@intel.com, Al Viro <viro@zeniv.linux.org.uk>, Dave Chinner <david@fromorbit.com>

On Tue 21-11-17 15:05:00, Michal Hocko wrote:
> [Cc Al and Dave - email thread starts http://lkml.kernel.org/r/001a113f996099503a055e793dd3@google.com]
[...]
> Something like the totally untested and possibly wrong
> ---
> diff --git a/fs/super.c b/fs/super.c
> index 994db21f59bf..1eb850413fdf 100644
> --- a/fs/super.c
> +++ b/fs/super.c
> @@ -506,6 +506,11 @@ struct super_block *sget_userns(struct file_system_type *type,
>  		s = alloc_super(type, (flags & ~SB_SUBMOUNT), user_ns);
>  		if (!s)
>  			return ERR_PTR(-ENOMEM);
> +		if (register_shrinker(&s->s_shrink)) {
> +			up_write(&s->s_umount);
> +			destroy_super(s);
> +			return ERR_PTR(-ENOMEM);
> +		}
>  		goto retry;
>  	}
>  
> @@ -522,7 +527,6 @@ struct super_block *sget_userns(struct file_system_type *type,
>  	hlist_add_head(&s->s_instances, &type->fs_supers);
>  	spin_unlock(&sb_lock);
>  	get_filesystem(type);
> -	register_shrinker(&s->s_shrink);
>  	return s;
>  }

This is not complete. I thought we would unregister the shrinker
somewher in destroy_super path but this is not the case. I will send
another patch along with other shrinkers registration fixes in a
separate thread.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
