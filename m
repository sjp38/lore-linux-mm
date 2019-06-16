Return-Path: <SRS0=z6ed=UP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 76257C31E50
	for <linux-mm@archiver.kernel.org>; Sun, 16 Jun 2019 16:26:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0B82620679
	for <linux-mm@archiver.kernel.org>; Sun, 16 Jun 2019 16:26:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ijVry35i"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0B82620679
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 538B06B0005; Sun, 16 Jun 2019 12:26:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4E9D88E0002; Sun, 16 Jun 2019 12:26:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 365508E0001; Sun, 16 Jun 2019 12:26:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id C94E26B0005
	for <linux-mm@kvack.org>; Sun, 16 Jun 2019 12:26:49 -0400 (EDT)
Received: by mail-lf1-f69.google.com with SMTP id e13so660773lfb.18
        for <linux-mm@kvack.org>; Sun, 16 Jun 2019 09:26:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=S2vKWdD0glGLsN86+msjXTlKQT0jYdW+WcffeWNC3YE=;
        b=SGV06ArpBb0rorKwfOGoLQ/q2Xy5/Rnzkg2ksJJHUMlKbKAdxw+Y8rBeu29vMzvS7D
         u3iFd6kJt2gvSFdIniorZKvTyO8vEXFBSljDZROyJC97t2mMMXBVFV6btyL34oUkxYaN
         QJBEpQ42jzXB9djMXCLIp+lgCuK+PtVHMrR0FgPCuMRl8R1h1UrqayunAOnAFYZzxTBC
         WunmCQJYp/mp/nQeAoRbPJWSFou1QZ5dydX58XahEpz6iHEroEkMziXVZv+dvn7Z5dSe
         J8inZwN5H8vNt3y+2awtGahQ4o4ZbEyGTPbdUYCfiEl9T6NA0zR+K51mJoPNC0yeE/K5
         9qpQ==
X-Gm-Message-State: APjAAAVJLMGQqe6P/pk3yCF6VMcz6IfbQEq6s3UMRiQK/T+30Fl399cg
	8BBR324l0vP1TgdD03H2KnKFbOz7uJsIJzJ8Gmev7ymXwxkkaiU9AVqZhiocYpluaSDVQp2MQ2L
	Uy+dXD7KdXbaxEV726QbVhh2A25Y7Wv4kAD8X72Hjl97PeOSvFlDvxJGId1P2Lw8AOQ==
X-Received: by 2002:a2e:900c:: with SMTP id h12mr29126625ljg.197.1560702408994;
        Sun, 16 Jun 2019 09:26:48 -0700 (PDT)
X-Received: by 2002:a2e:900c:: with SMTP id h12mr29126613ljg.197.1560702408280;
        Sun, 16 Jun 2019 09:26:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560702408; cv=none;
        d=google.com; s=arc-20160816;
        b=ReyrRwn6OQUd4dbEBnoH3JfcLq0u9XcfFUqDrFZztYUP9/Af6PRgMjGU4GpMvf272B
         J716n4l4DfwGRgAOemSV6gwIyQZOvPVGktAQGLHo3McUseo8scAehumhtXAFEsblxxZF
         7AyM0l8R5AiRwtNV0Ix4oXScla6oDPTSpf8erOKPPXByhmX4hsxwvNqrlz6dQA+wOGi2
         bJpWwvFvIqKWmZZBPjnpgSa7xwG7D4+hc87mOBA1mEdrGwJ3JnBzOSCOHmq+YLXxgi4a
         XR4QqAbe+71uQIZ8bAzo0j8FLX/YTo6+Ff9yQAoMNNrNRkTATfk+CTE2IggnpEzM+gl3
         FyNQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=S2vKWdD0glGLsN86+msjXTlKQT0jYdW+WcffeWNC3YE=;
        b=UpNOZ6blL9dY0Uyp/oYKm6Y1Vk0HEk8AMQtzBuWyC88IBY4CIfzfqHNHCJSlqhPExW
         FY2jte/jtvCPEloxiheumXh6uE0Knpm7zkz/Fkyp2TQjUhfXiCC7hJzaZJlNBAahz6sp
         nUWfKPmlvCg/T3ZzT0Lkqb7qFoHPC69TKLIbm2kgq3LR1masX0Bb2XeM5StsXocWDfGb
         L1PKnURPPecvZCMl0zqR/A3V/DO30+w5R+Arm0wK0j1t8mTuQaBESBHr1B6opb/ks/Av
         DI5Vh01XMIWk0mcnYTdipxXkOyRcEJGHAOVNZeSqBHFiYVfbE9hxELWBeY9VJIuPZRcb
         wKqg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ijVry35i;
       spf=pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vdavydov.dev@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o142sor2101409lff.32.2019.06.16.09.26.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 16 Jun 2019 09:26:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ijVry35i;
       spf=pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vdavydov.dev@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=S2vKWdD0glGLsN86+msjXTlKQT0jYdW+WcffeWNC3YE=;
        b=ijVry35ioGnqrLNPwg7Qdc3soSdUviCs43Ws+b7WZQpWZkrkjFpcNPtaadd05zyV27
         eye1hNuVhPV0MdxY7n2cpTXpeBkrfTNXznuKI56iCV2VGMgcpznyH5UW3813WhJToN6a
         zRVPg/Xc383rOwzNidEZMCeLIjPRu2BSu1gEuPuaOLuVC14it8GWaZjxANZYjVq6SCiM
         yJ68jKLTUFLa6LKVMJLyZ6zGrg+qG/qlLsv29fZuMKd+2n37E5swqhwh4p0U8pcRXBx4
         3qSawWU1Gj44vHvR4YtddyQ5m0ky31amOC/9CeXrdZFVMcrSZDBbxp8suFhXjS68oxfX
         GngQ==
X-Google-Smtp-Source: APXvYqwHsK9HmYkoBRaV5mX53vBWNhfqHOKQbpGSHLmmMgtNh9X4TDiaBlD50tp2dD18uvyneP0SXw==
X-Received: by 2002:ac2:528e:: with SMTP id q14mr24437296lfm.17.1560702407939;
        Sun, 16 Jun 2019 09:26:47 -0700 (PDT)
Received: from esperanza ([176.120.239.149])
        by smtp.gmail.com with ESMTPSA id y12sm1482549lfy.36.2019.06.16.09.26.46
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 16 Jun 2019 09:26:47 -0700 (PDT)
Date: Sun, 16 Jun 2019 19:26:45 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, kernel-team@fb.com,
	Johannes Weiner <hannes@cmpxchg.org>,
	Shakeel Butt <shakeelb@google.com>,
	Waiman Long <longman@redhat.com>
Subject: Re: [PATCH v7 06/10] mm: don't check the dying flag on kmem_cache
 creation
Message-ID: <20190616162645.rbcjhqjceuuxgvgr@esperanza>
References: <20190611231813.3148843-1-guro@fb.com>
 <20190611231813.3148843-7-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190611231813.3148843-7-guro@fb.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 11, 2019 at 04:18:09PM -0700, Roman Gushchin wrote:
> There is no point in checking the root_cache->memcg_params.dying
> flag on kmem_cache creation path. New allocations shouldn't be
> performed using a dead root kmem_cache, so no new memcg kmem_cache
> creation can be scheduled after the flag is set. And if it was
> scheduled before, flush_memcg_workqueue() will wait for it anyway.
> 
> So let's drop this check to simplify the code.
> 
> Signed-off-by: Roman Gushchin <guro@fb.com>

Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>

