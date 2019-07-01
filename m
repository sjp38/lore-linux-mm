Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D1C31C0650E
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 10:28:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 95125206A3
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 10:28:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 95125206A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 31D658E0003; Mon,  1 Jul 2019 06:28:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2CFED8E0002; Mon,  1 Jul 2019 06:28:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1BDF78E0003; Mon,  1 Jul 2019 06:28:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f77.google.com (mail-ed1-f77.google.com [209.85.208.77])
	by kanga.kvack.org (Postfix) with ESMTP id C0EB28E0002
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 06:27:59 -0400 (EDT)
Received: by mail-ed1-f77.google.com with SMTP id s7so16498159edb.19
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 03:27:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=G1Y6TvNPf1w7LF3eEJHGGaqkZoYfNpHgoCHLeOQDRlY=;
        b=oooZOcovft6ZdoYlPMeTtQT7uk+un7W0cHfGCF5pLG16wnDLcUQs0qrGPy69PaI+bD
         HHLJmqgdgmJzL0/EyHIts1Y29UELCC41+AVs9wlNgXXVShbpKztf27Vql2+pLmJBVLO6
         v/9NHnNPoGKOo+Gm5/hx7Dahmfp0otj1ao1LcjseucVlYNJa6cm9igkUTE8KDlf62UYu
         GMGD/iVgs0d1Amjg3V+D1ae+GjPMotX04b6+Od/Rop7pih1UNu/BNaWEtQdYb4aomtD0
         RRBkIr5OLSrNlg76BZGAO56opu/pXhgFEUm8yD77spNdXmvJjazDzQzKqTttMD5s0qd7
         0Dkw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVJWSAOQJF/eatUsaqEgRw7ZO5vpJHsXLYXPk21p6LqaPy2MU8Z
	n7knpJfYgIj5nkmAG9LuaHkMtsu6UtggN6adIk4h7bNPqWrGvZ9eb/iK6wj0WSEcSaC1FuMLh4x
	eowziJaGAu3QJDotth496KwZcR7mvzuMSCz7BdE2gcQbyAlyYiRKlg1LUf1k4/QI=
X-Received: by 2002:a17:906:cd1f:: with SMTP id oz31mr22175993ejb.226.1561976879366;
        Mon, 01 Jul 2019 03:27:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxtyyh6biuYl+OlEABIuIc/7OIYmqlwxn8H+9yR8vWnolHOZQq5yVtgoTrwluHR8YDJ8/cv
X-Received: by 2002:a17:906:cd1f:: with SMTP id oz31mr22175955ejb.226.1561976878688;
        Mon, 01 Jul 2019 03:27:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561976878; cv=none;
        d=google.com; s=arc-20160816;
        b=r72kEyHmvO4eMUPwfQK82AX/voOFfpFAqg4wrWUzJqFOnzUyw31N1wiL3FHlQW8dBa
         WCQRskiTOmuTBZh4dTHMK8XefoTE7/g6K0c97LZXPSRnc+2NwBK2NSmwQXWTyqgeViJH
         HwOAZX/c9Hv6wZi9EIihn5FSd/CZYo9WDr1WPFnIdPEnnW3Hz2eguw1ABk5ndM252Uo1
         +W1euWVFXILRVh8FP2n17NQG92veSH62N8GNdNwBbivq+NCh4lA+2phyBi+5/lUH8akn
         WG0oTSppE/5rym1H+Fp48/Pf4HKF+i3vz5hiiWYzj7Es6Fd0SXawKEMrzjMm8YiIG067
         X+9Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=G1Y6TvNPf1w7LF3eEJHGGaqkZoYfNpHgoCHLeOQDRlY=;
        b=XIIWLZ/g4RXHcmVpUP46FUscxs9RcXY1Oe1c4o8hZbKeJVIcW2r13TAycLdqmErzhA
         eaBUaQquMvYsVGirzspsQIC6h6EBljjDIxQSGDDVCmjYgUBAm8FZvDozXvqLp8eySMRl
         QB2IO0QN0sona907jDKUDFs6tZpXeziICmET/K0/nF2SU2VOElwZN2EA4/wrLhWW5C0T
         2uawW1M2QTbW/fJd2lwSIZVgaqg3xygsRCVyIntaW7ihT4SLBX9A26iz9AS7RWPpfgtP
         v6f4l2LsOGkMu12KS2/TEzZSkmJkoQ95LPvf2fVMIxvZMMSFFljIpqmYi1HMslzUSbfO
         EylA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c37si9034638edb.308.2019.07.01.03.27.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jul 2019 03:27:58 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id EE62EAF32;
	Mon,  1 Jul 2019 10:27:57 +0000 (UTC)
Date: Mon, 1 Jul 2019 12:27:56 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Oscar Salvador <osalvador@suse.de>
Cc: David Hildenbrand <david@redhat.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	akpm@linux-foundation.org, Dan Williams <dan.j.williams@intel.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Igor Mammedov <imammedo@redhat.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	Alex Deucher <alexander.deucher@amd.com>,
	"David S. Miller" <davem@davemloft.net>,
	Mark Brown <broonie@kernel.org>,
	Chris Wilson <chris@chris-wilson.co.uk>,
	Jonathan Cameron <Jonathan.Cameron@huawei.com>
Subject: Re: [PATCH v3 10/11] mm/memory_hotplug: Make
 unregister_memory_block_under_nodes() never fail
Message-ID: <20190701102756.GO6376@dhcp22.suse.cz>
References: <20190527111152.16324-1-david@redhat.com>
 <20190527111152.16324-11-david@redhat.com>
 <20190701085144.GJ6376@dhcp22.suse.cz>
 <20190701093640.GA17349@linux>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190701093640.GA17349@linux>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 01-07-19 11:36:44, Oscar Salvador wrote:
> On Mon, Jul 01, 2019 at 10:51:44AM +0200, Michal Hocko wrote:
> > Yeah, we do not allow to offline multi zone (node) ranges so the current
> > code seems to be over engineered.
> > 
> > Anyway, I am wondering why do we have to strictly check for already
> > removed nodes links. Is the sysfs code going to complain we we try to
> > remove again?
> 
> No, sysfs will silently "fail" if the symlink has already been removed.
> At least that is what I saw last time I played with it.
> 
> I guess the question is what if sysfs handling changes in the future
> and starts dropping warnings when trying to remove a symlink is not there.
> Maybe that is unlikely to happen?

And maybe we handle it then rather than have a static allocation that
everybody with hotremove configured has to pay for.
-- 
Michal Hocko
SUSE Labs

