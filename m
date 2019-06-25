Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1BCD7C48BD4
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 09:35:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CD0DF2084B
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 09:35:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="u8A/ZyMM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CD0DF2084B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5D8D36B0003; Tue, 25 Jun 2019 05:35:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5B16C8E0003; Tue, 25 Jun 2019 05:35:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4A1B08E0002; Tue, 25 Jun 2019 05:35:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id ECF036B0003
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 05:35:45 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id i9so24761270edr.13
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 02:35:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=xajd/k2gt2AWyDnLyY/AO4TDQLUBuztihD5Mc8Zw4LY=;
        b=STt9F9o6k4DZEwC07FvMaABuUcvoLszY7LG5NESVKRqjpVtG4UROGYcvBHhh0DwikL
         nV20VKx8VSKFNmerzy+ng3LVfTkoLylK9YuMU08wmEERKfB6VWZifezwkIpf8yErZYya
         WBLH9kDroHHD894qUSTPW2T5Tp66s/TyamzKyZb1lg0ZhDiiI8PzG1nipOx1IKcsfglN
         BpAZX5tMRZ81S64Oi3QYi2qRz4AiF/WomBWpAqp2Y8B9GtdOHH1Kb+U4l8kqfUs/ioy8
         fDnI3K8uPtmLVkkuL/MILQaHTvA3J3Mq25ixPNgieN/9WgI7ThAWpBcXJHVhzsX5urKU
         ShWw==
X-Gm-Message-State: APjAAAUHlDWRmXJy+SZi220jSLWOx1Y1vhsXGetUm6VSmeTTeFzCNT/z
	ipgtsZ8XiUOV/xDOeqWNvaVY8pwaJ4s5n1vDwbKUJ7hWPqZEKP1QCh5VURDJfMGRKa3LtaWLrMu
	BAR7ZU+5K8Ycc8LNT3JsorF2AEgF2qv7JyFb/MK3azmBtrUWcwUP3H8iNNKb1cLJ4eA==
X-Received: by 2002:a17:906:1e89:: with SMTP id e9mr23857918ejj.56.1561455345460;
        Tue, 25 Jun 2019 02:35:45 -0700 (PDT)
X-Received: by 2002:a17:906:1e89:: with SMTP id e9mr23857854ejj.56.1561455344582;
        Tue, 25 Jun 2019 02:35:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561455344; cv=none;
        d=google.com; s=arc-20160816;
        b=JBeKOkKCDp0tZQMbTzCjMlLq5HtzztSyxoz8Y7pUCgsbTI1bWHMAMqvvdckXVeOLRX
         u9zOnpTrWGQmELpYbY/jCgEfjU6BKNQgIgPpzJfowBy/Yx1X0G/qojqKhL+t9T63TJeL
         2690EF5ChYXQWCvRv6ShYn7IlQGZnHXOFFy6K4u29BOjGn1aJlc59tQCTVB5maMvy4K5
         48YMjZOMYFmJcrt4ZDeBQCi5jQVIMOZ5QuOB1LI1Z04/mtaLDRUA5ZbvfGdbF1oVhg7u
         DttVCv2dqG5SOXOacGjpHCnvhna4LNU6fJyh/FDV5owEo4OqeMtHw3WjUyxljRxRVK2a
         I34A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=xajd/k2gt2AWyDnLyY/AO4TDQLUBuztihD5Mc8Zw4LY=;
        b=YiHUmhwHgKlTnIZkKshEpkFDe7+TUJVnpbBs+W6lxHuvjr1JA0NMAKLiamUG2/FOp3
         hBHvBWOqXkx4sdh/yIbThn6M1iM5j/xS8mJ7aj2zhMI4R43D/Bk2RBq1xPcR1kHcLRE2
         5JmWSW2dtTITVSfAipbN0YWnsJiErEiTDQdXdaPg+gs6ygpIsctshGGFBkukTq97LJTB
         R8J/Is1qnhKyk5tJlNw1hmy1+laGkhVzbOs9neH8uVy3W8zsJu1uD9nv4No1LS8L2Jr8
         VD9izpS+XwQ6UsonBoCLy3X5xPcgELpAw2Rd3vGeUrwUsyWq2760JzEUbhcUTWX4hVeO
         kq1g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b="u8A/ZyMM";
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h8sor11928823edi.27.2019.06.25.02.35.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 25 Jun 2019 02:35:44 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b="u8A/ZyMM";
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=xajd/k2gt2AWyDnLyY/AO4TDQLUBuztihD5Mc8Zw4LY=;
        b=u8A/ZyMMg+ASFoP0CxSfIGHRwcuoSefnAvR87vTdQuoOH/kgLRyJqZ+7uOFMi0bgiJ
         dk+qC4xcH2rhooiooNXuxohrqhNjez+fVF3JRNmo5xmYY3dtviF5xQblarGj5TLHLd2K
         nf75P+qC62KhHGqjrkgPxsMyv3RQ5MQ4R2pONk2R9UcF7UP8jzAV3n+V/6Of3jktoLd7
         bkefb78CSiMB65hWzWRpeWlNJ+zaLomo73yTZIo6td5zN8UjGVMkIhvkgqnOuBR5sH2N
         Yo3YMJPwBhwuu6V/bUf5a+DK/jZRVyudE5em8pXaz92JXIfp15cuuv7fRvQdpvOttuAU
         hkeg==
