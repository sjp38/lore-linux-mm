Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5DF00C282C8
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 16:12:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1AEAA2148E
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 16:12:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="N90p1wmW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1AEAA2148E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AC8698E0007; Mon, 28 Jan 2019 11:12:05 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A77488E0001; Mon, 28 Jan 2019 11:12:05 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 93F548E0007; Mon, 28 Jan 2019 11:12:05 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 651E08E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 11:12:05 -0500 (EST)
Received: by mail-yw1-f71.google.com with SMTP id h3so9790454ywc.20
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 08:12:05 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=7sNEoit16a1lvfySq1HM53gTpeolqrKjGi3YRhbkM6Q=;
        b=AMMJ/lXdg0QPkTjs1Zj5AjuqyIzauW/luaKZ+hDCxRizTsLErWZRotWUS2iNh/CiMc
         tnI+oej0vIb4Q1MjUHVA+MNtzp6GE92HiODoVwhZXjGmedXCR2N9jVOM+01BMQVelSta
         JkJms6W2vnfaAjjedfLBfkuXOPLbnUooc74xig7LEgrajAuLm5157H8fLH8SlkD0wjC2
         hbUi6iH2wg6SbUTemmcHAZOTtkRllpZoibPJWjsskEdkB4AjkjQfQUttDJ+LedtIyK5L
         mewKR5Easm57vZQURRGIoHtQus0Q4iHMj/AmL3STYD8AKKf1tpG/9CLwHpJRfbneYb32
         SwJw==
X-Gm-Message-State: AHQUAuYJvw/DYfu4f6QoquoeDNj7MYM/zi1KlGPYMCk8vJKkE1pnF4MF
	bm8c27GnTnpyofrKTcppcO0SnUc49o94kPYS/KogR1nvgbSsCX0sdijTI6U0HWUX5RE6w5neFXk
	hJWUZIZgceHw5gtaShAvRhiEmk5irDPpSt0oVt6p881oiMycsWPr1/6bSfAYrHYihR3coIn0nt1
	1oq5srdHzVBoJ9IjBnjL+cZKgymnmELjK5sOtY07d9/KmIQ89nHHjOH+yxG6bzH9DDWTwvvzfrT
	HFHXz7GkGQ10Q82dNh7nXBK+AB+hbfviAj38c57GP2nKqpqB15mjpNlM+wLM2ZuIHRPgop9rH9E
	qQq45XyCM9IT6epQN0K/BBXCiYZASt2BaJXpHDLe9Qy/WHwwfSFCe7+Rl34DnsMBYyHc4hnUiA=
	=
X-Received: by 2002:a25:508f:: with SMTP id e137mr8765975ybb.397.1548691925191;
        Mon, 28 Jan 2019 08:12:05 -0800 (PST)
