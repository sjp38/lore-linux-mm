Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 247C3C28CC2
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 06:23:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E666E263A0
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 06:23:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E666E263A0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 75BDD6B026F; Fri, 31 May 2019 02:23:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 70C0A6B0278; Fri, 31 May 2019 02:23:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6217E6B027A; Fri, 31 May 2019 02:23:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 12ECC6B026F
	for <linux-mm@kvack.org>; Fri, 31 May 2019 02:23:21 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id k22so12432400ede.0
        for <linux-mm@kvack.org>; Thu, 30 May 2019 23:23:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ooUoMzCUpHYyT49z+y07Ex+8MwaPFZx4WdfiD9O/qUk=;
        b=cFI1f9mh/9fRwZZItcvgzW21E6h/hurkiWhgKIrL4g1/k/nbytRD4X6ZrFuYKfM+tp
         jH1oVD39nzc1C18BhmK90s28/pwbV/6y90yqmKvdqyvy2/QWnKk78gVu+VLOjPYFptep
         mvQIy4iMm/n2S+jCFh8f5wAzyFlyyrDjE1iaW5btcLG2807ggHSEYfLzoenVCgBDBgQ0
         OxrkPPSml3GZJvEbDeoMq0QZSXvMpYYGlhsSLx2Y+ZVCcE8KkWUnlKXXc4PANFhsmjpB
         Pl6gD9epczC+dpNTkAio36gyBj7IvR0seSJwa2RSFK4XwcrZc4ivD6/zRj3zgcAOkr7K
         GnbA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXljINzDZZZjjceaVMrVCSyLH8PL+5y4RtKSS4is9cRO4xyNUgW
	H7nYdixYPvzSBR5VkXkI7r6wsFSCUECM4hXP9TnnKOPzVCmwb2CkTz+86F2Ow35rm8WbzSd4qov
	ENL64O2cjOjb5sSt4Iwrvcgjv0YQ9A2JCMcDyW+T+2yCdKeST4NlbWenicbAMItw=
X-Received: by 2002:aa7:c554:: with SMTP id s20mr7676070edr.15.1559283800642;
        Thu, 30 May 2019 23:23:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwAFsSiqKvriJib4oH1eSTXWCdzq1/lkRO+2Ngc6aACI2IZfbdcsgozd86cIw4aF35sJpN+
X-Received: by 2002:aa7:c554:: with SMTP id s20mr7676028edr.15.1559283799990;
        Thu, 30 May 2019 23:23:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559283799; cv=none;
        d=google.com; s=arc-20160816;
        b=C38/Yh/0psyEi/GESlD49qwHA3dNCRtKL5K9eqWOcFK5393MtM+Ziupnv42aNTTjcT
         8xl11gH49ef5GsSdpijA/HlGGaa6pza8OXgdjP7fPy0/mcBve2xlgQ0mSZUDgxbWOTAx
         E6zz0gz1fUT+31Nl8Y/126t+Dg+syedpxOqBwLPX0Mq0nhL1CAVCzhcJ8WBHCgrJZmZg
         wUZ7Yy4VK4fSevDyRl4YmUdKO7hL4Kk3EwTkLcz+M0qeThOR2geLCOApr+rSiy0JUQ/l
         wNBYaLp+aEiqPMeFkArLVgkvRK1tCko1iKpsmLLiUPHPJwIQ196yFntGTX2vYoz5baZo
         +1tg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ooUoMzCUpHYyT49z+y07Ex+8MwaPFZx4WdfiD9O/qUk=;
        b=iZg/F7PVICtH/KqVrBx78BWT3Yu/yV4m1bML/g41LZaPDE0U4d7zOEufm07VLf+b4W
         jzo37jmvjpkWi5bnRLNRdOD807UDjQtfSjjdsAW+Otf5bvIYqfz3Hx6NcCoGZAjU2glD
         Hi8dZ1v4PRcexeopLlQg90pg9l+zhYf/UjA5dYOOl+0va/GuLIaD1h5gzqVmhUhjLNyc
         9HdKXl6liQ+v2aK9RfzALN41lmm33Bvc/CqZhHGtrC6wFJX4lTA0HdExK/wYpC+jK13Z
         cvhZMhURO79XPnPEl5bHaqgUfbSC/64PoU2EB5npZ9yCWO53lvtrZcbXztZV/BbVDkZ2
         Gs0A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h8si3236151ejz.140.2019.05.30.23.23.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 23:23:19 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 98B73AF60;
	Fri, 31 May 2019 06:23:19 +0000 (UTC)
Date: Fri, 31 May 2019 08:23:18 +0200
From: Michal Hocko <mhocko@kernel.org>
To: semenzato@chromium.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, sonnyrao@chromium.org,
	Yu Zhao <yuzhao@chromium.org>, linux-api@vger.kernel.org
Subject: Re: [PATCH v2 1/1] mm: smaps: split PSS into components
Message-ID: <20190531062318.GE6896@dhcp22.suse.cz>
References: <20190531002633.128370-1-semenzato@chromium.org>
 <20190531060401.GA7386@dhcp22.suse.cz>
 <20190531062206.GD6896@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190531062206.GD6896@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 31-05-19 08:22:06, Michal Hocko wrote:
> On Fri 31-05-19 08:04:01, Michal Hocko wrote:
> > [Please always Cc linux-api mailing list (now added) when adding a new
> > user visible API. Keeping the rest of the email intact for reference]
> > 
> > On Thu 30-05-19 17:26:33, semenzato@chromium.org wrote:
> > > From: Luigi Semenzato <semenzato@chromium.org>
> > > 
> > > Report separate components (anon, file, and shmem)
> > > for PSS in smaps_rollup.
> > > 
> > > This helps understand and tune the memory manager behavior
> > > in consumer devices, particularly mobile devices.  Many of
> > > them (e.g. chromebooks and Android-based devices) use zram
> > > for anon memory, and perform disk reads for discarded file
> > > pages.  The difference in latency is large (e.g. reading
> > > a single page from SSD is 30 times slower than decompressing
> > > a zram page on one popular device), thus it is useful to know
> > > how much of the PSS is anon vs. file.
> 
> Could you describe how exactly are those new counters going to be used?
> 
> I do not expect this to add a visible penalty to users who are not going
> to use the counter but have you tried to measure that?

Also forgot to mention that any change to smaps should be documented in
Documentation/filesystems/proc.txt.
-- 
Michal Hocko
SUSE Labs

