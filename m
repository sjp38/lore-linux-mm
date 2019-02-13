Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1D6F6C282CA
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 11:33:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BF4C82073D
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 11:33:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="I72evs5D"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BF4C82073D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 579B38E0003; Wed, 13 Feb 2019 06:33:21 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 52BDB8E0001; Wed, 13 Feb 2019 06:33:21 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 43F048E0003; Wed, 13 Feb 2019 06:33:21 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1E1EE8E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 06:33:21 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id m196so3624816itc.4
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 03:33:21 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=gdIwE2aBy/rd4nMZfHWmtIjw8GVWglWwxpfhXIWlMCc=;
        b=qB4UYMVXgQN/uTtTi5fFEBRb7pRiSC+ddYJce/XLEHsI4DKbkvBNM2SjMNBjWIZK2c
         S8Zg+MOAbkFdncg3/0pWPzzTN1UzgTbUzPA+lFG4aVMoBM1fEPh3msnyp+8kd6OIkcaq
         EnyX/90IdECAs2ekzGEAg4rS1NJTnFbjR0qHQEVRG8ZKqisMCyO7PiKciW1Xrqe1OAzG
         w9eq8f9VeZA20SsXWHTQS5lfkHJvDH9IlgO4L2FNIgd9GfbQdJ+c1bkFuBQRlWMeKfVr
         hmiKGiN6hZ+zjBJ/7r+XWpzuaad2QheIYE96owMPaBn6NyUePQ5tw2s3nvid/AaLcXwc
         zSzw==
X-Gm-Message-State: AHQUAubLd129aGPfuuykf7/bmalEr1OUVCA1xAIA4t2X8RtzKITaDllI
	w7vIzLh+fWYwV9+Knjw/6jiE49jcARXsG3oxivBhU9Dljn1HyS7DRoLqIrXRSDgBlIU+04CWoE/
	1rcV5KoLlqotj7ttRnWqDz7TkquP0WV+C+Tj6uRLFvzNWaBVTHVTUZDMnSm8FlPcjcZ8n7FdKgD
	bF1zG3BkOyLnn9TZkIhXetPKsJxCXZ8vs4wxzPusqIE9ZkYpjRJ3gV729QnFFdSB8xxEeBaD0OZ
	iGUsM3Idw2eVbI4u79/P6qT5x55j7EmSf5XjXV8F0YbkvtTL4R7lHrtFGmTFARzrx/DzC4H+8ls
	DV7zHpUqxnGgDA77KJlLEElVDwKda+PPWoaPZfIv0X3rLTlIofVQrcBhrt1Hcdy/wEvFP2g/xg=
	=
X-Received: by 2002:a6b:7402:: with SMTP id s2mr4364018iog.219.1550057600435;
        Wed, 13 Feb 2019 03:33:20 -0800 (PST)
