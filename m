Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B495EC282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 14:57:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 45733222C9
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 14:57:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="SW2DvWIV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 45733222C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D3FF08E0003; Wed, 13 Feb 2019 09:57:02 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CED9F8E0001; Wed, 13 Feb 2019 09:57:02 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BDC5F8E0003; Wed, 13 Feb 2019 09:57:02 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9542A8E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 09:57:02 -0500 (EST)
Received: by mail-yb1-f197.google.com with SMTP id y63so1497024yby.8
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 06:57:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=f1/JLvls4tgQtGqFCJ46gwCNkZrTvoZhTX+bAGzOhUs=;
        b=KI5r693CWGRGgcaN83If9slzjIJbyVsiOExM3/7ocBQlQpQ+0pIlvIenrUJpt/RoE8
         kgkHu6OkqtEO5zgjy4m/BaV1EG/wq+E+k8218tR/VMMATzp9pqBHxtv3Q3QZK3Ocs/yU
         jzU66mkijHt1AjfaRzgWz/GfSbVM1WIR0YpQ3RHsl7UyONciadpWashwOD2X4e9oIfP2
         bZD/RY1L3f94zMJ5PLqrAS4kYC7iJWIOrxekZyHmcEw3z1gQrA75AX60LRI1sADGPlzn
         9Ythy8Ya52FhPymsy6aOtlJRuq7yJFfRTgHpTImlMCCOP2eFadh6LB0DsERjYcFqxteC
         4IJQ==
X-Gm-Message-State: AHQUAuZsxFYwmqOQMway/KpOV5yzDiFl7e4TlSWtQwJSNPsNkLB6p47a
	T2v04IpyVCQgwXySEg+5WEkLrCOp7uF7KS/MrHKE1JZZtu2Tv1UcBhukAnteUUVAHkBSceB0tLM
	Bb3Ggm5LR8+zqmzL2nkpLcz/yIVcXTwjzk5aboT6xOXfvqjY4DHlo/o/wIu7DbhLq5V4BZsGA6f
	M5yAkFHgdcJ0OhaozEWNQKLXtBjvqESZnzVR9IAJVfzV5Y828VZOD78Wfoc46NCfK3OC1uRYdcl
	oHwoPKiNa2yZXLNjFPCxh6rRJesKNDIta3eUVca9B0zzSsVW3TgVgFrIK0EUOLjeSQFrTYKs8aL
	fsCPfbCsa83HGg2Yy8eZ/hyTo96bXpLuo6BpyvcdmUbyZ+IMysTDWSY2GdJ1xumyZ92XXhEqxb9
	c
X-Received: by 2002:a81:1c12:: with SMTP id c18mr4932326ywc.487.1550069822270;
        Wed, 13 Feb 2019 06:57:02 -0800 (PST)
X-Received: by 2002:a81:1c12:: with SMTP id c18mr4932288ywc.487.1550069821562;
        Wed, 13 Feb 2019 06:57:01 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550069821; cv=none;
        d=google.com; s=arc-20160816;
        b=Yzyb64l+l+/5IuzjVlfH2J4I+QkqEb0VhxNj9tn9O/2ydbBq/v6HaNZaNhFe/aBNXd
         g2oyrPXbZbIklFRlodVciW4K0rrbUlcy5mr/wdM3lBKAOdPz7rxEbKtIDHS81JHHCr1n
         oJ3DV/ZJNHNMaEj4m7X9+rGZQE6Dh5MIccvMpDIaU0eqs7MHjxFEdFvMdWwILnWyt3Du
         QGDk6yXTdwdZW8q7vh0cbYuuhhdzfJJQfqfiK2nEKXXE9yxFNcak5ubOfcPueS7/kVh0
         FF9vgK2yZkj2xP5mNFk9OTc/socqjIQZiCQYGp0JYz8jc0VQdakp6eiQGHJ7jCUMQ4s8
         c6pw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=f1/JLvls4tgQtGqFCJ46gwCNkZrTvoZhTX+bAGzOhUs=;
        b=U2uN7E7tIyVvC9+gRTFKiO6vjco+d0lOMmRuvC8G3ecEKeETwpQ7XFUc1xlERvBfPv
         KLC0pWZPfM5ZYdPE0wI80Zii+bSPAqmdcK9koJxr7gTiCx2gR6b+7BdPa7dL0V1SYZxS
         2JI8Gr6wCugmBYACo2E4Y56kWafF1se4vf9AKVxDTRVtcT/AvTeZJz04L9hTe2wVAZbQ
         Ib8R3FAnu2o5AenrAVmkZNdooHHl79bNt+wyaJIgo6t9beHLVhKbJlPYYuThIbIb5I7w
         5H3HJuduZxHj9i6aPQe4gw9FtIREelrErjWvk8lOin0zqmWkbrBYYJUZDkXMUwhdM9GA
         HqhQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=SW2DvWIV;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t15sor2266107ywc.203.2019.02.13.06.56.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Feb 2019 06:56:59 -0800 (PST)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=SW2DvWIV;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=f1/JLvls4tgQtGqFCJ46gwCNkZrTvoZhTX+bAGzOhUs=;
        b=SW2DvWIVmik6SokLYtJXB1o9nSv7CDj8HB+bEXt5W9JnEBLeXBDs9NPY7+fHS8WU99
         Z03BwC3gqxnjlPDVPKMa/G++d2pMsQDDUgDK6uP4ay913EIboec/GBjXIjXyYaTLLcSG
         7N2hBl9TG991r48LQaqqEsOvvmxwEyPKfHS0OgNl/TMNR0zH141jgKfvIKybSJ0n+9Hv
         GnkFkIn8g2mNKM6vQUGmyzeAYHeqrcZgkmMBGQ0Yk6+yMrVn/uotWgHP+rJYP9scgSbf
         p6wY6IpTDKbJ9jxmFXItlVJRcT/fQDVeVFfSR/ZDTWi+beiWLLjGY3FPuWTWllYSpHkk
         5AzQ==
