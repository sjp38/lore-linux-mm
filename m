Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 37DE5C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 18:52:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0125C2146E
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 18:52:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0125C2146E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AA62E6B0006; Wed, 20 Mar 2019 14:52:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A2F3E6B0007; Wed, 20 Mar 2019 14:52:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8F5EE6B0008; Wed, 20 Mar 2019 14:52:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 659366B0006
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 14:52:54 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id 33so3494581pgv.17
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 11:52:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ieSfa8lDFPiAb+pIE+Dypx9/8c9fhuM6W+im1sJ75Lc=;
        b=LAaMz/qtdD+J/kKUzTmnrpwcTM8bE82fum5M5SS1jjm7s02yyrCQ/t3cY/Yu6kvpN0
         lEiJ0BwD7YLTo2d3NT48XV6wLtwBdtr2SlGn+zy0uQjjEQXcwgRi21wibOca31KXfKDz
         tq94MCnBFqrC9wkAcOsYqLNXGUion/deNTkrH9jahysPGnZ5IYW3IYjxGWhb1XuVs8mZ
         uGGWnJTC4vPECtXJMoPMTxncS85YbQ5Pi7e6soJcM7Wt0silQMbQqJDBRcoXvXTzab9H
         m1m0xkojPWHczEByfgVNuV+p9lKzKiAVV3RVOFdDQaeMNjgT5v1ZjoMaVcHeDRuIuJYD
         qVbA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAWK/Fq6UVJFV2VT1moWucd5C2gSufI0wI08FYP2hPBwWPDm9b+7
	H+7ju7KG2h5bGoNRRMXy3UXhy/Ubkzkj3mCdXkD8NyumRgPkFl/E4wmvzYprQIOUbI+YBBshqxO
	HhUVrDXdHHUlqevyWfW9KXVOGcdLlwDYlBYsKlc4jIaF5QjZEs/2SIwgq9dUGX0od2g==
X-Received: by 2002:a17:902:6b04:: with SMTP id o4mr9358459plk.323.1553107974105;
        Wed, 20 Mar 2019 11:52:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyBWrYVJdKKWtnga0R45uhGh23ZnKghufJ1AWU70maGv7Im1acBjaIqN3lboEXDGJPEUjAa
X-Received: by 2002:a17:902:6b04:: with SMTP id o4mr9358415plk.323.1553107973504;
        Wed, 20 Mar 2019 11:52:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553107973; cv=none;
        d=google.com; s=arc-20160816;
        b=PokKIvwj0v8jFdXJ8t3lgIQmv0Oeq3qXeS0mBTIQbDzHyxNNhvh/R4Bf7/zP1DOIRV
         4DUGu5uLX0dtG2WxmILrjlNigQvlTsupZ/rhpGjfs3s7kSj6m1YK7ylSB+AQmbzLhzHr
         Yp3ohW+FMIdl9V461UdswzpnuHSCxpjNY+/4V4g2Vep4HE4XgBwxzFTSgaQAaqbWDmut
         Y9DoARx4ZUExyqvgBhkX0eLjT6y8lGwBZMSTBzJDYorZYf03yQ+zoVY8ghMHDfbwC5aY
         nIEZ5LVyOkZVLXHQ4A0U7ahN+w/+sx6cW+WxYDb1PIkOXsyZt7FufoMUa1eNhvSzjSo/
         R6GQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=ieSfa8lDFPiAb+pIE+Dypx9/8c9fhuM6W+im1sJ75Lc=;
        b=scPqldgOG5XxmJ9FhKdp3pWXyf69rgAbOLJrDR5mQwN++1q3ZyFQQoUosTqMe+BWxd
         DQfBPa648iJzBSKB6VEz0P7ruiKHC2D0InPH+PC+Ikq4U//Bcm9erWj0vxXnO9UmikW8
         vYj+hdo3UbhnMB6Rhy29ohHY+q9pCohJm7nuByxRZr/poTh/Ox+iuC4egsyOZkkpC5vb
         QtiGVHFNnmBz65bXzViSfBDpkyOhzQXGfh++tMB6c8FKy3k87igOP1kEc1twNl3cz4cr
         YNv/STjZ23iJCk4LXfWLvCnoHS3te0pe/ap6hyk9NRrIf5vlARbwJ85n25GqXNxmyqzi
         t2iA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id i10si2211913pgs.572.2019.03.20.11.52.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Mar 2019 11:52:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id BEFB34C50;
	Wed, 20 Mar 2019 18:52:52 +0000 (UTC)
Date: Wed, 20 Mar 2019 11:52:51 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: vdavydov.dev@gmail.com, bigeasy@linutronix.de, adobriyan@gmail.com,
 linux-mm@kvack.org
Subject: Re: [PATCH] mm/list_lru: Simplify __list_lru_walk_one()
Message-Id: <20190320115251.026f65e83ebde2b8ebf51134@linux-foundation.org>
In-Reply-To: <155308075272.10600.3895589023886665456.stgit@localhost.localdomain>
References: <155308075272.10600.3895589023886665456.stgit@localhost.localdomain>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 20 Mar 2019 14:19:27 +0300 Kirill Tkhai <ktkhai@virtuozzo.com> wrote:

> 1)Spinlock must be locked in any case, so assert_spin_locked()
>   are moved above the switch;

This isn't true.  When the ->isolate() handler xfs_buftarg_wait_rele()
(at least) returns LRU_SKIP, the lock is not held.

