Return-Path: <SRS0=oLae=WX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8BD48C3A5A6
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 08:32:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4FE592053B
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 08:32:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="nN9GaP2q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4FE592053B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C51686B0005; Tue, 27 Aug 2019 04:32:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C01576B0006; Tue, 27 Aug 2019 04:32:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AEF016B0007; Tue, 27 Aug 2019 04:32:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0040.hostedemail.com [216.40.44.40])
	by kanga.kvack.org (Postfix) with ESMTP id 8B1D16B0005
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 04:32:16 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 43FAD6418
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 08:32:16 +0000 (UTC)
X-FDA: 75867540672.07.mind54_6b12a9a3c5a55
X-HE-Tag: mind54_6b12a9a3c5a55
X-Filterd-Recvd-Size: 4974
Received: from mail-ed1-f66.google.com (mail-ed1-f66.google.com [209.85.208.66])
	by imf37.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 08:32:15 +0000 (UTC)
Received: by mail-ed1-f66.google.com with SMTP id g8so30258801edm.6
        for <linux-mm@kvack.org>; Tue, 27 Aug 2019 01:32:15 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=mn5KDVhwwChGG6/LPdXL9ASx19vYGpyQz4cnp0ZsO64=;
        b=nN9GaP2qDNZuPmqS08OSMU8Huq4aCRmmZzhT8DnxntN2vffDdHKBjdGhJzXFYocIl8
         6xVlrvQc4enclmZw83Vw1fcat6UOLNMQKAvGhvneyZ5ra6oZOv0Wh0jfirxdN8gT0ZWn
         /r/nUCayxZSNmEMi7S0LIVVdMNXXRZitVMUVXLAEuU8JeqBKGaqKCNgMVTWHyXk+aC4K
         uxDyJeFSFoId3Irrcu7auJg4oxQ415pQVawtyC065Ahb/w2P0CxpMuIyB0Zm18Lc+Qio
         F6gJIICJ5WW0rT67I4N9eIt6kowvkiI3G65jmnTsGEF+FJF+HNMC3BTXA8IUb/bN7Tri
         FWVg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=mn5KDVhwwChGG6/LPdXL9ASx19vYGpyQz4cnp0ZsO64=;
        b=Q8eMlt5vtv3WZMHPCw29byo9e/PocMzMvGZ9gkTvwTZGp+NEOexyxtu1Lsa79svVyb
         4JZ622/IMwAeCmO34yxt87CKYsShSifiQySiUtPVu8o5flxHMtq8BMQ52CTjSRM2c652
         8ivtsE7aIfKGPLvbJbElEWaG2ZMeeF/sk1Itgd7p/1LhDDk06cv49/oHL7FjaLRk4wRb
         VTjjVr04hKcT5JXB4e6SMEk2Gz1DTLxbVTrSC/u4OFHalOzknuZf6bxv48Otu39RypWG
         kYPeKXzESUJJtoqDN1X6ydZrv3yBtxdvBX19oJ70cbMH2RL8ddmRW2kg2r7XXC4ZHDm8
         iSRA==
X-Gm-Message-State: APjAAAX4ptOP5+faO/gx3v99KKL7Xp8oT8VDlzUyV5L1H7YBskRWfzPT
	+tWNndAP8CEoPutf2O6b7MSCCQ==
X-Google-Smtp-Source: APXvYqy1k2rGciB3gixbkGCGnzVsxkvoKZD9KqaqMcXAredlFXWTowmF9iBpZRxgetzzOudrTBTarQ==
X-Received: by 2002:a17:906:5391:: with SMTP id g17mr20529475ejo.61.1566894734382;
        Tue, 27 Aug 2019 01:32:14 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id q10sm3413891ejt.54.2019.08.27.01.32.13
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Aug 2019 01:32:13 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id C1EEA100746; Tue, 27 Aug 2019 11:32:15 +0300 (+03)
Date: Tue, 27 Aug 2019 11:32:15 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Michal Hocko <mhocko@kernel.org>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, kirill.shutemov@linux.intel.com,
	hannes@cmpxchg.org, vbabka@suse.cz, rientjes@google.com,
	akpm@linux-foundation.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [v2 PATCH -mm] mm: account deferred split THPs into MemAvailable
Message-ID: <20190827083215.lrgaonueazq7etl5@box>
References: <1566410125-66011-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190822080434.GF12785@dhcp22.suse.cz>
 <9e4ba38e-0670-7292-ab3a-38af391598ec@linux.alibaba.com>
 <20190826074350.GE7538@dhcp22.suse.cz>
 <416daa85-44d4-1ef9-cc4c-6b91a8354c79@linux.alibaba.com>
 <20190827055941.GL7538@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190827055941.GL7538@dhcp22.suse.cz>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 27, 2019 at 07:59:41AM +0200, Michal Hocko wrote:
> > > > > IIUC deferred splitting is mostly a workaround for nasty locking issues
> > > > > during splitting, right? This is not really an optimization to cache
> > > > > THPs for reuse or something like that. What is the reason this is not
> > > > > done from a worker context? At least THPs which would be freed
> > > > > completely sound like a good candidate for kworker tear down, no?
> > > > Yes, deferred split THP was introduced to avoid locking issues according to
> > > > the document. Memcg awareness would help to trigger the shrinker more often.
> > > > 
> > > > I think it could be done in a worker context, but when to trigger to worker
> > > > is a subtle problem.
> > > Why? What is the problem to trigger it after unmap of a batch worth of
> > > THPs?
> > 
> > This leads to another question, how many THPs are "a batch of worth"?
> 
> Some arbitrary reasonable number. Few dozens of THPs waiting for split
> are no big deal. Going into GB as you pointed out above is definitely a
> problem.

This will not work if these GBs worth of THPs are pinned (like with
RDMA).

We can kick the deferred split each N calls of deferred_split_huge_page()
if more than M pages queued or something.

Do we want to kick it again after some time if split from deferred queue
has failed?

The check if the page is splittable is not exactly free, so everyting has
trade offs.

-- 
 Kirill A. Shutemov

