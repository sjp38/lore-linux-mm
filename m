Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 723FFC7618B
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 14:35:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1D66F218EA
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 14:35:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="WLqofMgK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1D66F218EA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A6F486B0008; Tue, 23 Jul 2019 10:35:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9F8566B000C; Tue, 23 Jul 2019 10:35:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 899728E0002; Tue, 23 Jul 2019 10:35:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 520C06B0008
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 10:35:00 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id t18so16109952pgu.20
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 07:35:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=11EGKG6b5hoi9YzMa3B9zcamZozuOz9TYFdeDHSi/VQ=;
        b=F3YcYXxE2aWrbVeNsS9oUIXpIUOBfEO5bjBIMkbBq9kq5D4kFKlDl0kd1BGBtJez0q
         yN9b2we6waZQvonAKHwtBQ7TN8TG9vKvhUlJU1cr1Zvcvkqnsp1XtibegzSM3IeOfsv8
         2jOZLTmmyfIa4tsuuur5eEXLMFdLyhEPIkIpCxCnuwdlsQR3exoENnl1uLg151FYviqt
         vNqUYCIhNmBMrAMN1YLzUGbGHlSGCOjOYzIBTK3DP7gaFtWDqkSfxWlvlMkv7CY7WmyH
         uPbxt9WQ5Ltwx3sWEYvaC+1Ur0Rnu7a2VVbOfivXz7kNu7JfGgdTOFNkLxujEP/LJygi
         ChpA==
X-Gm-Message-State: APjAAAXO8nOqa4l7PQ0KYJpO7RnJMKSQrpvClpaaLXayW6kh+x9tdML8
	jyD3DnxYjVuc2CjLGGeQklwLpwWMNUmrYvHngIVkpUilYpNvC6L1Enz2VGqnc1pSTE9aSvv+AmI
	wizCazPICX8UTFd8qR+T1FFgx8YixbZmmLROU/I1u/CdPlF6VcDhQLJ0vQmiWewW4cA==
X-Received: by 2002:a17:902:820c:: with SMTP id x12mr81468719pln.216.1563892500010;
        Tue, 23 Jul 2019 07:35:00 -0700 (PDT)
X-Received: by 2002:a17:902:820c:: with SMTP id x12mr81468667pln.216.1563892499160;
        Tue, 23 Jul 2019 07:34:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563892499; cv=none;
        d=google.com; s=arc-20160816;
        b=GNaW+zwf38YMLe9NDQD6JFCXq9JcDDHBgeq1ULnQCFJjFEEx1yOgJPfQVc+GFhjcg7
         oFOr1h5RRUaYhmGHLzO0S6Sl7MMRz328ThbmCAFAHS9GPdAJ3jRhp7TmcHfoG6i/XqFN
         GK0atksxSxojh3apyUVwkZH36HoR4NU+kA7AdVJ4VZB9e+vckvczJz0iJVo5kkM7Ylh8
         oiKg7LQkroxLrmenN2vphuPJnvopicB3XWqPnm+nI4Y934S/TrwqiNwtTlDyuQvq3oOk
         m4RHzNeJl4Wax8nwRGT/M7Yqvas3qHOrRc9YKUf/V8pFXgRdncD2qtfFTt2Erl1FP1z7
         /Q7g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=11EGKG6b5hoi9YzMa3B9zcamZozuOz9TYFdeDHSi/VQ=;
        b=0CRnxwSjef1+OFqRLm/8L0CgdEUYezZd37kKOzlVSTdscM8u7iiLHuJw/2jmLQvPs4
         csCaTHKgNBNoACnJfxVwQ55kA71flOjueZujtbc5sQoewfbh6L54Z9Z2CimumcMumnc1
         263sbWAi8hkNQ3PJZsjsY0c1DLFmhxz7KZFNEfhOR8RfX/alUmHoAHd2xiFROD09HZgy
         m5bVhNVPD2JZCUq7993bi95V4k4AKBdktiKAxUUbVn8yCYzR4V60A2tsfh6sBjMsuEm2
         UXHaIOPEXVkh71xExbU0jtbvd/D55EU/q8SW4vlZorllk908jTZnLHbkLXq4hlN/4Klj
         EYsw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=WLqofMgK;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l13sor23539618pgq.30.2019.07.23.07.34.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jul 2019 07:34:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=WLqofMgK;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=11EGKG6b5hoi9YzMa3B9zcamZozuOz9TYFdeDHSi/VQ=;
        b=WLqofMgKgwX+GBBcQ17R0iUnyDTfMjIuZc7IpLN2ckGPX+hUVUkkKoMZj9FhwUiZKT
         AdminwPznOb1OAPsVPVbdpz5CvE0xheQ+a2Fa7GnwReA17UPZf46ynImqYVTMnImoysB
         TvEXipsHmJVKm9XkI32JDbIEWcb+EWSJ+gYkY=
