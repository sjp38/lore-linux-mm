Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DA9C3C10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 18:19:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A82A620818
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 18:19:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A82A620818
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4914F6B026B; Thu, 11 Apr 2019 14:19:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 440466B026C; Thu, 11 Apr 2019 14:19:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 358526B026D; Thu, 11 Apr 2019 14:19:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id DA9176B026B
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 14:19:48 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id p90so3527801edp.11
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 11:19:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=HPsNaI6UgA2pfuoIs5OFTN9/9rHtbmLIk2kt19mCXGA=;
        b=VOAQCE9Smhv1q6exOIOEEjt4sEBrYG3Ju3ZQSe2WFuNp4niU1wNPbWbRdg2qNFpQ0A
         wCBAToLmHGrve78a9PR2jOsiULA+9mcA5KSFTasstyx2i9ld4u1FJTdYoO16e5/4LLbM
         RsUXyjNdiiHfxoCcMeTO2cEg5fMl9dRcFIS2qPhiYNYthfkjOnzv4E1Wk/q9H+xm7a4R
         pHFnkeX+K+r10ImfUl7A/5oFa/G8IEU9C5OZUe6RlwjE3hQ1xTvVYdL7vCY2hXOa6Dvn
         WJRMVBVUrzREiL7SWdRk6k1XSKEMpX5fR2EnoWWsFXxK3uUM3Kj2eFlM3eud2EC1J91h
         mQMw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXsmsW5Z8KhMY7756/RXBOCpdTvEcl7W7aXoQdlhoLjgriaGKb4
	P+7+ghH7VEJefajdOsASDgWeEsw3Nm/zcrjEQ6SvbHN59N8yjcqe4nX62nXqN8+H2gtfpopRfru
	ZefIMfgOd52w+eRv2jP53pxhuh6OdAltBc4EUNJ8VXT0CjCxA7F/ChFMD5+HqNEU=
X-Received: by 2002:a17:906:4899:: with SMTP id v25mr6551026ejq.71.1555006788440;
        Thu, 11 Apr 2019 11:19:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxzvdHsKMg2YphzWvg2If2hxXZSrC30wFZWovbIA7bowANDCXIak9Z+DLPO1UYmqixuQpQp
X-Received: by 2002:a17:906:4899:: with SMTP id v25mr6550987ejq.71.1555006787689;
        Thu, 11 Apr 2019 11:19:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555006787; cv=none;
        d=google.com; s=arc-20160816;
        b=pUKOpihWslZkXsar52QFRQg0bvBupwpiSIazXbOTuEiX8jBIBCkw1fdO8bY6tsKnKL
         ARybkRgqlAoGTQ+Go7E+ZFN1Qc+028vFbYgd8dbr86dA+6nhfu8EVC2EEnXYgVXlJu1g
         qpzpgiajdemsDlhSBBE9QK4HQTHYU4weBpznvzVLth6cvnq6A8wrLuQgqT4ooizJc3Ws
         EepxkAnld7aiQFCJEYz514J0UbOnYwUQF7GwLDYQHpHNOGi8J+2drrmsTRsgjkjLlsaa
         ySUT0mX7aCfYdn5R9Gkukvoa0yj83uUWx1rmgg7mJdUcgjfDyaAzJGBOI7JI2ZJ9SAjX
         q37Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=HPsNaI6UgA2pfuoIs5OFTN9/9rHtbmLIk2kt19mCXGA=;
        b=ZAs+98PkDvEhOlcuG3xf5s5spm9l+Jt1VHhj8U7CYCt/C99idxxtEmkF0PSwbpXEeC
         PkqIlMTCCftwaAa8JCuooZaMZH2EyeDxFrqtP3suQjhWjACdh3WTA37/SNLiGZ452F88
         RqArC5O7/lb7ARkBg6yDW/IRdN3vqJqQv/ww/rmGIxuL12dn3BJt/PewQaol1FsdOBcJ
         IVxV771Wrw0jLfMhBMnT1LT4db4UdC0C1YxYb+TIoX2m7+HdkbAUCJd/r0MCDrZRDwU8
         O1QRi/UtqBEpK55xYoNyL26NDZ3eb/AjG/uBimpzmMuXFagIZbR8mc3PMhtHz5aD5bBq
         92VA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l17si361784edv.58.2019.04.11.11.19.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 11:19:47 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 1E593AD3E;
	Thu, 11 Apr 2019 18:19:47 +0000 (UTC)
Date: Thu, 11 Apr 2019 20:19:46 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Suren Baghdasaryan <surenb@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	David Rientjes <rientjes@google.com>,
	Matthew Wilcox <willy@infradead.org>, yuzhoujian@didichuxing.com,
	Souptick Joarder <jrdr.linux@gmail.com>,
	Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	ebiederm@xmission.com, Shakeel Butt <shakeelb@google.com>,
	Christian Brauner <christian@brauner.io>,
	Minchan Kim <minchan@kernel.org>, Tim Murray <timmurray@google.com>,
	Daniel Colascione <dancol@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Jann Horn <jannh@google.com>, linux-mm <linux-mm@kvack.org>,
	lsf-pc@lists.linux-foundation.org,
	LKML <linux-kernel@vger.kernel.org>,
	kernel-team <kernel-team@android.com>
Subject: Re: [RFC 0/2] opportunistic memory reclaim of a killed process
Message-ID: <20190411181946.GC10383@dhcp22.suse.cz>
References: <20190411014353.113252-1-surenb@google.com>
 <20190411105111.GR10383@dhcp22.suse.cz>
 <CAJuCfpEqCKSHwAmR_TR3FaQzb=jkPH1nvzvkhAG57=Pb09GVrA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJuCfpEqCKSHwAmR_TR3FaQzb=jkPH1nvzvkhAG57=Pb09GVrA@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 11-04-19 09:47:31, Suren Baghdasaryan wrote:
[...]
> > I would question whether we really need this at all? Relying on the exit
> > speed sounds like a fundamental design problem of anything that relies
> > on it.
> 
> Relying on it is wrong, I agree. There are protections like allocation
> throttling that we can fall back to stop memory depletion. However
> having a way to free up resources that are not needed by a dying
> process quickly would help to avoid throttling which hurts user
> experience.

I am not opposing speeding up the exit time in general. That is a good
thing. Especially for a very large processes (e.g. a DB). But I do not
really think we want to expose an API to control this specific aspect.
-- 
Michal Hocko
SUSE Labs

