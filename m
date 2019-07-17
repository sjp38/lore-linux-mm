Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 03816C7618F
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 17:53:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A718821743
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 17:53:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="PicqJS4o"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A718821743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F2D088E0001; Wed, 17 Jul 2019 13:53:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EDE7F6B0010; Wed, 17 Jul 2019 13:53:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DCCAA8E0001; Wed, 17 Jul 2019 13:53:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id A3B7A6B000E
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 13:53:28 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id e7so3553968pgm.2
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 10:53:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=z2SSmhd68h87dQhwvWTjUlLYyoXB//o48emXKDITCxQ=;
        b=XUiEDMhxt3WCZ3wIke8MiNWgOuWvHfNviM7ryeHW0BoOnOSesqMkl2AsK2tM1eCQ2M
         TEk8tV9flAhQEqldNmn2n1LBYsIzYtjwWZfxlpJuygkEXUOTXdmCo3mS0RijBrKBQSGv
         KK/JAhheUpLZREZG5kvZou0HOSosO6bzDmqAcwUImSDUz8fZyfP1SnPoZjflygNyOARZ
         Di4Lzt5cKQCwcO2uqCTOs1Kc15ZwDZ56Qy0TWmEvv4YmVUC3rQg2gdgZkWJ7wJ7o+yUC
         /I+jcTtktNqNzCiLFWFH/vRszg5SPUE6Znuzp+OxjV21v6jVdQdOlf/QfWIcQTaEfc2u
         C6tg==
X-Gm-Message-State: APjAAAVprjT4/l1hKEgpoWUa8P0haP2EBASopbMC33frFHdEwMXd83jr
	p+yUSutnrnZQISiRbopOzgyFuJByp9BbgrzN/dpYdE0zEzKkpgCfvpxUCCEQm8puLkwa8dh0uCE
	Y1uRTPDHtiq3WWCewZtK/B3zlmakeK/X9C98NnLE0LjzRHrjW79GD6JGx5toZ3x2jKw==
X-Received: by 2002:a63:460c:: with SMTP id t12mr42462750pga.69.1563386008174;
        Wed, 17 Jul 2019 10:53:28 -0700 (PDT)
X-Received: by 2002:a63:460c:: with SMTP id t12mr42462691pga.69.1563386007492;
        Wed, 17 Jul 2019 10:53:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563386007; cv=none;
        d=google.com; s=arc-20160816;
        b=djMWDZ22O9RqJGixrIJb1+DGZMWCJ7g42chtMh6znAn+5Ye7/DizV7bDOSBl8T3+zs
         1+I1H/miw42Zvxs9adY999IhEeq7Q3eZHNNyW4wWOvhq/ejS2EzIEv/3WAqUKF3fPb0c
         9KbzpT07vQ/5g/CqZrej/CQEDSEPQ95IbawMF4JJnQXSTo2BeiqrQP/zmRrUAK61QqKJ
         v7CrZKcVRujJ/T0ZBvsb8AM854h5vRce89Z8y81Xx+c0EMnSYeQoU3S2ZrVsfj93kAuK
         mcnhpLAd/Uark6HbMyCzi/S1Vx+nzxkl4ezuprr7efBonQ1cySCV3IGVJoh3GTrlTUsa
         JgIA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=z2SSmhd68h87dQhwvWTjUlLYyoXB//o48emXKDITCxQ=;
        b=RJnHuTttYLLUU46A3yRg1w4vZbfFivucFyWUbeymykzN+OYspfwB7jTZUz/wzkj0+w
         wGMtDNzpG6Iy0bMcOGwfqN4nbhhRK0dAdQiGBzdA1nDwQRTchhPHbeoDNWVBKR07K/mW
         GKBgxYpS0vrPSmCSLynAxNnxB95TcY0BD8u/UBgdRGb0pvMyjFiJNPUw26VNpqvsSsm7
         2K1rrQYXdZbMIgH04NP1wzyhxa9Rm3svlql4k2+lFHt0RBfi0wOWne1HdtRL8adXH4MO
         hPWNBgJcSW9fFo82C0FSwV1GUhaHzWNCoBJKUIVFXocwvIfB7wpQ7/gUtxtTq/Rn7WQ+
         OdTw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=PicqJS4o;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r27sor13135875pfq.73.2019.07.17.10.53.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Jul 2019 10:53:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=PicqJS4o;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=z2SSmhd68h87dQhwvWTjUlLYyoXB//o48emXKDITCxQ=;
        b=PicqJS4oQ5peSgXROAA8eXF277L4r7XmQo7cZukrfLSYdqLgbwsEd5Dqzk8QpxK7iV
         Jr7zEtrtR7thmPO+J1QqTaT3j+I0++ACo6TT6aLs2O6D/+ubRqwsDUj8iqkYUHlSu3uP
         S2KX/7zlhOpvgyqTAThJQxGs1jnQy4eGdv0gbpjnWh/cRorbYj9HH98ccTyznWgcEXac
         q+hc0yDQCCnUJLqZHjU4NiRzAjIzNBE+SyaYhXxaMZoParySRgAtaVZmE7db4nbJWShy
         2wprrKIAvpplpmvdMXRr1OD5xBE/XjJHL4qajuxjvrPz4tpMfAgYgXaVJxT7SoPPfBK0
         oskQ==
X-Google-Smtp-Source: APXvYqws5y1Y3Qi2XGvjYV4PuosbGfC72ojawETni+lagfagIVzMSmpCmtv3mdSH5rkpTds+RX2eng==
X-Received: by 2002:a65:4d4e:: with SMTP id j14mr42320858pgt.50.1563386002312;
        Wed, 17 Jul 2019 10:53:22 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::3:4db])
        by smtp.gmail.com with ESMTPSA id b26sm29434788pfo.129.2019.07.17.10.53.20
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 17 Jul 2019 10:53:21 -0700 (PDT)
Date: Wed, 17 Jul 2019 13:53:19 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm/memcontrol: split local and nested atomic
 vmstats/vmevents counters
Message-ID: <20190717175319.GB25882@cmpxchg.org>
References: <156336655741.2828.4721531901883313745.stgit@buzz>
 <156336655979.2828.15196553724473875230.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <156336655979.2828.15196553724473875230.stgit@buzz>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 17, 2019 at 03:29:19PM +0300, Konstantin Khlebnikov wrote:
> This is alternative solution for problem addressed in commit 815744d75152
> ("mm: memcontrol: don't batch updates of local VM stats and events").
> 
> Instead of adding second set of percpu counters which wastes memory and
> slows down showing statistics in cgroup-v1 this patch use two arrays of
> atomic counters: local and nested statistics.
> 
> Then update has the same amount of atomic operations: local update and
> one nested for each parent cgroup. Readers of hierarchical statistics
> have to sum two atomics which isn't a big deal.
> 
> All updates are still batched using one set of percpu counters.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

Yeah that looks better. Note that it was never about the atomics,
though, but rather the number of cachelines dirtied. Your patch should
solve this problem as well, but it might be a good idea to run
will-it-scale on it to make sure the struct layout is still fine.

