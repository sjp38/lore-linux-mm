Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 80E40C433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 10:48:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4C21B20818
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 10:48:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4C21B20818
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DD6C16B0008; Tue,  6 Aug 2019 06:47:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DADEC6B000A; Tue,  6 Aug 2019 06:47:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C76256B000C; Tue,  6 Aug 2019 06:47:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7CE5B6B0008
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 06:47:59 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b12so53593650eds.14
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 03:47:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=9l07xguLsmumbO3r6+6QNpZxDkbKD+pBUTJaKO0rO1c=;
        b=fBgkDl8obVarpLbgYSIHda8x5h4r9JMVzgWPOV/G+6n8Nv3uMbkAh/i2A6oujlXJc2
         /1d3yI3Grd1pJq9UNe7fL4oe94M0m5qGTnREXLRbhayyhh6Bc7Yq0KVpDLwfhWwpZEGQ
         mrJOcu14Eu74Di/OprYr60tyMY1iCAhub/GtJUcPD/qKOyQYM8oJfDqFwgfPYsMfhCV8
         kgpCPZT0MiQBjCYI2zWoGFuErR+Tk4nlNMqY5n+3U2PSH9+2HS33/Hry28FCqo/OPoCY
         CKybQd2mtcdvbe6gSlUGsbQzRN4tfgPV2h0DImdroCj07NuoNFgQCdeKcUj8VHcVTjUW
         RUlg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAW90LSfft90H23slNzk6ugyuBqKcfKqJP/mozHTiT3sq4mvWp2m
	dJx0JzjUw4g9qhnGKTSl6fvPyEsGYkCXDknpmxyRXbq/dBiWsmlCKQZ3+efbEr8i5qRRUm5rdJH
	ceAmFBF7RaqaYSLdL3Z7spVyM51v5q8aaDKzMiMPzHrFNZ+BMz+94lOrCwGAzifA=
X-Received: by 2002:a50:f410:: with SMTP id r16mr3108432edm.120.1565088479093;
        Tue, 06 Aug 2019 03:47:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxAZGpPUwg5j9pucwml5izKhwv09+xcqPP8LsyzjzljxrtvyUGFkZGbhVhH8w9E9cv75rTP
X-Received: by 2002:a50:f410:: with SMTP id r16mr3108368edm.120.1565088478310;
        Tue, 06 Aug 2019 03:47:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565088478; cv=none;
        d=google.com; s=arc-20160816;
        b=UFH53FThSuElL3lcHb/p9eGQpnPCztH3wp25YOz7D4GqJ/rYbHhXn9J88uH5ka/7MV
         OjEX0RRm8pYIOUWJBkJ+zY2Wg5A0VkkUVf9maO9f1UGHvPPGqSSvr5wi84Xh8uS4tvQF
         aE6Wvlutk/j03kp3EuULx3O3W3Yq0vCNwonTWkyY1//fJ+hVBTnpgXPwAIvAgH5vK61z
         P5hcf2YJW4BxQ3iVuMdSa+F3y8YfvQ/hPbA8BpurfEW7yGDKZOI5ZCp2GWXPz89POtiW
         T5D5i8f2LGx2Mb/2L/UztK3OFCE+oCfsfg+DN7TioxObgpWZW0I0qngZHaD4rxMcey46
         loNw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=9l07xguLsmumbO3r6+6QNpZxDkbKD+pBUTJaKO0rO1c=;
        b=LkiHdCT9cNOmagWz0SBeyg/KI08Fph/srhUKactN/8VXRrhGxKUJMTXXf6svbob4Tn
         qfKXrhhTjh4Gl1PTWggilz72xe0YHpuau/IgZdHTD0sqAORz+8Gs32hodIekv13Q1/GK
         MBlPzX4wPDk4zFzmsro3pkd/4DVM92ZpAFRbArT/hsBWcS4edPlR51NuKazzP//Qj6qh
         yx1FAkJSWf/gIsuYhPZHWEBL+Oz440zGj3Ya25qPqhgsNt2S99UojNqnusSClmGUdE7d
         4oFSIXCEk2Hj7wBCJzzA4BZ2VxF9CChYVu4S/6NgwlJSfu0gIaaqR+x/H6tJfZHVjkld
         nqyA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k8si30304397edd.67.2019.08.06.03.47.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 03:47:58 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 73D9CAFCC;
	Tue,  6 Aug 2019 10:47:57 +0000 (UTC)
Date: Tue, 6 Aug 2019 12:47:55 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Joel Fernandes <joel@joelfernandes.org>
Cc: linux-kernel@vger.kernel.org, Robin Murphy <robin.murphy@arm.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
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
	Roman Gushchin <guro@fb.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>, surenb@google.com,
	Thomas Gleixner <tglx@linutronix.de>, tkjos@google.com,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Vlastimil Babka <vbabka@suse.cz>, Will Deacon <will@kernel.org>
Subject: Re: [PATCH v4 3/5] [RFC] arm64: Add support for idle bit in swap PTE
Message-ID: <20190806104755.GR11812@dhcp22.suse.cz>
References: <20190805170451.26009-1-joel@joelfernandes.org>
 <20190805170451.26009-3-joel@joelfernandes.org>
 <20190806084203.GJ11812@dhcp22.suse.cz>
 <20190806103627.GA218260@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190806103627.GA218260@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 06-08-19 06:36:27, Joel Fernandes wrote:
> On Tue, Aug 06, 2019 at 10:42:03AM +0200, Michal Hocko wrote:
> > On Mon 05-08-19 13:04:49, Joel Fernandes (Google) wrote:
> > > This bit will be used by idle page tracking code to correctly identify
> > > if a page that was swapped out was idle before it got swapped out.
> > > Without this PTE bit, we lose information about if a page is idle or not
> > > since the page frame gets unmapped.
> > 
> > And why do we need that? Why cannot we simply assume all swapped out
> > pages to be idle? They were certainly idle enough to be reclaimed,
> > right? Or what does idle actualy mean here?
> 
> Yes, but other than swapping, in Android a page can be forced to be swapped
> out as well using the new hints that Minchan is adding?

Yes and that is effectivelly making them idle, no?

> Also, even if they were idle enough to be swapped, there is a chance that they
> were marked as idle and *accessed* before the swapping. Due to swapping, the
> "page was accessed since we last marked it as idle" information is lost. I am
> able to verify this.
> 
> Idle in this context means the same thing as in page idle tracking terms, the
> page was not accessed by userspace since we last marked it as idle (using
> /proc/<pid>/page_idle).

Please describe a usecase and why that information might be useful.

-- 
Michal Hocko
SUSE Labs

