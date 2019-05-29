Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 07E13C28CC0
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 17:01:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C0C2823E94
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 17:01:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="fS3Hs1Yr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C0C2823E94
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 537CB6B000E; Wed, 29 May 2019 13:01:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4E8016B0266; Wed, 29 May 2019 13:01:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3FF1C6B026A; Wed, 29 May 2019 13:01:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0B3266B000E
	for <linux-mm@kvack.org>; Wed, 29 May 2019 13:01:50 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id r25so302268pgv.17
        for <linux-mm@kvack.org>; Wed, 29 May 2019 10:01:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=ATiPYb6QVWJfqMIRxjJk9r0kehuG42lflrhOEdSkzdU=;
        b=sd8dfOKSnPrccQz6ecxkLjgBgmsdhhxaemaXcwx1Zt45P32rgIgnPhF6YO5QVmkTFv
         9wqtB6AHB+ZV941ROGYJ0adD5O+V3Zi4l1lgdHXz/K0wVqtLOj8PWsS//dTmx53uKl1r
         Od5sQstqt0+k2KfYTJgOFoKukviaiUF5I07bVCzQCAE+eQZW5pTFAGRsTCtn7YcGhQ7c
         Nl6XdlRmUxsVr9nrZOSqHwE3b/QlsCF6i4nJyM2DDyFVJrnyNVQKhNE0j/GayvSX1XJp
         TzmBa0JIdWDBQlHu50QtffWN3lQ6+GeEP0DlLRbLCAHL5+aD/K+6zVjcLi415nbk7SFG
         gypQ==
X-Gm-Message-State: APjAAAWHaFU+T9rKi/exB9S7/5099AidXZkT3NTg0th/pB7btv1bsZUO
	rPn/WDvFxriJTB5DJT/4KZArFcmUzd1IVFfAtMuQ6ts2Sd+1eRmTtD6LlTXTYmOnmTbbGmeq20N
	jIZP3oUvIVMmEztIeG+QGICf6nXU8ZOL5bnTthSaLyQPA9OKYlmezuv+ydot7YFd0tg==
X-Received: by 2002:a17:902:324:: with SMTP id 33mr143461163pld.284.1559149309623;
        Wed, 29 May 2019 10:01:49 -0700 (PDT)
X-Received: by 2002:a17:902:324:: with SMTP id 33mr143461065pld.284.1559149308680;
        Wed, 29 May 2019 10:01:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559149308; cv=none;
        d=google.com; s=arc-20160816;
        b=dXFmsfXM7qNzvdjOTECaLJ+8V8dCLBxrifORoAQICOFsbC71tK/3eHMko087K2Ug9z
         WK7KaTeQ0GfT7F5PLf4e3301lHhFq8JGscAdFFNtlByCskdoorB8spzrOd6YBQu51keo
         trN0sbjcu3b7WxHzJ7Ini6/zSoF8jxGM5nLvyff2VsEypfyzRypEScjakVwlmVD7qIIp
         y5Z4UYY4SkJQHdOXGvalPLTOit8pGQcwRozENzqsaHCJHPYBtCXfpqn/i1HkdRKzXMt8
         KgkdtH/slrGu2lXM9dBECRAR7V6OwU80tSHd3NK0Jz2tKcw1TKeyM8QUMtQo0Q49sXPB
         3CVA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=ATiPYb6QVWJfqMIRxjJk9r0kehuG42lflrhOEdSkzdU=;
        b=LACuDUGfHREGHBnNWMzU/OEuKta3s3SlfNpMnxdlcZtONfYe/vXcrTM4p1kUZ+vdEs
         gEVOcKSUp70VKz2AyoleZG16BiLwDjfVUxl1k9igXnLk7gmljNHWdXpEdX4zAgPx/v/P
         VkmQ80dIYqEUo6bWr8Na3rIR9/N3M5dsIrfi2fsa5fScReiP+sdgAQK5g9kJRTYElLm0
         CJpZXU9gzTIeqSu0z2l4Jk6VatPtqExcQ4xQMT4uwtK/5ASfX1MFofMlxE62/W1m4xyV
         d6GGV4GPA3nTRGzEaS+chfzK/KgllrXtEmBw46rl723dJNpqHXhCxLp15FJMdTlpWMbz
         mweA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=fS3Hs1Yr;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q20sor123459pfh.71.2019.05.29.10.01.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 May 2019 10:01:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=fS3Hs1Yr;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=ATiPYb6QVWJfqMIRxjJk9r0kehuG42lflrhOEdSkzdU=;
        b=fS3Hs1YrlmBlz66o8yW5j5lJGSOwB0f40hHewi73HAkx1JkP8DwsKVJD3oke6zsRzo
         x3fMWyGXird0w3TURVE6SpXs1vh+EXvXFX+S2l39bwxgPWpsnuiqtHTXSHy/76uj084s
         0Dv6zXlongF8W7DXnu5evVUrGLh4ybGOUGEz1bbh3XR1KW5896ZcsiDuBO47TbnlwDyG
         3vZoshv5HWBgvFFtKtUnr43MrUzIo47WoFFv+5Ji8d6NnEpjJYObsEu4TW2G3At+06Ib
         /WObBpQZR6BBmjPUDVJl4px+X23Sm4HF5D6Y4zYzIlmBVrbHAollpowPIcoI60LS1xBu
         7N7w==
X-Google-Smtp-Source: APXvYqyjE5P+va9ALwJlSxEieGnZMQxMLtmWGpxHFSU9l2LuRvYdbs8NYV7CWHPt1o3YB8YBJN2GYQ==
X-Received: by 2002:a17:90a:be0b:: with SMTP id a11mr13482926pjs.88.1559149306648;
        Wed, 29 May 2019 10:01:46 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::1:a47c])
        by smtp.gmail.com with ESMTPSA id l38sm103167pje.12.2019.05.29.10.01.45
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 29 May 2019 10:01:45 -0700 (PDT)
Date: Wed, 29 May 2019 13:01:44 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hillf Danton <hdanton@sina.com>,
	Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org,
	Minchan Kim <minchan@kernel.org>,
	Yang Shi <yang.shi@linux.alibaba.com>
Subject: Re: [PATCH] mm: vmscan: Add warn on inadvertently reclaiming mapped
 page
Message-ID: <20190529170144.GA30884@cmpxchg.org>
References: <20190526062353.14684-1-hdanton@sina.com>
 <20190528212257.f795b405ac1b88d72bb3fa2f@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190528212257.f795b405ac1b88d72bb3fa2f@linux-foundation.org>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 28, 2019 at 09:22:57PM -0700, Andrew Morton wrote:
> On Sun, 26 May 2019 14:23:53 +0800 Hillf Danton <hdanton@sina.com> wrote:
> 
> > In the function isolate_lru_pages(), we check scan_control::may_unmap and set
> > isolation mode accordingly in order to not isolate from the lru list any page
> > that does not match the isolation mode. For example, we should skip all sill
> > mapped pages if isolation mode is set to be ISOLATE_UNMAPPED.
> > 
> > So complain, while scanning the isolated pages, about the very unlikely event
> > that we hit a mapped page that we should never have isolated. Note no change
> > is added in the current scanning behavior without VM debug configured.
> 
> The patch is inoffensive enough, but one wonders what inspired it.  Do
> you have reason to believe that this will trigger?

I don't think this patch makes sense.

There isn't anything preventing someone from mapping the page between
the LRU isolation and shrink_page_list(). The isolation filter is only
an optimization to reduce unnecessary LRU churn, not a guarantee.

