Return-Path: <SRS0=T9E7=U7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 51B0DC06510
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 12:23:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 127C820836
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 12:23:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="PI/krrON"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 127C820836
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AC2306B0003; Tue,  2 Jul 2019 08:23:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A72848E0003; Tue,  2 Jul 2019 08:23:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 961ED8E0001; Tue,  2 Jul 2019 08:23:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 72B9D6B0003
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 08:23:32 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id j22so5368485pfe.11
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 05:23:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=qKrxyQJ9SgUXm99WAZTTjGGR42eLnd0bh+xx2k6emyg=;
        b=fkP9So5nOPYdbOeDDgDfuwqONhgvWWWFbvY0t4tLdJfyh7Lcgky/6s/e89P/zv16Aa
         pgI6jI9G4PU5LAcZybor+erewzwMi6DagF/SEmyloEc9DZURmWtPqJtvH1jNWoYQhmeL
         UdeGf+hiPBjFbehR0iZcseO77KehMqMltwXUVPqh7DoyERP15NxCyQoWdv+KWpQNIGOf
         kQtJs4s04ajSywRUf5Pau3KN8bIvZDz1rFIMFQ7ti7FUh2nEzhNZZ+SjwUTXflfxPgF9
         REvlxxxIQb3D4j1izvDTaQa5EZSVfTSfXMu8AaFFVasgc5UA8x/R4lLzV3b4BKg+Kv26
         A+9w==
X-Gm-Message-State: APjAAAUCkbmbq5I2VR63ZEoqEj2bqmqWOaGBVkytm9HsMK/bQUFL28VK
	XZRM5La8cZaja31Bo8KYMiSTXcvtrsCyDih5/4kKLYPfrp8gB1DOOCG+0I9da3tlJ18dZ0GqyaY
	gvdmLVpHJAcyhHdAYetafoX452u/3z9PnAfnmBhnuA9duqYeW9qWYHhUN6BUavBnmSw==
X-Received: by 2002:a63:2258:: with SMTP id t24mr30230685pgm.236.1562070211895;
        Tue, 02 Jul 2019 05:23:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxE+1xHomtbdOttAEDYy6Ro8GOTMx2w7PL1LXJC2nX39VZOIo9rPcWbX29RvISpplE2JVRK
X-Received: by 2002:a63:2258:: with SMTP id t24mr30230632pgm.236.1562070211189;
        Tue, 02 Jul 2019 05:23:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562070211; cv=none;
        d=google.com; s=arc-20160816;
        b=XeA2Ibgb/Ctj3SchFkrP55LOMk+YQf2jyyxlP3BLWLbiwJRe39r4QGlL3E7IUfQYtB
         EgZpiRFmWhUOrbkSBRTeFY9i4zYdMIof0ueEsRHHL+oBOrC3uPENyC5bRsGC6+EH4r7u
         4Golwl5CpJJgDG2nzvCM4n+xD3ocnEAQnCpP4Ls3ZCF5c+Fg0ymKmM1VbzbBOHoHgmxV
         hC1N8jzl0gIYYmjLKQSaBDaGTlhbh6KGVlqLawEzY68aB/NPYbBbDtcqmBWqtoZFdzaF
         epKItYhQ1usNs7ltKeEB6MCcrpIdGPrlnHkmwrYcyM3VAqae/yDjdWAcU97RVe42G18w
         bcow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=qKrxyQJ9SgUXm99WAZTTjGGR42eLnd0bh+xx2k6emyg=;
        b=Yj8qNdbTTQBYnbfA6Ya6fyUQ6qzS75d3Tp1rUOXWG0L9w4hTbXUKvBJC2jZBEZKWAx
         XoVMhWQ0t/UsP/dV+dCY296TVO1qD5xQawWDmc7DO/bpFJq/Td3lMyACVcNxy/z0+I1x
         kXi22kLRZ6eEKDILb8LiXK3pqBAQrnT+AxCJi6m2/C6WzylDkMcOfA/zUS/CxCGCP81O
         hEJJO8JES6fRJJYU8X02GjwinrBKf+qDmLU9WrQm1fjRcl58fFtT+350kw0yqdP7sw4Z
         PIXA9z+/s0ACGpBGni04AlZDzFVqOMrB65z8cZT9titajO6ENaKRW5B7OGD9rymXLpaA
         xdHw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="PI/krrON";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id v10si13203180plg.320.2019.07.02.05.23.30
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 02 Jul 2019 05:23:30 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="PI/krrON";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=qKrxyQJ9SgUXm99WAZTTjGGR42eLnd0bh+xx2k6emyg=; b=PI/krrONm2KN5eB0OOM3DxRy7
	VHoHinvVWugAGktCautlN02o/iJrv07CmHH6iiZih8czIKOr14F7lsDpPeB9w9gs7bI47+ad0LLlx
	3XnSTfZ33d49SWRbklND4Xg9O8uVy9IuOisojt/5DZ/VyzKXtZcPqHhpadtBCoB2dmI/PpQJo2LGp
	lK+v7InYtRaACYTvrXQOxFwwN2uL1OfhD70KvgaTM9fFJhd0vjtgHh+oBArZt5c3oiRuyGxKDe1sv
	8kbE/axYsg+jcG9ERYzEyAApM5UeDHbPFpxKI1Xp9NtghLmDkUnLHnhUuX3wOiODrlhmxxUCk2SCL
	pOxr7lrPw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hiHof-0000yN-MT; Tue, 02 Jul 2019 12:23:21 +0000
Date: Tue, 2 Jul 2019 05:23:21 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Pengfei Li <lpf.vector@gmail.com>
Cc: akpm@linux-foundation.org, peterz@infradead.org, urezki@gmail.com,
	rpenyaev@suse.de, mhocko@suse.com, guro@fb.com,
	aryabinin@virtuozzo.com, rppt@linux.ibm.com, mingo@kernel.org,
	rick.p.edgecombe@intel.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 3/5] mm/vmalloc.c: Rename function __find_vmap_area() for
 readability
Message-ID: <20190702122321.GC1729@bombadil.infradead.org>
References: <20190630075650.8516-1-lpf.vector@gmail.com>
 <20190630075650.8516-4-lpf.vector@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190630075650.8516-4-lpf.vector@gmail.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Jun 30, 2019 at 03:56:48PM +0800, Pengfei Li wrote:
> Rename function __find_vmap_area to __search_va_from_busy_tree to
> indicate that it is searching in the *BUSY* tree.

Wrong preposition; you search _in_ a tree, not _from_ a tree.

