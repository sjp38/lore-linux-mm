Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C630AC43381
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 02:22:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 872972183E
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 02:22:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 872972183E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2E3086B0008; Thu, 28 Mar 2019 22:22:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 293966B000C; Thu, 28 Mar 2019 22:22:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 184226B000D; Thu, 28 Mar 2019 22:22:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id EFABA6B0008
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 22:22:22 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id b188so545035qkg.15
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 19:22:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=/zDbOYGR3XfuZafIc7736W9toPpHSVSyCIewvBqysyg=;
        b=QsUtFoY7HG8O6q8uLtbhYWEu7eM3sP9v2x4HVuGQbqjvRPdOWKqeJxCQNm0iFp7NkD
         E9aJKtowXw6hBhoze6cPkxgVpLDKikhB3E4qL47/AKnvhZWZXeJJoXfp2yXTq4y3e585
         ELayy9ax3axaahA24gkp6Ky+JlgO3IUSQR96OBYZaDU9bIMjZOnAS/Qjq9DkzjmjDUul
         UpviJlvDlKLfZRyUyYPRgxYZExLYvmOwBKA046sINjHixH0n5/Wz1xOyqzLWXPQY9kv+
         QTf+mKuKDkyZluyTVTUhhhW6A5l5DEuByGiK38IoEcaVizKAd2f4t5eld9iR6YGO28nF
         zJuQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWlro2+ggvyfu2q66iPDsEUcGzfcdLsavkjXb1aJCoP5K0biQCe
	FtTCzwaroLEmw+HvTeMN0/gwNa2Ejv1v0dPv2+BOVK5ePMjQJsBwdChYNWq1vTz8dXaXXm2NrEP
	ZyNgoxx35H1pCkNKSRoqxQEfHe6GOQlUpXJaQLzYcb549UVmaSpB/WSRSyZvGfP27kQ==
X-Received: by 2002:a37:d8e:: with SMTP id 136mr35735901qkn.95.1553826142761;
        Thu, 28 Mar 2019 19:22:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyTLVEgwyIAwlHBWXYiVkAuEZFHpLpD3xhBaxB3QrkFkYWlbJWArieZb+AzxqScJJ6Edk2V
X-Received: by 2002:a37:d8e:: with SMTP id 136mr35735881qkn.95.1553826142241;
        Thu, 28 Mar 2019 19:22:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553826142; cv=none;
        d=google.com; s=arc-20160816;
        b=vsZNQmZa7Gno1JxujuxQ2pP73PniUysyATrdbXcXklzB82aUYt1UR9AKabDZmLKe7d
         Vcr53meeUeDKAbKSr9hFx28iEjym+cDau5BWkaYuMZJkMCteZv4kQgSsAh3JiachrPMF
         +h1Mjry70c3eb3rj9hq4B2ovqtqbx0S/7rR+o9D2U1YT9ILSKDzuEs9rYY9aiSp3e+V/
         VAvKhQ4Axwm9B0BSJS+Nbot0U7EDr45QxeLVycn9AlxiJrGgrFhWbBHTAAoJ9PYXpIZE
         33l9lrp9sPtyJIfOKWSPiZlT4RHaYlWqKcefeEER/Ef89e4am3bzVB3GfI5rIJKWuvBy
         4F7A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=/zDbOYGR3XfuZafIc7736W9toPpHSVSyCIewvBqysyg=;
        b=mna8+PjYf11QrqbsJ442TidAK3ZMQPqLhKY8RNyBGKhpQvXSva5+43XGb10i7jUoTZ
         Vmhzrf4S/I+9Vlz4dSoXP5TVUonHE0PDcH6LDHuMbrOgZrsuFXKmQfSFnTuZ2aFM4QxE
         VEgMDg7XCQfYlmdxn4ufzktrt4rgU2jIGFt/hb+J3aw9H+xQTccBTY6ORjEnUjbm7Esk
         rzXUdeJ3shmQgM4VpxZITQ38h2Pk/a9DwEpXiHFiFOHsTF58m6H7O4w8VFSrOECedVI7
         wpLVO/RGbwv5kW533w4JrMV0FOs5+Zm5oBTO4wx+qhYnToh/5Yt+eGtzL1jV2oy+V10B
         EWHw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 201si377261qkj.70.2019.03.28.19.22.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 19:22:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 62D5F307D85E;
	Fri, 29 Mar 2019 02:22:21 +0000 (UTC)
Received: from redhat.com (ovpn-121-118.rdu2.redhat.com [10.10.121.118])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 599DD6E40B;
	Fri, 29 Mar 2019 02:22:20 +0000 (UTC)
Date: Thu, 28 Mar 2019 22:22:18 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Ira Weiny <ira.weiny@intel.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH v2 02/11] mm/hmm: use reference counting for HMM struct v2
Message-ID: <20190329022217.GI16680@redhat.com>
References: <20190328110719.GA31324@iweiny-DESK2.sc.intel.com>
 <20190328191122.GA5740@redhat.com>
 <c8fd897f-b9d3-a77b-9898-78e20221ba44@nvidia.com>
 <20190328212145.GA13560@redhat.com>
 <fcb7be01-38c1-ed1f-70a0-d03dc9260473@nvidia.com>
 <20190328165708.GH31324@iweiny-DESK2.sc.intel.com>
 <20190329010059.GB16680@redhat.com>
 <55dd8607-c91b-12ab-e6d7-adfe6d9cb5e2@nvidia.com>
 <20190329015003.GE16680@redhat.com>
 <cc587c80-34ea-8d08-533d-0dc0c2fb079f@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <cc587c80-34ea-8d08-533d-0dc0c2fb079f@nvidia.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Fri, 29 Mar 2019 02:22:21 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000041, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 28, 2019 at 07:11:17PM -0700, John Hubbard wrote:
> On 3/28/19 6:50 PM, Jerome Glisse wrote:
> [...]
> >>>
> >>> The hmm_put() is just releasing the reference on the hmm struct.
> >>>
> >>> Here i feel i am getting contradicting requirement from different people.
> >>> I don't think there is a way to please everyone here.
> >>>
> >>
> >> That's not a true conflict: you're comparing your actual implementation
> >> to Ira's request, rather than comparing my request to Ira's request.
> >>
> >> I think there's a way forward. Ira and I are actually both asking for the
> >> same thing:
> >>
> >> a) clear, concise get/put routines
> >>
> >> b) avoiding odd side effects in functions that have one name, but do
> >> additional surprising things.
> > 
> > Please show me code because i do not see any other way to do it then
> > how i did.
> > 
> 
> Sure, I'll take a run at it. I've driven you crazy enough with the naming 
> today, it's time to back it up with actual code. :)

Note that every single line in mm_get_hmm() do matter.

> I hope this is not one of those "we must also change Nouveau in N+M steps" 
> situations, though. I'm starting to despair about reviewing code that
> basically can't be changed...

It can be change but i rather not do too many in one go, each change is
like a tango with one partner and having tango with multiple partner at
once is painful much more likely to step on each other foot.

Cheers,
Jérôme

