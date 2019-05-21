Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A87DCC04E87
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 15:45:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6E2D7208C3
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 15:45:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="rfl6geAC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6E2D7208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E5DE46B0003; Tue, 21 May 2019 11:45:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D9C816B0006; Tue, 21 May 2019 11:45:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C17696B0007; Tue, 21 May 2019 11:45:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7FAA76B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 11:45:52 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id a90so11603212plc.7
        for <linux-mm@kvack.org>; Tue, 21 May 2019 08:45:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=DCgLiR019LUQfhnXl76ud5P8ct/eu8hvw0HpmgFMVXQ=;
        b=BYrQzjBq8wxm+pvnQH0qq/9cEu2LzDvVAkWvJjZ5vUa+XfBZ2zuc180qAUsZt7N1bq
         EBL1QwTsLN8efKe/Uw/6lenK+r3YuToX8wwuOWiw7TQKbrZospvc4TeEdU3iXVUAU+Qe
         CMJeZPC4pE0k/gVahC0YgIH/wbk3eyMyOvdJeXRj8HMK6REnaJlvNN68VG5AtzAp1XnD
         tkHkdATmFdRqZA2/yOh+478KVoSjzWtvlIQ1bDaoEAKcCSUCfF4CtP7iZGnK583rdQuX
         8nnxfkBT9s7I//JjnCTiaq+VNPqCUw3LQEy+GH0ah+S6JSUe4hW35SNia9RVUFh7nZAa
         FJhw==
X-Gm-Message-State: APjAAAXFAkiULfUxa0gClCSTrOgY+B0zHZTctO224jaQl3n/CuIOnqJW
	Xc2v9YUddpn6wIh8v8lLqTaIXkdEJ/YXO/wLqY/VxJG2Bp2efXquJthhcOz1iLxHRkffWKeW0H6
	YCI1HKqw1f9WAlZpcScMBH4/zYWcrM3Xxb9MF5cUjY7LWntSKqfT20SSnGWbzQTifpg==
X-Received: by 2002:aa7:8f22:: with SMTP id y2mr76356204pfr.22.1558453552158;
        Tue, 21 May 2019 08:45:52 -0700 (PDT)
X-Received: by 2002:aa7:8f22:: with SMTP id y2mr76356142pfr.22.1558453551510;
        Tue, 21 May 2019 08:45:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558453551; cv=none;
        d=google.com; s=arc-20160816;
        b=FRyv15B7jiQbXrI4C+0AsrdOzGz/CSYyd5Gn9ILQKto2MWWzpVwYbZvbPJ/beKx0s/
         bIGQ1bWJKxbBy/tA8bZjywhpcqsF6S+OfzYKskXVHuz0ejMe3UAuBcIjumknABSvBqwm
         zD3e8IXmZYXAJhkzYT6jeraKM1BLBs5hkh5xp2VsQmW0fV3Xg3bhu+THRL7J32M5rZC2
         Ia/zH6kkE4xUKL5BrQMrb+R28c44S5tkn6d82468Ggd5LM6c5zeP6iULi0e6wIQbZKZO
         jaq6upE+yeY4jyl6io5archc5WC5+OSWFrb9zfAH5+WYr9VYhsFzUKDD/61800VHEn6s
         0ZcQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=DCgLiR019LUQfhnXl76ud5P8ct/eu8hvw0HpmgFMVXQ=;
        b=iPp3QHi7I4x+KbK/WDqb4Z5csSafE6QbG4XPWJPa2jT21ITAOKkspPODNdKcJbKXrv
         smZa0qJcTDavLat+yKNagWKaF80RDuh3iaDhvkANRh2qK7ljfbxx85W7J3El8W4wVduC
         x5oSdjjn2+iGrZjsK0ceBPZLnPhts3nzeXe0blTZVBLR0vzv4mdW7xVwqyQ/25t3hXZu
         oL0sYuoIoQQNooayAe4edf9aAqwFBjKKIFQ2O7KPqKjpd98zYgbRcnqy52JRccRVk+vy
         h17W+qwjvJDs3PXCKz47Cl+YlU1fY3czzRGrhZrd5xuHIOe24ImmtrPh7UmDeViCWDS9
         hJWg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=rfl6geAC;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d92sor17959199pld.33.2019.05.21.08.45.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 May 2019 08:45:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=rfl6geAC;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=DCgLiR019LUQfhnXl76ud5P8ct/eu8hvw0HpmgFMVXQ=;
        b=rfl6geACXaznE893Xv6EgsaoZwgicisSZNkTyws+FFmrjw0cygFwzOxsanbZMxvOf7
         6nSazz6qkCSgtzpNrz//Z0sti/qux5BfsEeQpe+9GbUFQ4F7Dmk2r0FnoE/WPfRXN90k
         8RRBaIX56/CJcvv0P1a5qYQ1bFdsoK2JKwlFNG+uJDsWnxUChFVNBCQvAXr0vq4KGSph
         JuAiFZCdMhxHo3BqWgWC3bsYnHIJhGI7oCzQKzV+gVv1tTbiJ9kaSZR453A4nFGOR1+e
         q8xc6+uuS8Hm84nvH19ohB3e+sXPemZlk/aeTiv3iKYhyfTJWvEpqn/jfzhFmFW28wgf
         xcvQ==
X-Google-Smtp-Source: APXvYqy660k6G3n/CoK0UJH2aQhhfLekgKFUK4qr3XL++igjtjitHM44q7FxegqNyS4YiSWiviy6/A==
X-Received: by 2002:a17:902:848c:: with SMTP id c12mr34232829plo.17.1558453550759;
        Tue, 21 May 2019 08:45:50 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::2:6169])
        by smtp.gmail.com with ESMTPSA id 127sm26255492pfc.159.2019.05.21.08.45.49
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 21 May 2019 08:45:49 -0700 (PDT)
Date: Tue, 21 May 2019 11:45:48 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: ying.huang@intel.com, mhocko@suse.com, mgorman@techsingularity.net,
	kirill.shutemov@linux.intel.com, josef@toxicpanda.com,
	hughd@google.com, shakeelb@google.com, akpm@linux-foundation.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [v3 PATCH 1/2] mm: vmscan: remove double slab pressure by
 inc'ing sc->nr_scanned
Message-ID: <20190521154548.GA3687@cmpxchg.org>
References: <1558431642-52120-1-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1558431642-52120-1-git-send-email-yang.shi@linux.alibaba.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 21, 2019 at 05:40:41PM +0800, Yang Shi wrote:
> The commit 9092c71bb724 ("mm: use sc->priority for slab shrink targets")
> has broken up the relationship between sc->nr_scanned and slab pressure.
> The sc->nr_scanned can't double slab pressure anymore.  So, it sounds no
> sense to still keep sc->nr_scanned inc'ed.  Actually, it would prevent
> from adding pressure on slab shrink since excessive sc->nr_scanned would
> prevent from scan->priority raise.
> 
> The bonnie test doesn't show this would change the behavior of
> slab shrinkers.
> 
> 				w/		w/o
> 			  /sec    %CP      /sec      %CP
> Sequential delete: 	3960.6    94.6    3997.6     96.2
> Random delete: 	2518      63.8    2561.6     64.6
> 
> The slight increase of "/sec" without the patch would be caused by the
> slight increase of CPU usage.
> 
> Cc: Josef Bacik <josef@toxicpanda.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