X-Google-Smtp-Source: APXvYqy9NLic55lASyMIY85+B+lQ1OjCWknehk/dmFVfpM4MYN73JlWt87c6/wD1FtJpl/gjOy5Bcg==
X-Received: by 2002:a50:8dcb:: with SMTP id s11mr106881027edh.144.1561455344282;
        Tue, 25 Jun 2019 02:35:44 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id a3sm4467108edr.48.2019.06.25.02.35.43
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 02:35:43 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 601D61043B7; Tue, 25 Jun 2019 12:35:43 +0300 (+03)
Date: Tue, 25 Jun 2019 12:35:43 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: ktkhai@virtuozzo.com, kirill.shutemov@linux.intel.com,
	hannes@cmpxchg.org, mhocko@suse.com, hughd@google.com,
	shakeelb@google.com, rientjes@google.com, akpm@linux-foundation.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [v3 PATCH 2/4] mm: move mem_cgroup_uncharge out of
 __page_cache_release()
Message-ID: <20190625093543.qsl5l5hyjv6shvve@box>
References: <1560376609-113689-1-git-send-email-yang.shi@linux.alibaba.com>
 <1560376609-113689-3-git-send-email-yang.shi@linux.alibaba.com>
 <20190613113943.ahmqpezemdbwgyax@box>
 <2909ce59-86ba-ea0b-479f-756020fb32af@linux.alibaba.com>
 <df469474-9b1c-6052-6aaa-be4558f7bd86@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <df469474-9b1c-6052-6aaa-be4558f7bd86@linux.alibaba.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 24, 2019 at 09:54:05AM -0700, Yang Shi wrote:
> 
> 
> On 6/13/19 10:13 AM, Yang Shi wrote:
> > 
> > 
> > On 6/13/19 4:39 AM, Kirill A. Shutemov wrote:
> > > On Thu, Jun 13, 2019 at 05:56:47AM +0800, Yang Shi wrote:
> > > > The later patch would make THP deferred split shrinker memcg aware, but
> > > > it needs page->mem_cgroup information in THP destructor, which
> > > > is called
> > > > after mem_cgroup_uncharge() now.
> > > > 
> > > > So, move mem_cgroup_uncharge() from __page_cache_release() to compound
> > > > page destructor, which is called by both THP and other compound pages
> > > > except HugeTLB.  And call it in __put_single_page() for single order
> > > > page.
> > > 
> > > If I read the patch correctly, it will change behaviour for pages with
> > > NULL_COMPOUND_DTOR. Have you considered it? Are you sure it will not
> > > break
> > > anything?
> > 
> 
> Hi Kirill,
> 
> Did this solve your concern? Any more comments on this series?

Everyting looks good now. You can use my

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

for the series.

-- 
 Kirill A. Shutemov

