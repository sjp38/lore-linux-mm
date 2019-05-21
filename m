Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 43CC9C04AAF
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 10:34:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 122FC21743
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 10:34:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 122FC21743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B450D6B0003; Tue, 21 May 2019 06:34:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AF7F16B0005; Tue, 21 May 2019 06:34:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9E49B6B0006; Tue, 21 May 2019 06:34:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4E3926B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 06:34:36 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id h2so30017804edi.13
        for <linux-mm@kvack.org>; Tue, 21 May 2019 03:34:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=YSgFLgCYEjIvYc9W0kfB21LvPOuwu8HHpfJojGnh07A=;
        b=nTwnR1fiNGmGPL+d6HstDDUeVtwK2fwdCAFGGV+h1o2Kldpb1JaN+c2d8IPfJMvsal
         uJeQexTC2HYacHCHn951mU+KYi35ZaJjMUrk4zgb0KsOiVBOTGDDlfFUrD0BKsF5Rs2g
         xJIWvTTIp9GSr41ctkwL3y90UDlwbCLSOV6puUpThMcV/XKcX/BDu5XlT1Co/8OIJIMM
         Wri/ilHxFukFwhm1adbgWdpKBovJ3+CSCBY4qS3G69qUqrA7KFyb8gDNAQnM3hbjybqd
         fjkXjIG6NZOK3z0zV6iL584Wuo+MRfpElUR+k09ZceTaZSE4QXKpPirSPfIGd0VRETx/
         0d+A==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAU6sGvvBHf7gLHKSkXzAJfNAFo+ID4WU/Hfqdc5wwaWcZcaJuOi
	D9gArVzWTsHcgCITkt22VwTbHggN61r/829h3aWdSkFCdbN02Bp1Ww0lSrAi4DoNKU4TpHgf+Kn
	lZ1VboywITQhbA6W87FHZnR7d8Oc78wSxR9e61ond9TN/LHJH33aBdOOCY7xsLY8=
X-Received: by 2002:a50:9435:: with SMTP id p50mr82586881eda.40.1558434875882;
        Tue, 21 May 2019 03:34:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyf5qBKcZSowF8ZMBTOT+V9k/3FnUFoEYG6BJTN7Bzhdzz40tH/1T3YAUrzZ5/lzsbn2wOu
X-Received: by 2002:a50:9435:: with SMTP id p50mr82586818eda.40.1558434875160;
        Tue, 21 May 2019 03:34:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558434875; cv=none;
        d=google.com; s=arc-20160816;
        b=Nzww5yWo1SPueI63W1SSy3lFSR86hqx0pRu2yg4Q2MJnrzPGUxd/enuR24JxZhd3nh
         Os8mzgCneTdjBlSDUko+ug6c4dgYlI4Ml4DoxlxAEvD3Xox3DemMhDcglNvhOPVbU6kV
         SpRlFuQmHN/wyf5+3UmyuFwSfAYa8c8l5/xhHouoHInnQ7MN8QypS/ubmbG/MF3GZbWo
         b10nzdXaGnxBGycdNtiIoBBzfe8E4ouO+NyEBf3vIr5LU3sBjTfHCGn7w/ZFy1m5Ow9P
         ZX3MggKxzSkEmMVTxGu/7QnbUXonLQ3/oCYoKq2TrxFs0bwhRQaYy9Zociic/4DpX+6+
         0tbQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=YSgFLgCYEjIvYc9W0kfB21LvPOuwu8HHpfJojGnh07A=;
        b=wKj7Ua4r6esljinVpvnv0m01blkGIvgnJESg4AAYlx1AVfW/xxOizleyqWUcbThK2o
         J57F3/mhgIaoXrsnbr1LCxAwLrhVELyXOGRE04LZD+HPTV04v32kscy37oGL/UDNFBj3
         p7k7PhQq+Fxlriq1ZUrhC9DyLnEIKp2XqdTocUMyS7YFIrCfWZlW4fUIr0d42hr/4AW2
         jN3biRlyf631puV68jnKR9FBswVK2NIVNavPIHYdVwYZovHihcMwEU7j7XY2gQ/BjOW9
         rHt/bTh5mAnoqjtCBdfDweq1m7R2rvH6VhBqU7TXRlmFNqmutbZrRWDjsXrfVeta16Sb
         6xTg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s11si12442035eji.295.2019.05.21.03.34.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 May 2019 03:34:35 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 7D287ABF4;
	Tue, 21 May 2019 10:34:34 +0000 (UTC)
Date: Tue, 21 May 2019 12:34:33 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Tim Murray <timmurray@google.com>, Minchan Kim <minchan@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>
Subject: Re: [RFC 0/7] introduce memory hinting API for external process
Message-ID: <20190521103433.GL32329@dhcp22.suse.cz>
References: <20190520035254.57579-1-minchan@kernel.org>
 <dbe801f0-4bbe-5f6e-9053-4b7deb38e235@arm.com>
 <CAEe=Sxka3Q3vX+7aWUJGKicM+a9Px0rrusyL+5bB1w4ywF6N4Q@mail.gmail.com>
 <1754d0ef-6756-d88b-f728-17b1fe5d5b07@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1754d0ef-6756-d88b-f728-17b1fe5d5b07@arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 21-05-19 08:25:55, Anshuman Khandual wrote:
> On 05/20/2019 10:29 PM, Tim Murray wrote:
[...]
> > not seem to introduce a noticeable hot start penalty, not does it
> > cause an increase in performance problems later in the app's
> > lifecycle. I've measured with and without process_madvise, and the
> > differences are within our noise bounds. Second, because we're not
> 
> That is assuming that post process_madvise() working set for the application is
> always smaller. There is another challenge. The external process should ideally
> have the knowledge of active areas of the working set for an application in
> question for it to invoke process_madvise() correctly to prevent such scenarios.

But that doesn't really seem relevant for the API itself, right? The
higher level logic the monitor's business.
-- 
Michal Hocko
SUSE Labs

