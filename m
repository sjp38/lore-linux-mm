Return-Path: <SRS0=sWz3=SD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59134C10F05
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 18:20:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 14A692133D
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 18:20:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="yYWfiYjk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 14A692133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9A88F6B0006; Mon,  1 Apr 2019 14:20:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 958716B0008; Mon,  1 Apr 2019 14:20:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 846B16B000A; Mon,  1 Apr 2019 14:20:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 615A76B0006
	for <linux-mm@kvack.org>; Mon,  1 Apr 2019 14:20:50 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id 204so5469475ybf.5
        for <linux-mm@kvack.org>; Mon, 01 Apr 2019 11:20:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=xawSNcb89Uo6X8oCMqaGeyypJgFbGg80AqgpmSx6PNw=;
        b=ppVtqLRRoYbqSuh/jKMs9NpaN8ZzftaKcb801o+X56wY0lS+C3nDaXXjcvZn2EzSbN
         UKHLNpL8t4ZHw8LfON7KdZipgwNWF2z2NJD3LxnI+w5/nkgkI0EpFGXU7ODmYuqulkSR
         mepot05LypB8y9WLDippX4tHiofeyEWmmemKpGly2sxdqKIXlMeOAXTxwIQCvUKLygZw
         vUnEZUy1kCjVJcqSxKhvxYcQe8iDesdgzB1O0TypbSNwFR7aewZTL5ZIYZnxrWI/9PZ+
         DVk9SvWrIg5URmZ0FSGdCosnvAx1PuHCtOmDbwcP3jN4H4u0IqeC7Lz7t1V4F7xtT7LB
         /l0w==
X-Gm-Message-State: APjAAAUrkY1cG9jkc+x7ka13yO8ZB72E4870BnCeaeri95vUo++5NQDW
	q0PIss4WgKR5kZrT1+T6NKkGr2CYJJXAHuh/K9Cvp5uDJMA/cUuwOUyDSXo5mRrQ8SEvxeF4Kya
	XxFIBO4No5U0qEerOYsUReyVHlzrNfy2QbbiVk0M6gnaGZbdhIRVu1MOjw49R7KPSBA==
X-Received: by 2002:a25:5d02:: with SMTP id r2mr37944919ybb.258.1554142850059;
        Mon, 01 Apr 2019 11:20:50 -0700 (PDT)
X-Received: by 2002:a25:5d02:: with SMTP id r2mr37944875ybb.258.1554142849404;
        Mon, 01 Apr 2019 11:20:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554142849; cv=none;
        d=google.com; s=arc-20160816;
        b=OOMxxrI+SfkJYF6g8CAuV3FzNIDDg0a+nNbHWc0VAorabwPuLf09B7zEOP1Za9evog
         IaPWvQOjSYIgvNodWD1V2H5Szw7a2nXtv3qhC3YiPGQdLkc1XgzYFpws3WfTOizW/UNB
         jxVcVZbFL2RGNU9u/ftQsbUskSPXy3tvr7oxK/LhSSgkL7/8k0lD+XnTXuBl3MThHkpr
         rwMLo3eoC+dAH9fy1O4xg6njzzdTsTrcU3vQEGukFHRwG/xX0f/Fnd0PSu6yYvfU7RSl
         g5kNpwa79W43uvfV3aV+VF+mAfRwF8al2N0udZma0PN7YxNSSB+rHL1aISimTxWEJwtR
         4VFw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=xawSNcb89Uo6X8oCMqaGeyypJgFbGg80AqgpmSx6PNw=;
        b=hdovKRslKcE8uYe8pzh4GywVuYMQuH5E5bhvcjjpfZuOQe/hzaiIOKoGOSdAUKtX89
         TPje21oDse6Z+6GIK1V0bCGh25jfaTJfMG9yrdfG+Pd6lZSeWAn0Vp6pvPOS0osXd35p
         wYVIv+U6AlGwAQeJkuM3TOvPRMH14kwlvbpEi3ae9ctEJ4LVOjv4xDm1kcv3f/CAi5aq
         2iw+npIzRA4u0Bbhxy3jPDN5mz4NOzsHXFfuMDu3UxcKFl7kbslbmOsY8svjMS8GWJYX
         tDmVl9QCAZxXK9AG8CA+H6qJaFvgoJ+odxyoXv/ZG1E0Xjx8V9pQwzdGfDi2qIQslaIG
         Z6ow==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=yYWfiYjk;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z65sor1148297yba.179.2019.04.01.11.20.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 01 Apr 2019 11:20:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=yYWfiYjk;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=xawSNcb89Uo6X8oCMqaGeyypJgFbGg80AqgpmSx6PNw=;
        b=yYWfiYjksvzCycCvVISWrOF1si2tzoUTbtYRIO3Q25hQ3L8PVGgWzkv+A3Ik4Y7NNH
         V0oGUi2/jMXGFY7kaU1DmwQxMkpGlw6Dg1lwsBlmL/4u0/6HyOe2S/NddX8hbhEQn8RB
         QYOLiBL2R+6jrYtYEwQLS5JPOa0nq8qW/nrez2scZlWrPP1oQqeEG9db5heWgMskCn1q
         EGrTHOE4zVQgN+HJ3TjT4Q+Rz85tSAXJuWLGteK0d1Iq0HJw1I+c4z3r9cg6u5Lb8pMt
         +Gy1OIxomtJFU0V/FTUvs3StyivwFtk/wBRkg82gxhTwhzwnbYqHH6wzrjRAZ4bXV5tb
         YHQQ==
