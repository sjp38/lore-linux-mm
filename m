Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 95CEBC04E87
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 10:05:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 64C2D217D4
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 10:05:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 64C2D217D4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DF36C6B0003; Tue, 21 May 2019 06:05:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D560C6B0005; Tue, 21 May 2019 06:05:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BF6526B0010; Tue, 21 May 2019 06:05:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 69D566B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 06:05:40 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id y12so29887181ede.19
        for <linux-mm@kvack.org>; Tue, 21 May 2019 03:05:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=TovN6wnHDR1tGUgeDnPRnjv2Mb/pC/4eRY9IcVUU4yQ=;
        b=GCRWUNgGQPnHQJsB/WEK81BbSh9CGkmqGSAHs+JdtYRRXzOZ6Djq1LG8BSMo/+XFue
         lEgvQ2c2stchheLRpStngP5MRGmQ0LZ2ChTNTVP7KZl8xJ3Rt9TrJrhaieITM/1cYzQI
         KyImaR6wy2iVuaMxS/IGfrcU93BUdN8YvGv44O+0JR0S5IaQuU9jhk2ZHRwzkbLv9wBL
         AhtgOZMck8IxppoFNiLZJrDWAoZvH7yzsKJAnih0nP9qk+gZeQ/LfWYpSetXjR/ljdLc
         Av8xyilX90MXAUsRgouPugxun8+XYKYMFT00QfsiZtjPeWtZjUF0l/WGS7+r60lQg2iX
         T4qw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWF/MCbJxEzJO5dM/mdM+MNXXZFqCl82SsNvlkNBqkuA7rOoRyt
	Ooo3Of5RBHiFRre6cMCiml6OnQoNtbJ1a8zOvlHCzHwb4vPUcZVu7b+O9YTFtIB9jaLhYwhjfW7
	/OiIXUHM2v6z3eABOEpETDiVvtxVKiNJioH/4Q5suwgxjdhIm83Wr1L41dqiw7iM=
X-Received: by 2002:a50:a535:: with SMTP id y50mr81452928edb.249.1558433139957;
        Tue, 21 May 2019 03:05:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwGLp/5SALB06S6+tXv1s1fO1dxJZY2AO+RHUiWxktUfLc+noIMKDiHnhFiRbRrTjQrJLa5
X-Received: by 2002:a50:a535:: with SMTP id y50mr81452852edb.249.1558433139171;
        Tue, 21 May 2019 03:05:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558433139; cv=none;
        d=google.com; s=arc-20160816;
        b=bg7+XXGmBD1HNEgRVs1duN3GvgGpsA1aWXiCvKIMcTB4PoZxQBYYCSnZw7ur6t89W6
         paz9LIDLrqMG0ca3pdxy7g7sK6iWEX2TQKsQeUAUqelc8txBYR+FhNnj1ndY2lNQa+1r
         eG53/66cYnIB7ywcMUMum8XxStXjVVZQQdcTOM0hMI24vQvJ1aLcFBpj3bg2lKxI6QHC
         DT75ZTpt6cKR55T+VBFgknxumPMWAbNfXQObOAd58ipBgz4nyB19dBvz7J72Jy83kAZ2
         wc04qKbV8AHHJzsx+aUnnJe6P9dVzHH9L2zwU/38/JxALCQOLA5zM3YhLcXcWIwKTuZX
         3G2A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=TovN6wnHDR1tGUgeDnPRnjv2Mb/pC/4eRY9IcVUU4yQ=;
        b=WAYTRCwDJjIhtN9HiW7STLAxuvLtswZtWiUsXKCfWRII2lyx/61SR95kE65Q5cjB+R
         A6roRdXyLVB9v47gMTwbztOlcjfu9L7LEmmKeUVy68xRe/JUzmcIAJJxccz8MACyjGcw
         pXzUx0FHHht32/FZbslmlbKEBAUuJhfQC6vYeJxqNe/jnN9d1aBxjlBni1/WagFeTNOS
         xR67Bfxv35mE7GdIIcJ2PpXomiXbJRU12kUV4r/zmdrgPMin7WPMeFCQxnDGZU4dUe7B
         03WL3OxhKzSPo/z+zn43CQf4cjg2anRoax9ad5fV8/ZlfPcwjUXVGWbAZpifWZT3w/PN
         tRxA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e5si12143220ejj.98.2019.05.21.03.05.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 May 2019 03:05:39 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 93DAAAC4F;
	Tue, 21 May 2019 10:05:38 +0000 (UTC)
Date: Tue, 21 May 2019 12:05:37 +0200
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
Message-ID: <20190521100537.GJ32329@dhcp22.suse.cz>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190520035254.57579-2-minchan@kernel.org>
 <20190520081621.GV6836@dhcp22.suse.cz>
 <20190520225419.GA10039@google.com>
 <20190521060443.GA32329@dhcp22.suse.cz>
 <20190521091134.GA219653@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190521091134.GA219653@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 21-05-19 18:11:34, Minchan Kim wrote:
> On Tue, May 21, 2019 at 08:04:43AM +0200, Michal Hocko wrote:
> > On Tue 21-05-19 07:54:19, Minchan Kim wrote:
> > > On Mon, May 20, 2019 at 10:16:21AM +0200, Michal Hocko wrote:
> > [...]
> > > > > Internally, it works via deactivating memory from active list to
> > > > > inactive's head so when the memory pressure happens, they will be
> > > > > reclaimed earlier than other active pages unless there is no
> > > > > access until the time.
> > > > 
> > > > Could you elaborate about the decision to move to the head rather than
> > > > tail? What should happen to inactive pages? Should we move them to the
> > > > tail? Your implementation seems to ignore those completely. Why?
> > > 
> > > Normally, inactive LRU could have used-once pages without any mapping
> > > to user's address space. Such pages would be better candicate to
> > > reclaim when the memory pressure happens. With deactivating only
> > > active LRU pages of the process to the head of inactive LRU, we will
> > > keep them in RAM longer than used-once pages and could have more chance
> > > to be activated once the process is resumed.
> > 
> > You are making some assumptions here. You have an explicit call what is
> > cold now you are assuming something is even colder. Is this assumption a
> > general enough to make people depend on it? Not that we wouldn't be able
> > to change to logic later but that will always be risky - especially in
> > the area when somebody want to make a user space driven memory
> > management.
> 
> Think about MADV_FREE. It moves those pages into inactive file LRU's head.
> See the get_scan_count which makes forceful scanning of inactive file LRU
> if it has enough size based on the memory pressure.
> The reason is it's likely to have used-once pages in inactive file LRU,
> generally. Those pages has been top-priority candidate to be reclaimed
> for a long time.

OK, fair enough. Being consistent with MADV_FREE is reasonable. I just
forgot we do rotate like this there.

-- 
Michal Hocko
SUSE Labs