X-Received: by 2002:a6b:7402:: with SMTP id s2mr4363991iog.219.1550057599771;
        Wed, 13 Feb 2019 03:33:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550057599; cv=none;
        d=google.com; s=arc-20160816;
        b=OEZj9z6mKQGVl9hSRhAiyOoEhaa4LEAkmyfkxzFD/yLYxfEfkILfOcmkZzEE87XM+o
         N3wzYs2fSkiYXxvmjxQ7u/9p5LLe7YmUTiVZl6ARPmNQabIPp79DdjSACqKGnA6mTJkR
         Dz2krlrqkj50UfpQK9zQ26RrFQImzWZqXPUw7/Td/RoWzpDyp4I+oes4LBQmjP9VAdD/
         vfasJCa3CEn48rw0YKaNEla2df9kjwEKBP+OvSKMN2KHgnUNlK+4FECEEl9pCLki57YC
         nzMKWGb5/qJQKMUjbu4rQVdH87BNW4KLBbPsHMyWDaYLnzwT0ADC9+YKfZBPhW8ADrWD
         0/7Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=gdIwE2aBy/rd4nMZfHWmtIjw8GVWglWwxpfhXIWlMCc=;
        b=Rpt7GP4t/zfvuW/+R17o4EYZvSo83LRSpJoE23nNWUf9ikBYEEYzm5XOA8pc8XXinp
         2bk2RFqe2wVaawpXSKr9inNn2PE3Bomsiqktg4mmeVqhHy47fMODlffCjtXV0g/lE557
         +c6XbkUPQgOLuHvEfNHSQOcxqt+LmkHPf5AAEYfhIsHwHr4Sr/JcQbRIlaNYuJ8KWJpq
         7OSsUphhiRnjI196aadNDY1/1sWErdPfjizxW8widZBixuml0B3M5N2sjBq9pnuoR4ZU
         qouSx4O5vVEkhywNXgvHDl30TaojSs/Srb0bCE5xxQKBUMSHgcpMO9Tw6u96Gq//6J2N
         Jbzw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=I72evs5D;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f2sor9525193iol.87.2019.02.13.03.33.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Feb 2019 03:33:19 -0800 (PST)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=I72evs5D;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=gdIwE2aBy/rd4nMZfHWmtIjw8GVWglWwxpfhXIWlMCc=;
        b=I72evs5DmhA/IkqhBTn3SfCPZeRF44Zs9eI4QXeKRbAp/XMivxySnEY+AVra3YHelk
         4aAAZIjJyYBdCd80BK058Cv/TU/cPa1eTldyk5WNgwjTspp9YPoR4t+2DY2fqgLZ2mIS
         bR0baOHsM/las67jgmo7vKyr/i6wCBw0aLCiMznGEhiMT7z/tGSTrSRdlFddmJxXdJnt
         dFcMwgAgBBO8WvLUxB0yS/0hgHjvqKIqqM86qz6+3hNtqyctHXxlLZBkdP179a4naxga
         mDzumdjxp3lFWYKeN02zMYjabvPf09NDfLscjQFWWAfjF3FsncUH94oroQYLOR/++Fto
         ZOmg==
X-Google-Smtp-Source: AHgI3IZLa6ZrZ3frPClxSclZ9XAR+2Ge7zfdXLzhOnpOJ2ueM396dqtnJMqSnq3bNGfHt/TMWjkdhg==
X-Received: by 2002:a6b:b4cf:: with SMTP id d198mr17658iof.96.1550057599322;
        Wed, 13 Feb 2019 03:33:19 -0800 (PST)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id y184sm3268683ity.27.2019.02.13.03.33.14
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 13 Feb 2019 03:33:17 -0800 (PST)
Date: Wed, 13 Feb 2019 20:33:12 +0900
From: Minchan Kim <minchan@kernel.org>
To: gregkh@linuxfoundation.org
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Michal Hocko <mhocko@suse.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Hugh Dickins <hughd@google.com>, Liu Bo <bo.liu@linux.alibaba.com>,
	stable@vger.kernel.org, Martin Liu <liumartin@google.com>
Subject: Re: [PATCH] mm: Fix the pgtable leak
Message-ID: <20190213113312.GA34988@google.com>
References: <20190213112900.33963-1-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190213112900.33963-1-minchan@kernel.org>
User-Agent: Mutt/1.10.1+60 (6df12dc1) (2018-08-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 13, 2019 at 08:29:00PM +0900, Minchan Kim wrote:
> [1] was backported to v4.9 stable tree but it introduces pgtable
> memory leak because with fault retrial, preallocated pagetable
> could be leaked in second iteration.
> To fix the problem, this patch backport [2].
> 
> [1] 5cf3e5ff95876, mm, memcg: fix reclaim deadlock with writeback
> [2] b0b9b3df27d10, mm: stop leaking PageTables
> 
> Fixes: 5cf3e5ff95876 ("mm, memcg: fix reclaim deadlock with writeback")
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Liu Bo <bo.liu@linux.alibaba.com>
> Cc: <stable@vger.kernel.org> [4.9]
> Signed-off-by: Minchan Kim <minchan@kernel.org>
Reported-by: Martin Liu <liumartin@google.com>

