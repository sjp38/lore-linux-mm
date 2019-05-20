Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D11A8C04AAF
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 08:19:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9E8B520656
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 08:19:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9E8B520656
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 498806B0007; Mon, 20 May 2019 04:19:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 448C36B0008; Mon, 20 May 2019 04:19:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 35F166B000A; Mon, 20 May 2019 04:19:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id DE2536B0007
	for <linux-mm@kvack.org>; Mon, 20 May 2019 04:19:45 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id h2so24003946edi.13
        for <linux-mm@kvack.org>; Mon, 20 May 2019 01:19:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=mEVQ3Q8yuA+cC//lqTDduqY0Yvb2wFNkbMp4MNfJdcQ=;
        b=JoJrF5RWltVCzPV7SsvN474zABoDZuOsjLhW/QQ4d3ItaYGQnVXmMQasnEN1H54nkT
         lYJuYsJoIkJh++6HPSqwtLs2iKzvGe2oI+CIS2y8ZU9P53HiLkRyrHXEDSb8lSSdSHR0
         IK32QseXvWepnQYV7Y2NzIkaNYnROWFpCqLLdq+ZSgrA/CozEpOSm4gh0/XUtMV9JYmn
         KrIVvGq40j/wTLoAvcMqDEIq+Fo1vqjQOCxcY9Pp+chVJ2i+Q6uQvO/6wcIaRG8hANCA
         RtfKQKeoiw6xMEG520yq6YsRq6uW+Mdkx+zSoEp6N6qk4+X7PNX4ruAeLliq9YanUHRU
         U59A==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXB8J/IA+cRRsln1uTOXpGNpK7R68gCqvlOe2KdgOTZujPYnUct
	p7RuC3cjh1iH8huwyM4SGm9ygdYiaNFHbmNeuOZOozd8AaiYXCKPhMHot+u6/bwq8AhSqTqAQhs
	O1y+ATYb4RtdzyabPAEUqx/jnWCtZv2IND2/0iNPfS4uRtSDtiBVwtOXC3PsKXnc=
X-Received: by 2002:a50:b19a:: with SMTP id m26mr74680580edd.243.1558340385494;
        Mon, 20 May 2019 01:19:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxdm58DFMHJgB4xf+so8af3V6THVYSE4vVYI2lHooUUUgfC9e1IypGsb+BLFxuKdSW99MGd
X-Received: by 2002:a50:b19a:: with SMTP id m26mr74680535edd.243.1558340384864;
        Mon, 20 May 2019 01:19:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558340384; cv=none;
        d=google.com; s=arc-20160816;
        b=gwt8l3l4HNmUu23+AFERnF7uedHF9jFwy0L4k7wq8IDJWF7CrutGG8NfUhdtXkd67I
         BvirxOivTRgWLR2KuYUysaOir8xz2oLsC/bX6Gvghde69Vd/zNPbuTfaAbwdyXtKzkuz
         kbVcYa1ORPAsAE+0mo76ZpDqiqk/vdUsvcRGmIlcnEdEYcvOrhwQnTiK0PL1xaprRuw3
         qpBLdGRMRHQRJJ3x2hpo/b2xMQ21x+YOrJIuEWvClfNsaXNK1j9munhCoDa9lzo8CvLZ
         zpS2oWK77E0NN1jkQ9q9Zac6ulB9A0RbBOR2tPY4FCi7u1VUSUAaiGdhYE8T7MWh4evB
         9VSw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=mEVQ3Q8yuA+cC//lqTDduqY0Yvb2wFNkbMp4MNfJdcQ=;
        b=B7C79EwN0pl/hLZPTHoTYLKj6HxfzNXUUXtdDLLpyLIEGALL7vNrFFTTyh++SP0Ztl
         CAYzzFg+++TI7Fi5fB3DeVRq/i66aiNTEZbzTtyWq+Rxjy0SaGQy4xRc/u15G6mnfq/N
         h5eLyAGZ/IIrhIiVtZErpG6i3ZHTcbBgZ4l/s57k3zanKqIzxZZkypFZiZJi8jqJNFYi
         4i4g7hVclcc7Asd9twui3G8G10a27alA+N4xKkQvrhvS8ANn5nzILzn3EglKnljdHrqC
         6ZEW+pTj1gKyBgxOlfhExstqeSzeF4GAAx5KhgcuL0iFFKyd6BycLm+FctOUFUpJyZXR
         CSOA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v1si2491679ejk.50.2019.05.20.01.19.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 01:19:44 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 19660AE48;
	Mon, 20 May 2019 08:19:44 +0000 (UTC)
Date: Mon, 20 May 2019 10:19:43 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>, linux-api@vger.kernel.org
Subject: Re: [RFC 1/7] mm: introduce MADV_COOL
Message-ID: <20190520081943.GW6836@dhcp22.suse.cz>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190520035254.57579-2-minchan@kernel.org>
 <20190520081621.GV6836@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190520081621.GV6836@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 20-05-19 10:16:21, Michal Hocko wrote:
> [CC linux-api]
> 
> On Mon 20-05-19 12:52:48, Minchan Kim wrote:
> > When a process expects no accesses to a certain memory range
> > it could hint kernel that the pages can be reclaimed
> > when memory pressure happens but data should be preserved
> > for future use.  This could reduce workingset eviction so it
> > ends up increasing performance.
> > 
> > This patch introduces the new MADV_COOL hint to madvise(2)
> > syscall. MADV_COOL can be used by a process to mark a memory range
> > as not expected to be used in the near future. The hint can help
> > kernel in deciding which pages to evict early during memory
> > pressure.
> 
> I do not want to start naming fight but MADV_COOL sounds a bit
> misleading. Everybody thinks his pages are cool ;). Probably MADV_COLD
> or MADV_DONTNEED_PRESERVE.

OK, I can see that you have used MADV_COLD for a different mode.
So this one is effectively a non destructive MADV_FREE alternative
so MADV_FREE_PRESERVE would sound like a good fit. Your MADV_COLD
in other patch would then be MADV_DONTNEED_PRESERVE. Right?

-- 
Michal Hocko
SUSE Labs

