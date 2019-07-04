Return-Path: <SRS0=d6aY=VB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 757A5C06513
	for <linux-mm@archiver.kernel.org>; Thu,  4 Jul 2019 11:04:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2B9DE205C9
	for <linux-mm@archiver.kernel.org>; Thu,  4 Jul 2019 11:04:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2B9DE205C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 945B06B0003; Thu,  4 Jul 2019 07:04:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8F5B18E0003; Thu,  4 Jul 2019 07:04:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7C08B8E0001; Thu,  4 Jul 2019 07:04:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2F2AF6B0003
	for <linux-mm@kvack.org>; Thu,  4 Jul 2019 07:04:29 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id n49so3621178edd.15
        for <linux-mm@kvack.org>; Thu, 04 Jul 2019 04:04:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=F/9BY1Ps5YjmtLN6X76yUk67wuG4Kc2bLYgzjgFPRYI=;
        b=Wx8s04CWO7VeU1mkF4CGxuO9+EwnoPne0Djtlr/jurlOmw46mO4b/Vjcl6euhRQQnr
         FwpOI7zH0PcQeZmy4/saY1XcW/KqKwy/yExwVrn9nMBd3lBc9UJlBh9Gb/06MtT2+RrR
         sTgE4bUYf9+m3RfGoPQCBgPZjcnlccivsGaLO4HAGYKtqfAmC8IZfxIF3Hz+8Qn0QJoX
         oUXkzNLX3Q5wF/42M/UCPV54WWAMkg761OOymQ/UquX8J2hfiDrorshjZj+QiUV3vMYf
         rmSKLvuuIxP5tiwD0p1hXwCrwxASsGpIzlCHbyNFw42Xctmya6Iaguko1hJPJmGk3H5r
         qUQQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUsbyNn495fbtII+DzZ17AFxQYctdKpoYok7Lmbfr+YQdbfvyXv
	nQ99dW9Fg0vnFjmMMyGpP4suU2Di/svXWS2HjuBLLqdkZCiUR6B+NWvnJPQ7/cJmzexm/mYc7EH
	sg6043yHGJP89qb5aag/+buum+iyb7gPBQ7EAJBLWGBjD+Vv+wsSTehSyEh7eC4Q=
X-Received: by 2002:a17:906:e087:: with SMTP id gh7mr39737375ejb.22.1562238268696;
        Thu, 04 Jul 2019 04:04:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzKHBhPJOYILr6umZCyCube9aHqT6OMtmsse0tmpl6JKKWguQtZh9NYB7TpFUzwGI25T5mx
X-Received: by 2002:a17:906:e087:: with SMTP id gh7mr39737256ejb.22.1562238267404;
        Thu, 04 Jul 2019 04:04:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562238267; cv=none;
        d=google.com; s=arc-20160816;
        b=G0V9wUiqGJJmaUfL0ZLDtGWhW895+15pGQohcjAeSi7LAQNLdD7lzpWmYkLgjHhLaI
         gp75+tsl36RVzgJFUp+jaNi6aN8LcYRBQqKMFAFjZyYQ+qRRtfR3lchuaOUxVZaKdPp/
         WQ3k+z7naPje2omSAXQbIy3Y8tZSQVI5z09GMUK7xEtGk3AhYWSgyBofimVJx7CwI+/c
         1Wa+TOJXg6JHzgUSIjexS1oDQXAgLUEzgo5vNuaW8YZqtxCzojNyebxrPByUBnPfcnex
         aCQ563BSjMV811Nmrtp02+oz33bcE82duyOnlJUfAykUGH1w01vGpabd+nIT2pF4oSdr
         5BOw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=F/9BY1Ps5YjmtLN6X76yUk67wuG4Kc2bLYgzjgFPRYI=;
        b=yZUyYaPUTCQKfSofrhmxF6MaGb8RYEXct2gWVXqsKCxMvMCCFbuv9XyNLQ3GabbIlX
         VgRlSBfuM5CEBxYw4wW7EXt/uS2ZSk7qabtM5+DpkHrLUBzTcKYn6NTd1QmcqRd4ANx3
         DupuMNOeYnaVpOPcD8yYvfB/ydW9uqE+HZ4Lc2duqfoSQIDa0Dtw9DykXk833QgX5Y2S
         72jlCoXbiFURIMKzcpq1J2VaWMHHP1Ua3tRZIvRw0dqUByOTkzIVqDJqT8OXK7GeFKUa
         zRNe9D4tfzWNMpYpi9mLnNocQzel9swUKrADBmzEZo9OfQQakhyMhSMVpHFbaqj+aE3c
         fokA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s41si4219853edd.252.2019.07.04.04.04.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Jul 2019 04:04:27 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 7483FAEAF;
	Thu,  4 Jul 2019 11:04:26 +0000 (UTC)
Date: Thu, 4 Jul 2019 13:04:25 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Kuo-Hsin Yang <vovoy@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Minchan Kim <minchan@kernel.org>, Sonny Rao <sonnyrao@chromium.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	stable@vger.kernel.org
Subject: Re: [PATCH] mm: vmscan: scan anonymous pages on file refaults
Message-ID: <20190704110425.GD5620@dhcp22.suse.cz>
References: <20190628111627.GA107040@google.com>
 <20190701081038.GA83398@google.com>
 <20190703143057.GQ978@dhcp22.suse.cz>
 <20190704094716.GA245276@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190704094716.GA245276@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 04-07-19 17:47:16, Kuo-Hsin Yang wrote:
> On Wed, Jul 03, 2019 at 04:30:57PM +0200, Michal Hocko wrote:
> > 
> > How does the reclaim behave with workloads with file backed data set
> > not fitting into the memory? Aren't we going to to swap a lot -
> > something that the heuristic is protecting from?
> > 
> 
> In common case, most of the pages in a large file backed data set are
> non-executable. When there are a lot of non-executable file pages,
> usually more file pages are scanned because of the recent_scanned /
> recent_rotated ratio.
> 
> I modified the test program to set the accessed sizes of the executable
> and non-executable file pages respectively. The test program runs on 2GB
> RAM VM with kernel 5.2.0-rc7 and this patch, allocates 2000 MB anonymous
> memory, then accesses 100 MB executable file pages and 2100 MB
> non-executable file pages for 10 times. The test also prints the file
> and anonymous page sizes in kB from /proc/meminfo. There are not too
> many swaps in this test case. I got similar test result without this
> patch.

Could you record swap out stats please? Also what happens if you have
multiple readers?

Thanks!
-- 
Michal Hocko
SUSE Labs

