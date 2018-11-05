Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 03BAD6B0003
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 04:01:17 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id z7-v6so5063364edh.19
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 01:01:16 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u35-v6si168221edm.244.2018.11.05.01.01.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 01:01:15 -0800 (PST)
Date: Mon, 5 Nov 2018 10:01:14 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] mm: fix uninitialized variable warnings
Message-ID: <20181105090114.GD6953@quack2.suse.cz>
References: <20181102153138.1399758-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181102153138.1399758-1-arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.com>, Wang Long <wanglong19@meituan.com>, Matthew Wilcox <willy@infradead.org>, Dave Chinner <dchinner@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>

On Fri 02-11-18 16:31:06, Arnd Bergmann wrote:
> In a rare randconfig build, I got a warning about possibly uninitialized
> variables:
> 
> mm/page-writeback.c: In function 'balance_dirty_pages':
> mm/page-writeback.c:1623:16: error: 'writeback' may be used uninitialized in this function [-Werror=maybe-uninitialized]
>     mdtc->dirty += writeback;
>                 ^~
> mm/page-writeback.c:1624:4: error: 'filepages' may be used uninitialized in this function [-Werror=maybe-uninitialized]
>     mdtc_calc_avail(mdtc, filepages, headroom);
>     ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> mm/page-writeback.c:1624:4: error: 'headroom' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> 
> The compiler evidently fails to notice that the usage is in dead code
> after 'mdtc' is set to NULL when CONFIG_CGROUP_WRITEBACK is disabled.
> Adding an IS_ENABLED() check makes this clear to the compiler.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

I'm surprised the compiler was not able to infer this since:

struct dirty_throttle_control * const mdtc = mdtc_valid(&mdtc_stor) ?
                                                     &mdtc_stor : NULL;

and if CONFIG_CGROUP_WRITEBACK is disabled, mdtc_valid() is defined to
'false'.  But possibly the function is just too big and the problematic
condition is in the loop so maybe it all confuses the compiler too much.

> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index 3f690bae6b78..f02535b7731a 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -1611,7 +1611,7 @@ static void balance_dirty_pages(struct bdi_writeback *wb,
>  			bg_thresh = gdtc->bg_thresh;
>  		}
>  
> -		if (mdtc) {
> +		if (IS_ENABLED(CONFIG_CGROUP_WRITEBACK) && mdtc) {
>  			unsigned long filepages, headroom, writeback;

Honestly, I don't like the IS_ENABLED(CONFIG_CGROUP_WRITEBACK) check here.
It just looks too arbitrary. Could we perhaps change the code like

struct dirty_throttle_control * const mdtc = &mdtc_stor;

And then replace checks for !mtdc in the function to !mdtc_valid(mdtc)?
That is the same thing as currently and it should make it obvious to the
compiler as well as human what is going on... Tejun?

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
