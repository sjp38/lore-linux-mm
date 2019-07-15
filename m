Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B67C3C7618F
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 22:57:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 71AF120693
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 22:57:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chrisdown.name header.i=@chrisdown.name header.b="FupgII/o"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 71AF120693
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chrisdown.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0C0A26B0005; Mon, 15 Jul 2019 18:57:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 070EF6B0006; Mon, 15 Jul 2019 18:57:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E7C2A6B0007; Mon, 15 Jul 2019 18:57:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 97CA76B0005
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 18:57:33 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id m25so4799466wml.6
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 15:57:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=7VSl4WMlmc5jmN5dNuL2dV5fcPROFvmtmokhA+NF36I=;
        b=P9AtkKrrxeD5TvtXgmVLlEGwgDIiNDDWJKO9vi/oR0TN6jBt3UlC/UxIOgeeMYh1uH
         1qrkb9V5qjnDiUhJw8H/apEAO221nwu4/9Q5dekBuJTg5WwHI0O7ebiy+HhI+H4T5BSl
         txiEBb6xLhh6v/ljYFEZrvArv6WngMXA/vTIChlC6dnNEpc8LwjFL5OW7/68ejryr/0V
         rXAtPEXuOInpcGiIwg1Oglgx3h7gyfm3MO6nmIEABoNmN8AfvkQwSBAtb3gOmRp0jylz
         PjI4p4S5Hwr714ynr4PXvmySzeC1FgPa770GgNnFx4i9SQv2NMD3LS9OB0DCLZ6H3DIf
         cjRQ==
X-Gm-Message-State: APjAAAU2ePnlPoLSFq/rDfzrfPBU7T7lw/E7NsUzGpCx2kSSsjTN/sEq
	ZY2RTIO/CgjrMQ0bBXFwvnj6V/bxYqZSw0oi1qTT6EGrzON37dz+qa2A3q5kEn2Nhw5IVW0iswp
	R7/0JyhAslkciTxjxUE4/ha0tFQ6V1BAn240HKD4FqZitCdXqx/5jwDVmL9MLMQvPag==
X-Received: by 2002:a5d:6a90:: with SMTP id s16mr21649020wru.288.1563231453156;
        Mon, 15 Jul 2019 15:57:33 -0700 (PDT)
X-Received: by 2002:a5d:6a90:: with SMTP id s16mr21648968wru.288.1563231452066;
        Mon, 15 Jul 2019 15:57:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563231452; cv=none;
        d=google.com; s=arc-20160816;
        b=NJTlV/rI8ZrMRDplxjcosdl8cGhyjmE6NjGeyViWiQyNJ4/H/PqD01U2nID/yg/hut
         l27jc/uY300BSezxt9qsmS3B9pTbb6M+jt9lvZFZau5TLnYOTuEaYec/rN3EPTQS/NTy
         q3I5FcBwMywx9Oe3dRLfkkPLoAS0zuDSVzOfjrL3zgo2CVvw/bECJGoRO3eY6E3xq80+
         mzCNIX1ZRr3JF+i6rdND2yX2l7dTT7xV7VpGkGsZh/nJaP7JqNRMZI8ty0S4nEUSTSht
         YGSu45ux3avYp/0YxjWZ8MjQDgrU/8YwBbV68zDkT6VQLYBg3AF5PS7Zp+N9emFZ2lv/
         avyg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=7VSl4WMlmc5jmN5dNuL2dV5fcPROFvmtmokhA+NF36I=;
        b=D7kS3ELBoMutu3oUiVnqLkpZZ6jNj9di1Pnu+/O88hV+eUzQVegjp1ZqW5IZc7kRfk
         51QEtKYLQzBWMNZokEXBF577oZ7nnlcsdbPnifnelDSu9naL/GCiCqdloSceDTlcCO+I
         xyDe8tW3Y6dO4KNtbxB7xIMPznsybsCyiEbeMW1TVZFlU8w6RUXmFAtp9XVVV42X/dg+
         0wLA3mPYXMdV5yN86vpBab1C8I2madcUpR6mBegG7jDBrqZdo7Ne6QEu6P4E4Bs4r9B1
         A3ozIOJaiH3916BNgDqNldLjk97BMjSZ7ufEECza/4LhuEjaeBeJ1OG8wQQx9Y2n2fYc
         DOlg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b="FupgII/o";
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x186sor10526714wmg.25.2019.07.15.15.57.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 15 Jul 2019 15:57:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b="FupgII/o";
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chrisdown.name; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=7VSl4WMlmc5jmN5dNuL2dV5fcPROFvmtmokhA+NF36I=;
        b=FupgII/o9bbimWyh0bR/UkrMCpIcBrEpJ9ja2EO6K5VA/hOxrdLwUrKeytS0QyP0Y0
         OhXsBBkmUiEHwe9vHBVKjTY1KbQ8/G/lcXfmnhG5kapCPmdHusIlp+cwSXAld52Wnqa/
         nRh649s69N06QxHZL6McwutEtJnh9SDnxj+SU=
