Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E1316C04AA7
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 12:04:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A80BC20989
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 12:04:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A80BC20989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4ED516B028D; Mon, 13 May 2019 08:04:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 49E916B028E; Mon, 13 May 2019 08:04:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 38C456B028F; Mon, 13 May 2019 08:04:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 187156B028D
	for <linux-mm@kvack.org>; Mon, 13 May 2019 08:04:57 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id p190so12539261qke.10
        for <linux-mm@kvack.org>; Mon, 13 May 2019 05:04:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:organization
         :from:in-reply-to:references:to:cc:subject:mime-version:content-id
         :date:message-id;
        bh=WRjxJbv6EkBOUfGfGrVWZ6SdRQ6i5rYK2+PVeKVllGQ=;
        b=NnFJHogGyFFo4nskMgALvwuknG+DJCXZPAwMV4D6iI2t140wGKnpG85Fq3h1If6b0p
         xaYQpQ53tbhGznUjiSctZ8czz4Cbs2Osvmd9DCXLnAFZl3K+Rz6Z1RreI/Fgi/JSIdRZ
         vzEfI1QQKR438sAM6av1WANXTWStghQI8HHY8hRCGT2B1tNxSHLZPVZDX7qnDFrx8Faz
         l9ykw+obCZzZN5Kw/aBB8b4+yj8H42fXEzzO3ZYejzOY54CAbfH0g61y4a9ALbcYA3X6
         Te04wvSOCZdCdu4gYbkMd38RFGclX51dy70uw+bj6CKyHBCFLHXT4WCzTBaqcD1+MN/S
         dDcQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dhowells@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dhowells@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUHMJ/tG2X8KnL2fMaGMHxgkEP4H6TLfl0WuI+YYeuuJsIvLvsb
	3H/dV2AcNad8gPP0/AArVXIc3a58/0oLRwnpULc7ujsbNbd+Dru5Tz1CDCKghe0t+O595R4j/aB
	wBM7wWZZV/f6hzQ5HBZ44bh1kwivxQG1IxRNx2LEwt9v/E6LK7jubGKcTq+6oIblHVg==
X-Received: by 2002:ae9:ec10:: with SMTP id h16mr22173381qkg.215.1557749096727;
        Mon, 13 May 2019 05:04:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxyHFiS4UCLtm61J8SSepmsQfQMxvJwUVIKOBpDHmGn9bKONrXYwGzs3EMDjPGtymY/qCKk
X-Received: by 2002:ae9:ec10:: with SMTP id h16mr22173342qkg.215.1557749096169;
        Mon, 13 May 2019 05:04:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557749096; cv=none;
        d=google.com; s=arc-20160816;
        b=MuqaLdOPMFfqdCNCOAMIdJN+r0vEC17/bpYrmyRCWdIC+CEhsNlGKpGcpCSHVXMyBr
         OUMA+C2wEC/JyA7JcQihO29gh1DVQAW8nFos+eweXF9unrQ9LdEJiUgrNfhZ2Zj/pQ1n
         Z+AhDxf6q6XS9W6tYCNKo2np4nRZLUkJveXw/gqfWX2KKljjIMisZre6Ujk30ySiH4KL
         ZPjG+MG24z2oN1qDixiLPxeImsfCZgWzUXolRUpcD+rq95DzV74uAUoiQVpRD7B9KTSJ
         BqYPXbfHrAKSjn2ye/AAC2F6D4EpLG8sDEG7ZA6p3YlRObUbFnvxUPCiGIuot76m1nHL
         TUpg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:content-id:mime-version:subject:cc:to:references
         :in-reply-to:from:organization;
        bh=WRjxJbv6EkBOUfGfGrVWZ6SdRQ6i5rYK2+PVeKVllGQ=;
        b=eqgi/sn7pBJua+nEXT926raSwJdPbfieY0kIb6NmqC0IDkbp7Gm4bse76xFTVKAR3M
         1GyG1tZ/YMaLYFwfPQnY6aLqlowNUEBIbSO1/UQx2Rw6AxgQdDaBIXC3WzlkumP/4ckI
         fNaEGSq5uoEuc9GmKsNG0JQTxBjgYZfNJzwZh+4SD4XmJlxQxLfSGPnB3X6QYV961laL
         BuDXMcDpKrt++hOwYYX6cUHMl0izUZ8jl8N+ynqzTzjqOmvcWEYBQtiy/62OWERDU0S9
         mO7Gvx5ObnfqgdnoGw6fxkRS1nabd3LRVGVJTuB1WyyRUbkPzL0iDAHzEwZ2UN60wG0z
         1GYA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dhowells@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dhowells@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c57si515367qte.12.2019.05.13.05.04.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 05:04:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of dhowells@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dhowells@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dhowells@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 574BE3079B90;
	Mon, 13 May 2019 12:04:46 +0000 (UTC)
Received: from warthog.procyon.org.uk (ovpn-120-61.rdu2.redhat.com [10.10.120.61])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 1EFEA5D71E;
	Mon, 13 May 2019 12:04:41 +0000 (UTC)
Organization: Red Hat UK Ltd. Registered Address: Red Hat UK Ltd, Amberley
	Place, 107-111 Peascod Street, Windsor, Berkshire, SI4 1TE, United
	Kingdom.
	Registered in England and Wales under Company Registration No. 3798903
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20190510165001.GA3162@bombadil.infradead.org>
References: <20190510165001.GA3162@bombadil.infradead.org> <20190510135031.1e8908fd@carbon> <14647.1557415738@warthog.procyon.org.uk> <3261.1557505403@warthog.procyon.org.uk>
To: Matthew Wilcox <willy@infradead.org>
Cc: dhowells@redhat.com, Jesper Dangaard Brouer <brouer@redhat.com>,
    Christoph Lameter <cl@linux.com>,
    Andrew Morton <akpm@linux-foundation.org>,
    linux-mm <linux-mm@kvack.org>
Subject: Re: Bulk kmalloc
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <4823.1557749080.1@warthog.procyon.org.uk>
Date: Mon, 13 May 2019 13:04:40 +0100
Message-ID: <4824.1557749080@warthog.procyon.org.uk>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Mon, 13 May 2019 12:04:50 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Matthew Wilcox <willy@infradead.org> wrote:

> kvmalloc() is the normal solution here.  Usual reasons for not being
> able to do that would be that you do DMA to the memory or that you need
> to be able to free each of these objects individually.

I don't need to DMA to the memory - but it might be worth my while removing
status, cb_expires_at, cb_version and cb_type from struct afs_vnode and
replacing them with an RCU-managed pointer to an afs_status_cb struct.

I could then use plain RCU rather than a seqlock to manage reading from the
record (the problem being that updating these records cannot be done
atomically).  That would allow me to make afs_d_revalidate() more efficient by
doing the checks first in LOOKUP_RCU mode.

I'm not sure it's worth the extra RCU load, though.

David

