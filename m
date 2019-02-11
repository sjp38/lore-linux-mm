Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 11040C282CE
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 18:54:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CE57521B25
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 18:54:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CE57521B25
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7E23A8E0131; Mon, 11 Feb 2019 13:54:51 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7B89F8E012D; Mon, 11 Feb 2019 13:54:51 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6CF6E8E0131; Mon, 11 Feb 2019 13:54:51 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3FAA58E012D
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 13:54:51 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id b6so13212799qkg.4
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 10:54:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=hllwwMJ/8SbmGBMFJM2JbYIpnIqObbh2LBiUQ6YduI8=;
        b=GFrpvT/3/kYOH843pTWVlsWcaLiJWu6ryzNEKciTW8ZRli2GhrJRCREBi/VNnONcmt
         lqmRQ+DZEblz3Ce/J+GbxOIkPsD2Rsj2h4PseEwjIKAkBWjGOL2Zrh+iF/X0O4AGFZA6
         v3vA1A/S8/zSR+AEMBeqBUBd+Lt8Xr93sZECJtoX7kDHQOn8O7Xfb9RizWMNyEC7JGi7
         v+2q4HwBdD9KJvusQfCU6XVAjvI4OYK9iS7KcT/Qsrxwy4+NZXZT+nnbf/TUw+PIWNGr
         KpgyPtOnDJhqv8lEZRn/yQYMf079wDJzYCt5rA1TnBPPoA+MrKuHQ+W84EiskpZO0Bdt
         V7Dg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuapa3Qk54Ed+Af4K2Q99+SmLm+rsIe8tSDkvRxptAsy1gCCFg6p
	DvdKGbmUEbnQLD35r6QbxtmA38pyn37mFE0KEU83HTI9XoQ4G9/KoyhS+0WVUQlpEXFgjKX8SZI
	Of+/5J4+b/1fsC0RfAdT0acm4JCOZsBI/WSH9JByT9+mbooXUbQDcSMU3ij41Lz5fQw==
X-Received: by 2002:a0c:afa1:: with SMTP id s30mr28076564qvc.53.1549911291002;
        Mon, 11 Feb 2019 10:54:51 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia+yU4i4fUa8qq4NU0kaW6bmbh6e9bpDHORG+bctI5pleYDuN6bACWQr/6o/+HjZibYS7HK
X-Received: by 2002:a0c:afa1:: with SMTP id s30mr28076536qvc.53.1549911290463;
        Mon, 11 Feb 2019 10:54:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549911290; cv=none;
        d=google.com; s=arc-20160816;
        b=z65FFgGhlRlxSIh0NrO9bVmwMNzN9avPgxHtm8GQhtqkH+Mn0+SQjbRtGnzxGEWTFl
         Jt0+gHGYH4QxHxLBBNEEPiOgEsyye0XFFqLR8TGTtPNANt5RNKPZyDIIVNHUO8g4Bicd
         /u0UdmeW4nl+JgfSQH3TaXQ8ieib0lDNI5w8EJW8ycXV2Vv0XT+/9h5Cy0VzGM/3kwtP
         AO1ZUqBej8eZVTldqiworRbhjESnpel+YrAePefE2DpgWjv8dRxVYUwDdaCUSelmgv3v
         vzwj0hu+yvD+o8sDBChVXCCgtbW8rl2tKR6X6WVOi92x/o1tCSNqQGbX11IGDiv7dRb7
         XuTQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=hllwwMJ/8SbmGBMFJM2JbYIpnIqObbh2LBiUQ6YduI8=;
        b=TiEXpVTECV2T2dXiidQZ8EZCKF1xvd63ydQ6b879A+rbpb++2zvYlPuH4M3BtZtadB
         9NB+2YZgAEeeUUXPI4H+bhoU3Px8SDpSjLpb5qmcLZ0SsGIZpqOB1BghrvZC6sFqBkHv
         IUQmJiSjhcOp8Lw4g+yPloFMB/0sTTO08NK0KAadlW2ViNGcP7pYfLoJE/F1nLYiVzm+
         kNvditilj+uGClsNrgD9VefD3ejO85pNeXpZeP4JC/jR4SY/b5u63wh+QWvalB4BbtO4
         AxLMXtFuZGmUAaGE7E21ryhGVdJDxVT0Q329eJ7JBXubx7X0EGNQHWYEiqYSN84QemFi
         Z5kw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v18si1639612qtp.194.2019.02.11.10.54.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 10:54:50 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 59639804E4;
	Mon, 11 Feb 2019 18:54:49 +0000 (UTC)
Received: from redhat.com (ovpn-123-21.rdu2.redhat.com [10.10.123.21])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 389C55C21D;
	Mon, 11 Feb 2019 18:54:47 +0000 (UTC)
Date: Mon, 11 Feb 2019 13:54:45 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Matthew Wilcox <mawilcox@microsoft.com>,
	Ross Zwisler <zwisler@kernel.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Paolo Bonzini <pbonzini@redhat.com>,
	Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>,
	Michal Hocko <mhocko@kernel.org>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>, kvm@vger.kernel.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v4 0/9] mmu notifier provide context informations
Message-ID: <20190211185445.GA3838@redhat.com>
References: <20190123222315.1122-1-jglisse@redhat.com>
 <20190131161006.GA16593@redhat.com>
 <20190201210230.GA11643@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190201210230.GA11643@quack2.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Mon, 11 Feb 2019 18:54:49 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 01, 2019 at 10:02:30PM +0100, Jan Kara wrote:
> On Thu 31-01-19 11:10:06, Jerome Glisse wrote:
> > 
> > Andrew what is your plan for this ? I had a discussion with Peter Xu
> > and Andrea about change_pte() and kvm. Today the change_pte() kvm
> > optimization is effectively disabled because of invalidate_range
> > calls. With a minimal couple lines patch on top of this patchset
> > we can bring back the kvm change_pte optimization and we can also
> > optimize some other cases like for instance when write protecting
> > after fork (but i am not sure this is something qemu does often so
> > it might not help for real kvm workload).
> > 
> > I will be posting a the extra patch as an RFC, but in the meantime
> > i wanted to know what was the status for this.
> > 
> > Jan, Christian does your previous ACK still holds for this ?
> 
> Yes, I still think the approach makes sense. Dan's concern about in tree
> users is valid but it seems you have those just not merged yet, right?

(Catching up on email)

This version included some of the first users for this but i do not
want to merge them through Andrew but through the individual driver
project tree. Also in the meantime i found a use for this with kvm
and i expect few others users of mmu notifier will leverage this
extra informations.

Cheers,
Jérôme

