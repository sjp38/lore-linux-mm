Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 77418C0650E
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 15:53:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 467732189E
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 15:53:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 467732189E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C76686B0003; Wed,  3 Jul 2019 11:53:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C25C98E0003; Wed,  3 Jul 2019 11:53:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AEE7E8E0001; Wed,  3 Jul 2019 11:53:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 612AC6B0003
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 11:53:24 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id n49so1990205edd.15
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 08:53:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=PbrprqKsjRm70x7B3lq2YoJmdw3Fwp/r60uQoFn3GQ4=;
        b=ISgQGqBDO13jVODZ31fq6hUN70Pt54bMcjySg6SMDTuaK4BFjOOvsuXoWEYXx3l+cO
         RbsTZncaOhFgmqS6TJFp1+XLDqkVe9sy2bfZ3/dhhTkcjSB8qRyGwNRW9A/Owyc5/h5/
         9uxLVHB2mXoTa5bgK9uFgDf82mbN5qOftzqiNg32EStPaMAL3/OAZQby610pPciSsmL/
         9af8WEBNM41nunLNSG+3ADc1J1Nc/0TymNMk5SRQqKe10kgwevllLeR0yNmKrkmDiZug
         cT4BxNNxwPwRp0XAMwMpQjK7WcKDPcvInngnPiNsV7ENmnYyPSyOacCRAOwzC43EdmhE
         Ql5w==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVQfHrPl66k4gAfEz5Or7mtp3O+KDf+imACkTL2/snY2CsGsodQ
	mV1+wmvGh4y6b88+iY4V+oRq4sQG762f574KWNvV8Bhmhhut4PWggsQa6+8vQyccqo2pG+6/zga
	nv4UsVY4Z98SkEh/mY58Hd9RWpazIetryr3zEv45yU4zqCaFdfWe6tCMJ47FFll8=
X-Received: by 2002:aa7:c554:: with SMTP id s20mr42311564edr.209.1562169203853;
        Wed, 03 Jul 2019 08:53:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwqSVKsvfzm74kLitYWaIN2qSUp2kt1uqAtOHjZtqHFtoRPKeFGiCzFq7mpAuXcnZfSszbd
X-Received: by 2002:aa7:c554:: with SMTP id s20mr42311504edr.209.1562169203098;
        Wed, 03 Jul 2019 08:53:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562169203; cv=none;
        d=google.com; s=arc-20160816;
        b=vJqFqvAktAGNVxXCcV1JHogU3s74aQ9TuOF833N8db1L7IWIFZRDQ8zjoNufMfGykp
         y5bU4s53GwtDC9omZ56fIcdV+tIzw8YubRPwYguHUcELSpt9G0G5v7pl19pqijOm5Zle
         T6cIFQ0bU2p428fX+r0JmRXm1KzzbIBlpb0O8yTNyFZAAf8j82w7RFHS8g1QYiHgFN5S
         tEP9TpKp19EBiVZlrI6FMt7008sj7wIn0tZKL5rI++Pos8ij4EKMhkeY25kMGRNrjdsd
         K+7/SYSmIVR/CRcubBTD2FRr3B4J61zUX1tZ3nSDG6xGppuenEokyV8ZGSoUFJ2H7V14
         LYyg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=PbrprqKsjRm70x7B3lq2YoJmdw3Fwp/r60uQoFn3GQ4=;
        b=pkM7ccvmD/+VzHlnPI1Eqt5YqKZf1OHx24NZjwu2xI/6GKZYfBYA0uBWr+1AeU6CWD
         YT+Zmvk0Lb/sOagoSlL/uYB4arOl6SQtdtC+wBvW1ln7uDnEHMyq2zKigG3+APwV7FvX
         6+/3GR2X7B1CVuCCrFjj1FT+Reqch4N1SiWmTtjrUpp58gLSj4fbNuCW/XN9JoMUu+PH
         nxBnBL+rXJ4lKdaz5RHYOfwPLljPyY2E7++HWO6Yfp6EKh5tQsVJY7VPIfKKLEsNdE3X
         VwRAKH2Wf/lnJvaZ2KFQ8mcnZ0TCS0qwpRsoGHppBPDcF46qrjNvg/hP5LCeHzGIQzSv
         ZMQA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l8si2415789eda.181.2019.07.03.08.53.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jul 2019 08:53:23 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 18B12AD17;
	Wed,  3 Jul 2019 15:53:22 +0000 (UTC)
Date: Wed, 3 Jul 2019 17:53:14 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Waiman Long <longman@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Jonathan Corbet <corbet@lwn.net>,
	Luis Chamberlain <mcgrof@kernel.org>,
	Kees Cook <keescook@chromium.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org,
	linux-doc@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	cgroups@vger.kernel.org, linux-kernel@vger.kernel.org,
	Roman Gushchin <guro@fb.com>, Shakeel Butt <shakeelb@google.com>,
	Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm, slab: Extend slab/shrink to shrink all the memcg
 caches
Message-ID: <20190703155314.GT978@dhcp22.suse.cz>
References: <20190702183730.14461-1-longman@redhat.com>
 <20190702130318.39d187dc27dbdd9267788165@linux-foundation.org>
 <78879b79-1b8f-cdfd-d4fa-610afe5e5d48@redhat.com>
 <20190702143340.715f771192721f60de1699d7@linux-foundation.org>
 <c29ff725-95ba-db4d-944f-d33f5f766cd3@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <c29ff725-95ba-db4d-944f-d33f5f766cd3@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 03-07-19 11:21:16, Waiman Long wrote:
> On 7/2/19 5:33 PM, Andrew Morton wrote:
> > On Tue, 2 Jul 2019 16:44:24 -0400 Waiman Long <longman@redhat.com> wrote:
> >
> >> On 7/2/19 4:03 PM, Andrew Morton wrote:
> >>> On Tue,  2 Jul 2019 14:37:30 -0400 Waiman Long <longman@redhat.com> wrote:
> >>>
> >>>> Currently, a value of '1" is written to /sys/kernel/slab/<slab>/shrink
> >>>> file to shrink the slab by flushing all the per-cpu slabs and free
> >>>> slabs in partial lists. This applies only to the root caches, though.
> >>>>
> >>>> Extends this capability by shrinking all the child memcg caches and
> >>>> the root cache when a value of '2' is written to the shrink sysfs file.
> >>> Why?
> >>>
> >>> Please fully describe the value of the proposed feature to or users. 
> >>> Always.
> >> Sure. Essentially, the sysfs shrink interface is not complete. It allows
> >> the root cache to be shrunk, but not any of the memcg caches. 
> > But that doesn't describe anything of value.  Who wants to use this,
> > and why?  How will it be used?  What are the use-cases?
> >
> For me, the primary motivation of posting this patch is to have a way to
> make the number of active objects reported in /proc/slabinfo more
> accurately reflect the number of objects that are actually being used by
> the kernel.

I believe we have been through that. If the number is inexact due to
caching then lets fix slabinfo rather than trick around it and teach
people to do a magic write to some file that will "solve" a problem.
This is exactly what drop_caches turned out to be in fact. People just
got used to drop caches because they were told so by $random web page.
So really, think about the underlying problem and try to fix it.

It is true that you could argue that this patch is actually fixing the
existing interface because it doesn't really do what it is documented to
do and on those grounds I would agree with the change. But do not teach
people that they have to write to some file to get proper numbers.
Because that is just a bad idea and it will kick back the same way
drop_caches.
-- 
Michal Hocko
SUSE Labs

