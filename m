Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 49D8DC41514
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 15:43:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0D13B20665
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 15:43:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="hyuuAh2C"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0D13B20665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 97D1D6B02A1; Thu, 15 Aug 2019 11:43:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 92DD26B02A2; Thu, 15 Aug 2019 11:43:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 81CD26B02A3; Thu, 15 Aug 2019 11:43:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0136.hostedemail.com [216.40.44.136])
	by kanga.kvack.org (Postfix) with ESMTP id 5FC506B02A1
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 11:43:08 -0400 (EDT)
Received: from smtpin10.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 14E038248AAF
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 15:43:08 +0000 (UTC)
X-FDA: 75825080856.10.week21_729beb3aeb22e
X-HE-Tag: week21_729beb3aeb22e
X-Filterd-Recvd-Size: 3686
Received: from mail-qk1-f175.google.com (mail-qk1-f175.google.com [209.85.222.175])
	by imf18.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 15:43:07 +0000 (UTC)
Received: by mail-qk1-f175.google.com with SMTP id 201so2155814qkm.9
        for <linux-mm@kvack.org>; Thu, 15 Aug 2019 08:43:07 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=VSR3T6Q49rCFXPPoyb9XFgF2ejksN7y0WyTo3YMYamM=;
        b=hyuuAh2CNIxYP3ggj8gDm8R4p/9az4kHrRaL6c7xkvVmp5KasB2iSYzUaAGIeZjGiM
         A95PrUyUJC+0/lW0z1W+odNW7+/4tOmRmm6g86Fh0uQd7iEZ7NQH9paD1ey8Ro+yUg4g
         y3VeNucMGXfPbFqNNe2fdHGkico4kMYi0IGp8QW1kdMhBhiJeExKMtbS0t6bdR0K3WmR
         I+szM8wY4iywtp965t3+afNr0ujT0/Y5OO7fs8HNBxXO9ilORnMG3/ZqeRVzaRoWWy1f
         y2cWJTQHxaLlPv/FNGs6kLzLnFQz0yqnp8YocfIMbukfVsK2R/XaBg8GPyF6ZzZ2cszC
         /M0g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:date:from:to:cc:subject:message-id
         :references:mime-version:content-disposition:in-reply-to:user-agent;
        bh=VSR3T6Q49rCFXPPoyb9XFgF2ejksN7y0WyTo3YMYamM=;
        b=G+0KrOuQdI6bgK3Rtqi9hAitFaQTSG6AQAQz2TqrW8E+1Sh64tTvzXiTh9Pyatsgw7
         C7L7ADdEzA2PEEw1sD0kBWzfQ6gam5zHuaV36LLl07qddY7FFKDDbaDYBkNbBE+c9Euo
         D0RvWk73zobE6lxdUZ40QyYpRSDLXzzdQqV4zuni6rFYJ/+aG7qQsO0LdKdxo8IhPi7u
         6hxiWDFfXAFhti50K1aOkjlGlFdPY/YU7KJrQiWEwyE+9rUBJUOEiJQzHZ+bSk1O85Ku
         FI1Cw+5cDaGzkA0ThjO57+FJYIsdEilH67+sRYlzwlE67Yrn5puiTcJWPGfjL4+7BaeL
         aYBQ==
X-Gm-Message-State: APjAAAUJVbqhNXVKmppgGniD/cfRnfvtiO8RwEt43YVIIbszvpIZb/Vi
	3Xd8uvb6699VAMD8zT4724Q=
X-Google-Smtp-Source: APXvYqxzLjuzQD27bfrn2cScIeA+V2HcpeVzSikxHaN5jBJPh/YwChCQxz2+g7+fHLFfxda2FIzOsw==
X-Received: by 2002:a37:270a:: with SMTP id n10mr4625997qkn.434.1565883786758;
        Thu, 15 Aug 2019 08:43:06 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::1:25cd])
        by smtp.gmail.com with ESMTPSA id t2sm1529090qkm.34.2019.08.15.08.43.05
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Aug 2019 08:43:06 -0700 (PDT)
Date: Thu, 15 Aug 2019 08:43:02 -0700
From: Tejun Heo <tj@kernel.org>
To: Jan Kara <jack@suse.cz>
Cc: axboe@kernel.dk, hannes@cmpxchg.org, mhocko@kernel.org,
	vdavydov.dev@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org,
	linux-block@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com, guro@fb.com, akpm@linux-foundation.org
Subject: Re: [PATCH 3/4] writeback, memcg: Implement cgroup_writeback_by_id()
Message-ID: <20190815154302.GB588936@devbig004.ftw2.facebook.com>
References: <20190803140155.181190-1-tj@kernel.org>
 <20190803140155.181190-4-tj@kernel.org>
 <20190815140535.GJ14313@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190815140535.GJ14313@quack2.suse.cz>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 15, 2019 at 04:05:35PM +0200, Jan Kara wrote:
> > +int cgroup_writeback_by_id(u64 bdi_id, int memcg_id, unsigned long nr_pages,
> > +			   enum wb_reason reason, struct wb_completion *done);
> > +int writeback_by_id(int id, unsigned long nr, enum wb_reason reason,
> > +		    struct wb_completion *done);
> 
> I guess this writeback_by_id() is stale? I didn't find it anywhere else...

Yes, removed.

Thanks.

-- 
tejun

