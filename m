Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f173.google.com (mail-qc0-f173.google.com [209.85.216.173])
	by kanga.kvack.org (Postfix) with ESMTP id C14216B0032
	for <linux-mm@kvack.org>; Thu, 22 Jan 2015 09:34:58 -0500 (EST)
Received: by mail-qc0-f173.google.com with SMTP id m20so1445144qcx.4
        for <linux-mm@kvack.org>; Thu, 22 Jan 2015 06:34:58 -0800 (PST)
Received: from mail-qg0-x232.google.com (mail-qg0-x232.google.com. [2607:f8b0:400d:c04::232])
        by mx.google.com with ESMTPS id q16si9088682qam.36.2015.01.22.06.34.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Jan 2015 06:34:57 -0800 (PST)
Received: by mail-qg0-f50.google.com with SMTP id f51so1390107qge.9
        for <linux-mm@kvack.org>; Thu, 22 Jan 2015 06:34:57 -0800 (PST)
Date: Thu, 22 Jan 2015 09:34:54 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [Regression] 3.19-rc3 : memcg: Hang in mount memcg
Message-ID: <20150122143454.GA4507@htj.dyndns.org>
References: <54B01335.4060901@arm.com>
 <20150110085525.GD2110@esperanza>
 <54BCFDCF.9090603@arm.com>
 <20150121163955.GM4549@arm.com>
 <20150122134550.GA13876@phnom.home.cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150122134550.GA13876@phnom.home.cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Will Deacon <will.deacon@arm.com>, "Suzuki K. Poulose" <Suzuki.Poulose@arm.com>, Vladimir Davydov <vdavydov@parallels.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "mhocko@suse.cz" <mhocko@suse.cz>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

Hello,

On Thu, Jan 22, 2015 at 08:45:50AM -0500, Johannes Weiner wrote:
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index bb263d0caab3..9a09308c8066 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -1819,8 +1819,11 @@ static struct dentry *cgroup_mount(struct file_system_type *fs_type,
>  			goto out_unlock;
>  		}
>  
> -		if (root->flags ^ opts.flags)
> -			pr_warn("new mount options do not match the existing superblock, will be ignored\n");
> +		if (root->flags ^ opts.flags) {
> +			pr_warn("new mount options do not match the existing superblock\n");
> +			ret = -EBUSY;
> +			goto out_unlock;
> +		}

Do we really need the above chunk?

> @@ -1909,7 +1912,7 @@ static void cgroup_kill_sb(struct super_block *sb)
>  	 *
>  	 * And don't kill the default root.
>  	 */
> -	if (css_has_online_children(&root->cgrp.self) ||
> +	if (!list_empty(&root->cgrp.self.children) ||
>  	    root == &cgrp_dfl_root)
>  		cgroup_put(&root->cgrp);

I tried to do something a bit more advanced so that eventual async
release of dying children, if they happen, can also release the
hierarchy but I don't think it really matters unless we can forcefully
drain.  So, shouldn't just the above part be enough?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
