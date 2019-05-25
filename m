Return-Path: <SRS0=GxOJ=TZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 19F37C07542
	for <linux-mm@archiver.kernel.org>; Sat, 25 May 2019 17:39:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DCE9F20863
	for <linux-mm@archiver.kernel.org>; Sat, 25 May 2019 17:39:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DCE9F20863
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 72FBC6B0003; Sat, 25 May 2019 13:39:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6B9D66B0005; Sat, 25 May 2019 13:39:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5809D6B0007; Sat, 25 May 2019 13:39:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1FDF86B0003
	for <linux-mm@kvack.org>; Sat, 25 May 2019 13:39:30 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id b20so503771wmj.3
        for <linux-mm@kvack.org>; Sat, 25 May 2019 10:39:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=kxxlz9bSFrWVfWvvsiOdLYxdjBiTU//cWdy8Xh4oN34=;
        b=S5PkIHYG9r5BF262Z9TsxJ4KgmdPKe2CmrBAHmxheb8EOr0/ESxyPhLpxJxVkxE530
         kFYQ/NpkAStHBLrEGQ7gszVhpNbIxRPRHRzk63T0q5+bI1Ztum9VrWucp3wFlTeBFALL
         w9vIiCaL180kgIWtja7ypsnY2/18VPWFQ32L9IekH3iXoDvWuLO2FyjIiF4kiLWwcAtv
         kmdqvx1OjaCe76irN6r35+zvjNpSnSzFADiRhC+TsCSq3CJ/GItMrZvdYZvRlj5XXXby
         KpRoA97D+AzrVdFFQfFpDCod8NQXeMa40RFayTVlACRtUbBuuut1E3li8ziDjtb/mcqZ
         UqeA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAU78opIN5hSmNYr90tQpnLp69U4XoErDftyGIsnccOG2wXLbvTW
	kgqbgrDY4VWn1VmB9QwKptTJgd9ZBC82KVgTVxtk9OSOTMKlrjDCZIIzZ3NIxOpbhwVjwcXC+W2
	LGM5u23bsIpitWcEu3Yuj1l7RhpiOQRhLZg1M3Me15c04E5NzVzG8v2rt5lWZ2U6zxg==
X-Received: by 2002:a1c:b4d4:: with SMTP id d203mr19818883wmf.34.1558805969630;
        Sat, 25 May 2019 10:39:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwg3z2nzrNp3/xqMoulDJWGsu83IpAQntBx3mcDEZA5sBCSGoOvLsVFWogRmA7pOwMw4TGM
X-Received: by 2002:a1c:b4d4:: with SMTP id d203mr19818859wmf.34.1558805968842;
        Sat, 25 May 2019 10:39:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558805968; cv=none;
        d=google.com; s=arc-20160816;
        b=XkPIGfzzvs4G5TW/ij4PaP+x4TOx70BTnhTovdyFNzrRtDlPOkrYMOSG+kPw7MyuT5
         hQVJu1wVPxb2AFWPdgIP2vle0RKLSqDCP4mVChBu9piYDSsAxOMbAcQFgyytuGPpBGkp
         ImPnHJoxQ2tUVxXU3glY3WOSFhUKm352VS4qeR8PwibWgCvenUDVHEuZ5T7uZMkJM437
         eLdlCzte1PDYfrH+sMIAOjVNjy3Wi+FozRPobuxSFVxKKDOLo23PT4eNEcL70sfq9QSm
         vri4v7VwkQ9y4oJnntwGNgjLFRWROiPnlj/9jL8bU2yostCPBTOKYQyq0Qv/v/6WOCMX
         lokQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=kxxlz9bSFrWVfWvvsiOdLYxdjBiTU//cWdy8Xh4oN34=;
        b=QLgdtAMm/1mDfhWZpvWD77G8V1+4RDiBO2Amiex5KWfx/cJ/zd2jWMOpHBLzOqj9Hl
         BlZf3mPgL5uXeWVDNp95ia9pGV8psHFpAicCBHWcD22eAn7fuBNTuAQibPqr+QZ6gpLK
         1q1fNvPYUDBbhjMFYVDdnhZd+ggEKhQxfKv6cNHUU/3Nxj+LQw+6CKAgbRPlbDBuYmHZ
         2NEbbdY+AtwxFkrWqCm5fssyiUJmQcN9A9GXpZ2Yiwf2uvFtNrlOoRVEjRZEIhIujOwj
         5r5AMnV8DerwOxGMfV8LGENWm4zkaZfB1OxSwfs1YEJlAKvzuBwPTrgVE5kiOmxWHl5Q
         skDA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id g10si1661350wmk.201.2019.05.25.10.39.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 25 May 2019 10:39:28 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id AF14668B20; Sat, 25 May 2019 19:39:05 +0200 (CEST)
Date: Sat, 25 May 2019 19:39:05 +0200
From: Christoph Hellwig <hch@lst.de>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Hellwig <hch@lst.de>, Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>,
	"David S. Miller" <davem@davemloft.net>,
	Nicholas Piggin <npiggin@gmail.com>, linux-mips@vger.kernel.org,
	Linux-sh list <linux-sh@vger.kernel.org>,
	sparclinux@vger.kernel.org, Linux-MM <linux-mm@kvack.org>,
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>
Subject: Re: RFC: switch the remaining architectures to use generic GUP
Message-ID: <20190525173905.GA14769@lst.de>
References: <20190525133203.25853-1-hch@lst.de> <CAHk-=wi7=yxWUwao10GfUvE1aecidtHm8TGTPAUnvg0kbH8fpA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHk-=wi7=yxWUwao10GfUvE1aecidtHm8TGTPAUnvg0kbH8fpA@mail.gmail.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, May 25, 2019 at 10:07:32AM -0700, Linus Torvalds wrote:
> Looks good to me apart from the question about sparc64 (that you also
> raised) and requesting that interface to be re-named if it is really
> needed.
> 
> Let's just do it (but presumably for 5.3), and any architecture that
> doesn't react to this and gets broken because it wasn't tested can get
> fixed up later when/if they notice.

FYI, my compile testing was very basic and a few issues showed up
from the build bot later on.  I'll keep the branch here uptodate
for now:

	http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/generic-gup

and won't resend until we make progress on the pointer tagging
thing.  I've also got a few follow on patches on top, so they might
be ready by then as well.

