Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 82C7FC43381
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 21:11:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 37DEC2147C
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 21:11:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="dcva41yz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 37DEC2147C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B1D668E000E; Mon, 11 Mar 2019 17:11:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ACA9B8E0009; Mon, 11 Mar 2019 17:11:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 993208E000E; Mon, 11 Mar 2019 17:11:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 72CBB8E0009
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 17:11:28 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id p40so324252qtb.10
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 14:11:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=smMkHZ9JhQfb6/mQRtbcBe+zcweWT3OeKffPkYTaNks=;
        b=FdVNsvA8TM5q897GulJnkHoWkLDqlyZSpsdngUqMPb29gN7GfvgJ52wLqW0Ouf/SId
         xFbuVuaJJ94PXLw9Y87HJZqWEb4n5NbI8XQNOqZKf6O9pudtofa/gPC/l7S4YDanzK//
         hpD4xsvHzlZO83EN26MABl9q3haP7jbNjalCfIVUrGYv64MKniGkwH/vdh+58xNsKVVf
         jURwcuJektj0eQBtjk5ORiSY4h9onpjoU5GgZF4kVrEBoDQ+ux2zVfe7jgcL0cqr3Xa2
         kCm9ScejVikjr9dr4dQSzul7kEWC4/Q5NA0Y9ZgesZj776n6vnOj5D+WU0A4VZuxYZoa
         NboQ==
X-Gm-Message-State: APjAAAXgY2EyZl3M/R7TZWrw2sZhFCROXp5nLAmidSRUF6SfL7bof/ll
	JPvX+D8cI24r5YRMKXFJDN5CetjAw1mA13ksOVTL+EMBiUcAxiL5bfLMjC0OZwkMo3lpX1BKYdb
	E7TAoWlT2Z1A7DRt4E/L18sN3DZlUMQyT9J0lVGRMVzuFuLT13eiCnmehE/rq/x7Xgq4zHa+iPM
	Uo0Y5m6GvO1SYqCyDW92vtmhVAvV7lJjoxpslN5dHW1Let+sYNcwlmh5hc5sDxYhEoxNsmc3DeL
	CPIZZjUbdvrcjuQ2BJM2sdobS/SBWPOkDwgzCgKHfDxsIhsKUpUP32cg+IShyO3B5w9zC/YwCJg
	w9owUZynIN0rgSxKw/NRmw3Wgwu2ciqqv5i7hF2zwdWU7qFkFGiVtPJ82zQiQtRoEXQOg7tCzkV
	v
X-Received: by 2002:ac8:3f3b:: with SMTP id c56mr26643500qtk.81.1552338688246;
        Mon, 11 Mar 2019 14:11:28 -0700 (PDT)
