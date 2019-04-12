Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CDF35C10F0E
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 09:36:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 95D43205F4
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 09:36:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 95D43205F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3429C6B000C; Fri, 12 Apr 2019 05:36:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2EF2E6B0010; Fri, 12 Apr 2019 05:36:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 206A06B0266; Fri, 12 Apr 2019 05:36:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id CA2776B000C
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 05:36:44 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id w27so4631099edb.13
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 02:36:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=+rx6zAlr2l9R8f/bwxW9MeAq0fzlFTdEi2n+Roc53v4=;
        b=DRrAKDN8ANJudtDGZ24VQ21qj9AMOFly9TLwfw0WZP+e99q3sEeczV1D1n5Z64EFnp
         uX5XHR0DvkBzIKvCNCV4W3M5gj0aQzU2jk4CK2dltztPHKDfBdAGZGobYHSptY1Jkv7M
         /oUX2gzK6Tqp7jXfTpSYK67GinxBtOx09aHnWpyP6dWiGaUF6TzX2k3UgcdCio/hsazm
         g32VvxaQT9+5ICIvWqmVZBqBYwRJnD2aYe5gkL8lvxWbUA8ac+U4r+PFv+jgw0ydMgfj
         LWefDmpMKl9v+gGGODZ6BradSCM1SDBA+MBwxOpzaQx/sYUfzkYqFH722Qg4lc6okC7e
         l/7w==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXXfoE3DYkgi6syenL4wr4rZMaAtz5qcmBmAKL16FMP26L8VMNA
	9fihDUvdbRQrAce49kuu1K/ZfLAfch3OlFwuoLmdPGNUrU4CeuNGA4ZGemhxQW3+yqMMnwq3EYS
	vZMMR9f3JRLTQrXERj1Oyy94mtWT9tBx774vYSZONiyXGQkzBqvNIf4RxO/IHy+0=
X-Received: by 2002:aa7:c5c4:: with SMTP id h4mr34461692eds.19.1555061804405;
        Fri, 12 Apr 2019 02:36:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxpXbi+QQIQC0UfskvwLi03k9rYmvpbiscMiPEJ57FwFJ4V9SImyAdYaGS+GmxbsQICpQ1j
X-Received: by 2002:aa7:c5c4:: with SMTP id h4mr34461639eds.19.1555061803576;
        Fri, 12 Apr 2019 02:36:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555061803; cv=none;
        d=google.com; s=arc-20160816;
        b=slMmcpOKIcq4blVaeYBbBZ5FzQ6afcO1mgfdslJdGv5bFQbM5zc72AT07hK+9cglXF
         YBSPopf3g+byW2ASLsmGW6iC5GP/rvTrfsCqv8ofA40ff3mXdqW4czgILrTz7EGpU5b3
         w8p9xZe/XNfx8mtU/Q5q2cwv7WvkERhyBI0nQK5AZw8jqkZIFGQHfM7Q5ieTrtbI09uR
         RCJHzgwXkPYH+YtcwykVwRd3ULiwWqpdwdqercVWLW42YtioVKjIWtwSMFeI4/jiSt8k
         k1bIgOeP96bKwQLhoZtNGOFbRXexKezbAuiLgX1bpc76wfR8w7O+lhlwAylLDPRHVJyi
         N4fA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=+rx6zAlr2l9R8f/bwxW9MeAq0fzlFTdEi2n+Roc53v4=;
        b=s9RV2TAbOyQyyV/Pjd1AnMCMuM7nMpsMwG0OPuGonRAyJMDnoZpX2ADTa3kF5R4TLX
         9DoV9HjH40scQcdbJIB9pN7y6at1VPhs39A/AIHqHU2jqpTj5gnQztoUj37ydJczfyvp
         XSVjGAuAUYKhaxcLv+KG2EhF0zkOXglMkfmRE7WJCpSZRKv1SdlAnDDYq9vx5l9Gl3SM
         Y/nJ9VThqfmwFnYQ9kxsWXuk4qGNn1b39oXAl5niyuDVsLIZysuGReveRmGZjL7LK+8S
         9M0GsF1T1s1g5WwPD/edqCAcVncPNhk87A5Od43AmuphSLMxDvERo4I8SlMWKjHJnhYP
         kJLQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x7si3548205ejb.77.2019.04.12.02.36.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Apr 2019 02:36:43 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id E93DDAA85;
	Fri, 12 Apr 2019 09:36:42 +0000 (UTC)
Date: Fri, 12 Apr 2019 11:36:41 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Chris Down <chris@chrisdown.name>,
	Andrew Morton <akpm@linux-foundation.org>,
	Cgroups <cgroups@vger.kernel.org>, Linux MM <linux-mm@kvack.org>,
	shaoyafang@didiglobal.com
Subject: Re: [PATCH] mm/memcg: add allocstall to memory.stat
Message-ID: <20190412093641.GG13373@dhcp22.suse.cz>
References: <20190411122659.GW10383@dhcp22.suse.cz>
 <CALOAHbD7PwABb+OX=2JHzcTTLhv_-o8Wxk7hX-0+M5ZNUtokhA@mail.gmail.com>
 <20190411133300.GX10383@dhcp22.suse.cz>
 <CALOAHbBq8p63rxr5wGuZx5fv5bZ689A=wbioRn8RXfLYvbxCdw@mail.gmail.com>
 <20190411151039.GY10383@dhcp22.suse.cz>
 <CALOAHbBCGx-d-=Z0CdL+tzWRCCQ7Hd9CFqjMhLKbEofDfFpoMw@mail.gmail.com>
 <20190412063417.GA13373@dhcp22.suse.cz>
 <CALOAHbBKkznCUG39se2wcGt9PZYiGFhCm9t2t-X+CL5yipT8cQ@mail.gmail.com>
 <20190412090929.GE13373@dhcp22.suse.cz>
 <CALOAHbAcXDDdq_XO+hvwTq6PMNjFFgHAY2OPmkAReKV8-wR6sg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALOAHbAcXDDdq_XO+hvwTq6PMNjFFgHAY2OPmkAReKV8-wR6sg@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 12-04-19 17:29:04, Yafang Shao wrote:
> On Fri, Apr 12, 2019 at 5:09 PM Michal Hocko <mhocko@kernel.org> wrote:
[...]
> > > Then we can do some trace for this memcg, i.e. to trace how long the
> > > applicatons may stall via tracepoint.
> > > (but current tracepoints can't trace a specified cgroup only, that's
> > > another point to be improved.)
> >
> > It is a task that is stalled, not a cgroup.
> 
> But these tracepoints can't filter a speficied task neither.

each trace line output should cotain a pid, no?
-- 
Michal Hocko
SUSE Labs

