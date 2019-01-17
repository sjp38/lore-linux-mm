Return-Path: <SRS0=SJ39=PZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A98F9C43387
	for <linux-mm@archiver.kernel.org>; Thu, 17 Jan 2019 16:25:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 70E1720851
	for <linux-mm@archiver.kernel.org>; Thu, 17 Jan 2019 16:25:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 70E1720851
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EBB3D8E000B; Thu, 17 Jan 2019 11:25:43 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E6B838E0002; Thu, 17 Jan 2019 11:25:43 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D81288E000B; Thu, 17 Jan 2019 11:25:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id AD75C8E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 11:25:43 -0500 (EST)
Received: by mail-oi1-f198.google.com with SMTP id u63so3512505oie.17
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 08:25:43 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=E//4eBJBqqAWyVDqY++P+ol3f8CvDIv+MgsFQ4gxZrI=;
        b=gH6LKK0xkQFzBegdRpZZbbKnv1/dFcRRBKajPbDIttLnjHsEk9sqKZWN+wAX7eaVhl
         McbjrYiTYMpehO302GecGoeLVJtuDR03OZsylQ6jS9+w9LhQZnv8i9UaTf3gMZEfN88/
         U/KNr+gPJmYDYtK0WbOTkMk1K0wYv0upg107Z6hFmeTGKSi+Xd/lTrQOoX1Wdw9Yw0e6
         Q+yQzOylEeM8HvRz8cvo1dQGmo6UNZdXujXuAoeJufA0jfAuIRJci8IscaKGbwfhQ15Z
         BRYIMy8J+CVHMYaSUptM8fNxib2bnAlybUgyqa02QsUAJ0FI7bt2o4E3aTw4c9DgC8ez
         5wsA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukehWNq5GDsb/JKp7HNOtO9YJQJijNZEJ5pk6FH2itheZAnokNG7
	HRVfASvZAMtiBdxwvw+aJNByqE9z2E9kLgFa/l3j43U8205X1xNVnJIKRvZuGbCBLI9rz2GnK7L
	U8xZl0aH3s/3RcPNDConXTsl7gfOJEdApIexoQm0BK3tyHzgFQahv1Bly1AFBemctf/L/zbQ24y
	N2dqFNqRn6zzYMjQQSo/NBlbljvAayZ/tVu6ym0s6kxtlH7bn8qb7pZYAZ41BSsh/dC7yGLA2eg
	flpEJgzkOtv+9SHRwFx0SqqY4Ed6faum8dEchmcfBRjhXz6ciSPNngJqD94PKx/MChiUVY+FzgG
	lagolsW33rWh9Mjqy8xDqQ1Jc8W0foXYWQy3vgC6aQzYC+P3RI8WWJnQWcjhUPc4BbfK6Gbg1g=
	=
X-Received: by 2002:aca:3506:: with SMTP id c6mr8406330oia.65.1547742343343;
        Thu, 17 Jan 2019 08:25:43 -0800 (PST)
X-Received: by 2002:aca:3506:: with SMTP id c6mr8406296oia.65.1547742342593;
        Thu, 17 Jan 2019 08:25:42 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547742342; cv=none;
        d=google.com; s=arc-20160816;
        b=yHWXpp3BCVKFsXx2N7l82HLd7xnsKQ2Qs0Rpn2BgPQVtzHzIKlSG9uHsJWoYkCteTR
         84xtgtqwz9WNaE9E1bWk1uIFaUFkjB9lkNbnEx1r0iFiNhkR1ZIhe/LoLGU0/ZonpsDp
         ujZEjV0loPu438pfEketxINTfSoVgebn/pcyZ8heeO89b33ymLrjwrGSh+c6oM9K9e1R
         HyTlEHmd0j6ee860ey649a86eEOFIyDJkbQhmB7fptf3jSR/Gtfz8nxv7iT7n7oTspZ2
         AwYG2/9/c+KaoQuidXBp2+sWSNXThwvAPojOML/P4Da8qLZIiP9F6ZIKnAhPIfmqVxdi
         L86w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=E//4eBJBqqAWyVDqY++P+ol3f8CvDIv+MgsFQ4gxZrI=;
        b=eKtcMBJDgQJyKijpO21grG4UUkX2ljT/WMK0BilmDoqq+UuPbrDzFj22XT4RNKGAu1
         5Q8CanOCLmtcspIFvvb3bj2bvidJo2Q0aNtXJ+V+ZLKW0tWHGY1kc3szF+EdrcK9Yps8
         G/5joGj9ZXoTXnM70fbk2AJMw74l1FVReUHVBRr9LY3DV7pbX/NhPJbGrodADn5kOWZF
         qST99ZtP2tx4IJ5THaAuosqQ+0IdfuVDZTYoRNDyk5deRK5AyRbZjA0ztBPUlSA41Rih
         ExbdjAYDvWR5hwh9N6E7cbtMUad5Uufs5X0ZK8TiJJl/qyhAxVBBU5i6FOc1WKK593sH
         1Iww==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id m110sor1082525otc.176.2019.01.17.08.25.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 17 Jan 2019 08:25:42 -0800 (PST)
