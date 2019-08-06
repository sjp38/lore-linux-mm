Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 987BCC31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 10:51:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 60ECD20818
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 10:51:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 60ECD20818
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E97736B0003; Tue,  6 Aug 2019 06:51:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E47956B0008; Tue,  6 Aug 2019 06:51:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D36146B000A; Tue,  6 Aug 2019 06:51:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8637E6B0003
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 06:51:52 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id l14so53632101edw.20
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 03:51:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=VBsSFNtcL+N4QoS6rmkdGDQ3ht9M6mQGWdM1yqSruMU=;
        b=S8Q/3O1Ev/EaJJ8M6St0slpxZDQ6LJBUrStRXvn1z8to8ndFEce5QDU5H49P6p9Z1i
         RU2P1OQoSzuhkX83Fouint89Uuqym7Gfd1pRvsc1raW92hnBD6+ttU9tAoYBKTqRaCGZ
         t79scY3NttHkNb1A67eYZpIzec12LOHVm5WLsjhV6TH8rIKFyZU8NaDGVrqvVkPZjaAh
         3nhAUKfXPQ/KNuvfSke/mYCdeqejeoV61XbzyN+j9YMyr62oOey2akR36TohZsaYMjW5
         CF2ysWb4tOPn5OGvT6HEop6y32JvnA6O8l54iWYt+ONKNspP6FtkCLtq0bc8dPlR5IGI
         ISSw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXgd/KYSE4G9pDm1kKZtog7oNzHk76Yc2Z6zPhGEzWCYiqjYaHI
	YiX9zl1CvkkAtZEq8QjgDJtJrmNiySpoI0D9IfDL7qoMQ8wai1bTDLrcuRoAn9qi9HdyFezhlEG
	5jvSxg5ikj0p7Kfg1RDciDcyzdHWkaijiIFDh86ff/vXkEVQIZxjfuJxfprS2YOM=
X-Received: by 2002:a50:b635:: with SMTP id b50mr3022859ede.293.1565088712119;
        Tue, 06 Aug 2019 03:51:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzq1wZ1l6OTgpQC/8KEaODDXtWtOyd5e/lWmoPdF8M82vlOK7cJvr0qtt23z0llEbhv9BQb
X-Received: by 2002:a50:b635:: with SMTP id b50mr3022813ede.293.1565088711385;
        Tue, 06 Aug 2019 03:51:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565088711; cv=none;
        d=google.com; s=arc-20160816;
        b=SRb6oMzFuFoHrtZK4z1yI5xEoEzr20ny5MU7LGXb/862xC2ZN6EASVBF46jVs4Tc+7
         FRGJiqkYUcy8qqWdCtSBAXdE2qWnenyuu7pZBC+68w4v/hFtoDcxRSJIQBS/tocUL3TO
         q1QkEiZH1cvviWsnfdV7fQTzgATY1ab7YHEnqsZPRr09dCejU2bBwHCw/MtI80K4pTWR
         R1q1UxZXB8++bibDbFT/K9vdsPIPvzRixrztUiXkXLalpdty5hc8vYWVJfA/8CraL0yG
         eB5bNC2OD5xJp3DJhOhS26pMKMl2At4cxW7zanOR2mp9f35vy98w+65pXf9sbrAamXW2
         KPNA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=VBsSFNtcL+N4QoS6rmkdGDQ3ht9M6mQGWdM1yqSruMU=;
        b=zBbzjNQV1SkBsOq8IZpfCxnm6l/hB1G55VR7ZvCRkxDVI1pxWxUSjpZfyl2qGE2kSG
         aU8wddG1HrlHjB3IOKUo3YbeLI6hVVQQrVB3dikceeXJEB6iTBiR7EPsyz/6ylYnqeuT
         FBqRG1yALuByK0U0n66N5jhASWc1aAIo2epZHiEcsx3XawCq2RNAWTg/YY5kx+K0UVVW
         xCcWA1QisMliPrr3fk/XWx598jI+bAk0+RrOMNHIcQj1UwoAOXsXYckG++GtUJ7Y6Wff
         92d+7EBXcAd+QB9TMDrLlcKxSog7f29dE2Y92xHWlYdguT6xJYZ5OGEoUOwaXPnBztdd
         ZtXA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id nm5si28090903ejb.223.2019.08.06.03.51.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 03:51:51 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id CF4EBAFCC;
	Tue,  6 Aug 2019 10:51:50 +0000 (UTC)
Date: Tue, 6 Aug 2019 12:51:49 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Joel Fernandes <joel@joelfernandes.org>
Cc: linux-kernel@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Borislav Petkov <bp@alien8.de>, Brendan Gregg <bgregg@netflix.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Christian Hansen <chansen3@cisco.com>, dancol@google.com,
	fmayer@google.com, "H. Peter Anvin" <hpa@zytor.com>,
	Ingo Molnar <mingo@redhat.com>, Jonathan Corbet <corbet@lwn.net>,
	Kees Cook <keescook@chromium.org>, kernel-team@android.com,
	linux-api@vger.kernel.org, linux-doc@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
	Mike Rapoport <rppt@linux.ibm.com>, minchan@kernel.org,
	namhyung@google.com, paulmck@linux.ibm.com,
	Robin Murphy <robin.murphy@arm.com>, Roman Gushchin <guro@fb.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>, surenb@google.com,
	Thomas Gleixner <tglx@linutronix.de>, tkjos@google.com,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Vlastimil Babka <vbabka@suse.cz>, Will Deacon <will@kernel.org>
Subject: Re: [PATCH v4 4/5] page_idle: Drain all LRU pagevec before idle
 tracking
Message-ID: <20190806105149.GT11812@dhcp22.suse.cz>
References: <20190805170451.26009-1-joel@joelfernandes.org>
 <20190805170451.26009-4-joel@joelfernandes.org>
 <20190806084357.GK11812@dhcp22.suse.cz>
 <20190806104554.GB218260@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190806104554.GB218260@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 06-08-19 06:45:54, Joel Fernandes wrote:
> On Tue, Aug 06, 2019 at 10:43:57AM +0200, Michal Hocko wrote:
> > On Mon 05-08-19 13:04:50, Joel Fernandes (Google) wrote:
> > > During idle tracking, we see that sometimes faulted anon pages are in
> > > pagevec but are not drained to LRU. Idle tracking considers pages only
> > > on LRU. Drain all CPU's LRU before starting idle tracking.
> > 
> > Please expand on why does this matter enough to introduce a potentially
> > expensinve draining which has to schedule a work on each CPU and wait
> > for them to finish.
> 
> Sure, I can expand. I am able to find multiple issues involving this. One
> issue looks like idle tracking is completely broken. It shows up in my
> testing as if a page that is marked as idle is always "accessed" -- because
> it was never marked as idle (due to not draining of pagevec).
> 
> The other issue shows up as a failure in my "swap test", with the following
> sequence:
> 1. Allocate some pages
> 2. Write to them
> 3. Mark them as idle                                    <--- fails
> 4. Introduce some memory pressure to induce swapping.
> 5. Check the swap bit I introduced in this series.      <--- fails to set idle
>                                                              bit in swap PTE.
> 
> Draining the pagevec in advance fixes both of these issues.

This belongs to the changelog.

> This operation even if expensive is only done once during the access of the
> page_idle file. Did you have a better fix in mind?

Can we set the idle bit also for non-lru pages as long as they are
reachable via pte?
-- 
Michal Hocko
SUSE Labs

