Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 43429C7618F
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 15:57:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1033B217F4
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 15:57:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1033B217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8DC7D8E0006; Thu, 18 Jul 2019 11:57:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 88D528E0001; Thu, 18 Jul 2019 11:57:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 753DE8E0006; Thu, 18 Jul 2019 11:57:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 25C8C8E0001
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 11:57:08 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b33so20233866edc.17
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 08:57:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=SVRVJ6ku0Lh30S7upn2pQxZyI7oLhrU90aVBWDg5Wc0=;
        b=gCY8Q+VXqowY4I66pDtmDnrKzC3NAIHOmH+Z+J3Sqff2CJMzih1F86s2n/kiZcpFjd
         4bKfThLtwDZeCpKxxQubtlopP0E9Qt/HELCQKWa70ZAj6gWKpgLi6XDrlgAanGiMR/Zg
         09n7ZQcXf3VkzLG4bPWUsWQWQCGRVlS8e2P+q/0nyoMc3wkcpGlaF+u6/+/0gzbcFekM
         eI23Z2wqQJS4/4adDD+FZT9u4hVLfcjRb6iGPHoCbcc1GiVf837ZtUijvzaNi1TEn0T7
         3KLywYXj0M3pOLPJdDL5LHHzRCPSFYKOHF7UoHWD5pFzwnzD2jeSvlZqyS8twpaoBffE
         uGvw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXTGGGCgNTCtmHqLDsPivvCQ0gcRpeL+GlGbTJUuAtPCp84mKrv
	sXMYXRVpDFGEM4IsJ2FMuZHPjLxZJiHQVU9R+OkIA40Qy+d2BMFK/lDhPhQfIkLgXS4KqBZ30Dm
	IK15LnR4uh7WF6bG2Kv9SpMWUZuf/covN3GJkZukhSLqb+E24mxf2frnBm7vxSmg=
X-Received: by 2002:a50:f410:: with SMTP id r16mr41736908edm.120.1563465427729;
        Thu, 18 Jul 2019 08:57:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxnGQIde92E43B7Nwd/1jF2csLgFwM1S4ERX4KHZ4DK8bxMAXsADH76a3+cXH9Yzju1jX4C
X-Received: by 2002:a50:f410:: with SMTP id r16mr41736862edm.120.1563465427100;
        Thu, 18 Jul 2019 08:57:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563465427; cv=none;
        d=google.com; s=arc-20160816;
        b=IiwhIb3cpbtWB8CN6IenQOcq7wggbywblXbUEC8AvLxO9NMIyMpYJyPK5gHu8AJzE3
         Gdj9BS0AMbISLMYJwU/Lh5q6KL0x8F5RcS7C7b5FFycjCtnouh0QqMHLLcWhm49kA2ef
         6xQG6qs6YkNIu7vZSk3yscPBkEB3of8nD7GebpYXd60mJ7wkeP5HUtgx+84ousgIo92u
         +mKy+cLOUz7ItRUghHmluNtDIYfuwjlbyZ45hqFIrDX+RRouzu6vp+AuTDt3D321Wjwf
         JSY51HrZZ3PfFPZPDNMsapITTB7/yvl7el6tTQ2CqOMJ29/OV1ynv7sgT4+bdtcLU8rj
         5P9Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=SVRVJ6ku0Lh30S7upn2pQxZyI7oLhrU90aVBWDg5Wc0=;
        b=F4+FjGUU6XaxXgCeV+q0t9W5ETxQajHb/MF5S3pEAVwKRXhoM4aQUiHwmd7CHNblDN
         4sF2ujXfvCpOoRHkV2Hb5w2gYYrMFrip8owqfN/1AWmBPeBinR2FRthoehVyXUR5+rqm
         uEqdybig5bncUHlIZSM8g2VWr5n+3Wm72BcU0Ao/RdkBoq6Is/7p8/LPPGfDCkG2fu9c
         5XHldkZS4VxAClgTVgp+f5/mdc/vUfC6zLDiEGq9+RACqO0S5MOWVtdrkWHpqCQLVcrT
         Rq7/jTuJhGcFuBcdGAt3/voxXEp/XPWqMhagO7KVK2x6+Fuw8kS+PkR5SoMGsg34cg/7
         qkxA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w23si219048eju.93.2019.07.18.08.57.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 08:57:07 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 438B1AF6B;
	Thu, 18 Jul 2019 15:57:06 +0000 (UTC)
Date: Thu, 18 Jul 2019 17:57:04 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Leonardo Bras <leonardo@linux.ibm.com>
Cc: Oscar Salvador <osalvador@suse.de>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Pavel Tatashin <pasha.tatashin@oracle.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Pasha Tatashin <Pavel.Tatashin@microsoft.com>,
	Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: Re: [PATCH 1/1] mm/memory_hotplug: Adds option to hot-add memory in
 ZONE_MOVABLE
Message-ID: <20190718155704.GD30461@dhcp22.suse.cz>
References: <20190718024133.3873-1-leonardo@linux.ibm.com>
 <1563430353.3077.1.camel@suse.de>
 <0e67afe465cbbdf6ec9b122f596910cae77bc734.camel@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0e67afe465cbbdf6ec9b122f596910cae77bc734.camel@linux.ibm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000005, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 18-07-19 12:50:29, Leonardo Bras wrote:
> On Thu, 2019-07-18 at 08:12 +0200, Oscar Salvador wrote:
> > We do already have "movable_node" boot option, which exactly has that
> > effect.
> > Any hotplugged range will be placed in ZONE_MOVABLE.
> Oh, I was not aware of it.
> 
> > Why do we need yet another option to achieve the same? Was not that
> > enough for your case?
> Well, another use of this config could be doing this boot option a
> default on any given kernel. 
> But in the above case I agree it would be wiser to add the code on
> movable_node_is_enabled() directly, and not where I did put.
> 
> What do you think about it?

No further config options please. We do have means a more flexible way
to achieve movable node onlining so let's use it. Or could you be more
specific about cases which cannot use the command line option and really
need a config option to workaround that?
-- 
Michal Hocko
SUSE Labs

