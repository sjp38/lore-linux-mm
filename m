Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C3E26C76190
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 07:57:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 915692166E
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 07:57:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 915692166E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1633C6B0006; Fri, 26 Jul 2019 03:57:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 114F96B0007; Fri, 26 Jul 2019 03:57:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 02AB68E0002; Fri, 26 Jul 2019 03:57:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id AA5006B0006
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 03:57:31 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id i44so33646521eda.3
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 00:57:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=/d82FpnxsJ+doW4zz6SvGj8uwEgjo1fA/TwTViO67UU=;
        b=VxbSmq1jYzSY/fHB6uzVvj0n8pGszAcnYz7/POG0VykLC6eB7RUrCHjGw6kyaqyX/2
         tEiufGNUXndQhZNLDf9yptLahJ2ATmdgAcyJDwd2UbGq/mcIzzqnvoDv5vceaAiew89o
         7daRsvKJyJm8s5a5N8EVs534HDhiKb3sRWBZCyVij1JVtx2EAWwrr/WFgsgdwSunzR8J
         1XdIXcx7ce9jC2YEWt+aO5pd9UjscT6uLkFGZNu9b4Tev3FVcNcqZroxJpM6NQ75ohiH
         LnuzVr5xnMlN+6BcIqKy98CS0vYJtwiDR9WxMSJdKSdsmvQUop435YQA6MGNCKcqhI5Y
         CPLQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAX2Kx7RkZsvz6kJkEQ4Ka/0zYc3tjtmRxf1zg2XVJqTGBYLv6BQ
	OsBjqNNatkcV0iIptOHmoh0YdWLirFvL1/IzkBtlBsihHAE/nCCGc6eyxB/4dcwdPl+0vosww1+
	X9GHPsqh6E2cVdbi2Ds6uM7gy2Q6Ns5/m4bO1SkmLdwD5sxqilUjStDUkWSlYMjk=
X-Received: by 2002:a50:a4ef:: with SMTP id x44mr82516488edb.304.1564127851244;
        Fri, 26 Jul 2019 00:57:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzVUt/qwf9pPv2Yg8V8RbKzHmXEfDOLr552YTk81Brkca3Ye43msYEz37wNqR6oXRnUYUa8
X-Received: by 2002:a50:a4ef:: with SMTP id x44mr82516467edb.304.1564127850583;
        Fri, 26 Jul 2019 00:57:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564127850; cv=none;
        d=google.com; s=arc-20160816;
        b=u0kY0u0sW3l6MCvWzupTRSgGo8gBdB12n8zUJOv3qdFZkmTcHABNMq8lRvhbQY8VOh
         66zHm6FXyE6Ql9D3/A83NqmS/GbtbHP0tvvmi7TJ0rJIdWmpjtmQUrKWBb6CgYyfjVhn
         E59EHh+qJOUB2nmU9tyEI8lisNwQVDX79XuR0E+DBH1OOYIzhewoL0IGP42c/GMkB7db
         6iRI3s8kAiIpM2XEQTjgYxoncgDup37qdxuGjSSx86+KyhZxES84CJkcINL853mg0y5A
         e4AoBYB5G6Xtu7TvzhToaJ53HKytT4uMI/NIXceo+YgUaGNWxpVV7NNqBKhftW3VX59m
         THxQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=/d82FpnxsJ+doW4zz6SvGj8uwEgjo1fA/TwTViO67UU=;
        b=rLkmOzze4K+dQK51C4qCKesExwCdDIFwvt57ze5hk3P37Q2uz0A+AdrsM8DUO5F7Q2
         QGSEPdEcGX5w3sBMkBLq7AZ6yzwqITPh+n6EE0IIN6jXGZoSGlaFeNtuilkUQiBl2NYn
         ABMaZrvNv3zVr7yle/NJX+9HRuCEwdgLINX7X3UjnnI9YcTSRc2CZgTcynTivCBsH1hB
         13gCAI6i9xqAU+/ju+B0xwM+vUclWvwhodLVBz2CwZ1QnUy8bz04BPyMOOWKGRIkRGE/
         dkwmdDTUqm8U86nvqzWN5n7vawuwlQEnyPhtcGTaRsWZgHOvmHnsg6GzRiAUBOhPWuvS
         3Pxg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q29si11782469eda.83.2019.07.26.00.57.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jul 2019 00:57:30 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A6042B01F;
	Fri, 26 Jul 2019 07:57:29 +0000 (UTC)
Date: Fri, 26 Jul 2019 09:57:29 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-acpi@vger.kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Oscar Salvador <osalvador@suse.de>
Subject: Re: [PATCH v1] ACPI / scan: Acquire device_hotplug_lock in
 acpi_scan_init()
Message-ID: <20190726075729.GG6142@dhcp22.suse.cz>
References: <20190724143017.12841-1-david@redhat.com>
 <20190725125636.GA3582@dhcp22.suse.cz>
 <6dc566c2-faf6-565d-4ef1-2ac3a366bc76@redhat.com>
 <20190725135747.GB3582@dhcp22.suse.cz>
 <447b74ca-f7c7-0835-fd50-a9f7191fe47c@redhat.com>
 <20190725191943.GA6142@dhcp22.suse.cz>
 <e31882cf-3290-ea36-77d6-637eaf66fe77@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e31882cf-3290-ea36-77d6-637eaf66fe77@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 25-07-19 22:49:36, David Hildenbrand wrote:
> On 25.07.19 21:19, Michal Hocko wrote:
[...]
> > We need to rationalize the locking here, not to add more hacks.
> 
> No, sorry. The real hack is calling a function that is *documented* to
> be called under lock without it. That is an optimization for a special
> case. That is the black magic in the code.

OK, let me ask differently. What does the device_hotplug_lock actually
protects from in the add_memory path? (Which data structures)

This function is meant to be used when struct pages and node/zone data
structures should be updated. Why should we even care about some device
concept here? This should all be handled a layer up. Not all memory will
have user space API to control online/offline state.
-- 
Michal Hocko
SUSE Labs

