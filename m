Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_MED,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 77703C04AB6
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 17:35:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2F2E526D42
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 17:35:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="XkRXGO8r"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2F2E526D42
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C681F6B0010; Fri, 31 May 2019 13:35:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C3E406B026F; Fri, 31 May 2019 13:35:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B5E106B0272; Fri, 31 May 2019 13:35:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f197.google.com (mail-vk1-f197.google.com [209.85.221.197])
	by kanga.kvack.org (Postfix) with ESMTP id 944376B0010
	for <linux-mm@kvack.org>; Fri, 31 May 2019 13:35:33 -0400 (EDT)
Received: by mail-vk1-f197.google.com with SMTP id g137so3936984vke.14
        for <linux-mm@kvack.org>; Fri, 31 May 2019 10:35:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=UT95TGe8i+iSc4Mrslq2c6bgkkgpf7MqKUVEvywS9rQ=;
        b=SZ1q2GIZwCAH6p9Uzwu/RdieSSYXov/phvFzklXR6RVmC6koxkSGJ/jt+84d+M36nL
         3xHhiyYvVuaJGMOIPCNthh8ZdsMWbbGatnL2m36PZuJEMOXJ/Rn3+dDuqN0oLoTenS6W
         ujcH3YAKsCiGPTt/U9XQ5ls+4vFJZ32xw8pSR2hXvrRGSh3Jds0bucPWJLShwUU9jI5q
         7Xk02vazqr2KzwUL+AJclWpdo2gBiNWCKsHci1eY+eP8rEXjBr4ou0ybtDBHJzDsJYlK
         vATLohh+X9XY23++/653/TdpIRTxwXMX6ify83bFSDhkaFdr7JbFbNHEro6Axm6YtdQf
         gtzA==
X-Gm-Message-State: APjAAAV8LnAETHjoxZduDJpecjjNk24feSq9zw/Wr9vNFLhYqzJm7al6
	fKMVfIeNgZlNgtr8M72Kr+XxoT567bDrWHISdnxfVY9nnHCgrhVDWz1sXJvAxB9R95Q2ggQ77wq
	g6EqdkfktUMa5QEQMu4e9RHTtrKwFLI9lWmSH4VkdgNV/aH1PfJyFk7FWdcCb7bzstQ==
X-Received: by 2002:a67:ee96:: with SMTP id n22mr5762904vsp.187.1559324133192;
        Fri, 31 May 2019 10:35:33 -0700 (PDT)
X-Received: by 2002:a67:ee96:: with SMTP id n22mr5762867vsp.187.1559324132497;
        Fri, 31 May 2019 10:35:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559324132; cv=none;
        d=google.com; s=arc-20160816;
        b=FkaWn0eB0c3LQsZx9v04gHkL2pl1Xc3Tbh0XBQg6ruMZpJANitDcb8wXJHZVx0cM/P
         8uqhRr2PRwjBaWo0z7UZPX9ZlC81yFB99XUuA4kv1Xj0gbYAcZPZNVluPk67GKqVC5Al
         EOKj7WgjYYt6HExi14IFVAUmG7SbdyQXbywAcQVS82QEmBzC+fZBeL56MiRDkU38V758
         a4d14FIf92mQbNBNhQXDnnmtlxsxX3XY7Ayksk7t7/YxcEkcmLYFWrz7wAbOFcj4vJD0
         KhkyUxiY1UBTj0piLc2QB+pGYSzUT/m7aUkfztCe+WHMd7Ro78qD1juZ64MS9sX7NoJZ
         E/qQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=UT95TGe8i+iSc4Mrslq2c6bgkkgpf7MqKUVEvywS9rQ=;
        b=uWadV3U8JT7k7znzkyr/uqCj5dKBBmaBYZpiYoBXXPSvI2PxqXM0h9rOZ/LS84smMr
         32v6uRMVrTZdZIDqJs6KLmSqKm1cziRhY8p+Q/vgAQgUyMmIbpknspsmDGGofZ6pRj8+
         qYnhJmUdDgqMPpq8JRr0A953zwkIKBB4d7gca4xPInp/loqjJ341KGSd8xkHpHifJIhZ
         0LHjJTNno+NmIWNImr3v/I2LSxL7YhNypvtuFXsqVpe1l1bytukzTM6bteDIiVv2533v
         DAEiA9+t+H6qSkedXi3l9jX9pq8stF1dzttFMV+ejTCNTwU4/8/X/nQxzipM0LZ53yxU
         mLLw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=XkRXGO8r;
       spf=pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dancol@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r13sor2656709vsk.43.2019.05.31.10.35.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 31 May 2019 10:35:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=XkRXGO8r;
       spf=pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dancol@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=UT95TGe8i+iSc4Mrslq2c6bgkkgpf7MqKUVEvywS9rQ=;
        b=XkRXGO8rGh8TZ4EUzxfokC5808K1dz1UcgRHXk5nSZXjzX7ByJ9OOS3VUfLxIGGAe4
         tBJOQ41tQiTrAGL8Vqh+uDVv6x0PoGvSasP0vc6fBcPf9wEekZyVRoXaNo1xuJ2Fn5wJ
         Mdw2jJZ25WDo6I4uz8vJmqlZY84v/5BJKw6tSscV26kE59k4+mPTnBO54Ga2JiQ3fF49
         9f36MMHIrDv6UDicgzKbwCc4KmUky3yRfA6nB2SCVng6BOkS7L2+dNFKBJmEgZK6JRI0
         aOaHXvY0eVS+UnHvlhi71Ao0kSR18YVuOC0awHBXNUVnRpG6nJezGgjBM5MLoZEwisfe
         er5A==
