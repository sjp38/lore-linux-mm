Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.4 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 77D07C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 12:06:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 18E6B218D8
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 12:06:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="lyWkFD1m"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 18E6B218D8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 762208E00D9; Mon, 11 Feb 2019 07:06:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 713988E00C3; Mon, 11 Feb 2019 07:06:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5DC5C8E00D9; Mon, 11 Feb 2019 07:06:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 066B78E00C3
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 07:06:55 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id x3so1525897wru.22
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 04:06:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=HLCHP8NxEDiWe1qBDtN3X/VTCkmbDj2pXwqcT6cfrkk=;
        b=lPluw3UTS//kgRhP9TrIVSDWdDvyvJfeob7gU47d+In7QKpl1gMIeZwfzQEtlMiqWO
         ijRfy/3w7Riq94qi+0qjjBAIzXEoNs3NR6p3lN1jZupc/AtXuv7LfX5QIZ5QWEoaZB31
         moOxe8oNRDcNmEV4L7dqsA6z/zhykrILItlehi/pRAmO/DTyE+ZHOIV+IwC3EZCTz2wY
         nW5hQ0grNdxUE0R1TTsH85LKXTP2Q187dk88s1aL19zvqE60LigcA66DBqRpeZp5hfrf
         Y68s247UWNuOCkvzS1ayINspqvPUvuK8DhAlBOnDbpj5XxVNJU/Q1ksZvTzPdLP95fry
         nR6A==
X-Gm-Message-State: AHQUAua+pPvFM5tq/MZpVh5LkRnRAWXf6NT6bbPxaHTj05Ff82K6o8Qt
	KLIWWwzyBWpe1uaNncpvLH5Covii4KLY3JxbpL3hYG/l8doRfzQklmaMDvHg5dYM/7uhqk/G/dM
	s8YMhY7sjO0SRsAYvi0hFD0b067Q+5R59rDo+CA4iODc8pf5uH47vUUKs5nfODHPnZpOMrUPRa/
	2wnkpv2EiHDblItGxhayLaPmpY2MU2WsBUvwxZrNRjakC0z70k/vYtaTUQcdBnqiPtlXqIodEN+
	d02zgqe1y6QrrHzkBOGh5YaXPPTCrCZc6uUrXjajHxQiOZQpAsqapWARulpRQXdZ1keWn/nmCgg
	vySQZ2nGzvdK2Ji/fPZuiy9XwRsqigrLc2vu2iKWFpaQ66ceVwzUhKL7+rG7GwanJsiIv36VVg=
	=
X-Received: by 2002:adf:ba8e:: with SMTP id p14mr26327581wrg.230.1549886814285;
        Mon, 11 Feb 2019 04:06:54 -0800 (PST)
