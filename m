Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E7A89C43381
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 15:13:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 891552085A
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 15:13:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 891552085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EBE9E8E0003; Fri,  8 Mar 2019 10:13:31 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E6DC68E0002; Fri,  8 Mar 2019 10:13:31 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D5CB18E0003; Fri,  8 Mar 2019 10:13:31 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 90E838E0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2019 10:13:31 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id d31so9898360eda.1
        for <linux-mm@kvack.org>; Fri, 08 Mar 2019 07:13:31 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=e0hTWyOPvhCFeNSg8cE0IxChKQbRQsm0F7znCy3B/zo=;
        b=RDMn4eI1HA/eYJAULL3lHoOJ4pbkfBuEKwQT3ZjTUG/+TF1mXjWKzluPUEGgHUymfm
         l0u3SlFZQxUuclrX3qJP5+sRBuFKKrVbHE3bpwB+N7Nu285pxa6ZQRDjIwMll9x9reRL
         aLgJTsfVAWhdJaqyrf213tjICCHbEP+sSmN/oe0aCU2ETsNb350eEoHgM15YgyxO0IRG
         2n3A6KtVI27Vaz6fGPPvnlsGC4ZEY+psxFoMEsBWBuMON5e3JgskrWjod1pjbiokxk8s
         FDODLMg7hZmid3e8FiTLkTPSLR7m8Z1toWZ6Rqwsv6m7T+4pYUxO9xviTuBlyCxT1Gk0
         U32Q==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVC636jXnDpPqs/9RRDtop4d+uAyb7zXb5S2coli+Rsy/gZiqas
	Rq2DCgjBBv+CMF+cJlUWpBPpTbfFjIRB0I4niWzHVdNuUduUuMCBoC3NpkxPWgJ5o5FYrTH1HoN
	gCcxIUvWAKlU81pFu5VHVBFRgu3xp+Pip1Oc+/ic4Neltw5GafkRmfHIRnxMqAho=
X-Received: by 2002:a50:976a:: with SMTP id d39mr33642747edb.289.1552058011177;
        Fri, 08 Mar 2019 07:13:31 -0800 (PST)
X-Google-Smtp-Source: APXvYqzMiicG6NmoFXCSmogVwIYgH0Zn6gS2O8m+OFsSNzcfZTTTtLhqQDNBqHkBVACNh7pyvijB
X-Received: by 2002:a50:976a:: with SMTP id d39mr33642697edb.289.1552058010362;
        Fri, 08 Mar 2019 07:13:30 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552058010; cv=none;
        d=google.com; s=arc-20160816;
        b=raRzFvWdyvvm9EpR+7yEGyv1ae1DowqT/DoAHyVT3AnjGTRPVumclA0bU3hDC3AyFk
         3XcGlEO5vOrjpXA5ZkYnxp4NPGvhGDarZcG0liFXLv1grtd2RC4hBtxBeSeqAJWZbsNn
         u16Z28seWI/433iI5VBiKanrB9uJWQzH/l9i1I+xIc+AXKKe3mroHEPKV/XU+uOcHJEN
         sGTtGmbUWEkwMfL47ZVCijGqkHNHKptu/D0rNRUtlVYKiW7g+tGpvGcnJzMimoy7mZJm
         vT2n3OMt91Axk0iXg5tzHtcY3LDaYj3A37XNQ0qsqb+YZ7d29KE45/o8b0MYFwQ9P4Si
         1Dew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=e0hTWyOPvhCFeNSg8cE0IxChKQbRQsm0F7znCy3B/zo=;
        b=K8RfIxxdI2A01ncguwyDKfA/yZI6wdMCT5GEBfOKjGJSZPEWLYvC8Zo1W3esBd/79i
         WgHnCAt8mh2+aKbnFyaCFx+dX/jFTRAX3CdBj7F5rhZd/Xi3yN9GPHStSpWgBPXjIEYR
         EQZCzPIfqZg+0JYW/HkXXCJpfNrUwgGaRPbMbd5AQxfvq/zLuQ3cAM0ywoRlgAVnXZKT
         KcgJlCzP3LP6EKOmVti8leOvRxFaN4kb2UElTfiuIVXwAl4lWPa+U++QoMj07uPZp6xD
         iucUwK2MaKMRL9hu8ZrpgjIPZPDXJDa/cABquFlASqN5Kt7B3AJoG1FoWylRHbynZASI
         XFpg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w7si1210366eji.144.2019.03.08.07.13.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Mar 2019 07:13:30 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 7E54AAB71;
	Fri,  8 Mar 2019 15:13:29 +0000 (UTC)
Date: Fri, 8 Mar 2019 16:13:27 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	akpm@linux-foundation.org, linux-mm@kvack.org
Subject: Re: [PATCH] mm,oom: Teach lockdep about oom_lock.
Message-ID: <20190308151327.GU5232@dhcp22.suse.cz>
References: <1552040522-9085-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20190308110325.GF5232@dhcp22.suse.cz>
 <0ada8109-19a7-6d9c-8420-45f32811c6aa@i-love.sakura.ne.jp>
 <20190308115413.GI5232@dhcp22.suse.cz>
 <20190308115802.GJ5232@dhcp22.suse.cz>
 <20190308150105.GZ32494@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190308150105.GZ32494@hirez.programming.kicks-ass.net>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 08-03-19 16:01:05, Peter Zijlstra wrote:
> On Fri, Mar 08, 2019 at 12:58:02PM +0100, Michal Hocko wrote:
> > On Fri 08-03-19 12:54:13, Michal Hocko wrote:
> > > [Cc Petr for the lockdep part - the patch is
> > > http://lkml.kernel.org/r/1552040522-9085-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp]
> > 
> > now for real.
> 
> That really wants a few more comments; I _think_ it is ok, but *shees*.

It would be also great to pull it out of the code flow and hide it
behind a helper static inline. Something like
lockdep_track_oom_alloc_reentrant or a like.
-- 
Michal Hocko
SUSE Labs

