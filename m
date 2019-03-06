Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4D59C10F00
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 15:49:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 42AA120663
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 15:49:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 42AA120663
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7CEEE8E0003; Wed,  6 Mar 2019 10:49:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 77E208E0002; Wed,  6 Mar 2019 10:49:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 646A68E0003; Wed,  6 Mar 2019 10:49:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 36E428E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 10:49:09 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id w134so10135742qka.6
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 07:49:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=+Tu/0BhMLJngAD4p0WwitxSDlvK4Cgp/DO4xvc2KNC0=;
        b=MjVHgYdiSL5R2gY5BUBWm/VoSEuN0fnPHc161r9X71X+eSN0o+0xE3o1pZfYmFn0Et
         OznrDw2MmUIT4tRz3q/XIIesGRFRUkf/iQIj1eboNBaDyC0beOCwV7kfGogHIxMvQlMJ
         EKff9QvelWiEam+qIlC1JdkM/ZoYacfITzD99mcJ3H1BSed7TzxUUzY1H0g37q5tMDsH
         cyebb3jF6hnWuJAS9DDOJGxGJl2a+o0kW1L8tDkNRViy/1c6lXpqzj0YlL6HrUrWOgrz
         z7Ox7ixSyeK9TbzjKZZvY0TY1wqgrqbwPrlRKro2V42pPlyUYKPXGGZ5n+o7oTrORSc7
         6WtQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWBSOnv65ogVeUaCEZkkYyUri9hrWThDrB3sSn+uG/Pc+xyNQwY
	H69dR5U9tdWMDDPWwibh4U0g3tOt9t83pfFR+wJLVoRRMa3wUxcvsOLDzbXvJSXYH5N85LY++Xv
	bW2eqGVitGTeI16WRdJM7/jOzmI+BUwqzVMcZvgEVmEfX9t5e/3PQbvYytXP0TD4UlQ==
X-Received: by 2002:a37:4e0f:: with SMTP id c15mr6332291qkb.267.1551887348972;
        Wed, 06 Mar 2019 07:49:08 -0800 (PST)
X-Google-Smtp-Source: APXvYqwLY9ugpbeKH8Fzfr9K1DL3U9milgMQb56SFi+QiUVIqE7oKKDKAxknD4fLHyOuJGkRpr+V
X-Received: by 2002:a37:4e0f:: with SMTP id c15mr6332237qkb.267.1551887348032;
        Wed, 06 Mar 2019 07:49:08 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551887348; cv=none;
        d=google.com; s=arc-20160816;
        b=xvdemrvhO9a9xgxRVP1xJSmpySLHBivwfwQ7216rpW8vW+5M9T8p+kaKPiFqnEK0uw
         14/tGr5+tjEe1AeesMi1KUe0tztKXqeJ/zJsM98eb+TCBoRVDgxG9i3T0OyYxccnsH4H
         mnOEO+gJUGoFLun4orUbzYg0p0vYuDgWl7kIW5A1/qqfAXIRpXQVE60oC2RBwkdRcrsv
         Ko/jc8l0GE6/bys92FKQ0kTnAY360EBwSyi5jbtKx0sZLVbjYJYPT5tvfn4ZTa1wA2Zr
         3Ypd5Na8r5hPyhGJDgA3VLoT2A6nV3oJNW1urETTE6KnznJCX8iRX4y0zktHFFmez/dx
         oDjg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=+Tu/0BhMLJngAD4p0WwitxSDlvK4Cgp/DO4xvc2KNC0=;
        b=EZhPdXDTeI+3Sa5Xs+0OnJyhhib9/vdgwp451uL/5FzYG2Hd8vKP2nayODcu6OLEYl
         N0G04tsB+O881e+eA74CsF/lrv9Qe3khwwLN61KXwtBjxAb2mSgAlHIEa83DySTiUzfb
         yZ69//1LSrutPb/EnzlNiZ/5W+d62U9/P6WUDATowB4B/MR+xBOhgTb/GryufMoWqUJr
         PeQ99BR5YMXApRlMuO36R5qx+8BzmVIA1NMQBxPdkPY8NmpHCwChlhosGsdSbSyClxc1
         7uok+smQqSXky84dMUIvDqRClFwXBYTDwP61OCMRiMDQaXNAfsX0Wh2t37MSISxY0zwi
         oMfA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j14si1159025qta.106.2019.03.06.07.49.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Mar 2019 07:49:08 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 2141B3092653;
	Wed,  6 Mar 2019 15:49:07 +0000 (UTC)