X-Google-Smtp-Source: APXvYqxOGRZiTbW/QTUYHoxI40F9UeoHJjkS/MqxYprvHRJGH4uUkNovTWILl0d4sr9ylHebOwhw0w==
X-Received: by 2002:a63:d852:: with SMTP id k18mr5381517pgj.313.1563892498725;
        Tue, 23 Jul 2019 07:34:58 -0700 (PDT)
Received: from localhost ([2620:15c:6:12:9c46:e0da:efbf:69cc])
        by smtp.gmail.com with ESMTPSA id r1sm48527298pfq.100.2019.07.23.07.34.57
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 23 Jul 2019 07:34:57 -0700 (PDT)
Date: Tue, 23 Jul 2019 10:34:56 -0400
From: Joel Fernandes <joel@joelfernandes.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, vdavydov.dev@gmail.com,
	Brendan Gregg <bgregg@netflix.com>, kernel-team@android.com,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Andrew Morton <akpm@linux-foundation.org>, carmenjackson@google.com,
	Christian Hansen <chansen3@cisco.com>,
	Colin Ian King <colin.king@canonical.com>, dancol@google.com,
	David Howells <dhowells@redhat.com>, fmayer@google.com,
	joaodias@google.com, Jonathan Corbet <corbet@lwn.net>,
	Kees Cook <keescook@chromium.org>,
	Kirill Tkhai <ktkhai@virtuozzo.com>,
	Konstantin Khlebnikov <khlebnikov@yandex-team.ru>,
	linux-doc@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org, Mike Rapoport <rppt@linux.ibm.com>,
	minchan@google.com, minchan@kernel.org, namhyung@google.com,
	sspatil@google.com, surenb@google.com,
	Thomas Gleixner <tglx@linutronix.de>, timmurray@google.com,
	tkjos@google.com, Vlastimil Babka <vbabka@suse.cz>, wvw@google.com,
	linux-api@vger.kernel.org
Subject: Re: [PATCH v1 1/2] mm/page_idle: Add support for per-pid page_idle
 using virtual indexing
Message-ID: <20190723143456.GE104199@google.com>
References: <20190722213205.140845-1-joel@joelfernandes.org>
 <20190723060525.GA4552@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190723060525.GA4552@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 23, 2019 at 08:05:25AM +0200, Michal Hocko wrote:
> [Cc linux-api - please always do CC this list when introducing a user
>  visible API]

Sorry, will do.

> On Mon 22-07-19 17:32:04, Joel Fernandes (Google) wrote:
> > The page_idle tracking feature currently requires looking up the pagemap
> > for a process followed by interacting with /sys/kernel/mm/page_idle.
> > This is quite cumbersome and can be error-prone too. If between
> > accessing the per-PID pagemap and the global page_idle bitmap, if
> > something changes with the page then the information is not accurate.
> > More over looking up PFN from pagemap in Android devices is not
> > supported by unprivileged process and requires SYS_ADMIN and gives 0 for
> > the PFN.
> > 
> > This patch adds support to directly interact with page_idle tracking at
> > the PID level by introducing a /proc/<pid>/page_idle file. This
> > eliminates the need for userspace to calculate the mapping of the page.
> > It follows the exact same semantics as the global
> > /sys/kernel/mm/page_idle, however it is easier to use for some usecases
> > where looking up PFN is not needed and also does not require SYS_ADMIN.
> > It ended up simplifying userspace code, solving the security issue
> > mentioned and works quite well. SELinux does not need to be turned off
> > since no pagemap look up is needed.
> > 
> > In Android, we are using this for the heap profiler (heapprofd) which
> > profiles and pin points code paths which allocates and leaves memory
> > idle for long periods of time.
> > 
> > Documentation material:
> > The idle page tracking API for virtual address indexing using virtual page
> > frame numbers (VFN) is located at /proc/<pid>/page_idle. It is a bitmap
> > that follows the same semantics as /sys/kernel/mm/page_idle/bitmap
> > except that it uses virtual instead of physical frame numbers.
> > 
> > This idle page tracking API can be simpler to use than physical address
> > indexing, since the pagemap for a process does not need to be looked up
> > to mark or read a page's idle bit. It is also more accurate than
> > physical address indexing since in physical address indexing, address
> > space changes can occur between reading the pagemap and reading the
> > bitmap. In virtual address indexing, the process's mmap_sem is held for
> > the duration of the access.
> 
> I didn't get to read the actual code but the overall idea makes sense to
> me. I can see this being useful for userspace memory management (along
> with remote MADV_PAGEOUT, MADV_COLD).

Thanks.

> Normally I would object that a cumbersome nature of the existing
> interface can be hidden in a userspace but I do agree that rowhammer has
> made this one close to unusable for anything but a privileged process.

Agreed, this is one of the primary motivations for the patch as you said.

> I do not think you can make any argument about accuracy because
> the information will never be accurate. Sure the race window is smaller
> in principle but you can hardly say anything about how much or whether
> at all.

Sure, fair enough. That is why I wasn't beating the drum too much on the
accuracy point. However, this surprisingly does work quite well.

thanks,

 - Joel

