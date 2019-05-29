Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 06361C04AB3
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 05:05:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B009C20B1F
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 05:05:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B009C20B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1A8726B026E; Wed, 29 May 2019 01:05:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 159266B0271; Wed, 29 May 2019 01:05:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 06EC36B0272; Wed, 29 May 2019 01:05:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id AC1116B026E
	for <linux-mm@kvack.org>; Wed, 29 May 2019 01:05:50 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id y24so1409471edb.1
        for <linux-mm@kvack.org>; Tue, 28 May 2019 22:05:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=YL+Pkk8hmtEX6kOEbAMOVKaxsl63VsMPaFNVZ/M/rPg=;
        b=Qmr2PtjFnZyTk0zv/EnSCKHBUlO0nH3L5G9zf2gr4lSzn2gCqWxqcViyzcDp7iq7fV
         h4gje1zIPgN/NQqckL0IY86LDfAB4KJrYmeJD7pLFkmoQKnPP8X5JHWnVNhEuBXM0QCD
         7BJdAXczngzRGk2FikoF5ftmpZufvmC4h4JxvxQvjgDaTeRxfx9l5RmMezQJzqfexcKw
         PZnukJk+0RO/ldQROGSpdPXVq29BLKwVWexqCuDTxeissZO9Ezb9tXU9ZkbWeLanQJmv
         oedaQ+80njAvjhcHlIukmugkKw/ImgCcyMvedCjYETotNhG0xbR7Bq0DoLOIODtfjz0S
         IE0g==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVHcC1QP+xH6QuZNrBvCvM6gmRe5wIj0xMEO7ARfXsWKtaI7Ps2
	8GktLmeYky2EsBG99vHk0ApGFOnv1Zrs0Yrnh6L9omwPFXVUC1jLLbmeiAj4lApO7Io369b9G80
	Uk2BYlhgRApNW6tHAaDsmWYwYGBwDdv2VCAwbM85HC5vs+1VbCnvpEyLaR0OB5BU=
X-Received: by 2002:a50:ba5c:: with SMTP id 28mr54751134eds.238.1559106350111;
        Tue, 28 May 2019 22:05:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyWd1iwpPP8knFRXWY7xHqXH7P//RMqC5T6BvFhc92JeRkLN0t0AZWlb1hxmYupR6WWV5BM
X-Received: by 2002:a50:ba5c:: with SMTP id 28mr54750935eds.238.1559106347803;
        Tue, 28 May 2019 22:05:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559106347; cv=none;
        d=google.com; s=arc-20160816;
        b=KMVqazQYFdrmTLgCGwh0o1BAgXD9iTmI8aWFPsvF0Yrg66TYQVbhxxqUNX1V8IKtMK
         UMTT0Kfv2Bx6SspOUe0ThMpRIxpp+BpHD1BppqKdhtQY+Aq4o2NLgHqaDA9gUE+OHNEx
         gHsK4LLQCuqcGfHjXCo4B/fzbRg2cTQC1Xn0hqtHtANmSnLasCm1iTbhOdySpA4zTi6a
         g+TIv+DOYIqWkdde8/hEOJ3EAjHYQ00DdlPC5WklIPtnQIiil9ed8WbVE8uzO6lAltSv
         D5SdOJVkybfJPPetwopRGSv2Xr9HMynYdBZoK4C3flSBTl/E3ZGWjwFEQ+g/baAe6UYy
         zeHg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=YL+Pkk8hmtEX6kOEbAMOVKaxsl63VsMPaFNVZ/M/rPg=;
        b=jwDE59Ow9uOR/a0b718gJJWqJk43CSB/fAQPVSSgqylm/qTs3WvY+eJd3j4XOL4d+E
         YmNGUR+FxpwwZTEP2LKjmjppEsIUaswLCo1qvfRSk7g2ktzXI58s9O4A9Q/L/4LB67R9
         QPOC/JxLBe3RaZkvyMEWmGw+N9c4hxb7foIt2Tfo/Y4gnieCL+n33dzpNQ5YggYZEhFm
         coNCFyFe9J63KCziwWC73/c4uYjD2JFMJ2z5uG8I8Sx7K4iq3CzvEH8UEdI0CSyd1y7C
         n/jTneQfjZuRxV1gziqL8LhFJoPCjnmf5JumwkGQFq6OpjZXYbUbfuGMJ69jA+e28+Qn
         Cx4w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g26si302905edb.410.2019.05.28.22.05.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 May 2019 22:05:47 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 434C4AD7E;
	Wed, 29 May 2019 05:05:47 +0000 (UTC)
Date: Wed, 29 May 2019 07:05:45 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Hillf Danton <hdanton@sina.com>
Cc: Minchan Kim <minchan@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>
Subject: Re: [RFC 1/7] mm: introduce MADV_COOL
Message-ID: <20190529050545.GA18589@dhcp22.suse.cz>
References: <20190529024033.13500-1-hdanton@sina.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190529024033.13500-1-hdanton@sina.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 29-05-19 10:40:33, Hillf Danton wrote:
> 
> On Wed, 29 May 2019 00:11:15 +0800 Michal Hocko wrote:
> > On Tue 28-05-19 23:38:11, Hillf Danton wrote:
> > > 
> > > In short, I prefer to skip IO mapping since any kind of address range
> > > can be expected from userspace, and it may probably cover an IO mapping.
> > > And things can get out of control, if we reclaim some IO pages while
> > > underlying device is trying to fill data into any of them, for instance.
> > 
> > What do you mean by IO pages why what is the actual problem?
> > 
> Io pages are the backing-store pages of a mapping whose vm_flags has
> VM_IO set, and the comment in mm/memory.c says:
>         /*
>          * Physically remapped pages are special. Tell the
>          * rest of the world about it:
>          *   VM_IO tells people not to look at these pages
>          *      (accesses can have side effects).
> 

OK, thanks for the clarification of the first part of the question. Now
to the second and the more important one. What is the actual concern?
AFAIK those pages shouldn't be on LRU list. If they are then they should
be safe to get reclaimed otherwise we would have a problem when
reclaiming them on the normal memory pressure. Why is this madvise any
different?
-- 
Michal Hocko
SUSE Labs

