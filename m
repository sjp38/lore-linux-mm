Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 11F916B0003
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 20:59:50 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id q6so83227wre.20
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 17:59:50 -0700 (PDT)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id i16si2640296wre.357.2018.04.10.17.59.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Apr 2018 17:59:48 -0700 (PDT)
Date: Wed, 11 Apr 2018 01:59:38 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: WARNING in kill_block_super
Message-ID: <20180411005938.GN30522@ZenIV.linux.org.uk>
References: <001a114043bcfab6ab05689518f9@google.com>
 <6c95e826-4b9f-fb21-b311-830411e58480@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6c95e826-4b9f-fb21-b311-830411e58480@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Michal Hocko <mhocko@suse.com>, syzbot <syzbot+5a170e19c963a2e0df79@syzkaller.appspotmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, syzkaller-bugs@googlegroups.com, linux-mm <linux-mm@kvack.org>, Dmitry Vyukov <dvyukov@google.com>

On Wed, Apr 04, 2018 at 07:53:07PM +0900, Tetsuo Handa wrote:
> Al and Michal, are you OK with this patch?

First of all, it does *NOT* fix the problems with careless ->kill_sb().
The fuse-blk case is the only real rationale so far.  Said that,

> @@ -166,6 +166,7 @@ static void destroy_unused_super(struct super_block *s)
>  	security_sb_free(s);
>  	put_user_ns(s->s_user_ns);
>  	kfree(s->s_subtype);
> +	kfree(s->s_shrink.nr_deferred);

is probably better done with an inlined helper (fs/super.c has no business knowing
about ->nr_deferred name, and there probably will be other users of that
preallocation of yours).  And the same helper would be better off zeroing the
pointer, same as unregister_shrinker() does.


> -int register_shrinker(struct shrinker *shrinker)
> +int prepare_shrinker(struct shrinker *shrinker)

preallocate_shrinker(), perhaps?

> +int register_shrinker(struct shrinker *shrinker)
> +{
> +	int err = prepare_shrinker(shrinker);
> +
> +	if (err)
> +		return err;
> +	register_shrinker_prepared(shrinker);

	if (!err)
		register_....;
	return err;

would be better, IMO.
