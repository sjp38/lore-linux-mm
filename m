Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F10AC76195
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 06:48:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E78582173E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 06:48:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E78582173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 879E46B0005; Thu, 18 Jul 2019 02:48:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 82B4B6B0007; Thu, 18 Jul 2019 02:48:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 71A2B8E0001; Thu, 18 Jul 2019 02:48:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 536046B0005
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 02:48:05 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id s22so23408072qtb.22
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 23:48:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=zDCoXD/nkDhoP9AXJVuyUjGLHCg5Dqk8JG+BiorhxGc=;
        b=NBfpaIXaUa8os/50qK2ZEZzT/oyfoiKPhRpHJELA7Ik9FOT5CdBqeFbLHgnw0XGLk8
         5JOUJwOTMbIdKHBA5j+HeOblwkk6IrKho6DaOFEILDLcq4FmZUqxFqX5Jhjm9WQNp3sJ
         OIUl9FsORyBGaVbHf11nsoYNN3GO0fdBYjRwFS0l+Rm6PS5/8fgEYmVi43sRC6r+lCvz
         QN3WDuuQ5a5Bel4uThgtlLji3YsRfM1c7WhgogOIvRNhYvogcRw4A98xUaoJMRTecpOe
         gHIkOwBzNIkytIqoqRmG+1zrqjErY+R84IMi6pbjIxhac2/rc3KYQQS8va+UVnyOsn51
         JgSA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUkDaq3ZtYNgu4Gf0TJV6gL3cyCmNf0opN4XWbwY95eJXHkgYAf
	Pa1FGcz5OGPPe7Orvjz98wg4o0w86A8Cpfh7KgRrXwDhMpNmVtDL+tftutjvjK+sUBAubgTfNIc
	3xdYy5EzQgm0CgxwcGQf8foZ1HqTe7JjEqE1arnFF0ZG/16Mi1uIAGb2OIX3AR1lSgQ==
X-Received: by 2002:a0c:8722:: with SMTP id 31mr31765681qvh.164.1563432485095;
        Wed, 17 Jul 2019 23:48:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyNZxlUCSzDNTJs5GKTtLuk5ch5QPjSd4M7mIpEUoYqdrywaKyqSy2K7MfoHfd64j2cpxtw
X-Received: by 2002:a0c:8722:: with SMTP id 31mr31765660qvh.164.1563432484430;
        Wed, 17 Jul 2019 23:48:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563432484; cv=none;
        d=google.com; s=arc-20160816;
        b=gARXizzsh1IGovW157TzSo51BM7cHV2ydCNfgTVAo8LqzwP0Tu1NSqiHKWxyYMU6kq
         pfiQsS6sUf4+KKdLPFZjLEApfd78EnYlE/LUETY0KEhQcxGW7sX2O3YRytlUFhX3LWfU
         CbzkLRVgKzaQ/2j5+hn0GU8QTbqOzcChF247K7pdon3DJ6J4MKMrWvpROOfvvJoJD3u9
         X4hhN4una6Nb1Q8Q9GPPwf1lKvhjpW0FuXX1iQha9LUysqkG6YUxHDb4A9iWpxQ+scj8
         oIr+Vqfoy+0xLh1xL5xBOutF3Fw1BmayQPnmVkYMcWNXwGeEMpmY5iW5YSwz/UAmD7r+
         3Mhw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=zDCoXD/nkDhoP9AXJVuyUjGLHCg5Dqk8JG+BiorhxGc=;
        b=KCuxbrS3vVMWrmS2yGV6xj3JCQcxKgMr/xUFisZVCAM2d/KTlC5iF9mP1MIIU2pOzZ
         7i4QAx5TNE28+9kSUX5XgcZswKxal2gJLMfXl9r6g3MD+VbCSr2Zxr6vS1vVR8NEojeC
         yma8j1nVkMnypTFQlzER8CbrdzVC8ZDsj5965DpCe9QGCLluyl8003IdtUA4rc3HezU5
         ykQjFlpprnIqtcVVCa91k8Sn/MI3Ds6DbGN9RPcW+u2OaeSRmKJZAjXWtzXF9nckyf9A
         IpLptEBaASBFlDoJuISEleXozWuYynrYCPQzusnoQEfgR3VXmEjQqkGdTynsCFoqhcBz
         FnDw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f6si13193965qkm.111.2019.07.17.23.48.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jul 2019 23:48:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9342D30BC590;
	Thu, 18 Jul 2019 06:48:03 +0000 (UTC)
Received: from redhat.com (ovpn-120-147.rdu2.redhat.com [10.10.120.147])
	by smtp.corp.redhat.com (Postfix) with SMTP id 5B13B19C65;
	Thu, 18 Jul 2019 06:47:53 +0000 (UTC)
Date: Thu, 18 Jul 2019 02:47:52 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Wei Wang <wei.w.wang@intel.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	Nitesh Narayan Lal <nitesh@redhat.com>,
	kvm list <kvm@vger.kernel.org>,
	David Hildenbrand <david@redhat.com>,
	"Hansen, Dave" <dave.hansen@intel.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Yang Zhang <yang.zhang.wz@gmail.com>,
	"pagupta@redhat.com" <pagupta@redhat.com>,
	Rik van Riel <riel@surriel.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	"lcapitulino@redhat.com" <lcapitulino@redhat.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Paolo Bonzini <pbonzini@redhat.com>,
	"Williams, Dan J" <dan.j.williams@intel.com>,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>
Subject: Re: use of shrinker in virtio balloon free page hinting
Message-ID: <20190718024408-mutt-send-email-mst@kernel.org>
References: <20190717071332-mutt-send-email-mst@kernel.org>
 <286AC319A985734F985F78AFA26841F73E16D4B2@shsmsx102.ccr.corp.intel.com>
 <20190718000434-mutt-send-email-mst@kernel.org>
 <5D300A32.4090300@intel.com>
 <20190718015319-mutt-send-email-mst@kernel.org>
 <5D3011E9.4040908@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5D3011E9.4040908@intel.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Thu, 18 Jul 2019 06:48:03 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 18, 2019 at 02:30:01PM +0800, Wei Wang wrote:
> On 07/18/2019 01:58 PM, Michael S. Tsirkin wrote:
> > 
> > what if it does not fail?
> > 
> > 
> > > Shrinker is called on system memory pressure. On memory pressure
> > > get_free_page_and_send will fail memory allocation, so it stops allocating
> > > more.
> > Memory pressure could be triggered by an unrelated allocation
> > e.g. from another driver.
> 
> As memory pressure is system-wide (no matter who triggers it), free page
> hinting
> will fail on memory pressure, same as other drivers.

That would be good.  Except instead of failing it can hit a race
condition where it will reallocate memory freed by shrinker. Not good.

Yes lots of drivers do that but they do not drink up memory
quite as aggressively as page hinting.


> As long as the page allocation succeeds, we could just think the system is
> not in
> the memory pressure situation, then thing could go on normally.

Given we have a shrinker callback we can't pretend we don't
know or care.

> Also, the VIRTIO_BALLOON_FREE_PAGE_ALLOC_FLAG includes NORETRY and
> NOMEMALLOC,
> which makes it easier than most other drivers to fail allocation first.
> 
> Best,
> Wei

It's a classic race condition and I don't see why do arguments
about probability matter. With a big fleet of machines
it is guaranteed to happen on some.

-- 
MST

