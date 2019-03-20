Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6A547C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 21:01:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 28BDB218B0
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 21:01:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="JEjXZibp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 28BDB218B0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A8C4F6B0003; Wed, 20 Mar 2019 17:01:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A3C576B0006; Wed, 20 Mar 2019 17:01:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 954866B0007; Wed, 20 Mar 2019 17:01:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6D5FF6B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 17:01:19 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id y129so4956485ywd.1
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 14:01:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Ac3c8BuwXRGufN3K90gjwkHmlf5WusrlHW6NBm1q4lU=;
        b=uQpNnYX6UJixFRx/mjvKY11RaqkZmyLXIuRBIJbF86ctSflyjHsegF85nstvCXRMgW
         BOLOTTgxvKiZlQRoiljArl/QV8v4SYLPgO20vUoJOZFQ9OJ1mTf59CGy/rHzmzSEpRxl
         TlQhKki1K7ctQebXjXd3Ts1jJcbVnngq4tTAd07TC2naJVDx8Hq+JmximAXU2TiohJ6a
         kqEX5Q58ngwSg+CLHqPi8pgYnp7VMoQF8SnJ4aX+ARzxuRjzIsAw50fpBM59Qc2A7Fql
         BFuj/ylXlKriH7Pf2HTJTcKadkD/88v9omEFaQViewF9d16BMlROcG5X77N72fqgG/4X
         MVQQ==
X-Gm-Message-State: APjAAAXryXEl1NFbiEVErqm58BkwQlrBswaTLOUdfgr3vJqrTWPfNmyy
	G2GtHwnIGqOZbb3fwgAmTeCIfTS95EojlPFxEzJlGz96nUV/JGQr1FAoWrWeFbSTSjlQHwnMYTs
	tiDz4KlQEv5KNHAVXFX07XxKx3ZHLAcCpAG6g+sn11apiYOzAX9SYVMJZ9QVHN9uw2w==
X-Received: by 2002:a5b:603:: with SMTP id d3mr8759951ybq.299.1553115679238;
        Wed, 20 Mar 2019 14:01:19 -0700 (PDT)
X-Received: by 2002:a5b:603:: with SMTP id d3mr8759858ybq.299.1553115678229;
        Wed, 20 Mar 2019 14:01:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553115678; cv=none;
        d=google.com; s=arc-20160816;
        b=1FaZqz1WPhmDhHt53MM5J2qzm5TmHsKF93Z1c6ezrVG+IiaZZcEeZavOSjFxdC9LVI
         jRNh878m9pPGVGHGms6spXfKaewqBGqSujuZyUJDesv4Lwt16ODjO3RyoRjr80I4At7f
         wN036KggXY1GKXYmbHPzBtycLX3Vrf4xbrJmyv4M+Wpz/SG/JmBC04SOSuVkqH/yWKk9
         nGfuCoBB9w0SLCecgRsTmT90AUGsr0HDVOyWI6fgEqJ6yIwqNbsxN0kYCMSH94rk1hx7
         BipujrhW1WDitLgsD8cFIIb17vF6fLGSMJKD2QigkM6AkUrbZNq3Ow7SqQhL76MYGxu8
         04BQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Ac3c8BuwXRGufN3K90gjwkHmlf5WusrlHW6NBm1q4lU=;
        b=YyCn9ahzCotjsnhHrqf9pI1ZMB9NGpKmEQxiVIWuSl8iIUJzs6YsuTcqDzD6UPqpgO
         EzyH9O17yBqSO7bxQI27zuwY3duB3gV2IfJAZZ0/m4x1jJDkXcdH1CmCSVfCHLCvHOD5
         rELIOzaVIExY46DCNxZDZg3JIHWG/UCt912FNu5aTFAI15uJ42gLhYWyuMs5NXDo88gE
         k33dzGbq/OePzAUVNGT8Mj/OsmalpRctcZkmrGAwlcHer5C7UeuCJ6+ruK/PR517BJn4
         7L+cxvLb5qeLA6994kbf3iOoNmtDjWvxSfQjSAjVDzDjvzCFksRkWx1OMapFad8NuL7W
         v/FA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=JEjXZibp;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x1sor977475ywf.114.2019.03.20.14.01.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Mar 2019 14:01:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=JEjXZibp;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=Ac3c8BuwXRGufN3K90gjwkHmlf5WusrlHW6NBm1q4lU=;
        b=JEjXZibp3H4f5ucHf9/nYNdp/ytl0tGHWy0AKX8AmsOYBRlU8V7e7ASVsOt5LncbG1
         gCS3JBKOn47BLQ8g8YjIgv5iVaKorzkc91V8QDkcVsYe9/uFey0bvFZJ40zD0zOsl8II
         nHTxk66AWJwMWj4oEKBm1cbfvp6BYEg7JuMVewxzaYlEdBuWcOECG93P/lHKqFr/4AtI
         Ay0134rkQc9XtvkOKQ5mUy2sa9+TvRSVaXpfbxTCCpsuq4KZKEtKZF+CElW2vAYDxjNZ
         iH6/4zmve2aF6+bRlPsYN4X24H06xqEBtv9npU1i8LLPi3xQMpqTA2LPRN+hWfZwilZn
         FBVg==
X-Google-Smtp-Source: APXvYqwtzykOHbzXPKJJWcXH+CWrw+RxKVwf2qkPOM6F/W9FMVFsz+4hKQS1ImujNybU7Y3XRpcA9g==
X-Received: by 2002:a81:430a:: with SMTP id q10mr156204ywa.508.1553115677811;
        Wed, 20 Mar 2019 14:01:17 -0700 (PDT)
Received: from localhost ([2620:10d:c091:200::2:b52c])
        by smtp.gmail.com with ESMTPSA id 207sm1091449yws.38.2019.03.20.14.01.16
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 20 Mar 2019 14:01:17 -0700 (PDT)
Date: Wed, 20 Mar 2019 17:01:15 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Suren Baghdasaryan <surenb@google.com>
Cc: gregkh@linuxfoundation.org, tj@kernel.org, lizefan@huawei.com,
	axboe@kernel.dk, dennis@kernel.org, dennisszhou@gmail.com,
	mingo@redhat.com, peterz@infradead.org, akpm@linux-foundation.org,
	corbet@lwn.net, cgroups@vger.kernel.org, linux-mm@kvack.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@android.com
Subject: Re: [PATCH v6 5/7] psi: track changed states
Message-ID: <20190320210115.GD19382@cmpxchg.org>
References: <20190319235619.260832-1-surenb@google.com>
 <20190319235619.260832-6-surenb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190319235619.260832-6-surenb@google.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 19, 2019 at 04:56:17PM -0700, Suren Baghdasaryan wrote:
> Introduce changed_states parameter into collect_percpu_times to track
> the states changed since the last update.
> 
> Signed-off-by: Suren Baghdasaryan <surenb@google.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

This will be needed to detect whether polled states activated in the
monitor patch.

