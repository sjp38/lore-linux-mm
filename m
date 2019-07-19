Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EE1A4C76196
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 21:13:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AAC682189F
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 21:13:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AAC682189F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 369968E0001; Fri, 19 Jul 2019 17:13:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 319586B000E; Fri, 19 Jul 2019 17:13:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 208728E0001; Fri, 19 Jul 2019 17:13:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id E11926B000D
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 17:13:19 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id a21so12530627pgv.0
        for <linux-mm@kvack.org>; Fri, 19 Jul 2019 14:13:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=/jrcNVnMnIue6k9k1aJZFVhcqPM8sqJaZBnSCJJiWqU=;
        b=YUZLAIrd97fUml064KTkd51aq8X5BPau7zVwh1+sb5rldkUpU0fbPEFWVJK+vWJym6
         RfY3svbZ1dk1OKg4mxQ9Ed2oLO7jXit2yyfzEkRtcSCtkg5xRbBkYIGZpJGmfKNeotYi
         icUkFAYzDjECe0Jzk7xf2tzyItqapXjUpyEihd1PABdUb+/I5oKmAlf/I4b/cYW/+9AI
         B8t0hTRVstsxjY+swU2O5xNMZSRQQsu4cufNA4UhE9GULtms6FTEDxCoxqm3n/f8/j77
         +IP+W3FD4PA7JrT1p87Z6X/nWU9k8Jc5hrDz8VVh8/eU9SeMQhaVZVrQ6Rf6XcYzeIM1
         D3Pg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVGUc6/MCQf4vL5RQBJJ/qi3IiYH9iadfE7k3NXjic0VFkJazls
	1SQmed0iE2nK3eNWOYNUC5AneKK0y2SYRLdddRyM0RxvASGVgXdSeGQ7nAdfoSmAEySdqheOvsl
	enar0VzSsbz4aBK7gq6cTVcpDX/NCp37Om3G0MvAD3f99JJWjBMTgXHxX+/ZK20Y=
X-Received: by 2002:a65:6497:: with SMTP id e23mr54132669pgv.89.1563570799440;
        Fri, 19 Jul 2019 14:13:19 -0700 (PDT)
X-Received: by 2002:a65:6497:: with SMTP id e23mr54132616pgv.89.1563570798414;
        Fri, 19 Jul 2019 14:13:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563570798; cv=none;
        d=google.com; s=arc-20160816;
        b=FCLUf/oncsou0RWTul4g/vVbGr2poJ/3xsdTVsmfMo7tTOtJ5HBpct4OCOFTA5quV2
         q6vOa+6ioQloOgmDQqHjou/NLGBsJN6fQ4XT2CJEA3d6ucPoDJ2PZU2zUc6xNgIbHWy7
         iQTHOKikLgT0Dajk0wY5aBd6pc+Qsskgd/Rry6Oio6WgC7KUis40WZePH8GVs78l9PRH
         kxcNiGIiJ6Vl6JoG4kGPsfBMwYAbg2EkUYieQfcJR1tOUvLRUzeHMvKiydX5ZXeySBsq
         71JejLqgKg+BrpOUyI9TZC5GzxybrsEh3v/n23QXA8Zdsur8jnduLug/crkAn8US+42k
         HU+A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=/jrcNVnMnIue6k9k1aJZFVhcqPM8sqJaZBnSCJJiWqU=;
        b=i5hzRB6IWC8VMrnZiB3gkYAsT+WwFWpI5bPHg7zf+ITT5pPVw37jrs8Xt3AQ9CrZyA
         jEnQH5iy8E5PWND/uvgXpWBuY0U0j8f569ntmvSg43B0YCZ4mLUWVrD5/fEVVRuzP0QB
         dKFpUYZu6PTJloqowhyIL9oUczdwTGNOs1AP3CAHVRxl3hWwnOFK/1OXaJTft72hmN2g
         sNAl5bqwpiRCzH230ifeeu14H1Yex0+0xhhCXLLXAoQbSV63aL1lbrg6O1TFz4LVwb/f
         NlFKebYB/2lLWaqmDH9vGLqeusc8aWfrDGDJco9UcfLEreWAcM9wOBxqATtRgIKQERqR
         LG2A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z15sor12759719pfq.47.2019.07.19.14.13.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 19 Jul 2019 14:13:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: APXvYqwXfURNPNAeVm7Xt/Ctx5dOnsMBuPlWNIwmEr1NkC0XINNORv4z730nJ7Dz3I0FzWKvlSvp1Q==
X-Received: by 2002:a63:ff20:: with SMTP id k32mr56387095pgi.445.1563570798006;
        Fri, 19 Jul 2019 14:13:18 -0700 (PDT)
