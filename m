Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E13D0C28CC3
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 18:47:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B3F0725FE9
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 18:47:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B3F0725FE9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4CE9B6B000E; Thu, 30 May 2019 14:47:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4581F6B026D; Thu, 30 May 2019 14:47:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 36E576B026E; Thu, 30 May 2019 14:47:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id E00CC6B000E
	for <linux-mm@kvack.org>; Thu, 30 May 2019 14:47:16 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id n52so9910073edd.2
        for <linux-mm@kvack.org>; Thu, 30 May 2019 11:47:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=5Gt107Vtbqvi8jilyENgjygJpy+ZvOEaCBRdu81GjtU=;
        b=mjHJU0FsUr9PUBtwubQNiHXkipEku3AU5otX0bheMbOXkx9jsvk+8YFkz2vpQJOmcg
         FFS3OeK4tiNIBvN6AEhZTKbbYDp1WTiaam9HDMgCxhMheZm2TQ17VsiDiWY58kuXENig
         OVdEh9sS1aEa1qcuDs0cR7AbA7mdSuzWLzLCibDxfDbRYkEbyDeMQ85xgnAaLqOAFaYR
         waYlMwLDixGI8jiaJvKHOwpSYVadpguKEck21M1ZFMTq9esqyyt0BmaVPq2LfkByUvY0
         9nOBnae0YZN7OdLKar1kiA9SFsFoqEMbC2WQY8jMJn087IcpBE4Fsy7ajJzzUaYoZGXL
         HmcQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVYQ40Qku+kSVcHFZcpyO5SjsclLbxqjM9FqsDGiYIt5KNEeOfJ
	FR4jBtDfnbU0wioRfgkV/0GKozfGq1xsf3WASZqUAkSgVbEmnvV+aIk55O28cc7Q784LsaAiN9i
	6mWlBrcmyVAtspoIDl8dxEW8of9iD/L5Xyf2KNCwqBPBTrfBPqaDFRlGJBDCYyV4=
X-Received: by 2002:a50:d717:: with SMTP id t23mr6437445edi.248.1559242036442;
        Thu, 30 May 2019 11:47:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzWtxub3B0oBgKt+HfsXGaU3Cn4u3/KaKcqDj6MBI4m74MQNBBdRsHcCO1IBCkI9s8iJWjo
X-Received: by 2002:a50:d717:: with SMTP id t23mr6437376edi.248.1559242035555;
        Thu, 30 May 2019 11:47:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559242035; cv=none;
        d=google.com; s=arc-20160816;
        b=cnZnfMJdaZPgI2evWi8ZxGRSsozL+o5eElTBfx9266pZXppw9/I0IR+9DLorzw8NRr
         lChJk4NnU7qWIcSZJ0MReJ9+H42xDJXGG0PpvF7Ks6a1naeASzBke/slBwXXHJiMmoXr
         lnpA4dl8tKPgV+lWrekWITylbgMwO+JF7ixTqZNOfLpnjbcKdP4MP/dmwPjHKkOl3moC
         Sq3odKxlGUQaqBiz38ImYeHKAtYzu6A2uI/+XmudweLc77gQIGyOtahKwRHbKpiljLs0
         TSlOAQXQ9rjbDnPDrK8i2fOyjFuqyg2Kl8gpRKhxvT5yE6xsk+Ia8wN6dG8hTXcG0pRq
         YmHw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=5Gt107Vtbqvi8jilyENgjygJpy+ZvOEaCBRdu81GjtU=;
        b=SEGZWXfM2ukuE4USFLEa/OwEDU3HUVnMtUC38LrCsv8nv1vWuRBy/tvrKHmeoFAJ1L
         hgX8ZIoCGdEZyIqhtHN6ZdoRthBXUTFz6tmWMOmIlJAgv40bRYoLUfASmBNewr8k+MLd
         Yn0MMuPHyX53PoUPCfa+oECaQ8FNzpE7GcFZkgd7hNdpPandamv7Chj/Yz++Oq9h9KqK
         htHKcJ+AdkRXvoR3Qh7hMmxG16GsQSsNebVw5UEQZi6KDe6eenwyuh0kSnJ6fZLITMFL
         X344Xf170kXOo7htq4LjXoYpGxBOS62Z3Vmlexhiv0RCUKUXBAPlZrpeRpDX6ROdbEp5
         NhrQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c1si1896878ejf.45.2019.05.30.11.47.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 11:47:15 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 96A02AD35;
	Thu, 30 May 2019 18:47:14 +0000 (UTC)
Date: Thu, 30 May 2019 20:47:13 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Daniel Colascione <dancol@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>,
	Linux API <linux-api@vger.kernel.org>
Subject: Re: [RFC 6/7] mm: extend process_madvise syscall to support vector
 arrary
Message-ID: <20190530184713.GI6703@dhcp22.suse.cz>
References: <20190521024820.GG10039@google.com>
 <20190521062421.GD32329@dhcp22.suse.cz>
 <20190521102613.GC219653@google.com>
 <20190521103726.GM32329@dhcp22.suse.cz>
 <20190527074940.GB6879@google.com>
 <CAKOZuesK-8zrm1zua4dzqh4TEMivsZKiccySMvfBjOyDkg-MEw@mail.gmail.com>
 <20190529103352.GD18589@dhcp22.suse.cz>
 <20190530021748.GE229459@google.com>
 <20190530065755.GD6703@dhcp22.suse.cz>
 <20190530080214.GA159502@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190530080214.GA159502@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 30-05-19 17:02:14, Minchan Kim wrote:
> On Thu, May 30, 2019 at 08:57:55AM +0200, Michal Hocko wrote:
> > On Thu 30-05-19 11:17:48, Minchan Kim wrote:
[...]
> > > First time, I didn't think about atomicity about address range race
> > > because MADV_COLD/PAGEOUT is not critical for the race.
> > > However you raised the atomicity issue because people would extend
> > > hints to destructive ones easily. I agree with that and that's why
> > > we discussed how to guarantee the race and Daniel comes up with good idea.
> > 
> > Just for the clarification, I didn't really mean atomicity but rather a
> > _consistency_ (essentially time to check to time to use consistency).
> 
> What do you mean by *consistency*? Could you elaborate it more?

That you operate on the object you have got by some means. In other
words that the range you want to call madvise on hasn't been
remapped/replaced by a different mmap operation.

-- 
Michal Hocko
SUSE Labs

