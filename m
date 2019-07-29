Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8B336C433FF
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 15:44:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 50DDC2067D
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 15:44:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="xtfjplAv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 50DDC2067D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E366E8E0008; Mon, 29 Jul 2019 11:44:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DE7AE8E0002; Mon, 29 Jul 2019 11:44:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CD6F98E0008; Mon, 29 Jul 2019 11:44:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 849238E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 11:44:26 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id g8so30286853wrw.2
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 08:44:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=qErB5hAyr+6D1ok8s8gYAwp7NlEM0ZUbJetryLu9lfI=;
        b=NN7/xAmoLsonHcYqTBbA3NiMUY+uVrSNNdKGWJI31ItwkxEe/E2XqC+fz4XYPIW6Wz
         LWhCIQhMRYEB2Cb5E1oznZstt1B9MfwFxSIDSzaAHKU7VbIBWQ8+Kj1ZBdNH2sE61HZh
         juQZ8FIyJvw3fttz9hqmbc+Wn6W/Pr+Q1SA48531fpyowq3u4CTcwkx0ca2g/iBR27uH
         2la2GbySGfuEB4A1paqx/du3Pq0vq3Yx0Y8ao1WzQXu2wInJ9pHff3W5hmcWUsN5m1qW
         lMMb0rpBtNkBO+R2B0JCwaHaqTi+SX5Ld5yfG6sDXcspnZ1ip73rjXp4EXd2BveMVhFA
         NAxg==
X-Gm-Message-State: APjAAAU9kQX6R+5W9qdhD+7EfH1LUBPWfmJgdngZFTz3jiCTv3ON1Ivl
	8qzL4ocCaGhNMosQg8cFDk94nk2o5BJtXCEVTWB1+lLaYkJ+Si0STsCR1C/riWj/1QFgMoEGnKn
	2yOWeibcsIh4GY7L+m314kkCp4N8+w2FZoGP8hp1tLhnR+cqB4jYQAua/oYJ0x9WPPw==
X-Received: by 2002:a1c:2015:: with SMTP id g21mr98247799wmg.33.1564415066122;
        Mon, 29 Jul 2019 08:44:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxpvwwlAPWZKBwXILhNVSMtyRs/1m2m5+TEhi6wbuLiwXMqfoNatUsEQj/qauRurfn6Zaa5
X-Received: by 2002:a1c:2015:: with SMTP id g21mr98247763wmg.33.1564415065414;
        Mon, 29 Jul 2019 08:44:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564415065; cv=none;
        d=google.com; s=arc-20160816;
        b=FvlyjasTLPc0CcfwMsme/W6oasBE7gBqU/2zDjyXGG8O/48QCs5/h3KLbjWpbFFJdJ
         ZRsn4BXc9pV1o1TypdfeTCl32NV7T0N8aKyKCjUEVIfv8sRggg03G4ETFpqbqp6OCGL9
         vhCMZ5r07dUlSg6AQKyN9l6dmh5AD0izFtTB6vrlKlQO/J481d7hShPZwjnMGOZukbrG
         WCuKgxNKNGxJroDEwb/6kznMwWNou9KQJFvPweCG+YJH7atNGFODQ5Y1ipK37JJZ9U2s
         H2ySvxE3dCvVNEzzxh/0csfZZEvn3lJ1gHwq4N3QFvpv8yCA6b3EiEuxol99/VIh0gAS
         r9Ww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=qErB5hAyr+6D1ok8s8gYAwp7NlEM0ZUbJetryLu9lfI=;
        b=BrTDN798hoYAjPEqPfUd/A22CofirhSj1mKdwQU6gEaY9zxU5IBw9Ci6OFCjHFqwon
         gncofZz8CrCFXp4Qclw+jMVuoCNlYKi2pLqKn9X+4vfDUAauwh75BLYaLPiIxLpBlD68
         QeLtAko5hpVBg2kVOhXiM7ty4mS1Vc6MqVF3sV+mYv0EW8nFpsWf4xTdF5KQaGUAXrJx
         6YSyLjz+XN6svVGC0prAlmkAinrfIQJVchm87MOnqfI3hrygXIFF+UGeSZIqGQVcepH7
         0+aVUGDA7lBqkxAMWSYlCZspMVh0U21mf2nQgRTqKbGNQUdrunLTu4vy1EowJa5bSGeG
         zniQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=xtfjplAv;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id m13si56912519wru.8.2019.07.29.08.44.25
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 29 Jul 2019 08:44:25 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=xtfjplAv;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Transfer-Encoding:
	Content-Type:MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:
	Sender:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=qErB5hAyr+6D1ok8s8gYAwp7NlEM0ZUbJetryLu9lfI=; b=xtfjplAvplgj8E7ZbGTMOZ/Xfe
	X7BDyj9GfttyYNCU9AOypvshDqSYZTru04BNEExlfrvPcdD+e7aDw/83uj3n1uL0IuBhszUN3Hv49
	7qjpvBxQKjlsU4TWhIRJqBjU8MFYrhHW58v0gf6gFRNqd6foy/7NCCxUMYtCbgFndhUpfR3JLo9fF
	gt+Arzhzdkuu3ajbMxLZXv7xisD5kPPPqbJyM6A/eU639MecKRngik0KgdHmrd/GlusUrN4JeHkiD
	OcbpYBeg+bDKZKPPAWXkhERkBsUe3pAHjVvwkhGjEVGGN0uqFIJNPy3mU8B2X2mpzpN+F3H6RzX26
	7g5MHmfA==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hs7p0-0003fc-8q; Mon, 29 Jul 2019 15:44:22 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id CD26120AF2C00; Mon, 29 Jul 2019 17:44:19 +0200 (CEST)
Date: Mon, 29 Jul 2019 17:44:19 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Rik van Riel <riel@surriel.com>
Cc: Waiman Long <longman@redhat.com>, Ingo Molnar <mingo@redhat.com>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Phil Auld <pauld@redhat.com>, Andy Lutomirski <luto@kernel.org>
Subject: Re: [PATCH v2] sched/core: Don't use dying mm as active_mm of
 kthreads
Message-ID: <20190729154419.GJ31398@hirez.programming.kicks-ass.net>
References: <20190727171047.31610-1-longman@redhat.com>
 <20190729085235.GT31381@hirez.programming.kicks-ass.net>
 <4cd17c3a-428c-37a0-b3a2-04e6195a61d5@redhat.com>
 <20190729150338.GF31398@hirez.programming.kicks-ass.net>
 <25cd74fcee33dfd0b9604a8d1612187734037394.camel@surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <25cd74fcee33dfd0b9604a8d1612187734037394.camel@surriel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 29, 2019 at 11:28:04AM -0400, Rik van Riel wrote:
> On Mon, 2019-07-29 at 17:03 +0200, Peter Zijlstra wrote:
>=20
> > The 'sad' part is that x86 already switches to init_mm on idle and we
> > only keep the active_mm around for 'stupid'.
>=20
> Wait, where do we do that?

drivers/idle/intel_idle.c:              leave_mm(cpu);
drivers/acpi/processor_idle.c:  acpi_unlazy_tlb(smp_processor_id());

> > Rik and Andy were working on getting that 'fixed' a while ago, not
> > sure
> > where that went.
>=20
> My lazy TLB stuff got merged last year.=20

Yes, but we never got around to getting rid of active_mm for x86, right?