Received: from dennisz-mbp.dhcp.thefacebook.com ([2620:10d:c091:500::790f])
        by smtp.gmail.com with ESMTPSA id 6sm17543929pfn.87.2019.07.19.14.13.16
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jul 2019 14:13:17 -0700 (PDT)
Date: Fri, 19 Jul 2019 17:13:14 -0400
From: Dennis Zhou <dennis@kernel.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: Jens Axboe <axboe@fb.com>, linux-kernel@vger.kernel.org,
	linux-block@vger.kernel.org, linux-mm@kvack.org,
	Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org
Subject: Re: [PATCH] cgroup writeback: use online cgroup when switching from
 dying bdi_writebacks
Message-ID: <20190719211314.GA5066@dennisz-mbp.dhcp.thefacebook.com>
References: <156355839560.2063.5265687291430814589.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <156355839560.2063.5265687291430814589.stgit@buzz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 19, 2019 at 08:46:35PM +0300, Konstantin Khlebnikov wrote:
> Offline memory cgroups forbids creation new bdi_writebacks.
> Each try wastes cpu cycles and increases contention around cgwb_lock.
> 
> For example each O_DIRECT read calls filemap_write_and_wait_range()
> if inode has cached pages which tries to switch from dying writeback.
> 
> This patch switches inode writeback to closest online parent cgroup.
> 
> Fixes: e8a7abf5a5bd ("writeback: disassociate inodes from dying bdi_writebacks")
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> ---
>  fs/fs-writeback.c |   13 ++++++++++---
>  1 file changed, 10 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
> index 542b02d170f8..3af44591a106 100644
> --- a/fs/fs-writeback.c
> +++ b/fs/fs-writeback.c
> @@ -505,7 +505,7 @@ static void inode_switch_wbs(struct inode *inode, int new_wb_id)
>  	/* find and pin the new wb */
>  	rcu_read_lock();
>  	memcg_css = css_from_id(new_wb_id, &memory_cgrp_subsys);
> -	if (memcg_css)
> +	if (memcg_css && (memcg_css->flags & CSS_ONLINE))
>  		isw->new_wb = wb_get_create(bdi, memcg_css, GFP_ATOMIC);
>  	rcu_read_unlock();
>  	if (!isw->new_wb)
> @@ -579,9 +579,16 @@ void wbc_attach_and_unlock_inode(struct writeback_control *wbc,
>  	/*
>  	 * A dying wb indicates that the memcg-blkcg mapping has changed
>  	 * and a new wb is already serving the memcg.  Switch immediately.
> +	 * If memory cgroup is offline switch to closest online parent.
>  	 */
> -	if (unlikely(wb_dying(wbc->wb)))
> -		inode_switch_wbs(inode, wbc->wb_id);
> +	if (unlikely(wb_dying(wbc->wb))) {
> +		struct cgroup_subsys_state *memcg_css = wbc->wb->memcg_css;
> +
> +		while (!(memcg_css->flags & CSS_ONLINE))
> +			memcg_css = memcg_css->parent;
> +
> +		inode_switch_wbs(inode, memcg_css->id);
> +	}
>  }
>  EXPORT_SYMBOL_GPL(wbc_attach_and_unlock_inode);
>  
> 

Hi Konstantin,

Alibaba also hit this a few months back, but never got back to me about
the patch I sent them [1]. At least in v2, it gets a little hairy with
the no internal process constraint. You end up with IO being attributed
to cgroups you may not necessarily expect and how IO competes then I'm
not really sure. Below is what I sent them. This punts to root instead
which isn't necessarily better.

Thanks,
Dennis

[1] https://lore.kernel.org/linux-mm/1557389033-39649-1-git-send-email-zhangliguang@linux.alibaba.com/

----
commit 0908bd801cc1dac120fa3b213174670a1d6487ff
Author: Dennis Zhou <dennis@kernel.org>
Date:   Mon May 13 09:44:12 2019 -0700

    wb: fix trying to switch wbs on a dead memcg

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 36855c1f8daf..fb331ea2a626 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -577,7 +577,7 @@ void wbc_attach_and_unlock_inode(struct writeback_control *wbc,
 	 * A dying wb indicates that the memcg-blkcg mapping has changed
 	 * and a new wb is already serving the memcg.  Switch immediately.
 	 */
-	if (unlikely(wb_dying(wbc->wb)))
+	if (unlikely(wb_dying(wbc->wb)) && !css_is_dying(wbc->wb->memcg_css))
 		inode_switch_wbs(inode, wbc->wb_id);
 }
 
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 72e6d0c55cfa..685563ed9788 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -659,7 +659,7 @@ struct bdi_writeback *wb_get_create(struct backing_dev_info *bdi,
 
 	might_sleep_if(gfpflags_allow_blocking(gfp));
 
-	if (!memcg_css->parent)
+	if (!memcg_css->parent || css_is_dying(memcg_css))
 		return &bdi->wb;
 
 	do {

