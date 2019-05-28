Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C127DC072B1
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 18:21:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9580D20B7C
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 18:21:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9580D20B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 11FBF6B028A; Tue, 28 May 2019 14:21:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0CFE76B028B; Tue, 28 May 2019 14:21:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F29356B028C; Tue, 28 May 2019 14:21:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id A6F896B028A
	for <linux-mm@kvack.org>; Tue, 28 May 2019 14:21:34 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id 18so34318902eds.5
        for <linux-mm@kvack.org>; Tue, 28 May 2019 11:21:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=648JJbwQvwAB/uwhXdfmyCLHy3g9zEsmwANnRpUyMfg=;
        b=D2vs7HYjwJ07B8FI0TOsq3zO6TTO9oMwchyeqCVBaSPOiNdWpFvh5/eWFaz7SWITkd
         fBvN2U/DTcfnXIqSrQ+3ykP04DQkI9V0d73Z1xdmk/VhOK/P4eXNTazKMhJS/HK/KV57
         HsEg03X4HMYteyEj0f7NJEVdlE/vT8Ms8NoRZe2iQFvFFjIFCLzO9lonpY3LvPPJ6OAV
         qe8hrK9gpKISvyqLCYZQheYhbUF4b3CjmyAfsDVj6gkv63kZ65qgzPhNU185mKB1xc1A
         4maTHDkLnZc3tHZsxn9zOQgJllQ2jBQPVxs0LqRiBS+IXSK6beRY+CU+xC5bHwAf3ARW
         a5lQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXwFq5tlYA/SLhTBRh6f6mKEzIIxB4TDSEcUtm+RbgEcr59sSA/
	/zCAbEdD1PXXKVuN99ujbm0uHR3OYGAxFouIbvOKHWOmpcYTFUBYiG11iNpoaEpY9gFJcmwoIv+
	S9UDt0WaqzoDuZxdtdHon3FZpF0J9vSkHHSt+BS8xa2/J9KSIIGHWFNhc6jr27K0=
X-Received: by 2002:a50:abe5:: with SMTP id u92mr10539718edc.164.1559067694290;
        Tue, 28 May 2019 11:21:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzjTsjwhPfKiq2jDadV28pcILiFKXADZp7g4t0KQ+AbagkDXtCQ/f7hqJlgUsL+Q7pWomhK
X-Received: by 2002:a50:abe5:: with SMTP id u92mr10539658edc.164.1559067693585;
        Tue, 28 May 2019 11:21:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559067693; cv=none;
        d=google.com; s=arc-20160816;
        b=lU3vS8R99X8XHNVa9GEDjE6Aqd+F0LXM+hxmxLhPj/JHNLbKpa0nNA33v0wQWBoPgm
         810SQ/urO4OIApGf0NbKO9/YIAdng1caTdTzXRV9IUgTqwODhydeuk0RGD4oXC8hKVcu
         kOsLfzrxTt98qNi/DGnBV5OkSGf6JZjyxDWfqQUjvq3rbqTOWan+oetU6RXlqitEHqsr
         ghypvVZ4BUhYY/wf4o1E+U5HeIW1zXRymbcF4n0CCaJvn8hZbdK4/zrK4P6EMHPnwKr+
         wfGsJ1gOJ+TS1xySlFQ4e/afHxQ3nVdEhcqhnqarTV0gIwtLHo22+GJqVTSQUJXq1esG
         Aizw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=648JJbwQvwAB/uwhXdfmyCLHy3g9zEsmwANnRpUyMfg=;
        b=MVaLBis0Wsy68I6Er66LPHpPIKOQGSQ6uhWlKkkM3eZig3g+vc6WUyl56pxNleAI1I
         h0HV1BUgGpANaCrWSG7jShS35KzvBuyXpCZir5N2oWjLPDYT/uj/hvWSe3VidqOpdGb0
         LW4dWQXtVj4RLGgoJxKJRvy33s/HiostTfJtfUorZgaXkFRAT0DMdzdgQy6/vpZtJsDx
         94J49QmULHSftmki2FsMCjXuvIV/iLQ5/bv4b/kvvbfLVZB8/W2vs71hvrfMB5GLzJCL
         LIWSPYjqboZye6tfnxExOW6zJ7xDaWLN976kEuXXnRyQIGnyQ8u/DvqSkIuNX+QeYGZo
         7yaQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v3si9630815edm.338.2019.05.28.11.21.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 May 2019 11:21:33 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 33F7CAEA0;
	Tue, 28 May 2019 18:21:33 +0000 (UTC)
Date: Tue, 28 May 2019 20:21:32 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Pingfan Liu <kernelfans@gmail.com>
Cc: Qian Cai <cai@lca.pw>, Andrew Morton <akpm@linux-foundation.org>,
	Barret Rhoden <brho@google.com>,
	Dave Hansen <dave.hansen@intel.com>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Michael Ellerman <mpe@ellerman.id.au>, Ingo Molnar <mingo@elte.hu>,
	Oscar Salvador <osalvador@suse.de>,
	Andy Lutomirski <luto@kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org,
	LKML <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH -next v2] mm/hotplug: fix a null-ptr-deref during NUMA
 boot
Message-ID: <20190528182132.GH1658@dhcp22.suse.cz>
References: <20190512054829.11899-1-cai@lca.pw>
 <20190513124112.GH24036@dhcp22.suse.cz>
 <1557755039.6132.23.camel@lca.pw>
 <20190513140448.GJ24036@dhcp22.suse.cz>
 <1557760846.6132.25.camel@lca.pw>
 <20190513153143.GK24036@dhcp22.suse.cz>
 <CAFgQCTt9XA9_Y6q8wVHkE9_i+b0ZXCAj__zYU0DU9XUkM3F4Ew@mail.gmail.com>
 <20190522111655.GA4374@dhcp22.suse.cz>
 <CAFgQCTuKVif9gPTsbNdAqLGQyQpQ+gC2D1BQT99d0yDYHj4_mA@mail.gmail.com>
 <CAFgQCTvKZU1B0e4Bg3hQedMJ4Oq2uiOshnsBQCjKinmrGdKcYg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFgQCTvKZU1B0e4Bg3hQedMJ4Oq2uiOshnsBQCjKinmrGdKcYg@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 23-05-19 12:00:46, Pingfan Liu wrote:
[...]
> > Yes, but maybe it will pay great effort on it.
> >
> And as a first step, we can find a way to fix the bug reported by me
> and the one reported by Barret

Can we try http://lkml.kernel.org/r/20190513140448.GJ24036@dhcp22.suse.cz
for starter?
-- 
Michal Hocko
SUSE Labs

