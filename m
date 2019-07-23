Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1220EC76188
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 06:05:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C3EA52238E
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 06:05:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C3EA52238E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5D3E36B0007; Tue, 23 Jul 2019 02:05:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 584448E0003; Tue, 23 Jul 2019 02:05:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 44D868E0001; Tue, 23 Jul 2019 02:05:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id ECB646B0007
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 02:05:29 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id e9so16452159edv.18
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 23:05:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=wZavSHwrM0Rlryz5bWLqrhSScYMHD+KWghq/h1q8GpU=;
        b=e1EJ8qSPnXGWQ3gm908W7GR26mmU+JY8C+LJATAH9nNH/0rwUIFCq3btxngM9Bchcm
         BSijTTu2YmDGfNofbITour0rgaxWsqW1qJD/YytnEukED12A3Miic26fbScwZaYFCKQt
         ZP1K6IHEAcBHY0nh0KLWOk98tZEsa420Sp4zYvfZXNZLIVy97IIspkVbpmjo6SBTjHJB
         8deOAjNo0ztVUwGPTGdAnyJJfbre+dfKFlZkiWRCDQsCG54feIe453+OAPgtPCxGlLEs
         WsR1EZudLx8QvSWOWpOmWvwMF535Gxo/b+UKK2S3+939czxgXvuvV5jT0fPxn5s+BpUF
         EPGg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXNYYZNLlBUSnG2lPcIuQ4uMZKbE6sAPBk1+kVHC5Fztr27v36f
	dmX6otv2b9S2lHcchB8pLCUrxH+Li2CVH0N9X1xF7tyhhOvAPORWQhqFg/4Xr/U0CN8as1VYsv2
	npnqzxxbN3IUFQNlZZdBFpfZjDruGilk3f2h/AG6CcrkhE7loDOZowu6tH0R6VVI=
X-Received: by 2002:a17:906:5446:: with SMTP id d6mr23798545ejp.185.1563861929364;
        Mon, 22 Jul 2019 23:05:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw82iX5FkHP0bCOf3u1HmZO+BLq28DECqMw0O9qhl1Tukoy/zcR/bqv+wOVC2bnGA/tryjv
X-Received: by 2002:a17:906:5446:: with SMTP id d6mr23798486ejp.185.1563861928462;
        Mon, 22 Jul 2019 23:05:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563861928; cv=none;
        d=google.com; s=arc-20160816;
        b=Ti3acWGnmk2qVHEVitiqAxfoHbPxM5ZtVxmrXHdfS2bRNQXsLhbK+eh/m8Ntv2dJ9k
         +u11W4njMBIgEJOaXtxLQ1a+yxeW+JJ7w4UPU3Tki+7FNspc+txlIMB3ZJ889v8NXiS5
         40O5dQQZHvyZ9s2+Dn4I74adJxp9gGlm1wzUKlrKEFu2xUe7702CTXv0WAaZqFjP+8y/
         fsj/GF9fiVgqGCQ2RcYVZJ1y/Dis8RocatYdeQr7cO5PmR4vQx2s1QOpC5Hvw3hVpCOS
         cxJHEb+gFw7ZHYnbuj7CZjG3XC65X9p7lciiaPyHYtFbPAdf7uzLTBMbaJuFWxzxCFa7
         NpCg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=wZavSHwrM0Rlryz5bWLqrhSScYMHD+KWghq/h1q8GpU=;
        b=UE0LasQuCChDxmNRiImQR5j8VhjjoSXT7MWoyU+qkShC95Ki3rUFy4oxrbNVdDm7D9
         vUKXdlPlFUSeVJgfBY03C8v6DD4VjB9Rrsd9Vg+Z5UX0Ryht8EjmOqdsJ4a2fqC2xMho
         8jrTef2WpXnUry8Z98FFrnIhp9dr5d7vGbW2bJsdpq61bL8q8EKArRlq1TAv9Z9vecEa
         MvRkmg0CoMwRuFuM9YQOAXCFSKYZJmntTNYhfVaj9T6IXo0SK0U9CEjM3DBULtsRcT8V
         60BJyASe4RC74KK5l5tg/3YXsXD4PBYAu5jS96UHQbwbbs2ct49AOwcyK4YiwYeQSAcU
         U4KQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t54si6067772edd.313.2019.07.22.23.05.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jul 2019 23:05:28 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 817ADAF35;
	Tue, 23 Jul 2019 06:05:27 +0000 (UTC)
