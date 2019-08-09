Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 82563C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 08:32:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 51A282171F
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 08:32:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 51A282171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 084E96B0008; Fri,  9 Aug 2019 04:32:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 00C7E6B000A; Fri,  9 Aug 2019 04:32:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E16AD6B000C; Fri,  9 Aug 2019 04:32:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8EE426B0008
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 04:32:19 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id r21so59862312edc.6
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 01:32:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=xIxE+xVZMQTD1DCNt3+SZQZTZ63dGBFcEDEKLCZBQhg=;
        b=bPav2i37NmuvgDGzrFinSHpheUMgad82zerOWsaGwYLT2El0cRuGu7HQPBf7QGG+BU
         kOe2Di7i4gfxyq9O3Yfjd+qUZBGuc8zkyF5M3DUUn6dB1AvtGC1dbJ428MufN6cUsqA3
         D8d/S45DAtcG1JREtU0NiAE98TJsAhLEe0HNfgYkZetiBc2Rib2TL4rwb4t/Qw8TycOm
         BjE6fQAht8Zg8q/Is/CgZwG5ct25XgE8mUXSlf1gPhmz2hhuR7fCknodXuPveZj1gv0p
         Ag7QieqWZGRYn6EjLsLIVSIduBQ3Ty8eHYv867qrIhIsYmMs5sD3vNLZkPs3XkkpH/J2
         Lh2Q==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXLp3RPuOP0SpuMmCRulw+et1bJxnczxmB519IFGcLoG8GPADSR
	s9lve/ur2X+eBjbw96OIJPXTzUhQJuMRd4Erpxb2ph2B8gKRsm8gWn6pSQLdx9z59zqow6vN1yV
	ejFBw3/YTUyLNY0j0E4xYtuWfSEOYOLpNGzSsaalKEW2wns2iH58w7SWIc8duaK4=
X-Received: by 2002:a50:e718:: with SMTP id a24mr20234274edn.91.1565339539169;
        Fri, 09 Aug 2019 01:32:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwq5We3boUy3Kp/R7j0mANCBCofJB12bHzkl6X+ISVflRcT02lsuU+vnpHEr0/8ST8Eb8OW
X-Received: by 2002:a50:e718:: with SMTP id a24mr20234234edn.91.1565339538529;
        Fri, 09 Aug 2019 01:32:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565339538; cv=none;
        d=google.com; s=arc-20160816;
        b=i+0uvc3CXvOzMLL7gKWe7FDLkEWzs9E4fQn7zKpmbPQ3evVh8QOPOvooJ0wZBQUvmP
         lhsg42ESXSc70Gms/R63DF2/ei2jVDV3MR6DSQvTeZTqwmFfg6mbauL/mQUW3y5529JL
         e9Qc+xQ4i+U9WwiRcOG+Wp4a8lFOVSw46tT6h3CohfR0UTv4VGO09D1BhzmyHoDHIJqZ
         1DHomr9lCtfxrQNMhInX/8bdeBeT1cZZ1S2GKfvxzhPa7HHiy4aklROikwf1MMoABg2t
         t4dvM0rKZfYbCbeVJv+C3N5lyVlVSy578lFGbcDPX4DBFN2mOrXGY/Y+AasqmeQZXaF1
         tDmg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=xIxE+xVZMQTD1DCNt3+SZQZTZ63dGBFcEDEKLCZBQhg=;
        b=li++ygQmw3zPihJOZCXnJ6eFrdt6SRpwZX+3F5dSn0wq1H7j5duPLEhJ5wB953NaRS
         fkNf5ck4TZqs5h3h/Hb8rEn/rc92YKAiKrv/rq7xlzANb2kLaNRbcY11LL+QHiVZ7JMK
         o7d8jD4Kt0Cv12VyRgYBzwgG0shgQ4HyJfndXZX/zlk0yFxHPsZPRMvXQQMEIkHhYTl4
         ldHMmsmesmVNkux6oRW9gHQbaYaaAFHIOVykWUoBfdfq9C7eWm5BMWtTkFnr3VLDpQC5
         jllCr2cR4rLZ8zBsk4lJ/GczriEiY0I5L0LOfeyU2bc98iUIZjUH8yjsmIbMO6ZRYbaE
         CyJg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c42si38489957eda.70.2019.08.09.01.32.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 01:32:18 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 8E435AF3F;
	Fri,  9 Aug 2019 08:32:17 +0000 (UTC)
Date: Fri, 9 Aug 2019 10:32:16 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: kirill.shutemov@linux.intel.com, hannes@cmpxchg.org, vbabka@suse.cz,
	rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [RESEND PATCH 1/2 -mm] mm: account lazy free pages separately
Message-ID: <20190809083216.GM18351@dhcp22.suse.cz>
References: <1565308665-24747-1-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1565308665-24747-1-git-send-email-yang.shi@linux.alibaba.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 09-08-19 07:57:44, Yang Shi wrote:
> When doing partial unmap to THP, the pages in the affected range would
> be considered to be reclaimable when memory pressure comes in.  And,
> such pages would be put on deferred split queue and get minus from the
> memory statistics (i.e. /proc/meminfo).
> 
> For example, when doing THP split test, /proc/meminfo would show:
> 
> Before put on lazy free list:
> MemTotal:       45288336 kB
> MemFree:        43281376 kB
> MemAvailable:   43254048 kB
> ...
> Active(anon):    1096296 kB
> Inactive(anon):     8372 kB
> ...
> AnonPages:       1096264 kB
> ...
> AnonHugePages:   1056768 kB
> 
> After put on lazy free list:
> MemTotal:       45288336 kB
> MemFree:        43282612 kB
> MemAvailable:   43255284 kB
> ...
> Active(anon):    1094228 kB
> Inactive(anon):     8372 kB
> ...
> AnonPages:         49668 kB
> ...
> AnonHugePages:     10240 kB
> 
> The THPs confusingly look disappeared although they are still on LRU if
> you are not familair the tricks done by kernel.

Is this a fallout of the recent deferred freeing work?

> Accounted the lazy free pages to NR_LAZYFREE, and show them in meminfo
> and other places.  With the change the /proc/meminfo would look like:
> Before put on lazy free list:

The name is really confusing because I have thought of MADV_FREE immediately.

> +LazyFreePages: Cleanly freeable pages under memory pressure (i.e. deferred
> +               split THP).

What does that mean actually? I have hard time imagine what cleanly
freeable pages mean.
-- 
Michal Hocko
SUSE Labs

