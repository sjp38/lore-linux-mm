Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 04DD9C43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 09:22:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C74DC206E0
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 09:22:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C74DC206E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 613306B0003; Thu, 20 Jun 2019 05:22:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5C31B8E0002; Thu, 20 Jun 2019 05:22:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 48B948E0001; Thu, 20 Jun 2019 05:22:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id F15FA6B0003
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 05:22:12 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id n49so3409541edd.15
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 02:22:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=sBPBhExStgMyW/2DzeZ5lD+JndetnoLAmThCc5fXkTM=;
        b=al7feuz59Qod+xRbowsvwpQpzh3nseo9uSDbX9jVUlrbZp3UnuARLNAGrSOMHtmcsN
         d4Z2Xjx2iGlgj3re/UmCfcj0a2J9Yb5DmtNIAGJ8anlAi841475cABZBs7pk7cqCcIWR
         5psDrDKvP9hqqPHYG//vfkoie2xTWGU4SAelqYdnTrS70yRjQCoC00nxMMvwR69vsbev
         J9gvWsjLzHe0a165K7Q9XjVpqJE4UAv8E2e9JkiM1R5AFVLlrBm1Ph9OsPiaLiqfBdXb
         hv7/RV+1npA7UIU+gIGhVPLJtF3RkPPMyh7r43Y9lurY4QND1VLGqdWtu0rbedhag0kG
         KoqQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWbyVmfqRv1gyn2blEeaHjrLL8qsPzSRTh1HkhcTquZ05vgNihZ
	pWx0wCBsihrjS1d4QTaB562Fmfjeu+TtqFLd7dECZCUJFgjj61ueGioMEnu7kBJtxyt/sLmhxa5
	tm4ji0XYx0EiOvnO+MNzwo4oikED+OSZEwSid1rJWPlHucjB/NhhvxLt0PzyVri0=
X-Received: by 2002:a17:906:1914:: with SMTP id a20mr31052376eje.294.1561022532512;
        Thu, 20 Jun 2019 02:22:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz6SjeJlbrO8aqmL6lBjcFNUY5eKgmcvU60iwtOtxURLIRVnfUG0+wOsO6gXJQrCcsg+WAh
X-Received: by 2002:a17:906:1914:: with SMTP id a20mr31052328eje.294.1561022531716;
        Thu, 20 Jun 2019 02:22:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561022531; cv=none;
        d=google.com; s=arc-20160816;
        b=0pTjXKokchCpMH1Xae2Jx4/Yi4+NCB1Ao0CkQHqZ5VxUKbE0kBM5HxtXEa5vz7R8Nu
         A52m4DTAN7tZvj0fQTGeVnFfxIFT0irybZEQvLfwer0gIGlAbR7TO4dAGT6eI6Hypd+x
         xzgvWzY1b9A3hqTG2iXDLmAfzupe9o1yyJC9QNU6LANDG6wN8klHw40vR6b0c9NphDa0
         noKexcW6Yw1a33bFeoHpmkAQ9kjhSgxShEW9Bekw9SOwoDKUD7Nwx8Ym+Eo1SSY5fdqq
         Hoff35IoMYuVvl/ezo6wtSoDBlYpdi/lEsP0ticl7MLjCPNoBW8a13lLdpxXRvMlfWBe
         e0pQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=sBPBhExStgMyW/2DzeZ5lD+JndetnoLAmThCc5fXkTM=;
        b=jt5GnKZqiYvJTBHpIyfx5eu14nTn29CP2DiBpVViFGbkJy9hs7bnlsAKUu1D9bxGe4
         4rFeqGVRq4EE+hyfG7iQriJsQCQIrq5KQOSO3BaEk0YpdLOPHjOX6/dztV02ESug6da0
         Lfnd7FKyfYXSQWcVp4Xaj4iwPXbzAvatcCNtEg4VqkJiTjvc/Yx17GiYHF8/8UhVdqxc
         qoSZlUktR4t8r/7vmZotaN/z7Pl1SqBsI2xOhGNnmqMRTjQbY32e1H+RgeU3FnNWYppT
         9kXIaqDPKxhaq1+8kAtBIIs4JGuWzTA8lcK/Lgrg+GgxdvwCZ06dZECaHYnpvkHBH8lC
         IeFA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k2si15079429eds.64.2019.06.20.02.22.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 02:22:11 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 1AA10AF58;
	Thu, 20 Jun 2019 09:22:11 +0000 (UTC)
Date: Thu, 20 Jun 2019 11:22:09 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>, jannh@google.com,
	oleg@redhat.com, christian@brauner.io, oleksandr@redhat.com,
	hdanton@sina.com, lizeb@google.com
Subject: Re: [PATCH v2 4/5] mm: introduce MADV_PAGEOUT
Message-ID: <20190620092209.GD12083@dhcp22.suse.cz>
References: <20190610111252.239156-1-minchan@kernel.org>
 <20190610111252.239156-5-minchan@kernel.org>
 <20190619132450.GQ2968@dhcp22.suse.cz>
 <20190620041620.GB105727@google.com>
 <20190620070444.GB12083@dhcp22.suse.cz>
 <20190620084040.GD105727@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190620084040.GD105727@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 20-06-19 17:40:40, Minchan Kim wrote:
> > > > Pushing out a shared page cache
> > > > is possible even now but this interface gives a much easier tool to
> > > > evict shared state and perform all sorts of timing attacks. Unless I am
> > > > missing something we should be doing something similar to mincore and
> > > > ignore shared pages without a writeable access or at least document why
> > > > we do not care.
> > > 
> > > I'm not sure IIUC side channel attach. As you mentioned, without this syscall,
> > > 1. they already can do that simply by memory hogging
> > 
> > This is way much more harder for practical attacks because the reclaim
> > logic is not fully under the attackers control. Having a direct tool to
> > reclaim memory directly then just opens doors to measure the other
> > consumers of that memory and all sorts of side channel.
> 
> Not sure it's much more harder. It's really easy on my experience.
> Just creating new memory hogger and consume memory step by step until
> you newly allocated pages will be reclaimed.

You can contain an untrusted application into a memcg and it will only
reclaim its own working set.

> > > 2. If we need fix MADV_PAGEOUT, that means we need to fix MADV_DONTNEED, too?
> > 
> > nope because MADV_DONTNEED doesn't unmap from other processes.
> 
> Hmm, I don't understand. MADV_PAGEOUT doesn't unmap from other
> processes, either.

Either I am confused or missing something. shrink_page_list does
try_to_unmap and that unmaps from all processes, right?

> Could you elborate it a bit more what's your concern?

If you manage to unmap from a remote process then you can measure delays
implied from the refault and that information can be used to infer what
the remote application is doing.
-- 
Michal Hocko
SUSE Labs