X-Received: by 2002:adf:ba8e:: with SMTP id p14mr26327527wrg.230.1549886813282;
        Mon, 11 Feb 2019 04:06:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549886813; cv=none;
        d=google.com; s=arc-20160816;
        b=U84Z54OmYQoPHKwwZxf3FV2gU6+6arKVxrFvKLWS/hI/cv//zKe1A+sy7YDaFo9EV5
         +/eQWaWWy8ZI7v2YHOzlMoptbkmguQz2jYLp4qvcnT28XcfWDj4W5dmx6O04QaRxwQ+N
         VvYDaON2TojLbThcywADWhENa5mHvdbuCSulhL8r0VkwGaIjqRFD4qdJeU9ZuwXFsBXu
         keO+AtLYQKrH4FvPTMGaWT4xbAicEPA9YK8n5m2/C+K5960s7IXmKpckVdyXmKQOCXUH
         X8kWvxSw/04tgeqblRJzZE3MbsxB8IzmxUeVR2i2DDcZ+N/QFjVOGX7sMgK07YJ5UH6J
         sFfQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=HLCHP8NxEDiWe1qBDtN3X/VTCkmbDj2pXwqcT6cfrkk=;
        b=IDJ1IuV8Xcvu9h08RnUxqnI5niRHcjAyWw1OPBqOaD4lx0H6E35HM5WdGwJDOLg6Cv
         Xbdb+6imc9yjJW1XaF4t94ut5fh/7eqGlruAG2+Ifcn8PsAqmukMS7fLp82O9/sisVh3
         n+AAbomDt9yUdVthBuZmSS5STl8750Mz0ie9PtGZ+esRw1sZ9Xgoya/+cTA7zk1DSc5v
         qJ4nxcz6izfANSaTN243kh+fqmlaIISPyGcTMVBuNz2H90OVBa2XXUtYoiHaB5blTqmj
         J+YMoi7o9hTlKEfxNT/uygpuqEOMZM9e5Xw0elrw5Bf3JyAG+1QPuVZSxraHxHIQnr2S
         HUCA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=lyWkFD1m;
       spf=pass (google.com: domain of mingo.kernel.org@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mingo.kernel.org@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l17sor1383076wmg.10.2019.02.11.04.06.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 04:06:53 -0800 (PST)
Received-SPF: pass (google.com: domain of mingo.kernel.org@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=lyWkFD1m;
       spf=pass (google.com: domain of mingo.kernel.org@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mingo.kernel.org@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=HLCHP8NxEDiWe1qBDtN3X/VTCkmbDj2pXwqcT6cfrkk=;
        b=lyWkFD1mdYdBRQGgOh8Li5uFNQG+1vE59V7ojuFhwFzEis+bzFRPAeQP/TgtmAwceE
         b6+3UwhOowm947z3q7ACbc4C5UfmmiQjvusQjRsb3ocZCTHKIxMir0lCBuH/4+8MCRu0
         h1lWSNmqHeYC4vXlbbTB0YZmUxZx/Q7adX/Swh43WngYauYhw0KNsv2BzXhap2FhyBW0
         KJ5UV4J26o6Zi3lBOr/9eYDMeMdbZIdoEloShg8YRVh52LxAvR3IKeFD4WfvHZlSO1G8
         T6dBSrGkiNT0THIvZSe3dKX8Ncdmp82AHVssMk4PxG2kmrTVeezxmXaKihhT9RkBW48M
         /dQw==
X-Google-Smtp-Source: AHgI3Ib+lDwmvVxBgv6HhkEOcg9cDaSIFcNQ+qwueukAhaQ5mZhJGXO8pSI2GqGFlDEGS3AK9OoUMw==
X-Received: by 2002:a1c:7dd6:: with SMTP id y205mr8607793wmc.121.1549886812729;
        Mon, 11 Feb 2019 04:06:52 -0800 (PST)
Received: from gmail.com (2E8B0CD5.catv.pool.telekom.hu. [46.139.12.213])
        by smtp.gmail.com with ESMTPSA id v132sm12245695wme.20.2019.02.11.04.06.51
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Feb 2019 04:06:52 -0800 (PST)
Date: Mon, 11 Feb 2019 13:06:50 +0100
From: Ingo Molnar <mingo@kernel.org>
To: Juergen Gross <jgross@suse.com>
Cc: linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org,
	x86@kernel.org, linux-mm@kvack.org, boris.ostrovsky@oracle.com,
	sstabellini@kernel.org, hpa@zytor.com, tglx@linutronix.de,
	mingo@redhat.com, bp@alien8.de
Subject: Re: [PATCH v2 1/2] x86: respect memory size limiting via mem=
 parameter
Message-ID: <20190211120650.GA74879@gmail.com>
References: <20190130082233.23840-1-jgross@suse.com>
 <20190130082233.23840-2-jgross@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190130082233.23840-2-jgross@suse.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


* Juergen Gross <jgross@suse.com> wrote:

> When limiting memory size via kernel parameter "mem=" this should be
> respected even in case of memory made accessible via a PCI card.
> 
> Today this kind of memory won't be made usable in initial memory
> setup as the memory won't be visible in E820 map, but it might be
> added when adding PCI devices due to corresponding ACPI table entries.
> 
> Not respecting "mem=" can be corrected by adding a global max_mem_size
> variable set by parse_memopt() which will result in rejecting adding
> memory areas resulting in a memory size above the allowed limit.

So historically 'mem=xxxM' was a way to quickly limit RAM.

If PCI devices had physical mmio memory areas above this range, we'd 
still expect them to work - the option was really only meant to limit 
RAM.

So I'm wondering what the new logic is here - why should an iomem 
resource from a PCI device be ignored? It's a completely separate area 
that might or might not be enumerated in the e820 table - the only 
requirement we have here I think is that it not overlap RAM areas or each 
other (obviously).

So if I understood this new restriction you want mem= to imply, devices 
would start failing to initialize on bare metal when mem= is used?

Thanks,

	Ingo

