Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id E5B9D6B0005
	for <linux-mm@kvack.org>; Wed, 16 Mar 2016 16:46:20 -0400 (EDT)
Received: by mail-pf0-f176.google.com with SMTP id u190so88834281pfb.3
        for <linux-mm@kvack.org>; Wed, 16 Mar 2016 13:46:20 -0700 (PDT)
Received: from mail-pf0-x233.google.com (mail-pf0-x233.google.com. [2607:f8b0:400e:c00::233])
        by mx.google.com with ESMTPS id u62si7254716pfi.160.2016.03.16.13.46.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Mar 2016 13:46:19 -0700 (PDT)
Received: by mail-pf0-x233.google.com with SMTP id x3so88735876pfb.1
        for <linux-mm@kvack.org>; Wed, 16 Mar 2016 13:46:19 -0700 (PDT)
Date: Wed, 16 Mar 2016 13:46:17 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] mm,writeback: Don't use memory reserves for
 wb_start_writeback
Message-ID: <20160316204617.GH21104@mtj.duckdns.org>
References: <1457847155-19394-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <201603132322.BEA57780.QMVOHFOSFJLOtF@I-love.SAKURA.ne.jp>
 <20160314160900.GC11400@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160314160900.GC11400@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, viro@zeniv.linux.org.uk, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Jan Kara <jack@suse.com>

Hello,

(cc'ing Jan)

On Mon, Mar 14, 2016 at 05:09:00PM +0100, Michal Hocko wrote:
> On Sun 13-03-16 23:22:23, Tetsuo Handa wrote:
> [...]
> 
> I am not familiar with the writeback code so I might be missing
> something essential here but why are we even queueing more and more
> work without checking there has been enough already scheduled or in
> progress.
>
> Something as simple as:
> diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
> index 6915c950e6e8..aa52e23ac280 100644
> --- a/fs/fs-writeback.c
> +++ b/fs/fs-writeback.c
> @@ -887,7 +887,7 @@ void wb_start_writeback(struct bdi_writeback *wb, long nr_pages,
>  {
>  	struct wb_writeback_work *work;
>  
> -	if (!wb_has_dirty_io(wb))
> +	if (!wb_has_dirty_io(wb) || writeback_in_progress(wb))
>  		return;

I'm not sure this would be safe.  It shouldn't harm correctness as
wb_start_writeback() isn't used in sync case but this might change
flush behavior in various ways.  Dropping GFP_ATOMIC as suggested by
Tetsuo is likely better.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
