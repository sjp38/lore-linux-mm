Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7F4AB6B32F5
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 23:01:26 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id b29-v6so4244725pfm.1
        for <linux-mm@kvack.org>; Fri, 24 Aug 2018 20:01:26 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x2-v6sor2240611pge.88.2018.08.24.20.01.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 24 Aug 2018 20:01:22 -0700 (PDT)
Subject: Re: [PATCH] fs: Fix double prealloc_shrinker() in sget_fc()
References: <153131984019.24777.15284245961241666054.stgit@localhost.localdomain>
From: Jia He <hejianet@gmail.com>
Message-ID: <3a12cb86-5d2d-aa24-56fb-ec046570705d@gmail.com>
Date: Sat, 25 Aug 2018 11:01:23 +0800
MIME-Version: 1.0
In-Reply-To: <153131984019.24777.15284245961241666054.stgit@localhost.localdomain>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, dhowells@redhat.com



On 7/11/2018 10:37 PM, Kirill Tkhai Wrote:
> Hi,
> 
> I'm observing "KASAN: use-after-free Read in shrink_slab" on recent
> linux-next in the code I've added:
> 
> https://syzkaller.appspot.com/bug?id=91767fc6346a4b9e0309a8cd7e2f356c434450b9
> 
> It seems to be not related to my patchset, since there is
> a problem with double preallocation of shrinker. We should
> use register_shrinker_prepared() in sget_fc(), since shrinker
> is already allocated in alloc_super().
> 
> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
> ---
>  fs/super.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/super.c b/fs/super.c
> index 13647d4fd262..47a819f1a300 100644
> --- a/fs/super.c
> +++ b/fs/super.c
> @@ -551,7 +551,7 @@ struct super_block *sget_fc(struct fs_context *fc,
>  	hlist_add_head(&s->s_instances, &s->s_type->fs_supers);
>  	spin_unlock(&sb_lock);
>  	get_filesystem(s->s_type);
> -	register_shrinker(&s->s_shrink);
> +	register_shrinker_prepared(&s->shrinker);

should be &s->shrink here  ?

-- 
Cheers,
Jia
