Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9CBB2C04E53
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 07:37:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4DA9420881
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 07:37:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4DA9420881
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 955AE6B0005; Wed, 15 May 2019 03:37:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 906AD6B0006; Wed, 15 May 2019 03:37:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7F5F86B0007; Wed, 15 May 2019 03:37:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3685C6B0005
	for <linux-mm@kvack.org>; Wed, 15 May 2019 03:37:27 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id t141so288087wmt.7
        for <linux-mm@kvack.org>; Wed, 15 May 2019 00:37:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Yj9XZyJEigbRqa/osUD7R/GjHPQqzoncrjwPfcCT3g0=;
        b=AgdAk7HX5p8z8GD0FsRPpD9++7nViSqpTUeMqvr3AmQ9lfTg7SLu6YiJjBOghSo1Li
         U+eLk8nus6F0FMeVC8U0+cXzP5yAIrOyRV6AG2KzTJZXjn1GFx5L6O5B7tN6YYpo8VVf
         iPVXFhHxjpY7WjYs2BBSKAob2a/SaYp+FGNwgRHuZKJT+PICNykE5d/6teFCIh8AzJUP
         1XP8PleGg+30LdONEkUKe5s5ECk6JlmVGFPgrKyMV4FsmDYTzXlxxHmbM+Qx5kP0WStI
         dES1p/okps9W6HbBQlFny0rbY3dgEOUX4lky2RRmFFoC4GUVMJXNwlE1H57RgsindzYc
         H2TQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUQy0BpitEEhN4i8qTXFhIqRy8ohtPaKLsKqpU14PwxMo7UdcAN
	FjXNWoHR6Ueig0yfW3gOSehTwgOys9LGGoa3w1APB9M8qD2Db+iw2Uek1VpfcTxu5GCT0PWPGlE
	tUWg55xC1fgLQFe3ddaEgAFtr2iaGPNKDMoHmEvhgZ0zGZgcnQHzf6IbzdvqYEm3iWg==
X-Received: by 2002:a5d:4707:: with SMTP id y7mr846941wrq.59.1557905846791;
        Wed, 15 May 2019 00:37:26 -0700 (PDT)
X-Received: by 2002:a5d:4707:: with SMTP id y7mr846890wrq.59.1557905845978;
        Wed, 15 May 2019 00:37:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557905845; cv=none;
        d=google.com; s=arc-20160816;
        b=TEULyZfHlwAkIlYMvTBwL7VZOC115Vj37swYrtmReSA3o6O3JFwnRHcRuoQJf2Q9ig
         3k12it+aMK717tsE4bZF8q1SkmaPrbGqkKm92I9WdbReA2hzuHe9zZSIZQ+9HK87U6tC
         73g32xZF9L7Zer39WfnwO35zVnCIg/kSHuJ7Pa86f8jgYxSSFK7C8gffBZMeCo05ycAp
         1Vbpg4OvNnWb0HQv58poPssV5J3JMwQuTdrXVv4VUCk1/8+F7+OfqboeKMLKxrsM7GNS
         ZC2y1xE9LBbbo8KvILohbuYFH9KMEY8jzIwpMPabHSFdIcayUWTGNdD+u0ib4a3DmFNI
         mslw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Yj9XZyJEigbRqa/osUD7R/GjHPQqzoncrjwPfcCT3g0=;
        b=KRk7rEnf/2hz/XisFwn9EP1f1qOpiGwTtbb52VTQHzuBZik0ZkGRX3+GCycKR7nb4b
         qDT5JKZPNTEMsyIVLeZOToWWBJrjff4xvahZ/lD3petTV06HXN26TeXNTUqjX9Y39J7v
         CxKdNm3253MgIjQvJ1ebP2UmjCoXzmCReqwWHOPSZ0IkVYK9bh7In7YSkvz6k7B0tCnZ
         qmQ2i8akmAa7Y22bgqfU5hJG+Mb6DewEwEocQqUtMBxV7EqE42znyNCNmLzuSK3XwSyY
         vBPTN1IwYbphWI7r2B5vuWy3Bka0tdJO7SQAA5m8qhK+orQZtToqr7IrF76vUKnPtkC6
         ZuiA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l25sor738161wmc.18.2019.05.15.00.37.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 15 May 2019 00:37:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqy5zHWEswH5rTU3ScYtOdXyuOYlmXMo5vxxHaeTCW2lRo0/VMy/6pvvXOi9nmKf0bD4sOWD2A==
