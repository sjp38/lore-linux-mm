Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 13FDAC433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 15:11:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D00E120717
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 15:11:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D00E120717
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5BE0E6B0006; Tue,  6 Aug 2019 11:11:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 56D3E6B0007; Tue,  6 Aug 2019 11:11:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 436E46B0008; Tue,  6 Aug 2019 11:11:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0E2E36B0006
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 11:11:27 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id i44so54152725eda.3
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 08:11:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=RWswhwLqhvXDXjmWmaVDpuQuBobhuHME7gslFG+s6Nk=;
        b=IQQvWBBKKeCEZxu+PJ54MUYrpXg3WOpdI9CMl36uEZOL2r4w4QTCvXTymFAt9WRuXA
         di5k4LhYzggRXfsV6z4o760G2K76ngoRdEg6kT3hrH6wExPlwKA6UcXDRzQ6FKM9ok9z
         LIWMuEr+j/3NXK2FMwtVqiI1pl8wvElwyXb/jd2KhEXnivalP4pwYOe95OrPVQnJlrw+
         paIKIRNmEd2AcNcDYDNZpmKeqinvRrPXjGZGXjEUu12GEnswb8qQUJTODNPFEIdgYIyJ
         gjvuKCP5+ZoZrb0cMagerpN9xjJasOnxD5V8jKvnUH5zSJvekD7/KDKVV4EwdSLIqMb4
         A8wA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUPJbupEKtVNjmxFAQhTzvMN0KKPvdNOb6Dxy56e5TaxafhONMt
	vPqc2cnOiy0LBmDChO/gQkjUhblYApN97G+Wam5ErmQvzHsgUSszpUyEJn3Rn71ZIpz9S3QTS2P
	IZwBTI0+fP78F9j0yDE4grpfRM/FvfDhB5yTOPWSBV6nWRzIYFeLyaCWAxJ29Hno=
X-Received: by 2002:aa7:d985:: with SMTP id u5mr4311640eds.222.1565104286622;
        Tue, 06 Aug 2019 08:11:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxz2APTYXv2GeNTuAD2qdwsYPRzUpBTtCzg+IrU2pVKUZMgbecNtGs8FMhTK1ZtDSKG+hih
X-Received: by 2002:aa7:d985:: with SMTP id u5mr4311604eds.222.1565104286133;
        Tue, 06 Aug 2019 08:11:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565104286; cv=none;
        d=google.com; s=arc-20160816;
        b=xgrUsjABfGEX465l0uMaoVrXAdHaFT5x3YbJpOlNHOrbdGqhJOn17I67oQ3MvlrBo0
         UxBiXoTVB9cf7gs5bdC2lcxhYcR2eglJDl6WPX7/iU9tJc29dnizGl6d7Hll/VDZ+PPD
         1FKNW3EyHPGbsXCXHSkPt2L2gbk+JqbZ+DEKFG2uh5QrIvWVaC5AXiYN5EZDIW0tPbPo
         aoTDXJI9dc7yY+Oqo/9eH30Pz1MI0ykAaZOK/FcYQQhspNhUeyrfitnIC4rNd2w3T9IE
         +l80GB6Y/7AnV+S7J0XFU1lNV9Hd6kMISBJceVcLeZS4/W4+NIX5xLef2K+CGVyUwFhO
         VHdw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=RWswhwLqhvXDXjmWmaVDpuQuBobhuHME7gslFG+s6Nk=;
        b=a4fKggQktWvxRaoLKCXWSH1N8GOyemJa5edCFWQNSE/ZoJuXXu289NujOUp1u9Ue+R
         7B59/XUhlBYgqteP6XlEYcPrzAIScrRvQgpvKQ/uDzWKnOivXphrh+NXIrfJa0pfMuUv
         H/Mb9P/vQxzIVd5OW/dl6D2UkTawjsyj/MnP3Ob0baZ6K6n1AmzpiE8Cx7ceMBJ3X7V1
         m9Wvhvn8XLTqcADjR+Qkf1GXR8HF++7Ic8rwsNy+3Ycu7yRKtiiFPZenL8V5hNoRq3r4
         jxsbFCxYv35YYq9fowuzwagA9VZyNZgCJ2nw1VpGJQd9hoLJGy0tc8kzvwdyUAfKJ5wi
         tQpQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s8si33711564eda.92.2019.08.06.08.11.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 08:11:26 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 5BEFFAE65;
	Tue,  6 Aug 2019 15:11:25 +0000 (UTC)
Date: Tue, 6 Aug 2019 17:11:23 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Pankaj Suryawanshi <pankajssuryawanshi@gmail.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, pankaj.suryawanshi@einfochips.com
Subject: Re: oom-killer
Message-ID: <20190806151123.GI11812@dhcp22.suse.cz>
References: <CACDBo54Jbueeq1XbtbrFOeOEyF-Q4ipZJab8mB7+0cyK1Foqyw@mail.gmail.com>
 <20190805112437.GF7597@dhcp22.suse.cz>
 <0821a17d-1703-1b82-d850-30455e19e0c1@suse.cz>
 <20190805120525.GL7597@dhcp22.suse.cz>
 <CACDBo562xHy6McF5KRq3yngKqAm4a15FFKgbWkCTGQZ0pnJWgw@mail.gmail.com>
 <df820f66-cf82-b43f-97b6-c92a116fa1a6@suse.cz>
 <CACDBo57Yjuc69GX+V7w_efSHPkpeU3D9RUr0TEd64oUTi4o8Ag@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACDBo57Yjuc69GX+V7w_efSHPkpeU3D9RUr0TEd64oUTi4o8Ag@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 06-08-19 20:25:51, Pankaj Suryawanshi wrote:
[...]
> lowmem reserve ? it is min_free_kbytes or something else.

Nope. Lowmem rezerve is a measure to protect from allocations targetting
higher zones (have a look at setup_per_zone_lowmem_reserve). The value
for each zone depends on the amount of memory managed by the zone
and the ratio which can be tuned from the userspace. min_free_kbytes
controls reclaim watermarks.

-- 
Michal Hocko
SUSE Labs

