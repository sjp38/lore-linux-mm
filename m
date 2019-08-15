Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BCD8EC3A59C
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 17:35:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 817D42086C
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 17:35:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="gfG9UzxT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 817D42086C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1AEA86B02EE; Thu, 15 Aug 2019 13:35:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 160976B02F0; Thu, 15 Aug 2019 13:35:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 04D166B02F1; Thu, 15 Aug 2019 13:35:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0109.hostedemail.com [216.40.44.109])
	by kanga.kvack.org (Postfix) with ESMTP id D2A1C6B02EE
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 13:35:02 -0400 (EDT)
Received: from smtpin10.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 8AF5D180AD805
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 17:35:02 +0000 (UTC)
X-FDA: 75825362844.10.spark97_49145ec19f713
X-HE-Tag: spark97_49145ec19f713
X-Filterd-Recvd-Size: 3817
Received: from mail-qt1-f178.google.com (mail-qt1-f178.google.com [209.85.160.178])
	by imf02.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 17:35:02 +0000 (UTC)
Received: by mail-qt1-f178.google.com with SMTP id 44so3132742qtg.11
        for <linux-mm@kvack.org>; Thu, 15 Aug 2019 10:35:01 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=2ZSbStm7AbDlXUhKJSg3L8e0NLU9fEch1EIrUdDIspw=;
        b=gfG9UzxThCigCBaKBs4lpzT/DQERj6tRex3zsyhWWtC5mNoRtHY0KVhl1Eusttge/6
         gTa0XkfdlzW5xd0gUiYLS0otjvybVrqu20zk5hDPLSTPCA42Rld4afQ1YnK0eHOHfAvx
         XchEDv5NXEmt5CcVefyG3DYRIVtmobbNBMwDKn8GtVpQKOTUK9LexdYi+sTLctzGyNxe
         TYWo1VhCO+dbNXL98G4TvRHHRh6LRAXKcuaLZV2w+2AsiVgzdSbIulXiEvLbHnLjM9/r
         FAzV2hVYQhnbnkcDrUmUq0qh4De17xFpCKGwoLpS0fpwYewK6JYlJy0m2NMukOuaQRKo
         U9Ag==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:date:from:to:cc:subject:message-id
         :references:mime-version:content-disposition:in-reply-to:user-agent;
        bh=2ZSbStm7AbDlXUhKJSg3L8e0NLU9fEch1EIrUdDIspw=;
        b=bz1Tr6Ei6Pt/ZlMT1JSk9xNM5WwQE0lYGx8nDA/xwNZxQfQUasi4ZR3seUL9AbSMff
         8y+2crxJFwTp1mVtctfM9eyd5N5sg9RXhmFHR7hXbjWCTe7YnP4yGFUKjCxadsieXiAC
         /BtSpkqXqcOexoS63U1n58pS5sYDHYMQbYifOG1UooYhf4pAZ7eJz1uDww6r/Gei+vG0
         8G5E1sVVUlPZtD6bprt3VpX4k2ZNo/q2lf5ccldbMQoLwybtA3qIrFEUdswtBYXrddr1
         F+Ar/InvDsWK8SRhf99UbJbbJBmZMHh06HElfITyrUzI3hJHS3klNhuwhX+jEFB/3MFi
         1WhQ==
X-Gm-Message-State: APjAAAWDqaXP3fiDl3IepmeiWuPl3ImDexIN3KA5NvJA+PUEC7RNQ1uG
	ekzK8h/plak7rb4iIIolvd0=
X-Google-Smtp-Source: APXvYqzlu7N6cRvS0ocSXBCf6KXcLrqKgjEDpi8R5FqcX+e5okBZTdTHSPWh9rbIZLoOA+UBtTrZqw==
X-Received: by 2002:a0c:e588:: with SMTP id t8mr4042293qvm.179.1565890501439;
        Thu, 15 Aug 2019 10:35:01 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::1:25cd])
        by smtp.gmail.com with ESMTPSA id y194sm1687796qkb.111.2019.08.15.10.35.00
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Aug 2019 10:35:00 -0700 (PDT)
Date: Thu, 15 Aug 2019 10:34:59 -0700
From: Tejun Heo <tj@kernel.org>
To: Jan Kara <jack@suse.cz>
Cc: axboe@kernel.dk, hannes@cmpxchg.org, mhocko@kernel.org,
	vdavydov.dev@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org,
	linux-block@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com, guro@fb.com, akpm@linux-foundation.org
Subject: Re: [PATCH 2/4] bdi: Add bdi->id
Message-ID: <20190815173459.GE588936@devbig004.ftw2.facebook.com>
References: <20190803140155.181190-1-tj@kernel.org>
 <20190803140155.181190-3-tj@kernel.org>
 <20190815144623.GM14313@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190815144623.GM14313@quack2.suse.cz>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

On Thu, Aug 15, 2019 at 04:46:23PM +0200, Jan Kara wrote:
> Although I would note that here you take effort not to recycle bdi->id so
> that you don't flush wrong devices while in patch 4 you take pretty lax
> approach to feeding garbage into the writeback system. So these two don't
> quite match to me...

So, I was trying to avoid systemic errors where the wrong thing can be
triggered repeatedly.  A wrong flush once in a blue moon shouldn't be
a big problem but if they can be triggered consistently by some
pathological behavior, it's an a lot bigger problem.

Thanks.

-- 
tejun

