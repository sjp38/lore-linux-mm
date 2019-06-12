Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EDC5DC31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 10:30:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B68E3207E0
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 10:30:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="zIQhadd+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B68E3207E0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EF5E76B0006; Wed, 12 Jun 2019 06:11:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E7FD36B0007; Wed, 12 Jun 2019 06:11:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D47C76B0008; Wed, 12 Jun 2019 06:11:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 810D26B0006
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 06:11:05 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id b12so17848350eds.14
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 03:11:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=yBJOOYa+63AgBYj8hVQxRRZyU5YRkS/ufWkxMFtkQpw=;
        b=CIm+sDPQ0MgUpVBR1NBk3+vgmp2m9UkUrGtV2U4k/sZC/mQgmvTVejyl48Snmt7f2N
         dzKSjB0HoJVjtVMdo/qvkynPDqLrlXhWlzDYdZoNeAwKw+AFlMApJ8q/7ltit9cJYza9
         IwHF8oOG0EW9ql+T4BdX2Zj8ipyh7+Q+CPQG4TYIOpQ07bkM/QgKfUsYoCnobYKfRKt6
         SZabuKmjCQVx5yEcXeI2Fx9UwMSixMXR/N4fuKVp0dez5hTAW3gKwn+nv9y0REIE1DFP
         jaZ9S3GIWM5ltqdXBiSP77yBdcpgj4G87cbof2iwA5mKZBlMX0NtPTPfR63lHEAIWnCr
         +i2g==
X-Gm-Message-State: APjAAAVxc9+OJ1rC5Z/j5s52g8aFUWrizu74m+3Yt9sVOJyV21JU954h
	uziH6nuj34qOnZfSGnSbd4rMo6zhkQ0jUvbroWrFMwrGGqkUSI6wOWXtZwj9Eebvc4xX/VDszjD
	HtVvzsx5Hv1HmreE0WjmphqLCohWdQrqtNZgi0AYnMhdkjy2ZX3inhs36pdiHfAQoPw==
X-Received: by 2002:a50:bc15:: with SMTP id j21mr85284083edh.163.1560334265070;
        Wed, 12 Jun 2019 03:11:05 -0700 (PDT)
X-Received: by 2002:a50:bc15:: with SMTP id j21mr85283997edh.163.1560334264348;
        Wed, 12 Jun 2019 03:11:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560334264; cv=none;
        d=google.com; s=arc-20160816;
        b=B71AoQdV3XB/+mpotFXgog/0JcqA6hGjxeqopHSNPvSfII5g3i7xlrfeJsDGSxY0vo
         b/MWB0AUk1/mbUywU5HXtwtUx2fBsj9JiGkHBYFR1ryyIvfDjIjnw8nZlWzqAlq3uoRH
         ZoiDJcU3AWClPhMoM2OeYexmB1DKIJras14+c7nKiGNtlQiUqNacMy0WCK6BlCP9D+CH
         85VQIoJJYNRoAVtlK76yziw+yboBljWeH3hEbGptC7qmuHlCkRCSHo7GaxQjAIE4Ri11
         xVkB2lm7cwg48RVRZEQwJFE1Nc3i+N1KIG3zFatPf2C+EPuIyeA8PC+4TVTkFfNQTZH3
         0GnQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=yBJOOYa+63AgBYj8hVQxRRZyU5YRkS/ufWkxMFtkQpw=;
        b=hFFAF19MsZw/jbLvs45+GXIXiH8KXhLb4kMxJwPPfDlD2PDU87J32HN/Buf9rQ4+SQ
         9pAvFbj66KbfRJY65+BzsT0q23EsRqomnieo/vBchptmQrmBnO0dmYFwV5H0EkbSxyiq
         rl25rq2FIS6e+uPZwDljwPwvnkmxn8mBgG+1s+Nsdhb++XvXtipUz+hexzPoXyX1t/Yk
         eiQBTx4xRnJtN4JBsG7KW8PO8ZTXmLnYTEGH1ilwqY7Z6cKBtmEMnKdcCLdLRhtxsDb/
         HUmYWdvWPBv0WAX2TCHf3EvJThq8yPF6oFOqUH8JQ1W0SMXkwHjTuTh4J774jCRn33BS
         wOig==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=zIQhadd+;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q4sor13175374edh.10.2019.06.12.03.11.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Jun 2019 03:11:04 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=zIQhadd+;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=yBJOOYa+63AgBYj8hVQxRRZyU5YRkS/ufWkxMFtkQpw=;
        b=zIQhadd+m2T9tT/6mG1ziuNw3VMUalNu4Kz48WIlrtDQYzMP38mSSA9Jbqssq+cETX
         wj/ORIpO4Bj9LqPBqsJ5kAJ7SuygwJvhr4eGeF6cridQOyXQ1ETvJIT8hOAa6qbtkCfj
         XYkIDwzKSQbv+2LsM54cilOSMN0r9OIRCZy4N8EndEomyOavMVP/NXZ5/zYqZtME1xnW
         PuifSMFFGEujEnWkoe2tAlEvda/LQc8tVUFQ1LGnWYwUnRAaghvGuhr8xi5DhMkIlOhU
         TGeZz76wqc4IKqwqewFUwuYP6rd9OErqQ+4/OI8x6xWu8zJfmcT8HrjtRen9Z3EyE7u0
         J0EQ==
