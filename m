Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B883AC76196
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 14:29:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 89B3B20873
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 14:29:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 89B3B20873
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 50C016B0005; Fri, 19 Jul 2019 10:29:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4BDCF8E0003; Fri, 19 Jul 2019 10:29:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3AB5A8E0001; Fri, 19 Jul 2019 10:29:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id DF7B96B0005
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 10:29:09 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id f19so22180760edv.16
        for <linux-mm@kvack.org>; Fri, 19 Jul 2019 07:29:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=7gM7qdyoxou8DXaWZqCWLWUhT/i75pvKGchIJAeNakw=;
        b=COSQqn6FMiev3bmKu4flaQ/w+h/DNRoV8eG9lwVuHGoyUMBWjKyStln10IKxe/YTfl
         1hDNyyJsV5PKa/xo/LKtoa3edkwAWn8frdos0J8As5pY9YkCJZnyQcDmT1+z7dO0VAwl
         vc5+ohDs6ynavTTo4kYtPt9GxcAiu5DelwlnXYbT7smwoKPLS6DZp5BvGJkaIoWXnWD8
         cfk+JxzZZ5d5O8MptAJ2oP0epDW3rpUDn6Db5OCeWW/gUspETudzb9ePOTLWKK+B6UFd
         D+p6yeXTPunl6RzMQ1fOhXiJf4UoMdEaYVkTTfeactjXunAjpvRrSOgARqkfVcf9Gd1a
         bxZA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWv0QlLW/bdx2+mseYWUOlTP86lXk0rEJxnMrRYUDD3y1u2bF/0
	QZvdcJS0A+TFshtWZSXg5Mp/VoC8Z5p90L5DHiOTP5UrCfAg4bT3Prx2bBs67WQvAocTtNazL74
	zjV1T0TWtzPwOuWb7yxowI150IIOCt6vrLHIauzdvzjlKVSIhL1aZ8s0FF+GLWIs=
X-Received: by 2002:a17:906:94ce:: with SMTP id d14mr42018406ejy.251.1563546549495;
        Fri, 19 Jul 2019 07:29:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzcmL2DzdQkSBW+cj9Ge1TGFTNQr3gnOPWUxTivYYMhaojE8p1Go7IpN7num5SgJL9abud4
X-Received: by 2002:a17:906:94ce:: with SMTP id d14mr42018343ejy.251.1563546548648;
        Fri, 19 Jul 2019 07:29:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563546548; cv=none;
        d=google.com; s=arc-20160816;
        b=ZAiRW1ZOjDNcAGxpkMhC/kN7EMSMkOx8Vzyq6Ll00LhAXZlpPO86TFKfuBfSCDjiTm
         2J3cQaVJDMtQTRcqpbNtAXGcWMFkkMoQ4/GsxbJNMmtW3w4DcET6f249HDujjAZaBKfS
         Xqh9Z0DfDkDYzC6gNHDSO8Ifh2QP9aEU7sg6YhKCwcc8kYhIkNPeGfr8WWmP2q8vxMpL
         /mzV04BtasD+JGz62edOhRl6DfrmbNyCGKIptHaaqxOH2jGHsfHYH7PHSoK6IKZiBU9S
         sHAMUzlv9wtVUzw0gV0K7HGlLLapApqbvwsG+dEAdXWhrBpeBFFz7ymViwU+pOFu+G2E
         Af1A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=7gM7qdyoxou8DXaWZqCWLWUhT/i75pvKGchIJAeNakw=;
        b=PjO1DToclYsYjBh9R09J0dGEMjn7QK8juS6LuglDvtIMijJ3yY2qoBWlvZgjurbF0L
         5Mav0kAzwXBW1b0qS10i8EUlVFstvZveXpVuKY1RvrO0d5bU5evuSuRB29LUm6rkPD1I
         Bimg/jkP65ZHp/3ba96xFBA7g++L5uDUoUsen96PAns3KAz0PP7dY2pkW800QgpvXnk+
         FzMS9qFmQuW5MOuIwJ6CSFMmBTKJVCeTaniWFbZplw//0VFzhFfjDRsR0fA8U0qE0X8J
         HxQ8pQycyBNaflLpNLFtPXSGxJiY03fhuDIpGIwhcC7u8cu21+MqozGXIh6rrpXTujT6
         6MoA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a24si1506242edd.382.2019.07.19.07.29.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jul 2019 07:29:08 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id AE41BB061;
	Fri, 19 Jul 2019 14:29:07 +0000 (UTC)
Date: Fri, 19 Jul 2019 16:29:06 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Waiman Long <longman@redhat.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Roman Gushchin <guro@fb.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Shakeel Butt <shakeelb@google.com>,
	Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH v2 2/2] mm, slab: Show last shrink time in us when
 slab/shrink is read
Message-ID: <20190719142906.GU30461@dhcp22.suse.cz>
References: <20190717202413.13237-1-longman@redhat.com>
 <20190717202413.13237-3-longman@redhat.com>
 <20190719061410.GJ30461@dhcp22.suse.cz>
 <a0ea7cd2-d66c-f251-d14f-979e0913c7ef@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a0ea7cd2-d66c-f251-d14f-979e0913c7ef@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 19-07-19 10:07:20, Waiman Long wrote:
> On 7/19/19 2:14 AM, Michal Hocko wrote:
> > On Wed 17-07-19 16:24:13, Waiman Long wrote:
> >> The show method of /sys/kernel/slab/<slab>/shrink sysfs file currently
> >> returns nothing. This is now modified to show the time of the last
> >> cache shrink operation in us.
> > Isn't this something that tracing can be used for without any kernel
> > modifications?
> 
> That is true, but it will be a bit more cumbersome to get the data.

I have no say for this code but if there is a way to capture timing data
I prefer to rely on the tracing infrastructure. If the current tooling
makes it cumbersome to get then this is a good reason to ask for a less
cumbersome way. On the other hand, if you somehow hardwire it to a user
visible interface then you just establish ABI which might stand in way
for potential/future development.

So take it as my 2c
-- 
Michal Hocko
SUSE Labs

