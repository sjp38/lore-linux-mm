Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D3DC1C7618B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 13:00:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A5A3721871
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 13:00:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A5A3721871
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B3EF6B0005; Fri, 26 Jul 2019 09:00:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 366826B0006; Fri, 26 Jul 2019 09:00:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 22CEE8E0002; Fri, 26 Jul 2019 09:00:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id C88DD6B0005
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 09:00:20 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id l26so34081994eda.2
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 06:00:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ZnFnLX57nZWl1UwsuvPEx2b1Ejn+8R9k/lPZDTJLfps=;
        b=YXLFYYEFQ5+UNjyABqI+3yQfr3HOJ9yt8dnkiuFxbqUVfbMjBnGe/Mh7YYnWgFeRXc
         xIaaAKBEHvICGSPdUuvelFpCCGCh7Fc4blS+c9Jgkx8GX2YS+l7x+1Izr4UfqpTjGb+r
         Mk6NvWemf/K8q94mKWNw5xlkcnwd2u/Cj+bWRATKgc0oq4jzAJbyA6l700leWFGbdskh
         0l6OyUOfPjzQA7StEsl37szjJNjMMa76VY5Hfp9ri/dWAodiHl2xPlD8Nut+5vh7y3EZ
         bRa45pldCdXgFRUwqj3Z9Ej68RErDYKECu0B0TWu57nMeo9tdhG9gSUIroVcWmeMrz6C
         lNpQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAU2CFUFlhyyAe6lVpSjGNGL7knEmV6czEV9RWqi52EPv7NyHxG3
	A0sIdmyQ20lGyw5kKGRuRJKgcTOSgll6SBRj6+CXIii9Nt8LwMZSKPjOiMrGVf1gPGDVSGjP2h0
	BKPgo3QKhqpwCFPLU2lhjR/GaTjMrqCT4I146exFC2ls1G0+USoM4x8ZOglQ01DDbFg==
X-Received: by 2002:aa7:cdc6:: with SMTP id h6mr81781963edw.5.1564146020360;
        Fri, 26 Jul 2019 06:00:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzSZvjOPzX+lQj9P2pLr2MZGaTKc5RmGjVVus0sgWk2iwQEIkpgOUGYWp9zS7RYepste9JB
X-Received: by 2002:aa7:cdc6:: with SMTP id h6mr81781848edw.5.1564146019305;
        Fri, 26 Jul 2019 06:00:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564146019; cv=none;
        d=google.com; s=arc-20160816;
        b=yPo/LduZaJLVNLQYMJMBZSiKCpHJscj/s1J2J4Yezn0Sf1Up33J/uTpYmWTQdI+5N7
         to4Odoav2QE8E3XWDD60te1wTtVJy5DQ32OaLpMnAICPxxzUxPn/mvkjLWkTQu67eahB
         wX1RYp0iLvi5F11a1Kzy0HONfeBT/wwb5uLaC4RF3iucLzwRbDNZaTpOFSOddyEDCkOJ
         Aq5raXV5kBRNmvHOsOB4CLGDJUexcemvDSCqN2/XCfYp6nfltZgf1wDRhE1KoCMbqO+d
         19ofGQN9BECqJAJPouxUin7pQm77BGDB6jX7ERY97dHdLAq4VQtFAOrPn4+rGQJU2Wk+
         yFug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ZnFnLX57nZWl1UwsuvPEx2b1Ejn+8R9k/lPZDTJLfps=;
        b=v4dvcp48hLetFMR6d5uqqD4h3AVIecUtYIZODDbncDyyj8pQjbWbFJkVFvMzFkfBJC
         pgUWzad3v2YfTrCGecX5HPsFOd4ENOS4ZD5U6VtaC5JnfTFA2lyXPHaYpjH33nZ0grTO
         Dc9I8ZxY7CaTBEqBsgxwwUk/OJ9Kte3pBWUwzPa+hQIEqnmrSO74rwrIgDaT7G5CfdI6
         et+HQ7eLLYc40ozfc/RLKx6PSvw67lnbCwHifQ+0mcw+hRzYH+h/nrSaO9WXTJfoOJJa
         3HOM9B57AfX8/eJd65v4kKrG6yJVOQuAiqATPAfsWS9OEHrSff0VUt9qC6Or+1IqjuYD
         p8Hg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id i13si10728982eja.216.2019.07.26.06.00.18
        for <linux-mm@kvack.org>;
        Fri, 26 Jul 2019 06:00:18 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 70923337;
	Fri, 26 Jul 2019 06:00:17 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 357033F694;
	Fri, 26 Jul 2019 06:00:16 -0700 (PDT)
Date: Fri, 26 Jul 2019 14:00:14 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: syzbot <syzbot+a871c1e6ea00685e73d7@syzkaller.appspotmail.com>
Cc: alexandre.belloni@free-electrons.com, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, nicolas.ferre@atmel.com, robh@kernel.org,
	sre@kernel.org, syzkaller-bugs@googlegroups.com
Subject: Re: memory leak in vq_meta_prefetch
Message-ID: <20190726130013.GC2368@arrakis.emea.arm.com>
References: <00000000000052ad6b058e722ba4@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <00000000000052ad6b058e722ba4@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 24, 2019 at 12:18:07PM -0700, syzbot wrote:
> syzbot found the following crash on:
> 
> HEAD commit:    c6dd78fc Merge branch 'x86-urgent-for-linus' of git://git...
> git tree:       upstream
> console output: https://syzkaller.appspot.com/x/log.txt?x=15fffef4600000
> kernel config:  https://syzkaller.appspot.com/x/.config?x=8de7d700ea5ac607
> dashboard link: https://syzkaller.appspot.com/bug?extid=a871c1e6ea00685e73d7
> compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
> syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=127b0334600000
> C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=12609e94600000
> 
> The bug was bisected to:
> 
> commit 0e5f7d0b39e1f184dc25e3adb580c79e85332167
> Author: Nicolas Ferre <nicolas.ferre@atmel.com>
> Date:   Wed Mar 16 13:19:49 2016 +0000
> 
>     ARM: dts: at91: shdwc binding: add new shutdown controller documentation

That's another wrong commit identification (a documentation patch should
not cause a memory leak).

I don't really think kmemleak, with its relatively high rate of false
positives, is suitable for automated testing like syzbot. You could
reduce the false positives if you add support for scanning in
stop_machine(). Otherwise, in order to avoid locking the kernel for long
periods, kmemleak runs concurrently with other threads (even on the
current CPU) and under high load, pointers are missed (e.g. they are in
CPU registers rather than stack).

-- 
Catalin