X-Received: by 2002:ac8:3f3b:: with SMTP id c56mr26643466qtk.81.1552338687539;
        Mon, 11 Mar 2019 14:11:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552338687; cv=none;
        d=google.com; s=arc-20160816;
        b=yViT7aEvOxvhHSVS8ViEkGctAvUUGFV1ozXFG+7uOD3E8PaEqWULZVhxHgxM70o85i
         3mLfLuXbog0mP9jVONdN2e5t3j6WzYoo+LbMzZe6p3lf6PtCZE5TzN/04TX8nvxFpkfB
         BAJ6QRs4uuLMWXediJ0aHkgxG4fzj1YvdHG/IT9QEV9zyZLQCUcixGPmJlZh/B865U1C
         oBayc3iWQPPnlWuOZq2XC21SaS/VR9C/sz2dgJKEWpIwP+/1/AuilJxSCoRgrbXrrqYD
         bm08zvw6m0aPLaozOnyfDVYmMYzHe+ScC5m6oGxjbE303sdD2Yd1UqQmC+rDku26AI+V
         2lxw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=smMkHZ9JhQfb6/mQRtbcBe+zcweWT3OeKffPkYTaNks=;
        b=zoVhlf7TH5UvWblSG5qNanebl++HH2vXQHstV2lBzaVKCMTCa+BKBTBqRRe7Vqaozs
         a+R0LnMr2bFCE2BwoFTbHRCLcKysUmHiGA3dYTZRqY+add/sKEZZs8ZVtWofsDD3CjQL
         OAbFl9SoHzpRN59e+RRNXUrfM1Wzt5m6XgYWhHopvePR3oWW+4gcsd2qf4JPooY7Tar3
         b3HNYycBWyNdRTBm89H93UlzBI8b6lkX6wtp96MFZYDRFiRlAvt80etaw5v7tmRsYTXi
         6hdj17XxNJXiETimc1myKzOYMu9300VO3W3vS7OabG9+qM53k4kZ01OIpqm5H0Whi0E+
         IR2A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=dcva41yz;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e63sor4006113qkj.30.2019.03.11.14.11.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Mar 2019 14:11:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=dcva41yz;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=smMkHZ9JhQfb6/mQRtbcBe+zcweWT3OeKffPkYTaNks=;
        b=dcva41yz79DBmbxdi62q2hDd5KunjFFVwMtEIXhRo0y2Ob9tWcI9vUYahMLSc2agDD
         1hVJvgi6SbMGAEJn2gJnoB0nWZNwX2j2ZGvATle39540M+XyP4qwocsJZhcn6YUCTxsf
         xEis5Uz2pqJHVnokDUmexoOV/bVauBtGu8a30=
X-Google-Smtp-Source: APXvYqxhPuKNd77/mnrTTLYNW5WlEYXalbibNjZXhCpLFMDWnTiPawwwmi+VCuY3bg9ERhA+zqSbJw==
X-Received: by 2002:a37:378f:: with SMTP id e137mr26822049qka.137.1552338687026;
        Mon, 11 Mar 2019 14:11:27 -0700 (PDT)
Received: from localhost ([2620:0:1004:1100:cca9:fccc:8667:9bdc])
        by smtp.gmail.com with ESMTPSA id g82sm3841105qkb.34.2019.03.11.14.11.25
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Mar 2019 14:11:26 -0700 (PDT)
Date: Mon, 11 Mar 2019 17:11:25 -0400
From: Joel Fernandes <joel@joelfernandes.org>
To: Sultan Alsawaf <sultan@kerneltoast.com>
Cc: Suren Baghdasaryan <surenb@google.com>,
	Michal Hocko <mhocko@kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve@android.com>,
	Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>,
	Christian Brauner <christian@brauner.io>,
	Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>, devel@driverdev.osuosl.org,
	linux-mm <linux-mm@kvack.org>, Tim Murray <timmurray@google.com>
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for Android
Message-ID: <20190311211125.GA127617@google.com>
References: <20190310203403.27915-1-sultan@kerneltoast.com>
 <20190311174320.GC5721@dhcp22.suse.cz>
 <20190311175800.GA5522@sultan-box.localdomain>
 <CAJuCfpHTjXejo+u--3MLZZj7kWQVbptyya4yp1GLE3hB=BBX7w@mail.gmail.com>
 <20190311204626.GA3119@sultan-box.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190311204626.GA3119@sultan-box.localdomain>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.011731, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 11, 2019 at 01:46:26PM -0700, Sultan Alsawaf wrote:
> On Mon, Mar 11, 2019 at 01:10:36PM -0700, Suren Baghdasaryan wrote:
> > The idea seems interesting although I need to think about this a bit
> > more. Killing processes based on failed page allocation might backfire
> > during transient spikes in memory usage.
> 
> This issue could be alleviated if tasks could be killed and have their pages
> reaped faster.

But the point is that a transient temporary memory spike should not be a
signal to kill _any_ process.  The reaction to kill shouldn't be so
spontaneous that unwanted tasks are killed because the system went into
panic mode. It should be averaged out which I believe is what PSI does.

thanks,

- Joel