X-Google-Smtp-Source: AHgI3IZ79n88Px9pLipPMB/C3I8JX1Jfy4KMW6DD5Zf0oVHGmbnEP30npB0/aHg46iCTA+4rE5eIJg==
X-Received: by 2002:a81:a691:: with SMTP id d139mr5100928ywh.278.1550069818793;
        Wed, 13 Feb 2019 06:56:58 -0800 (PST)
Received: from localhost ([2620:10d:c091:180::1:2791])
        by smtp.gmail.com with ESMTPSA id v9sm6969116ywh.2.2019.02.13.06.56.57
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 13 Feb 2019 06:56:57 -0800 (PST)
Date: Wed, 13 Feb 2019 09:56:56 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v2] mm: workingset: replace IRQ-off check with a lockdep
 assert.
Message-ID: <20190213145656.GA25205@cmpxchg.org>
References: <20190211095724.nmflaigqlcipbxtk@linutronix.de>
 <20190211113829.sqf6bdi4c4cdd3rp@linutronix.de>
 <20190211185318.GA13953@cmpxchg.org>
 <20190211191345.lmh4kupxyta5fpja@linutronix.de>
 <20190211210208.GA9580@cmpxchg.org>
 <20190213092754.baxi5zpe7kdpf3bj@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190213092754.baxi5zpe7kdpf3bj@linutronix.de>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 13, 2019 at 10:27:54AM +0100, Sebastian Andrzej Siewior wrote:
> On 2019-02-11 16:02:08 [-0500], Johannes Weiner wrote:
> > > how do you define safe? I've been looking for dependencies of
> > > __mod_lruvec_state() but found only that the lock is held during the RMW
> > > operation with WORKINGSET_NODES idx.
> > 
> > These stat functions are not allowed to nest, and the executing thread
> > cannot migrate to another CPU during the operation, otherwise they
> > corrupt the state they're modifying.
> 
> If everyone is taking the same lock (like i_pages.xa_lock) then there
> will not be two instances updating the same stat. The owner of the
> (sleeping)-spinlock will not be migrated to another CPU.

This might be true for this particular stat item, but they are general
VM statistics. They're assuredly not all taking the xa_lock.

> > They are called from interrupt handlers, such as when NR_WRITEBACK is
> > decreased. Thus workingset_node_update() must exclude preemption from
> > irq handlers on the local CPU.
> 
> Do you have an example for a code path to check NR_WRITEBACK?

end_page_writeback()
 test_clear_page_writeback()
   dec_lruvec_state(lruvec, NR_WRITEBACK)

> > They rely on IRQ-disabling to also disable CPU migration.
> The spinlock disables CPU migration. 
> 
> > > >                                            I'm guessing it's because
> > > > preemption is disabled and irq handlers are punted to process context.
> > > preemption is enabled and IRQ are processed in forced-threaded mode.
> > 
> > That doesn't sound safe.
> 
> Do you have test-case or something I could throw at it and verify that
> this still works? So far nothing complains…

It's not easy to get the timing right on purpose, but we've seen in
production what happens when you don't protect these counter updates
from interrupts. See c3cc39118c36 ("mm: memcontrol: fix NR_WRITEBACK
leak in memcg and system stats").

