Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EC125C32753
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 13:33:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BC66E206A2
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 13:33:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BC66E206A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4A17A8E0003; Wed, 31 Jul 2019 09:33:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 452C78E0001; Wed, 31 Jul 2019 09:33:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 343428E0003; Wed, 31 Jul 2019 09:33:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id DD1018E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 09:33:46 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id l14so42439654edw.20
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 06:33:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=SseHCc6KL5FSzccylaQ89Sfy0DBxYWxEkLKPyaFKMOk=;
        b=TcMpygqocHflxgwx5hAjh03xte+IlaGp+pdeXTa6H7ZmPYUWsrfy7HbazYcyQ6Gi7Q
         nyqV+KrjC05XaB+3LaBC2/8X8QYMHNBH0gs2A2wuKOdirtH9xkf8ss7k3tdBPJD5PXjZ
         b5UFxwvb7hgMVXaL6HaKnGwLUT3e/zE6MT6LM0DHtFXE5seHWJ7waVRWY4V/YLOC6hQ/
         YK4nAEUwGDKTSJZWLl1P7YSp8NvQsqOr/H+aaPGHaHN1cQJVtNXwe2V0c6HBSlt00tjV
         5Q5R+Bhfl8kk0o3FhZC1q6QO9zqxZ4bE2NiHPNHI5rf5K2Xde5Lj0vYq4Y4mORR9Iq+B
         tFCA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWpAId9hcq0luKRUqpJjCXtJTG5U4Zruj12XFucqhLwJXjTxM+N
	Gs4xThytOPLtNILDtC1rPb4y1zWiFPjFvKfRrQKjRerRl4edYTTorxgyluMqOsY7LIAfmKxMVKE
	8zbqmxiOgAuc/p76LGfNlYCr4PTm6E6/VdU4XDs9KeQgrGkBIxw1wYcFg7xgC+AE=
X-Received: by 2002:a17:906:1911:: with SMTP id a17mr94561302eje.290.1564580026452;
        Wed, 31 Jul 2019 06:33:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwIIE7NxDh8JmqWIPSRycSavrqKI+PI1uIAcMwFIDM3V4ZC3ahY8vwUIpjm9BuQNoqqPja9
X-Received: by 2002:a17:906:1911:: with SMTP id a17mr94561223eje.290.1564580025541;
        Wed, 31 Jul 2019 06:33:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564580025; cv=none;
        d=google.com; s=arc-20160816;
        b=hvu8xScZiBrE66VsF3ewW4uDO6AT7iBMLCT0Szewm6g35EO7xiBs6CmTUtcZ9C0vTd
         E7YTKr11YbzWUUwckLW9vJq7WyosZU0FieBvRcW8vcPoF5Yeoc1L5YmC5z8/A+POcS6R
         QhsL86EWPzujg2fyKfIYo77TWnrmRBYja1PBYEQMTp1HlPsw3IU/5we9pDcMnOELwrPx
         AuFh9bN2HeN6c7uJTlkSooLeWEg1ZxmX9+bUY3Q+2uFXztQRsLjtVYJt7m4kRWuMJVv6
         r1B270jxJElNS1T/r0KIh6ABN1rlw45xPvaGQfBoiRfZjf4O+MuVZnH3n6yz8p6kb4Px
         sm0g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=SseHCc6KL5FSzccylaQ89Sfy0DBxYWxEkLKPyaFKMOk=;
        b=heU6gulwntLGMIlLCEm+zswn+67Vd4A9Dst2EHZJarXB62dGdoJ5NQEexz8tH4qMZ2
         3yvs4hjOImjP/k3Q5oZqw0GxGBI18odeHmsGQnG+TX47ZmNakwbaaLYpHu9MfdNdSehS
         yYpnVGd0KnxNRmHFEsFz3mlaseXjhFr1fDf7/7wxKjK0O6c7pFHCnoVoy0Qt0RoHNti8
         igqgMwFJzFmepPaIKBWkyauaV5oF6h/8hwXfPhhOHg83Pk/EkpiSORj/p0YDK0OklL57
         cJgocNmr4Ve525VpyKuM8W8+5gFf67rWFuQ1iXtafI7+Zcb3FAB++Pzw9Sqi9XT/vFeC
         ttQA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id um8si18516740ejb.373.2019.07.31.06.33.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 06:33:45 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id C41B9AFCF;
	Wed, 31 Jul 2019 13:33:44 +0000 (UTC)
