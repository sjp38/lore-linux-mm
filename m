Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id BBAC86B007E
	for <linux-mm@kvack.org>; Mon, 14 Mar 2016 12:09:03 -0400 (EDT)
Received: by mail-wm0-f42.google.com with SMTP id l68so108897420wml.0
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 09:09:03 -0700 (PDT)
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com. [74.125.82.49])
        by mx.google.com with ESMTPS id bz2si26653413wjb.186.2016.03.14.09.09.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Mar 2016 09:09:02 -0700 (PDT)
Received: by mail-wm0-f49.google.com with SMTP id p65so108629133wmp.1
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 09:09:02 -0700 (PDT)
Date: Mon, 14 Mar 2016 17:09:00 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,writeback: Don't use memory reserves for
 wb_start_writeback
Message-ID: <20160314160900.GC11400@dhcp22.suse.cz>
References: <1457847155-19394-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <201603132322.BEA57780.QMVOHFOSFJLOtF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201603132322.BEA57780.QMVOHFOSFJLOtF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: viro@zeniv.linux.org.uk, tj@kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Sun 13-03-16 23:22:23, Tetsuo Handa wrote:
[...]

I am not familiar with the writeback code so I might be missing
something essential here but why are we even queueing more and more
work without checking there has been enough already scheduled or in
progress.

Something as simple as:
diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 6915c950e6e8..aa52e23ac280 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -887,7 +887,7 @@ void wb_start_writeback(struct bdi_writeback *wb, long nr_pages,
 {
 	struct wb_writeback_work *work;
 
-	if (!wb_has_dirty_io(wb))
+	if (!wb_has_dirty_io(wb) || writeback_in_progress(wb))
 		return;
 
 	/*

> diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
> index 5c46ed9..21450c7 100644
> --- a/fs/fs-writeback.c
> +++ b/fs/fs-writeback.c
> @@ -929,7 +929,8 @@ void wb_start_writeback(struct bdi_writeback *wb, long nr_pages,
>  	 * This is WB_SYNC_NONE writeback, so if allocation fails just
>  	 * wakeup the thread for old dirty data writeback
>  	 */
> -	work = kzalloc(sizeof(*work), GFP_ATOMIC);
> +	work = kzalloc(sizeof(*work),
> +		       GFP_NOWAIT | __GFP_NOMEMALLOC | __GFP_NOWARN);

Well, I guess you are right that this doesn't sound like a context
which really needs access to memory reserves and GFP_ATOMIC would more
used for what can be achieved by GFP_NOWAIT now. Using __GFP_NOMEMALLOC
would be needed regardless as you pointed out already because this might
be called from the page reclaim context. So if the above simple hack
or other explicit limit cannot be done then __GFP_NOMEMALLOC is an
absolute minimum.

>  	if (!work) {
>  		trace_writeback_nowork(wb);
>  		wb_wakeup(wb);
> -- 
> 1.8.3.1

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
