Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 031996B0005
	for <linux-mm@kvack.org>; Sun, 22 Apr 2018 14:03:41 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id p138-v6so2684286lfe.5
        for <linux-mm@kvack.org>; Sun, 22 Apr 2018 11:03:40 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w89-v6sor1324961lfk.66.2018.04.22.11.03.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 22 Apr 2018 11:03:39 -0700 (PDT)
Date: Sun, 22 Apr 2018 21:03:36 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH v2 05/12] fs: Propagate shrinker::id to list_lru
Message-ID: <20180422180336.n6ahbpwmpedjga5n@esperanza>
References: <152397794111.3456.1281420602140818725.stgit@localhost.localdomain>
 <152399122780.3456.1111065927024895559.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <152399122780.3456.1111065927024895559.stgit@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: akpm@linux-foundation.org, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, hillf.zj@alibaba-inc.com, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com

On Tue, Apr 17, 2018 at 09:53:47PM +0300, Kirill Tkhai wrote:
> The patch adds list_lru::shrinker_id field, and populates
> it by registered shrinker id.
> 
> This will be used to set correct bit in memcg shrinkers
> map by lru code in next patches, after there appeared
> the first related to memcg element in list_lru.
> 
> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
> ---
>  fs/super.c               |    4 +++-
>  include/linux/list_lru.h |    1 +
>  include/linux/shrinker.h |    8 +++++++-
>  mm/list_lru.c            |    6 ++++++
>  mm/vmscan.c              |   15 ++++++++++-----
>  mm/workingset.c          |    3 ++-
>  6 files changed, 29 insertions(+), 8 deletions(-)
> 
> diff --git a/fs/super.c b/fs/super.c
> index 5fa9a8d8d865..9bc5698c8c3c 100644
> --- a/fs/super.c
> +++ b/fs/super.c
> @@ -518,7 +518,9 @@ struct super_block *sget_userns(struct file_system_type *type,
>  	hlist_add_head(&s->s_instances, &type->fs_supers);
>  	spin_unlock(&sb_lock);
>  	get_filesystem(type);
> -	err = register_shrinker(&s->s_shrink);
> +	err = register_shrinker_args(&s->s_shrink, 2,
> +				     &s->s_dentry_lru.shrinker_id,
> +				     &s->s_inode_lru.shrinker_id);

This looks ugly. May be, we could allocate an id in prealloc_shrinker
then simply pass it to list_lru_init in arguments?
