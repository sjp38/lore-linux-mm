Return-Path: <SRS0=pZwQ=TG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 68002C04A6B
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 19:20:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2E85C206BF
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 19:20:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2E85C206BF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BF9546B0274; Mon,  6 May 2019 15:19:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BA89E6B0275; Mon,  6 May 2019 15:19:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A97C06B0276; Mon,  6 May 2019 15:19:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 57F996B0274
	for <linux-mm@kvack.org>; Mon,  6 May 2019 15:19:59 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id h2so11819591edi.13
        for <linux-mm@kvack.org>; Mon, 06 May 2019 12:19:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=MpYNzL8IUSLwhMssCMQBk2ybAbswnWhmXY2mWxXqE9w=;
        b=I46yAn9gzQl5svFmbJS2EdxhLVeTlZPv2/rjUASXezH30kYHuWz24VyEVwOHmYHX9C
         DXyDcGe6v2MWHVTAKVKNEbwhIMT/9FGnWuQTma5IdFWmNd6ECWr8RFnCzPDuc/c8DwLH
         fJLHgFSGzd1vjbCCEfjLjpZC7hMsoBJTDTqAra+NQq33IQnbF7sn0Ng2sZ6YZ9PqFMu2
         IXYDoHFJqxyi10uq5iJwnZjzTLxzy16fu/4vP/u+QcoowzOY5TStjtsuc/hG+eLGKhRt
         3XaEV1oMMxI+ihLwT8tUnTuZ82aVdTK9dKD6uNfO9lBWDTvcbgrhGvFQ/gFkqlXVmq5T
         N8Jg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Gm-Message-State: APjAAAUKEFlYWctK14Ql9rarmawbK2xvXWREUazwEsGiARkgm+T7IOuc
	aM9u9j8Osjs4Nc2FIPO6QxV+Ft8OnUDiXYwFCBr95QlabFlgUR3eUu0RyA3ZOBRk4DWFl4cM3mA
	aax/L0/6fbfduADhAJuCeE+J6jowZeZPt3sf+YgWuZKWDAXU/dFTWyb01Hd4QOWmMfQ==
X-Received: by 2002:a50:8a46:: with SMTP id i64mr27598680edi.177.1557170398923;
        Mon, 06 May 2019 12:19:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzcvAZT3TPoxflwd+KqreeDDGxqGtF1yYXMR66/at/tArmQp5RK2jdpZut78uxTIZV1JZpX
X-Received: by 2002:a50:8a46:: with SMTP id i64mr27598624edi.177.1557170398074;
        Mon, 06 May 2019 12:19:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557170398; cv=none;
        d=google.com; s=arc-20160816;
        b=uKyWC7KDMqmgfvkTsPqNwnxmS2DDGy3mLjKqhrGo9cx/rUOO8HknQnkVh17Cxl0uY+
         hS0kd4AhuHgMWkAQQTpNa2B6Bx6TU7uI2migWa33uz6G2TbPYhS7JoZm7SuEVAzCsf9h
         SgdohzjbedBg1o2PVKkBahAyVdf1sexPGUjb+J40EuBnz+99yzoXUgUkgMVXK2YH+AV6
         qH47F0SiHSXviLwM0EI8O8m2LyIPN51OcFv63mFWdIflhSx9c//T88L3J8uQIH6klWbX
         7IIKmjlUKqUDAIlfroSKPCuBKj3GRaU9+xEBn4G6XScBIHGSGeM/geDHz/i/E3MxrxxQ
         Jy0A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=MpYNzL8IUSLwhMssCMQBk2ybAbswnWhmXY2mWxXqE9w=;
        b=fA2id6HIKU7+A7UKk8Q8LCz8JBBgdVw24SPZYiih7TjUs8yEhrDEXHwCRg8/LQYJyn
         jmis4sDRkAUtQQqpOWOY6a1vbyDuQi8UwNz/uiDoo7T8aJqDAYoMavoWimOUHGpZWBr8
         ETcwvmIhMmXdu9qEU6nS/LLVHwfx+uyS0fqn1Hdbk3bC1M2DTbjTkoP9Tnlg89aauN0w
         SuhMCB/hKdSa3J04cuGUtbq9afnb8glEBEv0ICGJPu9NHHmoQZGzcoKNaxMOHCz8RuqN
         nkKL8C7dOjnzm9saUGsKYKz/adcSI5ey98UHMDj/2zNFOVjrLDSbLK4IYWLfYvUqaIJE
         0Qhg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z10si692236edc.287.2019.05.06.12.19.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 May 2019 12:19:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 9C915AEA0;
	Mon,  6 May 2019 19:19:57 +0000 (UTC)
Date: Mon, 6 May 2019 21:19:56 +0200
From: Michal Hocko <mhocko@suse.com>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linux MM <linux-mm@kvack.org>, shaoyafang@didiglobal.com
Subject: Re: [PATCH] mm/memcontrol: avoid unnecessary PageTransHuge() when
 counting compound page
Message-ID: <20190506191956.GF31017@dhcp22.suse.cz>
References: <1557038457-25924-1-git-send-email-laoar.shao@gmail.com>
 <20190506135954.GB31017@dhcp22.suse.cz>
 <CALOAHbAM26MTZ075OThmLtv+q_cCs_DDGVWW_GpycxWEDTydCA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALOAHbAM26MTZ075OThmLtv+q_cCs_DDGVWW_GpycxWEDTydCA@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 06-05-19 23:22:11, Yafang Shao wrote:
> On Mon, May 6, 2019 at 9:59 PM Michal Hocko <mhocko@suse.com> wrote:
> >
> > On Sun 05-05-19 14:40:57, Yafang Shao wrote:
> > > If CONFIG_TRANSPARENT_HUGEPAGE is not set, hpage_nr_pages() is always 1;
> > > if CONFIG_TRANSPARENT_HUGEPAGE is set, hpage_nr_pages() will
> > > call PageTransHuge() to judge whether the page is compound page or not.
> > > So we can use the result of hpage_nr_pages() to avoid uneccessary
> > > PageTransHuge().
> >
> > The changelog doesn't describe motivation. Does this result in a better
> > code/performance?
> >
> 
> It is a better code, I think.
> Regarding the performance, I don't think it is easy to measure.

I am not convinced the patch is worth it. The code aesthetic is a matter
of taste. On the other hand, the change will be an additional step in
the git history so git blame take an additional step to get to the
original commit which is a bit annoying. Also every change, even a
trivially looking one, can cause surprising side effects. These are all
arguments make a change to the code.

So unless the resulting code is really much more cleaner, easier to read
or maintain, or it is a part of a larger series that makes further steps
easier,then I would prefer not touching the code.
-- 
Michal Hocko
SUSE Labs