X-Google-Smtp-Source: APXvYqwXzH1wOrhlClP+4XIXhtYESdkaXQctuZZmUpL+byNkQuwIQh6PWl6WuJPpoo7fr6T7kU+2n6RwqkoaZfzW3Nw=
X-Received: by 2002:a67:2084:: with SMTP id g126mr6137960vsg.114.1559324131824;
 Fri, 31 May 2019 10:35:31 -0700 (PDT)
MIME-Version: 1.0
References: <20190531064313.193437-1-minchan@kernel.org> <20190531064313.193437-6-minchan@kernel.org>
In-Reply-To: <20190531064313.193437-6-minchan@kernel.org>
From: Daniel Colascione <dancol@google.com>
Date: Fri, 31 May 2019 10:35:20 -0700
Message-ID: <CAKOZuevswVxZjffQcwjqJFa5V4Vv2jxq=mq6hWhd1SpNrGAGkg@mail.gmail.com>
Subject: Re: [RFCv2 5/6] mm: introduce external memory hinting API
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, 
	Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Tim Murray <timmurray@google.com>, 
	Joel Fernandes <joel@joelfernandes.org>, Suren Baghdasaryan <surenb@google.com>, 
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>, 
	Brian Geffon <bgeffon@google.com>, Jann Horn <jannh@google.com>, Oleg Nesterov <oleg@redhat.com>, 
	Christian Brauner <christian@brauner.io>, oleksandr@redhat.com, hdanton@sina.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 30, 2019 at 11:43 PM Minchan Kim <minchan@kernel.org> wrote:
>
> There is some usecase that centralized userspace daemon want to give
> a memory hint like MADV_[COLD|PAGEEOUT] to other process. Android's
> ActivityManagerService is one of them.
>
> It's similar in spirit to madvise(MADV_WONTNEED), but the information
> required to make the reclaim decision is not known to the app. Instead,
> it is known to the centralized userspace daemon(ActivityManagerService),
> and that daemon must be able to initiate reclaim on its own without
> any app involvement.
>
> To solve the issue, this patch introduces new syscall process_madvise(2).
> It could give a hint to the exeternal process of pidfd.
>
>  int process_madvise(int pidfd, void *addr, size_t length, int advise,
>                         unsigned long cookie, unsigned long flag);
>
> Since it could affect other process's address range, only privileged
> process(CAP_SYS_PTRACE) or something else(e.g., being the same UID)
> gives it the right to ptrace the process could use it successfully.
>
> The syscall has a cookie argument to privode atomicity(i.e., detect
> target process's address space change since monitor process has parsed
> the address range of target process so the operaion could fail in case
> of happening race). Although there is no interface to get a cookie
> at this moment, it could be useful to consider it as argument to avoid
> introducing another new syscall in future. It could support *atomicity*
> for disruptive hint(e.g., MADV_DONTNEED|FREE).
> flag argument is reserved for future use if we need to extend the API.

How about a compromise? Let's allow all madvise hints if the process
is calling process_madvise *on itself* (which will be useful once we
wire up the atomicity cookie) and restrict the cross-process case to
the hints you've mentioned. This way, the restriction on madvise hints
isn't tied to the specific API, but to the relationship between hinter
and hintee.