X-Received: by 2002:a25:508f:: with SMTP id e137mr8765923ybb.397.1548691924621;
        Mon, 28 Jan 2019 08:12:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548691924; cv=none;
        d=google.com; s=arc-20160816;
        b=o+360/e+VGA9odHnTfZJEqL/W5zeHfCtEjVH+XbadATyk0e1e9nHTBJF0vFvTrtuV/
         9Qpp3RgTGfRxxtUz9fKAB6z1KU+6blpdai+ZG1ROr09+K4XXBBH3h4OBJi/7dnWbjI6f
         OL++t8EV1EhBKK8YSJDl397Kx/uaG1BcrP5PHcjKz6RsefuTSsMF3VbBXf7ORrpH24dM
         rOfruMqoLyH7awws8gSB9b+kUQ7clfh3GgX9AeKsQtpsrbuCppFNk2TlIo348cLX/zeO
         5nbX0STXrmHSY6knNTDR6HoEewCbbbN+PsM8MW6oLOQnzBTs5o3E+Ew4om6f7iZvIfYu
         Enfw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=7sNEoit16a1lvfySq1HM53gTpeolqrKjGi3YRhbkM6Q=;
        b=WB/ZgmG71Do1gLftdJELgMklEnFknPj8u05FHTvFyYSySYzFPJ7uCbmrsxIKD8C5Vw
         1/seJ52v0ADltp1BmW179EV8OtqJdjeEonCXap5OvIWtFbL3dHbqHv924DB/wHcT3Z32
         fzZEClhT0bzWPfGwcNHSXi+hlLh1Ni/6Qcd6WTHBy4+4cmhPTNHeYA82JPnDSxVwZu+Q
         vIUJpBwQF3mlh5vnGvpvp95IL6I6l6Hf2OxHd5WMmmnt/qMKlmBjcxbjkyECQ9IfCdm4
         nqhp9A6gYvj9XLfv1yq63KaQjLg9bHN+wdNzI3mMR4oKu5PD1j3VKJoR/yADFGXAD5CI
         zh9A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=N90p1wmW;
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e126sor13628828ybe.121.2019.01.28.08.12.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 28 Jan 2019 08:12:04 -0800 (PST)
Received-SPF: pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=N90p1wmW;
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=7sNEoit16a1lvfySq1HM53gTpeolqrKjGi3YRhbkM6Q=;
        b=N90p1wmW4Un144OHxTHB5bvyZ5q/P+Lb2PmLPmP3xl0nWZc/2QzaTCdkYnYkEDkSjR
         /wVrIvuYPhgsil8RMSYQPfptenZOa4gH322FL6/QQm6MLnhHPKwMvD2oK3LRE0gz4ghx
         LzhQs5Bf74L2OMermppFrL9suvGVTfnVbTtFo9/wY0lCqd7Bi5G7dGkWnDKKawjjd2eg
         c+CFgIeHtz1/fiEOj0dVxBv90ZoFn+XJQu1/1cj2xnAFrhS/SDeO7diQv9pERyfezrfG
         EvA7wPnpUWP7uOjYWjx898TLBGwk7gz/ttcXi/m5IQpgc4yKFv+zulskjicwe8WIA7Na
         ZTLQ==
X-Google-Smtp-Source: ALg8bN6dvRl+QxHCM6Kj5WM6BZyjvyc+4dFpQje6jXxC06hFR/M08ci81YWpJG2aqEcvxS6nTvkWSg==
X-Received: by 2002:a25:d8c2:: with SMTP id p185mr16000278ybg.79.1548691924215;
        Mon, 28 Jan 2019 08:12:04 -0800 (PST)
Received: from localhost ([2620:10d:c091:200::7:a62a])
        by smtp.gmail.com with ESMTPSA id l7sm12308964ywk.24.2019.01.28.08.12.03
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 08:12:03 -0800 (PST)
Date: Mon, 28 Jan 2019 08:12:01 -0800
From: Tejun Heo <tj@kernel.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>,
	Chris Down <chris@chrisdown.name>,
	Andrew Morton <akpm@linux-foundation.org>,
	Roman Gushchin <guro@fb.com>, Dennis Zhou <dennis@kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Cgroups <cgroups@vger.kernel.org>, Linux MM <linux-mm@kvack.org>,
	kernel-team@fb.com
Subject: Re: [PATCH 2/2] mm: Consider subtrees in memory.events
Message-ID: <20190128161201.GS50184@devbig004.ftw2.facebook.com>
References: <20190124160009.GA12436@cmpxchg.org>
 <20190124170117.GS4087@dhcp22.suse.cz>
 <20190124182328.GA10820@cmpxchg.org>
 <20190125074824.GD3560@dhcp22.suse.cz>
 <20190125165152.GK50184@devbig004.ftw2.facebook.com>
 <20190125173713.GD20411@dhcp22.suse.cz>
 <20190125182808.GL50184@devbig004.ftw2.facebook.com>
 <CALvZod6LFY+FYfBcAX0kLxV5KKB1-TX2cU5EDyyyjvHOtuWWbA@mail.gmail.com>
 <20190128160512.GR50184@devbig004.ftw2.facebook.com>
 <CALvZod5Rrr6ENW5yLNzniFeFmGB=mDRH+guNLmcayTX-_xDAGw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
In-Reply-To: <CALvZod5Rrr6ENW5yLNzniFeFmGB=mDRH+guNLmcayTX-_xDAGw@mail.gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190128161201.N4kYBPBs_mnZz_x5sidnGOWv50U7-fcwiPdUzlEKi6U@z>

Hello,

On Mon, Jan 28, 2019 at 08:08:26AM -0800, Shakeel Butt wrote:
> Do you envision a separate interface/file for recursive and local
> counters? That would make notifications simpler but that is an
> additional interface.

I need to think more about it but my first throught is that a separate
file would make more sense given that separating notifications could
be useful.

Thanks.

-- 
tejun