X-Google-Smtp-Source: APXvYqxl+K7Jjs97IcKCD8eAX5F/SrbeGuLebrgoG7sE8UJcNFGJoN4oL+ZPoJmgFfzdICWPWphMRw==
X-Received: by 2002:a25:99c3:: with SMTP id q3mr54775170ybo.263.1554142846659;
        Mon, 01 Apr 2019 11:20:46 -0700 (PDT)
Received: from localhost ([2620:10d:c091:200::2:8ed4])
        by smtp.gmail.com with ESMTPSA id d9sm7226304ywd.23.2019.04.01.11.20.45
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 01 Apr 2019 11:20:45 -0700 (PDT)
Date: Mon, 1 Apr 2019 14:20:44 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>,
	Michal Hocko <mhocko@kernel.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Tejun Heo <tj@kernel.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org
Subject: Re: [PATCH v2] writeback: use exact memcg dirty counts
Message-ID: <20190401182044.GA3694@cmpxchg.org>
References: <20190329174609.164344-1-gthelen@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190329174609.164344-1-gthelen@google.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 29, 2019 at 10:46:09AM -0700, Greg Thelen wrote:
> @@ -3907,10 +3923,10 @@ void mem_cgroup_wb_stats(struct bdi_writeback *wb, unsigned long *pfilepages,
>  	struct mem_cgroup *memcg = mem_cgroup_from_css(wb->memcg_css);
>  	struct mem_cgroup *parent;
>  
> -	*pdirty = memcg_page_state(memcg, NR_FILE_DIRTY);
> +	*pdirty = memcg_exact_page_state(memcg, NR_FILE_DIRTY);
>  
>  	/* this should eventually include NR_UNSTABLE_NFS */
> -	*pwriteback = memcg_page_state(memcg, NR_WRITEBACK);
> +	*pwriteback = memcg_exact_page_state(memcg, NR_WRITEBACK);
>  	*pfilepages = mem_cgroup_nr_lru_pages(memcg, (1 << LRU_INACTIVE_FILE) |
>  						     (1 << LRU_ACTIVE_FILE));

Andrew,

just a head-up: -mm has that LRU stat cleanup series queued ("mm:
memcontrol: clean up the LRU counts tracking") that changes the
mem_cgroup_nr_lru_pages() call here to two memcg_page_state().

I'm assuming Greg's fix here will get merged before the cleanup. When
it gets picked up, it'll conflict with "mm: memcontrol: push down
mem_cgroup_nr_lru_pages()".

"mm: memcontrol: push down mem_cgroup_nr_lru_pages()" will need to be
changed to use memcg_exact_page_state() calls instead of the plain
memcg_page_state() for *pfilepages.

Thanks