Date: Wed, 31 Jul 2019 15:33:44 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-acpi@vger.kernel.org,
	"Rafael J . Wysocki" <rafael.j.wysocki@intel.com>,
	Oscar Salvador <osalvador@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v1] drivers/acpi/scan.c: Fixup "acquire
 device_hotplug_lock in acpi_scan_init()"
Message-ID: <20190731133344.GR9330@dhcp22.suse.cz>
References: <20190731123201.13893-1-david@redhat.com>
 <20190731125334.GM9330@dhcp22.suse.cz>
 <d3cc595d-7e6f-ef6f-044c-b20bd1de3fb0@redhat.com>
 <20190731131408.GP9330@dhcp22.suse.cz>
 <23f28590-7765-bcd9-15f2-94e985b64218@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <23f28590-7765-bcd9-15f2-94e985b64218@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 31-07-19 15:18:42, David Hildenbrand wrote:
> On 31.07.19 15:14, Michal Hocko wrote:
> > On Wed 31-07-19 15:02:49, David Hildenbrand wrote:
> >> On 31.07.19 14:53, Michal Hocko wrote:
> >>> On Wed 31-07-19 14:32:01, David Hildenbrand wrote:
> >>>> Let's document why we take the lock here. If we're going to overhaul
> >>>> memory hotplug locking, we'll have to touch many places - this comment
> >>>> will help to clairfy why it was added here.
> >>>
> >>> And how exactly is "lock for consistency" comment going to help the poor
> >>> soul touching that code? How do people know that it is safe to remove it?
> >>> I am not going to repeat my arguments how/why I hate "locking for
> >>> consistency" (or fun or whatever but a real synchronization reasons)
> >>> but if you want to help then just explicitly state what should done to
> >>> remove this lock.
> >>>
> >>
> >> I know that you have a different opinion here. To remove the lock,
> >> add_memory() locking has to be changed *completely* to the point where
> >> we can drop the lock from the documentation of the function (*whoever
> >> knows what we have to exactly change* - and I don't have time to do that
> >> *right now*).
> > 
> > Not really. To remove a lock in this particular path it would be
> > sufficient to add
> > 	/*
> > 	 * Although __add_memory used down the road is documented to
> > 	 * require lock_device_hotplug, it is not necessary here because
> > 	 * this is an early code when userspace or any other code path
> > 	 * cannot trigger hotplug operations.
> > 	 */
> 
> Okay, let me phrase it like this: Are you 100% (!) sure that we don't
> need the lock here. I am not -  I only know what I documented back then
> and what I found out - could be that we are forgetting something else
> the lock protects.
> 
> As I already said, I am fine with adding such a comment instead. But I
> am not convinced that the absence of the lock is 100% safe. (I am 99.99%
> sure ;) ).

I am sorry but this is a shiny example of cargo cult programming. You do
not add locks just because you are not sure. Locks are protecting data
structures not code paths! If it is not clear what is actually protected
then that should be explored first before the lock is spread "just to be
sure"

Just look here. You have pushed that uncertainty to whoever is going
touch this code and guess what, they are going to follow that lead and
we are likely to grow the unjustified usage and any further changes will
be just harder. I have seen that pattern so many times that it is even
not funny. And that's why I pushed back here.

So let me repeat. If the lock is to stay then make sure that the comment
actually explains what has to be done to remove it because it is not
really required as of now.

-- 
Michal Hocko
SUSE Labs