Received-SPF: pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: ALg8bN5cQoDyBKjTUBH4XX90aC0QC8ljsrgq2cm+rOCtUJMhKGrFHk4+xXBVuPjn8+os6Yh9WWe/q2dtTJmLN/9ESOg=
X-Received: by 2002:a9d:60b:: with SMTP id 11mr8855039otn.200.1547742341916;
 Thu, 17 Jan 2019 08:25:41 -0800 (PST)
MIME-Version: 1.0
References: <20190116175804.30196-1-keith.busch@intel.com> <20190116175804.30196-12-keith.busch@intel.com>
In-Reply-To: <20190116175804.30196-12-keith.busch@intel.com>
From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Thu, 17 Jan 2019 17:25:30 +0100
Message-ID:
 <CAJZ5v0hYx_fG6UW+MXfLtdBAyWc_qi4A0h5xVTpTSAbo4ntz7g@mail.gmail.com>
Subject: Re: [PATCHv4 11/13] Documentation/ABI: Add node cache attributes
To: Keith Busch <keith.busch@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
	ACPI Devel Maling List <linux-acpi@vger.kernel.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, 
	Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190117162530.ikQph6tOL-u0m-EENeEmRsWef7Nbg_4YlOe80T4ubbQ@z>

On Wed, Jan 16, 2019 at 6:59 PM Keith Busch <keith.busch@intel.com> wrote:
>
> Add the attributes for the system memory side caches.

I really would combine this with the previous one.

> Signed-off-by: Keith Busch <keith.busch@intel.com>
> ---
>  Documentation/ABI/stable/sysfs-devices-node | 34 +++++++++++++++++++++++++++++
>  1 file changed, 34 insertions(+)
>
> diff --git a/Documentation/ABI/stable/sysfs-devices-node b/Documentation/ABI/stable/sysfs-devices-node
> index 2217557f29d3..613d51fb52a3 100644
> --- a/Documentation/ABI/stable/sysfs-devices-node
> +++ b/Documentation/ABI/stable/sysfs-devices-node
> @@ -142,3 +142,37 @@ Contact:   Keith Busch <keith.busch@intel.com>
>  Description:
>                 This node's write latency in nanoseconds available to memory
>                 initiators in nodes found in this class's initiators_nodelist.
> +
> +What:          /sys/devices/system/node/nodeX/side_cache/indexY/associativity
> +Date:          December 2018
> +Contact:       Keith Busch <keith.busch@intel.com>
> +Description:
> +               The caches associativity: 0 for direct mapped, non-zero if
> +               indexed.
> +
> +What:          /sys/devices/system/node/nodeX/side_cache/indexY/level
> +Date:          December 2018
> +Contact:       Keith Busch <keith.busch@intel.com>
> +Description:
> +               This cache's level in the memory hierarchy. Matches 'Y' in the
> +               directory name.
> +
> +What:          /sys/devices/system/node/nodeX/side_cache/indexY/line_size
> +Date:          December 2018
> +Contact:       Keith Busch <keith.busch@intel.com>
> +Description:
> +               The number of bytes accessed from the next cache level on a
> +               cache miss.
> +
> +What:          /sys/devices/system/node/nodeX/side_cache/indexY/size
> +Date:          December 2018
> +Contact:       Keith Busch <keith.busch@intel.com>
> +Description:
> +               The size of this memory side cache in bytes.
> +
> +What:          /sys/devices/system/node/nodeX/side_cache/indexY/write_policy
> +Date:          December 2018
> +Contact:       Keith Busch <keith.busch@intel.com>
> +Description:
> +               The cache write policy: 0 for write-back, 1 for write-through,
> +               2 for other or unknown.
> --

It would be good to document the meaning of indexY itself too.

