Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B02B8C04AAF
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 15:41:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 72CB8208C3
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 15:41:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 72CB8208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 15DC56B0007; Tue, 21 May 2019 11:41:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 10E966B0008; Tue, 21 May 2019 11:41:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 024086B000A; Tue, 21 May 2019 11:41:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id D4E836B0007
	for <linux-mm@kvack.org>; Tue, 21 May 2019 11:41:12 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id 49so17613163qtn.23
        for <linux-mm@kvack.org>; Tue, 21 May 2019 08:41:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=pvB+ipTmtcum6vNe8cy+MZiFmsCSVnxehggQ2f18MqY=;
        b=bt97DNYp5ijBv55Z4m/alYhNgenTobRXpXr6r9xEQiR9wvNg7YrZ3rvAaXhjRiwJeR
         1tYyveVwvItM+CStroJ9zr8MufPHUsYSvyhPajeiVy6AmroOOlqR+04cX63oDJlViWaH
         MXBkyJCamheOYITD3XBF3fHU4jmq/Ke13aeMSh9cB0vqjo5SZUaMs43vwVUplskgK4PT
         Txkhfv6aLkH5cm0dNi4HBkzC3r5ARKqulD5Q3vUC9UBnN/KBhK3hVOGBPXTF1eHj/k+5
         hIT3odIlpw5qeWN13AAastfNscchM4Ro7OmEQly81/6xobEQsGK8sCQXRRjp9q/6FQ2y
         dkpA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUYVGOp229Pzu9CDykeAuDPA+NkmSsiXEaU5OfQ0PE/QRNOE8OL
	IqFlIx3OnHJZrftYM54A8Dt6mgISpKpcMM1T+fKPzWBAdXaWBJBimREgno91zC/g+LTufgOvAdc
	helVuakbs88mB2FQ7oq26L/P9pmOWjVQHo1tY+SPDY9Gk5KbTaUWvkKm3Yl1ngNz/OA==
X-Received: by 2002:aed:3f4d:: with SMTP id q13mr68499157qtf.295.1558453272629;
        Tue, 21 May 2019 08:41:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxmTUBjm5UwZ7h1GwAgRECWlceRW4gnOe6PcPOoJFQ7f3q6lsQLuWJMS0SuJ2nkLHz7aqto
X-Received: by 2002:aed:3f4d:: with SMTP id q13mr68499051qtf.295.1558453271671;
        Tue, 21 May 2019 08:41:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558453271; cv=none;
        d=google.com; s=arc-20160816;
        b=cPum4hKk9KIvxEaYZw+UtQiO+o11Kzhdquu2a1yk3GHkzRItNDUh39XuLTqO+IJGmT
         AnyrGXzN39mbQfqls063dup1wMW9NPmWh1qzvqmR/b4MbTmXD9QRMu9jhJ51C3N3S61S
         ilm8rN62Bkgm3WcF8YcBnQxL+YZOVujKpSL/UfK0UQdK9b7Nxpgmetjqk1Qhlgs5P9N2
         U4dwXB7Vl8F2YhwNWCGjzgPasu1BxlltbKjWKMhI/BODVZhmf6GWL2ZTbXXf7Htuldao
         AA1DX0w8hPPlaL2j0w9rFg6HZMfkAiQGRlUIcZs1mF79JQy4pO0H5XR9NHAfTmlUOGS9
         2Mxg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=pvB+ipTmtcum6vNe8cy+MZiFmsCSVnxehggQ2f18MqY=;
        b=FqyBp33uKxleLrMtsYVIluhVz6QKwM6EAUfY1Dd0GoNA8vm96yElEOJR739JdDz9Qf
         6goy8W1z2+XAs+izaksLYtjI9ENYVNQVUSTWtnwPZWDoGxI+ttcmTosuy7hj01aByU1F
         EiHLLas6mwBtiejpTV7Yic9dXBB4Ydoh2y3RGbSTAp6HzTw1DRXBQ3iQM9TJzmrceiJg
         0Xb7A/WjNzHFkfrJ4YbmhDbEawdqlkPCQBi9f/P8oLAI12uw4eGTmguXSdjpeMZYFXCp
         I8z6NwAtzg6/GpK/votmdhwGzEX5JcqEKPAFw656uWP08BY6z5M/91s/cbwQp9ekyKEF
         uBTA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e12si2950782qkl.254.2019.05.21.08.41.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 May 2019 08:41:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 7524F30BB532;
	Tue, 21 May 2019 15:41:05 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.178])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id EE28453786;
	Tue, 21 May 2019 15:41:00 +0000 (UTC)
Date: Tue, 21 May 2019 11:40:59 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Daniel Vetter <daniel.vetter@ffwll.ch>
Cc: DRI Development <dri-devel@lists.freedesktop.org>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>,
	Chris Wilson <chris@chris-wilson.co.uk>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Rientjes <rientjes@google.com>,
	Michal Hocko <mhocko@suse.com>,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Daniel Vetter <daniel.vetter@intel.com>
Subject: Re: [PATCH 4/4] mm, notifier: Add a lockdep map for
 invalidate_range_start
Message-ID: <20190521154059.GC3836@redhat.com>
References: <20190520213945.17046-1-daniel.vetter@ffwll.ch>
 <20190520213945.17046-4-daniel.vetter@ffwll.ch>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190520213945.17046-4-daniel.vetter@ffwll.ch>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Tue, 21 May 2019 15:41:10 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 20, 2019 at 11:39:45PM +0200, Daniel Vetter wrote:
> This is a similar idea to the fs_reclaim fake lockdep lock. It's
> fairly easy to provoke a specific notifier to be run on a specific
> range: Just prep it, and then munmap() it.
> 
> A bit harder, but still doable, is to provoke the mmu notifiers for
> all the various callchains that might lead to them. But both at the
> same time is really hard to reliable hit, especially when you want to
> exercise paths like direct reclaim or compaction, where it's not
> easy to control what exactly will be unmapped.
> 
> By introducing a lockdep map to tie them all together we allow lockdep
> to see a lot more dependencies, without having to actually hit them
> in a single challchain while testing.
> 
> Aside: Since I typed this to test i915 mmu notifiers I've only rolled
> this out for the invaliate_range_start callback. If there's
> interest, we should probably roll this out to all of them. But my
> undestanding of core mm is seriously lacking, and I'm not clear on
> whether we need a lockdep map for each callback, or whether some can
> be shared.

I need to read more on lockdep but it is legal to have mmu notifier
invalidation within each other. For instance when you munmap you
might split a huge pmd and it will trigger a second invalidate range
while the munmap one is not done yet. Would that trigger the lockdep
here ?

Worst case i can think of is 2 invalidate_range_start chain one after
the other. I don't think you can triggers a 3 levels nesting but maybe.

Cheers,
Jérôme

