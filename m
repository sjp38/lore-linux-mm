Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 08D2BC76191
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 13:17:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A7CAF2086C
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 13:17:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A7CAF2086C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5596E6B0006; Mon, 15 Jul 2019 09:17:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 50A3B6B0007; Mon, 15 Jul 2019 09:17:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3F9646B0008; Mon, 15 Jul 2019 09:17:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 05E1B6B0006
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 09:17:37 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id m23so13586882edr.7
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 06:17:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=wQfUksnx/a5DGMCKTjZFd/leuZwE4dxH+KwTxbEOG70=;
        b=MdZzF8tcRdt+KYekVSvhesVAbguuTDns5UU93qnzDw/0sX7j51iWT5A3B5vciUFb61
         ruyPSjT7FaBXgiow4QLMN9RLvlmV2kz7FjgO4ZrT0eRleSb1pmi76fie/MiGCipQgx5C
         6cTOtWVXuUPrsKWnkKoncVBYKX4gslNcqousmP8+jdw71VYG8qQH6peQDNYsBKgbNMnA
         JcJxksNepQZWw6ZloWjcU9PpofFeM+l+doD99ievh71RnZYvJXmsxDYRK8zonzUU4z+G
         eJC2a1ebGBJ2jgVzTd+m9j/t7Ub1zqIoZvPbNsBu4abDvwyTd9p5KGGKb4NlWPYckSt0
         FmEQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAX+qlv8zVGkY/U+cGY1mIRjrEhXlvakjmzLyKMqJwUm3JdV48e/
	QDaYl+6ZI/I+Y+Xz9bbQ6/UkhfCx08L+3eLbjky1XJ9AVRDegO6g5iiX8b8yusKd1eg2qDJb7NG
	oZiyVcLignnbbVAvGTTZSokOKHNbDiRUGnLGk76wkkCYoydpqcknlj8bQxYhpp5M=
X-Received: by 2002:a50:aeee:: with SMTP id f43mr23408218edd.221.1563196656535;
        Mon, 15 Jul 2019 06:17:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz47gMJzuGnppptQIWaylDFjaSxRfP6jdNChclkBVwlLVFicP0ihCUaev16jYBVo5tswdi/
X-Received: by 2002:a50:aeee:: with SMTP id f43mr23408145edd.221.1563196655892;
        Mon, 15 Jul 2019 06:17:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563196655; cv=none;
        d=google.com; s=arc-20160816;
        b=N83WUy6mRQQSwSu0uUfgCLCeMU11iVBPUcF5PYqtWkeis/2gCr5npnCC0Y9eowGZ1I
         diXfWY3mbsTC++SrkmAt7iqIJXuAQZD9woR6xq6rhJ1FVK62gZ7vTHWq60hx5mZSaSa6
         ernX1Ek0zhgF+XQ470cqmPkTTukM6jKKA+iP2fQf4ECzs7DVsP1pfwTSKNYmzHW6Tlyk
         XbbtYaYB7AUi/h6MPkEHwq/m9AvZRcla78odfnC0qDUIgwXjSZjw7Va+nU2/31X3Rwa+
         aP3YmO1x9yIZ5aXOOHA9l4BiyNcBUG9YLJyNmNfUciafxFaGhxwQuuC5gjVVFRiazwcr
         CKQA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=wQfUksnx/a5DGMCKTjZFd/leuZwE4dxH+KwTxbEOG70=;
        b=mUZv+c14i18bN91rurwq9rXClPzlzAG9G9zXkwj00F0j9iYL9vLCeN2OywEiO9+u1J
         69OCHSN+E0HPNCeWZdxKqPuatiFtL9Ejo5Q9A+SIXIwHFUF8y244sPEz1VEVBFP2TIOm
         8UgGDbuqStVb8wm/ak0lDd7cKuHXNn6Cx9a/mtZAOTOFXFDFPl+PGKJbNXeluu3rJboE
         DSZs1orq0kO0wJVV9dcSNnepaxR5P99+eXuOds0I9JVtsZRRr1NsdW/bOLuGo4XCpNme
         rx/UzrgAv5LxsW0eBMMAITUdg7JKtx3cR8E4z4PYKvftKaoQsuP5oLCo2hHMOZVzQ2gg
         m46g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r11si8704560eju.317.2019.07.15.06.17.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jul 2019 06:17:35 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 0CA51AF7E;
	Mon, 15 Jul 2019 13:17:34 +0000 (UTC)
Date: Mon, 15 Jul 2019 15:17:32 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: dvyukov@google.com, catalin.marinas@arm.com, akpm@linux-foundation.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm: page_alloc: document kmemleak's non-blockable
 __GFP_NOFAIL case
Message-ID: <20190715131732.GX29483@dhcp22.suse.cz>
References: <1562964544-59519-1-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1562964544-59519-1-git-send-email-yang.shi@linux.alibaba.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat 13-07-19 04:49:04, Yang Shi wrote:
> When running ltp's oom test with kmemleak enabled, the below warning was
> triggerred since kernel detects __GFP_NOFAIL & ~__GFP_DIRECT_RECLAIM is
> passed in:

kmemleak is broken and this is a long term issue. I thought that
Catalin had something to address this.

While this patch only adds a comment and discourages future changes of
the warning which is fine and probably something that we should do,
kmemleak really should be fixed sooner than later.
-- 
Michal Hocko
SUSE Labs

