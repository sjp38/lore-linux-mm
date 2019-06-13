Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 17297C31E46
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 02:04:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CD8C321721
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 02:04:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="I7s+6BUD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CD8C321721
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 59B446B0006; Wed, 12 Jun 2019 22:04:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 54ACF6B0007; Wed, 12 Jun 2019 22:04:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4392E6B000D; Wed, 12 Jun 2019 22:04:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1A1AB6B0006
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 22:04:27 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id i123so13329511pfb.19
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 19:04:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=rHr+HNum2ZoZ6n9TuqyAITu764g/35CisPZqJOpxKJY=;
        b=mEj1JmkrHYJ686l/XYV8llrYIBNpDhcvDOQK9bwzEpU8Pm4kR4NqytrfhB1KgifrzX
         Gs7MX99BEM7uol+yFGTT2oaHTeCjP95lDyyrN9QE1jz5bAZKVRZPYJV2KX5eDbDoh80d
         6tO1U5YhCbyC5+j3qrI3cZBm4fTJyxREGOvIn90f3mtZxgM42bP4xbae+VAeUANNjhsd
         5ahKJnAUGF9CZaD4Qcba4nAgs3/UBS9X3AhE2Gno3uzbsQjrGAte7pEbyIvPG+FwDNQ7
         ziecdywW2nU1yAPnkGL6B62i8m5vjG9n2fdnWJNM+NGJSJ+gwUyicMKsVV8rXvOzncKg
         WvOA==
X-Gm-Message-State: APjAAAV+zW4LRbSbNZ+dBbjg3KK96PX1sEglzmHthgHl6sYAXbQ3kyk1
	2K14+44WaZhBXQ9zS856r7VadHsoYNQilpdkmceSksXzXv4jcAoY0ounUAvmtMMVK6UptFdXpdi
	Lw519HWIiZ/uOdd5q5wimlH1mxa2rojn+r8NCUllEiHUi1Y3Lrkkb1YS9G/PwZ6wx9Q==
X-Received: by 2002:a17:90a:22ea:: with SMTP id s97mr2183621pjc.39.1560391466711;
        Wed, 12 Jun 2019 19:04:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzB/eu8rH8ziKpzifhfidIwvSuMyEh4462BgH8minHr01H89ZXUx0xE4mcHw9zXMB4eDL83
X-Received: by 2002:a17:90a:22ea:: with SMTP id s97mr2183579pjc.39.1560391465964;
        Wed, 12 Jun 2019 19:04:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560391465; cv=none;
        d=google.com; s=arc-20160816;
        b=D8tHTk0tZ+N/U5+waNmKXpZU6gosV6HYmtReuq0ZBP1Jd1ny1z2mSufdd4DPLsBuTm
         Dn6/SMFr4y/fO1whKrppL2f6UE9tcCMRpyzPnfhIYeNvDbSucmUKSGOe+4JSaN1InmHp
         FIAuyzH5yvsPdwI8R1Qkpjx/8eIHyWvUsDjgrKMYL0R+Dqxsfg1L2aB4PBBAE+TCsefu
         mBtK/3qYsaVyyzfLUGpcGLgUDIBb9sKifA3q0WbiL/ZbfiY/h4QcNKzGNuzePK7l4cJr
         ZTEk47kzG5Dr9yKS3IU97WNL+AaYUg6u6B0fbdf2L+j5jSWlf8PVoW3DeMuruw+vBvn1
         FYjw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=rHr+HNum2ZoZ6n9TuqyAITu764g/35CisPZqJOpxKJY=;
        b=Xm4IA4UkVoe0Lnl2BmYcMcu/aqiXjC+H8Qc0i5sBpvnzutlsN1bt5V1xlJCJo7jFyW
         z01FrchntyCcJvXvxako9nbJAX5ILZXIEEM8UgtH9QAB8JUmHWuSIzzQT2tHfYXbgQrr
         vPSgNLRvAVQWGf6FgwcpWb2zr+nN+cqCzDar1SMu25Piw1QH3ZrhmvC8rtASgaBAG9dD
         nbF9N2B9joxzRr6l+Udb5VMN57Iq1wWRWFbjC9G41hiFGep8iVJYN0JQuucGu0My5N8q
         3IKgKIPScszgRCksWHoCNO0+C5zKkY/2BEYLk4QmQgjWqIxlu5Araa8rFGybNUO3xg0P
         JGdw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=I7s+6BUD;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 68si1200968plc.269.2019.06.12.19.04.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 19:04:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=I7s+6BUD;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 3E5FB208CA;
	Thu, 13 Jun 2019 02:04:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1560391464;
	bh=/ewpSppRNwtuoWk8VaEgHJcsNWYUbbPbRZ+qnk2kyu0=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=I7s+6BUD/VLMgDlpOTxcYbOO91mloye5QM2giwHGWpnPF9a5mIbZSRItaZFiRkGBu
	 pfL4yI8SigMJtXXa10yUVoenVbtJnNJtg49iHz/keiHPB9lbGzwHqEeyS8RvWrgt8o
	 1eQFFvGW7JDBZfcJ8qYMrZf0jWxzMVgTD7/EihwU=
Date: Wed, 12 Jun 2019 19:04:23 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Roman Gushchin <guro@fb.com>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>, <linux-mm@kvack.org>,
 <linux-kernel@vger.kernel.org>, <kernel-team@fb.com>, Johannes Weiner
 <hannes@cmpxchg.org>, Shakeel Butt <shakeelb@google.com>, Waiman Long
 <longman@redhat.com>
Subject: Re: [PATCH v7 01/10] mm: postpone kmem_cache memcg pointer
 initialization to memcg_link_cache()
Message-Id: <20190612190423.9971299bba0559e117faae92@linux-foundation.org>
In-Reply-To: <20190611231813.3148843-2-guro@fb.com>
References: <20190611231813.3148843-1-guro@fb.com>
	<20190611231813.3148843-2-guro@fb.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 11 Jun 2019 16:18:04 -0700 Roman Gushchin <guro@fb.com> wrote:

> Subject: [PATCH v7 01/10] mm: postpone kmem_cache memcg pointer initialization to memcg_link_cache()]

I think mm is too large a place for patches to be described as
affecting simply "mm".  So I'll irritatingly rewrite all these titles to
"mm: memcg/slab:".