Received: from redhat.com (ovpn-125-142.rdu2.redhat.com [10.10.125.142])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 27B3C611B6;
	Wed,  6 Mar 2019 15:49:06 +0000 (UTC)
Date: Wed, 6 Mar 2019 10:49:04 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dan Williams <dan.j.williams@intel.com>, Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH 09/10] mm/hmm: allow to mirror vma of a file on a DAX
 backed filesystem
Message-ID: <20190306154903.GA3230@redhat.com>
References: <CAPcyv4gkYTZ-_Et1ZriAcoHwhtPEftOt2LnR_kW+hQM5-0G4HA@mail.gmail.com>
 <20190129212150.GP3176@redhat.com>
 <CAPcyv4hZMcJ6r0Pw5aJsx37+YKx4qAY0rV4Ascc9LX6eFY8GJg@mail.gmail.com>
 <20190130030317.GC10462@redhat.com>
 <CAPcyv4jS7Y=DLOjRHbdRfwBEpxe_r7wpv0ixTGmL7kL_ThaQFA@mail.gmail.com>
 <20190130183616.GB5061@redhat.com>
 <CAPcyv4hB4p6po1+-hJ4Podxoan35w+T6uZJzqbw=zvj5XdeNVQ@mail.gmail.com>
 <20190131041641.GK5061@redhat.com>
 <CAPcyv4gb+r==riKFXkVZ7gGdnKe62yBmZ7xOa4uBBByhnK9Tzg@mail.gmail.com>
 <20190305141635.8134e310ba7187bc39532cd3@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190305141635.8134e310ba7187bc39532cd3@linux-foundation.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Wed, 06 Mar 2019 15:49:07 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 05, 2019 at 02:16:35PM -0800, Andrew Morton wrote:
> On Wed, 30 Jan 2019 21:44:46 -0800 Dan Williams <dan.j.williams@intel.com> wrote:
> 
> > >
> > > > Another way to help allay these worries is commit to no new exports
> > > > without in-tree users. In general, that should go without saying for
> > > > any core changes for new or future hardware.
> > >
> > > I always intend to have an upstream user the issue is that the device
> > > driver tree and the mm tree move a different pace and there is always
> > > a chicken and egg problem. I do not think Andrew wants to have to
> > > merge driver patches through its tree, nor Linus want to have to merge
> > > drivers and mm trees in specific order. So it is easier to introduce
> > > mm change in one release and driver change in the next. This is what
> > > i am doing with ODP. Adding things necessary in 5.1 and working with
> > > Mellanox to have the ODP HMM patch fully tested and ready to go in
> > > 5.2 (the patch is available today and Mellanox have begin testing it
> > > AFAIK). So this is the guideline i will be following. Post mm bits
> > > with driver patches, push to merge mm bits one release and have the
> > > driver bits in the next. I do hope this sound fine to everyone.
> > 
> > The track record to date has not been "merge HMM patch in one release
> > and merge the driver updates the next". If that is the plan going
> > forward that's great, and I do appreciate that this set came with
> > driver changes, and maintain hope the existing exports don't go
> > user-less for too much longer.
> 
> Decision time.  Jerome, how are things looking for getting these driver
> changes merged in the next cycle?

nouveau is merge already.

> 
> Dan, what's your overall take on this series for a 5.1-rc1 merge?
> 
> Jerome, what would be the risks in skipping just this [09/10] patch?

As nouveau is a new user it does not regress anything but for RDMA
mlx5 (which i expect to merge new window) it would regress that
driver.

Cheers,
Jérôme