X-Google-Smtp-Source: APXvYqy3qZPv7NxVmAgsG8P+5YpErVdVg3oEYNfChcxlHtHFxfOQT0uIAVxdzoD2pqCzf24bVM8CQw==
X-Received: by 2002:a7b:c766:: with SMTP id x6mr27363436wmk.40.1563231451449;
        Mon, 15 Jul 2019 15:57:31 -0700 (PDT)
Received: from localhost ([2620:10d:c092:180::1:d8da])
        by smtp.gmail.com with ESMTPSA id h8sm17918169wmf.12.2019.07.15.15.57.30
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 15 Jul 2019 15:57:30 -0700 (PDT)
Date: Mon, 15 Jul 2019 23:57:29 +0100
From: Chris Down <chris@chrisdown.name>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>,
	Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>,
	Dennis Zhou <dennis@kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"cgroups@vger.kernel.org" <cgroups@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	Kernel Team <Kernel-team@fb.com>
Subject: Re: [PATCH] mm: Proportional memory.{low,min} reclaim
Message-ID: <20190715225729.GA19191@chrisdown.name>
References: <20190124014455.GA6396@chrisdown.name>
 <20190128210031.GA31446@castle.DHCP.thefacebook.com>
 <20190128214213.GB15349@chrisdown.name>
 <20190128215230.GA32069@castle.DHCP.thefacebook.com>
 <20190715153527.86a3f6e65ecf5d501252dbf1@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20190715153527.86a3f6e65ecf5d501252dbf1@linux-foundation.org>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hey Andrew,

Andrew Morton writes:
>On Mon, 28 Jan 2019 21:52:40 +0000 Roman Gushchin <guro@fb.com> wrote:
>
>> > Hmm, this isn't really a common situation that I'd thought about, but it
>> > seems reasonable to make the boundaries when in low reclaim to be between
>> > min and low, rather than 0 and low. I'll add another patch with that. Thanks
>>
>> It's not a stopper, so I'm perfectly fine with a follow-up patch.
>
>Did this happen?

Yes, that's "mm, memcg: make memory.emin the baseline for utilisation 
determination" :-)

>I'm still trying to get this five month old patchset unstuck :(.

Thank you for your help. The patches are stable and proven to do what they're 
intended to do at scale (both shown by the test results, and production use 
inside FB at scale).

>I do have a note here that mhocko intended to take a closer look but I
>don't recall whether that happened.
>
>I could
>
>a) say what the hell and merge them or
>b) sit on them for another cycle or
>c) drop them and ask Chris for a resend so we can start again.

Is there any reason to resend? As far as I know these patches are good to go.  
I'm happy to rebase them, as long as it doesn't extend the time they're being 
sat on. I don't see anything changing before the next release, though, and I 
feel any reviews are clearly not coming at this series with any urgency.

Thanks for the poke on this, I appreciate it.

