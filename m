Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 19ED6C04E87
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 16:50:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D37CB214DA
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 16:50:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="Askw2Dy/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D37CB214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6E7D46B0006; Mon, 20 May 2019 12:50:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 698596B0008; Mon, 20 May 2019 12:50:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 586FC6B000A; Mon, 20 May 2019 12:50:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1E9156B0006
	for <linux-mm@kvack.org>; Mon, 20 May 2019 12:50:18 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id y1so9473385plr.13
        for <linux-mm@kvack.org>; Mon, 20 May 2019 09:50:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=K2nbzJiUbqitAe/vmw6KZ2Et+OZPFA/JK7MysTmH6vQ=;
        b=qy7pdFlDaUeTOJfCShODWZDcu36PaO69+qi9S4B27aWGHL+G298o7eV9+lm6aVbUqK
         8lYejHr0ycaS1BSSX7k1JGWvd7wi9EH5VQ3OcUJWBXjBpq0KheDKHdjM4a1GD+IbuFLb
         JpFZ7ZY4wKGkuRewXKCK9tkHQsShMtCk9cKsEIk82P8dZnyeHZVe4W91rtkZ3V9QqZMe
         +jBUAmXjhle4mei8c2qVLY7lvRUwzET6g4++PHyJRyJ2lkr8ZzUP077T24M4o4MGcsJ8
         AFRLWF3PTPlc6QvA9nIpeO20MFLWpi2KWYuATdVpANafsSoOqTprmKOIzI4iFv7ush75
         DzWQ==
X-Gm-Message-State: APjAAAXvC6jYUjuPkj8l4pkj9AuRKeAV7EbRoxSJnROnNLtSAEoL+I4O
	mgosLvBzYyYbT3anDYw/lJeVRAdAruSfNNPZEJo524EVgVdOnQYBlGznO/VE/ccyJQdgPQAEjPE
	KhbkGv8pQwIAVQPAZ5ujPXOSPqy7AssLSCUufUuvBeAC17Eqh/gYoFqn4y6QufRcsJA==
X-Received: by 2002:a63:f54c:: with SMTP id e12mr76756211pgk.62.1558371017544;
        Mon, 20 May 2019 09:50:17 -0700 (PDT)
X-Received: by 2002:a63:f54c:: with SMTP id e12mr76756160pgk.62.1558371016852;
        Mon, 20 May 2019 09:50:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558371016; cv=none;
        d=google.com; s=arc-20160816;
        b=QAO9nML1tn3TxXQb0Gdbhm9swfHXII5E/lbq1xLIUbtVPCWVm5Mk6izH/pxq9X/Kix
         aV67SOyPrh6Ur+20u7lLe93m+pBGfkNkwpcl01nIJCfuFIKpo5bnphkg5DCmQhZ4xW3E
         WMrxy2raaI9yllXm6Fr1uTQCP4RM/o4f+JRMJtM6QkPP8CUp4Rxaw1nkltM54nuDjXSx
         14Qyv8AIIMkMC6ugNEMRcLckcMjIyoYukSLiaOat531mzgUxiJOoNK/0dqHf7egD7tyq
         cG8ObfRn3gCkyfAqq2mqeyjgTFVfTGFnH34rcE5X5/tNqaZOM79NLiGTg6yzRTFYaQIC
         Umrg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=K2nbzJiUbqitAe/vmw6KZ2Et+OZPFA/JK7MysTmH6vQ=;
        b=x6MUOah9tK1idFmWbXhoWu+ACR/A1QGQZmgLQthodWQPrlWB0c9EkaJgGJlsXrJjVn
         Eo9ZFjUndCkKk66ZIlcfIYWT5Vph4iGeJrhj8vt7z0fekYj1Uiz16/q13yCTM4pSBSNH
         jVRP8PIVF8bcixoe3/Y/i2gSAsqyzLv3WKdNMb7DDN18FusPVR/hWYE3H1hTqo+FmyPa
         cMHYHldBXMmO2jSu/UQz/yG/kAkX6kVJpNJ1G33A2v1S4QXORChpZGCHrmpNIcKv74Ws
         GMPoZJM2COgW0Zw+anoddvqllDvRsZH2ugfV/Qq7KsBew2kSEgMqwD3GRK4UjWkgTHFd
         0LzQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b="Askw2Dy/";
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c12sor19867837plo.34.2019.05.20.09.50.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 20 May 2019 09:50:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b="Askw2Dy/";
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=K2nbzJiUbqitAe/vmw6KZ2Et+OZPFA/JK7MysTmH6vQ=;
        b=Askw2Dy/VRvGu3WZOwFDDolHJLJQt0vmzbsQp+Cjadu48CZiIfEEWpPzeAsy+nTPKB
         dxNDUb0wvk/qMauQPlQYiE42IIUFK/X03vC1FsrQq+WsvryUhA6Ck09WMQ4YcNObgZLa
         AboM37uBqIjpZkwpxIiSLmjQvtILHebnGIiVjR/T4vvoLW/fpf+DMRHo3PyAls280rCk
         diEfGB4rl1Wux2CUZgkLXXhjDcTUA77lH2bA7yJWzP/gcd5z1uBjzRvqxd1E6oNgkDQJ
         V6ZZfwHikUzlUzCd7k8rNRRas8HAsxHgcf30hCZn3tuGUTWvKoIYNfP3MJ9NtSHZ7cx+
         QnYA==
X-Google-Smtp-Source: APXvYqyAP5erzaLtIGoxn8EHRf6PIwFDu2SBNbb4v+K+AAUyEPJ5bcPtDafLb6k1FMVQiJbhcbpi6A==
X-Received: by 2002:a17:902:ba8d:: with SMTP id k13mr63146469pls.52.1558371016198;
        Mon, 20 May 2019 09:50:16 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::3:df5f])
        by smtp.gmail.com with ESMTPSA id 19sm21507630pfz.84.2019.05.20.09.50.14
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 20 May 2019 09:50:15 -0700 (PDT)
Date: Mon, 20 May 2019 12:50:13 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Michal Hocko <mhocko@suse.com>, Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>
Subject: Re: [RFC 2/7] mm: change PAGEREF_RECLAIM_CLEAN with PAGE_REFRECLAIM
Message-ID: <20190520165013.GB11665@cmpxchg.org>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190520035254.57579-3-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190520035254.57579-3-minchan@kernel.org>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 20, 2019 at 12:52:49PM +0900, Minchan Kim wrote:
> The local variable references in shrink_page_list is PAGEREF_RECLAIM_CLEAN
> as default. It is for preventing to reclaim dirty pages when CMA try to
> migrate pages. Strictly speaking, we don't need it because CMA didn't allow
> to write out by .may_writepage = 0 in reclaim_clean_pages_from_list.
>
> Moreover, it has a problem to prevent anonymous pages's swap out even
> though force_reclaim = true in shrink_page_list on upcoming patch.
> So this patch makes references's default value to PAGEREF_RECLAIM and
> rename force_reclaim with skip_reference_check to make it more clear.
> 
> This is a preparatory work for next patch.
> 
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Looks good to me, just one nit below.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

> ---
>  mm/vmscan.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index d9c3e873eca6..a28e5d17b495 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1102,7 +1102,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  				      struct scan_control *sc,
>  				      enum ttu_flags ttu_flags,
>  				      struct reclaim_stat *stat,
> -				      bool force_reclaim)
> +				      bool skip_reference_check)

"ignore_references" would be better IMO