X-Google-Smtp-Source: APXvYqzRmP8bkDzJtJb53QwuVwjTPB6C7X3I5M9sEgDKVw9ul38KEs25tZVf2ubiErLjeWv2/fbQ1w==
X-Received: by 2002:a50:95ae:: with SMTP id w43mr57909279eda.115.1560334264050;
        Wed, 12 Jun 2019 03:11:04 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id j3sm4419416edh.82.2019.06.12.03.11.03
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 03:11:03 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 4FD7F102306; Wed, 12 Jun 2019 13:11:04 +0300 (+03)
Date: Wed, 12 Jun 2019 13:11:04 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: ktkhai@virtuozzo.com, kirill.shutemov@linux.intel.com,
	hannes@cmpxchg.org, mhocko@suse.com, hughd@google.com,
	shakeelb@google.com, rientjes@google.com, akpm@linux-foundation.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 4/4] mm: shrinker: make shrinker not depend on memcg kmem
Message-ID: <20190612101104.7rmjzmfy5owhqcif@box>
References: <1559887659-23121-1-git-send-email-yang.shi@linux.alibaba.com>
 <1559887659-23121-5-git-send-email-yang.shi@linux.alibaba.com>
 <20190612025257.7fv55qmx6p45hz7o@box>
 <a8f6f119-fd72-9a93-de99-fc7bea6404c0@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a8f6f119-fd72-9a93-de99-fc7bea6404c0@linux.alibaba.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 11, 2019 at 10:07:54PM -0700, Yang Shi wrote:
> 
> 
> On 6/11/19 7:52 PM, Kirill A. Shutemov wrote:
> > On Fri, Jun 07, 2019 at 02:07:39PM +0800, Yang Shi wrote:
> > > Currently shrinker is just allocated and can work when memcg kmem is
> > > enabled.  But, THP deferred split shrinker is not slab shrinker, it
> > > doesn't make too much sense to have such shrinker depend on memcg kmem.
> > > It should be able to reclaim THP even though memcg kmem is disabled.
> > > 
> > > Introduce a new shrinker flag, SHRINKER_NONSLAB, for non-slab shrinker,
> > > i.e. THP deferred split shrinker.  When memcg kmem is disabled, just
> > > such shrinkers can be called in shrinking memcg slab.
> > Looks like it breaks bisectability. It has to be done before makeing
> > shrinker memcg-aware, hasn't it?
> 
> No, it doesn't break bisectability. But, THP shrinker just can be called
> with kmem charge enabled without this patch.

So, if kmem is disabled, it will not be called, right? Then it is
regression in my opinion. This patch has to go in before 2/4.

-- 
 Kirill A. Shutemov

