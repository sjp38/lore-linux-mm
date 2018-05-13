Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 67B276B000A
	for <linux-mm@kvack.org>; Sun, 13 May 2018 12:58:01 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id w26-v6so12839752qto.4
        for <linux-mm@kvack.org>; Sun, 13 May 2018 09:58:01 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z23-v6sor5602842qka.52.2018.05.13.09.58.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 13 May 2018 09:58:00 -0700 (PDT)
Date: Sun, 13 May 2018 19:57:56 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH v5 06/13] fs: Propagate shrinker::id to list_lru
Message-ID: <20180513165756.obsexfkvnyoylq6v@esperanza>
References: <152594582808.22949.8353313986092337675.stgit@localhost.localdomain>
 <152594598693.22949.2394903594690437296.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <152594598693.22949.2394903594690437296.stgit@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: akpm@linux-foundation.org, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com

On Thu, May 10, 2018 at 12:53:06PM +0300, Kirill Tkhai wrote:
> The patch adds list_lru::shrinker_id field, and populates
> it by registered shrinker id.
> 
> This will be used to set correct bit in memcg shrinkers
> map by lru code in next patches, after there appeared
> the first related to memcg element in list_lru.
> 
> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
> ---
>  fs/super.c               |    4 ++++
>  include/linux/list_lru.h |    3 +++
>  mm/list_lru.c            |    6 ++++++
>  mm/workingset.c          |    3 +++
>  4 files changed, 16 insertions(+)
> 
> diff --git a/fs/super.c b/fs/super.c
> index 2ccacb78f91c..dfa85e725e45 100644
> --- a/fs/super.c
> +++ b/fs/super.c
> @@ -258,6 +258,10 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags,
>  		goto fail;
>  	if (list_lru_init_memcg(&s->s_inode_lru))
>  		goto fail;
> +#ifdef CONFIG_MEMCG_SHRINKER
> +	s->s_dentry_lru.shrinker_id = s->s_shrink.id;
> +	s->s_inode_lru.shrinker_id = s->s_shrink.id;
> +#endif

I don't like this. Can't you simply pass struct shrinker to
list_lru_init_memcg() and let it extract the id?
