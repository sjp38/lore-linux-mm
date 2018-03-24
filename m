Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id E214D6B0024
	for <linux-mm@kvack.org>; Sat, 24 Mar 2018 14:50:22 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id i14-v6so4882647lfh.1
        for <linux-mm@kvack.org>; Sat, 24 Mar 2018 11:50:22 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c75-v6sor847456lfb.11.2018.03.24.11.50.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 24 Mar 2018 11:50:21 -0700 (PDT)
Date: Sat, 24 Mar 2018 21:50:18 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH 04/10] fs: Propagate shrinker::id to list_lru
Message-ID: <20180324185018.iibbx3zjtzikjtlc@esperanza>
References: <152163840790.21546.980703278415599202.stgit@localhost.localdomain>
 <152163851112.21546.11559231484397320114.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <152163851112.21546.11559231484397320114.stgit@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, akpm@linux-foundation.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, hillf.zj@alibaba-inc.com, ying.huang@intel.com, mgorman@techsingularity.net, shakeelb@google.com, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org

On Wed, Mar 21, 2018 at 04:21:51PM +0300, Kirill Tkhai wrote:
> The patch adds list_lru::shrk_id field, and populates
> it by registered shrinker id.
> 
> This will be used to set correct bit in memcg shrinkers
> map by lru code in next patches, after there appeared
> the first related to memcg element in list_lru.
> 
> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
> ---
>  fs/super.c               |    5 +++++
>  include/linux/list_lru.h |    1 +
>  mm/list_lru.c            |    7 ++++++-
>  mm/workingset.c          |    3 +++
>  4 files changed, 15 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/super.c b/fs/super.c
> index 0660083427fa..1f3dc4eab409 100644
> --- a/fs/super.c
> +++ b/fs/super.c
> @@ -521,6 +521,11 @@ struct super_block *sget_userns(struct file_system_type *type,
>  	if (err) {
>  		deactivate_locked_super(s);
>  		s = ERR_PTR(err);
> +	} else {
> +#if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
> +		s->s_dentry_lru.shrk_id = s->s_shrink.id;
> +		s->s_inode_lru.shrk_id = s->s_shrink.id;
> +#endif

I don't really like the new member name. Let's call it shrink_id or
shrinker_id, shall we?

Also, I think we'd better pass shrink_id to list_lru_init rather than
setting it explicitly.
