Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D5C6FC28D1E
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 11:17:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6AD94207E0
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 11:17:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6AD94207E0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D859F6B026D; Thu,  6 Jun 2019 07:17:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D37F56B026F; Thu,  6 Jun 2019 07:17:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C4C986B0270; Thu,  6 Jun 2019 07:17:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8E9956B026D
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 07:17:57 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id i44so3290604eda.3
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 04:17:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=vk4JDvDOJoO1192NwiGUNnVmpapz0Ns0xwa7nidCnOg=;
        b=cuNZoK9Zp9fBUbsW9YBI6THBts4qd6YPwSl06HqIAqFT+8yqe4Lnmh9v3kT5O0WSpz
         QyxLZgnkO/NRtj9e0Fajktwh9uhyud/wAXqaiIM7UTtAPG2/mOY9n9hY7TzlqyJLSQIX
         GpojwW0382Vgi2O0aRqh5LsSkCTo0Frk9qQS7+VodoBptWa+ukvLaykP6zT/YIR1g9Gf
         QAe/0k+TixZCLkI3H2lIKdsnBr7soJZuOlPBYnTsJho0g0bhU8oJbMXSOekc/HGIuCqa
         NAsA1bI7n9v0tMzZYO6ybVfPX78eK4h1dSWbn0rWs1bWEstMJfja9wrI6CCwMdlsHjjK
         7YCg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Gm-Message-State: APjAAAX0E0xKx0afYasrglGXGMUdoQQwDbPP2Z+5HFDhzO1TZWsK9bgc
	mNQ7rxpWWdcYPq6ZLv0jP38EuYSJRrRpC+qVj9IUy5lAj2G+3DcXOyvyel0Vz4RhxJ7bF9H3MxC
	AHTspMi/ikYzPxvSVFT//MXzwAi+X/Fjugr/PjnVOftj/3RIoan4vKxxqZcR+enZRiw==
X-Received: by 2002:a17:906:670c:: with SMTP id a12mr3080506ejp.290.1559819877103;
        Thu, 06 Jun 2019 04:17:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw8Yp4zOC/HrnLCi8qzCOJ4PemnAXRJ+2dJBbfYz20sYitz29cn4ECYKHkypJCzYQjkhvw3
X-Received: by 2002:a17:906:670c:: with SMTP id a12mr3080449ejp.290.1559819876374;
        Thu, 06 Jun 2019 04:17:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559819876; cv=none;
        d=google.com; s=arc-20160816;
        b=s+0wY6NwX6du2KYTnVEtzGinMlFt/hAtXxM5uR1/MsiimX0gMmieTM7L71DVKJoXJr
         Yy1oxAt5JsetiDys9fuLCuW1GOI/Vutc6qmbwfK421U94aeiCt5xE1Qaqzs4CNGUkauk
         2wVGQDxJhOOr7pwlaPTsJt1HgIjQH+uQRQMqAXAKKpXsJGvjuSnp6Ehx63kq6LxEkgyo
         5f34EJF8CpN33geOnXRCdvtVWLkxBtjPnN9BV5buljt2qZ4BfZOS3cqUtaMQ8NpRTh82
         I6mGuPc8PmYq8Oy90s5kiGOz04McN55pO0N8oWXw87w0s8A586y8HpKLOuWHyCBdPpWF
         J3dA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=vk4JDvDOJoO1192NwiGUNnVmpapz0Ns0xwa7nidCnOg=;
        b=f6zJ8rIjJdd9v/M5D+yFhgD4urv7bQ5tEII0hI4zo02JIV94CI2JmXQzNhuQ9XOX50
         5vviHUea2MOfW3cVpiNSfPCDg6jMcaHrNm9YBoGGtVafJqVeTPM6f4P2kpXLjG2Pwnj2
         cc1hvV3IVQO/xqM1SkoXCADWFMv4GAw9dhH+fMjx9ckfrhVQsqvThJtC644EwMYyCGJM
         uRc+s5vUY1eaEqLYDov7bU13bK9/atW4Xk9qUO1Bn+QNESxbtqnAmacqWHYauZSofM6P
         48H7hlB+qLO4xYcewUm8hWsjfZwaG+79t1GQiGTwN3qzgBdecWD/ATsqhVpqGS1YzkGU
         YvAw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a39si1375289edd.216.2019.06.06.04.17.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 04:17:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id E28B2AF99;
	Thu,  6 Jun 2019 11:17:55 +0000 (UTC)
Date: Thu, 6 Jun 2019 13:17:55 +0200
From: Michal Hocko <mhocko@suse.com>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: akpm@linux-foundation.org, linux.bhar@gmail.com, linux-mm@kvack.org,
	shaoyafang@didiglobal.com
Subject: Re: [PATCH v4 0/3] mm: improvements in shrink slab
Message-ID: <20190606111755.GB15779@dhcp22.suse.cz>
References: <1559816080-26405-1-git-send-email-laoar.shao@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1559816080-26405-1-git-send-email-laoar.shao@gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 06-06-19 18:14:37, Yafang Shao wrote:
> In the past few days, I found an issue in shrink slab.
> We I was trying to fix it, I find there are something in shrink slab need
> to be improved.
> 
> - #1 is to expose the min_slab_pages to help us analyze shrink slab.
> 
> - #2 is an code improvement.
> 
> - #3 is a fix to a issue. This issue is very easy to produce.
> In the zone reclaim mode.
> First you continuously cat a random non-exist file to produce
> more and more dentry, then you read big file to produce page cache.
> Finally you will find that the denty will never be shrunk.
> In order to fix this issue, a new bitmask no_pagecache is introduce,
> which is 0 by defalt.

Node reclaim mode is quite special and rarely used these days. Could you
be more specific on how did you get to see the above problems? Do you
really need node reclaim in your usecases or is this more about a
testing and seeing what happens. Not that I am against these changes but
I would like to understand the motivation. Especially because you are
exposing some internal implementation details of the node reclaim to the
userspace.

-- 
Michal Hocko
SUSE Labs

