Return-Path: <SRS0=bR/Z=QL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4D972C282C4
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 22:23:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 13CCE20823
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 22:23:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 13CCE20823
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9C6198E0060; Mon,  4 Feb 2019 17:23:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 950FA8E001C; Mon,  4 Feb 2019 17:23:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 818818E0060; Mon,  4 Feb 2019 17:23:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4F0FB8E001C
	for <linux-mm@kvack.org>; Mon,  4 Feb 2019 17:23:45 -0500 (EST)
Received: by mail-yw1-f71.google.com with SMTP id d73so1300980ywd.2
        for <linux-mm@kvack.org>; Mon, 04 Feb 2019 14:23:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=MPtEQEaye4UPLQvkJVscodsBwwpLOB6+axqeFQgy3uk=;
        b=qy+oViBJuqHZe97/YyJLcI8desLapdrYVMwfpqxUAU7nnLiUCUxxVRVo837D9NA9sH
         eRQ+HmoEJf0aNKzCeYOEK83eC8F6hTQ+rURHKz1VBu881gDcqgYmq0t5fcZnTNrOIaSX
         /lvVURcLBKIXXMLdCCTVgCV6MQTbD6Y3PNMFxaD5rfbB1yY2369KutSVyr8t+RDTKM1S
         xSIDfB4YFi0ZWXSyLRm3owSankP0E3P3l/Y/Iuc8anH260RYVYei/cXvwta91ci0kHH/
         eFPCseCHjH799mt0GKagBrxrxGv+LRIECh4PfukOmiL6TY9ce2hG23eXxb04x4DtF6Tb
         ilMg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mcgrof@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mcgrof@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuY2ah0XgOUK0xbi1cl/sYHxsZuPYT7WEWebDxFeAkcp/4v8X6up
	XDeTym1vUFsgMZXe+CymFqlyeXSzb1IfIOYtuNYC6zCdzCKEP3ljP3h5R5q4LEd3jHbVcFoDQd7
	MBihUAMyhgG+31+YlFTqmRQg8mKR6UJDJXW4KLfDRLaGUc7wFaGmaEhtz7tg54DInfl3c0EEzq7
	6l4Zy6YcSoDKeehwIjdQL9hGIS4bNdbPxjeHIERwTPm46EdoW+MfFvIWFP31zajJyvxCtYVceHW
	QXxPmOhzJlov4Rze/pmCVHo96zxZzQrgXSkgA3FfQ7gl7OR/CrDPYgM6XO7UctBnFCX5UHQC29V
	Z+4T8AQwgZgrqRV/g9ie37cEIUlUY038LxV4KGuACDc+e+tEHIDQtPaUjuGoEfdHXigPHp/Fpg=
	=
X-Received: by 2002:a0d:fcc6:: with SMTP id m189mr1495408ywf.71.1549319025030;
        Mon, 04 Feb 2019 14:23:45 -0800 (PST)
X-Received: by 2002:a0d:fcc6:: with SMTP id m189mr1495383ywf.71.1549319024427;
        Mon, 04 Feb 2019 14:23:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549319024; cv=none;
        d=google.com; s=arc-20160816;
        b=e7LAgmh1nitTjfYiBOXuA6IGyjUDpZoQML2ojF17xeq3u50PirYHxszop+f9Kxd23J
         Ef2q8tEaP8wjC4biNuh2M/ye3bi2qGnVsa2NYgIaacKfeAWW0Lg0BvxFIYIIBIklDuQa
         Rfdb4dPXj4cHa0i4+Mljsjxf0F/GeOSF8Q5zTJHATcKShmprvLW9p7SuV2UN5gZ0U1Rh
         jjoQjT4eTCy3q4OxOK2I+GxDwE/si8FvgnMmWwNFxC5EBrLTVJjoHuviW76AWvq4ClCH
         tp4P882+KPXmoF9AbuISbR1n1OAbp6cM71LWfrqf2AmKkS+J4JGMm0KtTVQtDi95JwuB
         MFWw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=MPtEQEaye4UPLQvkJVscodsBwwpLOB6+axqeFQgy3uk=;
        b=Tkhpzu07jzIPJwCgtPaQAv64SeFe9ji+RyzBYcdK5u0xj0HjBd5aJCgiT9ziYAddo5
         p6L0Cv3lQf1/kF6nrvmtnsJY8dSp6AZt2r/TriQFBxkrJiZ2Kz80agwwhPO4seCV6+Nu
         3VC83C+fIEsdQigjUYW2S9+OHQRH8rrU+J+ll8zFJVWrLpy1DdQykeKhvEnnLKf6SurY
         UbR/Gv7LqbyLUKE5AYYGtVxJlvTK49e07NJdmi+SO2k3Ft4TddgHuQk3W9rfrMicgJYx
         3HmzuNUW6zkfSmBcnK8BZw2V7X/v9QzkFlbharHXz7x54xu1zHtVvM2MBg4YRpfxLdrP
         0WaQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mcgrof@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mcgrof@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c190sor769303ybh.172.2019.02.04.14.23.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 04 Feb 2019 14:23:44 -0800 (PST)
Received-SPF: pass (google.com: domain of mcgrof@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mcgrof@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mcgrof@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: AHgI3IZvbVjxe1YNvbJI/uLMgftVnyjldcE0uVtw8PV8F1aOnZMvA/gPe8aAsYTjB9SXv6YlAPr1JQ==
X-Received: by 2002:a25:9b01:: with SMTP id y1mr1459452ybn.260.1549319024021;
        Mon, 04 Feb 2019 14:23:44 -0800 (PST)
Received: from garbanzo.do-not-panic.com (c-73-71-40-85.hsd1.ca.comcast.net. [73.71.40.85])
        by smtp.gmail.com with ESMTPSA id l3sm1800963ywb.39.2019.02.04.14.23.40
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 04 Feb 2019 14:23:42 -0800 (PST)
Received: by garbanzo.do-not-panic.com (sSMTP sendmail emulation); Mon, 04 Feb 2019 14:23:39 -0800
Date: Mon, 4 Feb 2019 14:23:39 -0800
From: Luis Chamberlain <mcgrof@kernel.org>
To: Waiman Long <longman@redhat.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
	Jonathan Corbet <corbet@lwn.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org, linux-doc@vger.kernel.org,
	Kees Cook <keescook@chromium.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Jan Kara <jack@suse.cz>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Ingo Molnar <mingo@kernel.org>,
	Miklos Szeredi <mszeredi@redhat.com>,
	Matthew Wilcox <willy@infradead.org>,
	Larry Woodman <lwoodman@redhat.com>,
	James Bottomley <James.Bottomley@HansenPartnership.com>,
	"Wangkai (Kevin C)" <wangkai86@huawei.com>,
	Michal Hocko <mhocko@kernel.org>
Subject: Re: [RESEND PATCH v4 3/3] fs/dcache: Track & report number of
 negative dentries
Message-ID: <20190204222339.GQ11489@garbanzo.do-not-panic.com>
References: <1548874358-6189-1-git-send-email-longman@redhat.com>
 <1548874358-6189-4-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1548874358-6189-4-git-send-email-longman@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Small nit below.

On Wed, Jan 30, 2019 at 01:52:38PM -0500, Waiman Long wrote:
> diff --git a/Documentation/sysctl/fs.txt b/Documentation/sysctl/fs.txt
>  
> +nr_negative shows the number of unused dentries that are also
> +negative dentries which do not mapped to actual files.

                     which are not mapped to actual files

Is that what you meant?

  Luis