X-Received: by 2002:a05:600c:21d7:: with SMTP id x23mr10334074wmj.87.1557905845417;
        Wed, 15 May 2019 00:37:25 -0700 (PDT)
Received: from localhost (nat-pool-brq-t.redhat.com. [213.175.37.10])
        by smtp.gmail.com with ESMTPSA id n15sm1056219wmi.42.2019.05.15.00.37.24
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 15 May 2019 00:37:24 -0700 (PDT)
Date: Wed, 15 May 2019 09:37:23 +0200
From: Oleksandr Natalenko <oleksandr@redhat.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, Kirill Tkhai <ktkhai@virtuozzo.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Matthew Wilcox <willy@infradead.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Timofey Titovets <nefelim4ag@gmail.com>,
	Aaron Tomlin <atomlin@redhat.com>,
	Grzegorz Halat <ghalat@redhat.com>, linux-mm@kvack.org,
	linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH RFC v2 0/4] mm/ksm: add option to automerge VMAs
Message-ID: <20190515073723.wbr522cpyjfelfav@butterfly.localdomain>
References: <20190514131654.25463-1-oleksandr@redhat.com>
 <20190514144105.GF4683@dhcp22.suse.cz>
 <20190514145122.GG4683@dhcp22.suse.cz>
 <20190515062523.5ndf7obzfgugilfs@butterfly.localdomain>
 <20190515065311.GB16651@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190515065311.GB16651@dhcp22.suse.cz>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi.

On Wed, May 15, 2019 at 08:53:11AM +0200, Michal Hocko wrote:
> On Wed 15-05-19 08:25:23, Oleksandr Natalenko wrote:
> [...]
> > > > Please make sure to describe a usecase that warrants adding a new
> > > > interface we have to maintain for ever.
> > 
> > I think of two major consumers of this interface:
> > 
> > 1) hosts, that run containers, especially similar ones and especially in
> > a trusted environment;
> > 
> > 2) heavy applications, that can be run in multiple instances, not
> > limited to opensource ones like Firefox, but also those that cannot be
> > modified.
> 
> This is way too generic. Please provide something more specific. Ideally
> with numbers. Why those usecases cannot use an existing interfaces.
> Remember you are trying to add a new user interface which we will have
> to maintain for ever.

For my current setup with 2 Firefox instances I get 100 to 200 MiB saved
for the second instance depending on the amount of tabs.

1 FF instance with 15 tabs:

$ echo "$(cat /sys/kernel/mm/ksm/pages_sharing) * 4 / 1024" | bc
410

2 FF instances, second one has 12 tabs (all the tabs are different):

$ echo "$(cat /sys/kernel/mm/ksm/pages_sharing) * 4 / 1024" | bc
592

At the very moment I do not have specific numbers for containerised
workload, but those should be similar in case the containers share
similar/same runtime (like multiple Node.js containers etc).

Answering your question regarding using existing interfaces, since
there's only one, madvise(2), this requires modifying all the
applications one wants to de-duplicate. In case of containers with
arbitrary content or in case of binary-only apps this is pretty hard if
not impossible to do properly.

> I will try to comment on the interface itself later. But I have to say
> that I am not impressed. Abusing sysfs for per process features is quite
> gross to be honest.

Sure, please do.

Thanks for your time and inputs.

-- 
  Best regards,
    Oleksandr Natalenko (post-factum)
    Senior Software Maintenance Engineer