Date: Tue, 23 Jul 2019 08:05:25 +0200
From: Michal Hocko <mhocko@kernel.org>
To: "Joel Fernandes (Google)" <joel@joelfernandes.org>
Cc: linux-kernel@vger.kernel.org, vdavydov.dev@gmail.com,
	Brendan Gregg <bgregg@netflix.com>, kernel-team@android.com,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Andrew Morton <akpm@linux-foundation.org>, carmenjackson@google.com,
	Christian Hansen <chansen3@cisco.com>,
	Colin Ian King <colin.king@canonical.com>, dancol@google.com,
	David Howells <dhowells@redhat.com>, fmayer@google.com,
	joaodias@google.com, joelaf@google.com,
	Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>,
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
Message-ID: <20190723060525.GA4552@dhcp22.suse.cz>
References: <20190722213205.140845-1-joel@joelfernandes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190722213205.140845-1-joel@joelfernandes.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[Cc linux-api - please always do CC this list when introducing a user
 visible API]

On Mon 22-07-19 17:32:04, Joel Fernandes (Google) wrote:
> The page_idle tracking feature currently requires looking up the pagemap
> for a process followed by interacting with /sys/kernel/mm/page_idle.
> This is quite cumbersome and can be error-prone too. If between
> accessing the per-PID pagemap and the global page_idle bitmap, if
> something changes with the page then the information is not accurate.
> More over looking up PFN from pagemap in Android devices is not
> supported by unprivileged process and requires SYS_ADMIN and gives 0 for
> the PFN.
> 
> This patch adds support to directly interact with page_idle tracking at
> the PID level by introducing a /proc/<pid>/page_idle file. This
> eliminates the need for userspace to calculate the mapping of the page.
> It follows the exact same semantics as the global
> /sys/kernel/mm/page_idle, however it is easier to use for some usecases
> where looking up PFN is not needed and also does not require SYS_ADMIN.
> It ended up simplifying userspace code, solving the security issue
> mentioned and works quite well. SELinux does not need to be turned off
> since no pagemap look up is needed.
> 
> In Android, we are using this for the heap profiler (heapprofd) which
> profiles and pin points code paths which allocates and leaves memory
> idle for long periods of time.
> 
> Documentation material:
> The idle page tracking API for virtual address indexing using virtual page
> frame numbers (VFN) is located at /proc/<pid>/page_idle. It is a bitmap
> that follows the same semantics as /sys/kernel/mm/page_idle/bitmap
> except that it uses virtual instead of physical frame numbers.
> 
> This idle page tracking API can be simpler to use than physical address
> indexing, since the pagemap for a process does not need to be looked up
> to mark or read a page's idle bit. It is also more accurate than
> physical address indexing since in physical address indexing, address
> space changes can occur between reading the pagemap and reading the
> bitmap. In virtual address indexing, the process's mmap_sem is held for
> the duration of the access.

I didn't get to read the actual code but the overall idea makes sense to
me. I can see this being useful for userspace memory management (along
with remote MADV_PAGEOUT, MADV_COLD).

Normally I would object that a cumbersome nature of the existing
interface can be hidden in a userspace but I do agree that rowhammer has
made this one close to unusable for anything but a privileged process.

I do not think you can make any argument about accuracy because
the information will never be accurate. Sure the race window is smaller
in principle but you can hardly say anything about how much or whether
at all.

Thanks.
-- 
Michal Hocko
SUSE Labs

