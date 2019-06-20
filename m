Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A088DC43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 10:55:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6AD642075E
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 10:55:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6AD642075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 09C938E0007; Thu, 20 Jun 2019 06:55:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 073E08E0002; Thu, 20 Jun 2019 06:55:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EA5718E0007; Thu, 20 Jun 2019 06:55:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id B07F18E0002
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 06:55:18 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b33so3720379edc.17
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 03:55:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=HWB6I6qwTBLuFCielVRE3Fsv1M7FpNu2jxa57O/iHvo=;
        b=pU7KDROUhUbzXhHz+u/A3xoF8PRmmFlkm8548/H3JKc8zLyYye6Abes3RNWPTEOeKf
         ut9/i7WAu1B9AGqtygB/uboKYQKgn44F5XkA+5JQhzOxG502AHoIR2BAOlFAebjuG9ry
         m00QScHdkw+BEO0ydE2WC8Wqt6sLqUjJnWum2ZreABo0V1Ltz22bgLEzDlWzTCFn/N2O
         jBFhDj4GdzC0EheVtLb91YYzIrsHe0DNTAabVTNT847LKLLJK0kUUo2F471Z8adFiZPt
         OotFIUvK9ECF1H5P+k0Y58LhTYu/uuKrlcBQCiUMh038kh4DIxAWB0RJhPanXO0hm+0b
         oiKg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUXY7elT+pCsMu4AGgKNYmjY07/1lHml+l00WkvDYjQoE+5251h
	4iAagwSbuL9ug6olVm9Bs1AsRLvkvwjU/IhSh+d6aXkAjkU+JjQjY6K5GixlciuXz8tF/snt6jA
	PYoczi0b3MHToSjiq8ExmcEE0BGB3NUvjQyCvtDjYteB87TnDcktBGWSteDmUses=
X-Received: by 2002:a50:b1bd:: with SMTP id m58mr34581477edd.185.1561028118303;
        Thu, 20 Jun 2019 03:55:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyN0RXaa4cLycabo/+dDvN3ysIe9uKK7XWcBTwP1pXClrA7YJ+Udeo+Xg2XgqK3LDNgGbEG
X-Received: by 2002:a50:b1bd:: with SMTP id m58mr34581430edd.185.1561028117579;
        Thu, 20 Jun 2019 03:55:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561028117; cv=none;
        d=google.com; s=arc-20160816;
        b=oc8Xj4D7JzWTFNt3+Sq6ojB8VLuPpswPdwjwXCMlOLdJ0xtv1BsyeHMO9o4/79sPhJ
         1Mc0p34wmdTsGoYu8Y4KUZdJ0vJqVFk9L9OKjikhZ7aPMAjAVp/j7GtGl//aM/qUCy67
         sJ5AHNc8+jFO8377y9V0Q96f7X2FLMLyfC2kuWgT/BcgwSsX3rVJUIco6/XlVkm/8PPN
         KGKeB2bTtmCF0Wcsxlzs/vy5quLJ3APU58w/KObrNDYZKxzPySOQ7YNLI7pPrnYCigqS
         SfXBTCRTUwUknMoWHF98gG96tMJBv6gSFC/2YmkRHsOpFI9IGl7EZ8ZBiPwo/drwIjBR
         NfOQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=HWB6I6qwTBLuFCielVRE3Fsv1M7FpNu2jxa57O/iHvo=;
        b=avsXbg45fxaGH2GMqnKTvt6AJIyV1OAa56Mi31Io40hi7xZx1n5jp7OQbPaQON9TDN
         AMix6dzQBoyBH5OEZxX77ifowYMjWiYPYeegK8qaqYTDBHKfoKfq5Y51xT6psWvADan0
         6e4PvcZ3TeOtk9r/3kJ/2dufTejjd/ypbXNAE1N30EFK0r1xIQ4RR+SO5mDyzvev2Cnq
         EJWKHNxCzV9wNqSlqfTalh9vktLVGyZXH8s+ZFnVMNyR3Yle0qciCfmvZnLA3dBIIY+G
         eZqCbzUSmSzzMWkLAsROqbSWgnTaLPiJIeXJGO+rPY0/X6rxo6aqVlb3ToGT/Pf0sfua
         5uAA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h12si12654591edi.314.2019.06.20.03.55.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 03:55:17 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 03F8AAD12;
	Thu, 20 Jun 2019 10:55:16 +0000 (UTC)
Date: Thu, 20 Jun 2019 12:55:15 +0200
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
Message-ID: <20190620105515.GE12083@dhcp22.suse.cz>
References: <20190610111252.239156-1-minchan@kernel.org>
 <20190610111252.239156-5-minchan@kernel.org>
 <20190619132450.GQ2968@dhcp22.suse.cz>
 <20190620041620.GB105727@google.com>
 <20190620070444.GB12083@dhcp22.suse.cz>
 <20190620084040.GD105727@google.com>
 <20190620092209.GD12083@dhcp22.suse.cz>
 <20190620103215.GF105727@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190620103215.GF105727@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 20-06-19 19:32:15, Minchan Kim wrote:
[...]
> Then, okay, I will add can_do_mincore similar check for the MADV_PAGEOUT syscall
> if others have different ideas.

Great that we are on the same page. We can simply skip over those pages.
-- 
Michal Hocko
SUSE Labs

