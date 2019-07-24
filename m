Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7E8A5C76191
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 09:17:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 50A93227BF
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 09:17:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 50A93227BF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E05576B0006; Wed, 24 Jul 2019 05:17:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DB6A48E0003; Wed, 24 Jul 2019 05:17:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C7D488E0002; Wed, 24 Jul 2019 05:17:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id AC8B96B0006
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 05:17:29 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id j81so38652629qke.23
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 02:17:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=tuugOoBJw7nxB4oRweQBZ1Y2hf+P1zUQ2W+xilUNTVw=;
        b=N1iMUblIfjVbeZTR2tNUcw1/uAnSN2nEqGII3EcZ2s79U2RYlTnjEgoJa4N9rXDx5+
         NGkfDJEMz2580GaN5/AlOzXI0HfBY0VyAW42EY+6twfgc7QqRzlEtkQGF8XHaWxABkQs
         pbLV/6jDnD/c8+xSuaZE37PrWRfpEQ4W3AlHpfwrMP7/5Qrqd2i/V6GlPYMmNBOc7cYR
         3h6ArEJ/koWr1WsptJjLSbSBK34Jq1js0gYF1QlndNp7CU5XWIYcVywYETCoOxzsipAK
         Z0ScKrQ6AmiEPgSP/S++yJjcNpT2Z1SyK2U6QPkeEwOChBd/4vORCpuFzkIE02NFducM
         h8HA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUr/tDnLCQdP8JxgprHYYzI3MI7eiWBF2vFhBZZJQ/i6G1JN1Jw
	0FM473pMV8ZRUnupEEOoyY1AeSlJskqJDsbN4IEZ7X+iRYe5EzDU4ooIhLFKbaS+uwps4S3QI4C
	AvmGHb+FVHz73at/CVY1yvNJPUjyb9kYq0X5sB9MoE6p/xeh5KzDxXuFXPtV06fa8GQ==
X-Received: by 2002:ac8:f91:: with SMTP id b17mr56292342qtk.352.1563959849506;
        Wed, 24 Jul 2019 02:17:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqygK0qK1x9UepEPBDBS+rAEl9vEzys0SXYeyyeP8oEgJc7LPFhVqXvFfaMwyIAoxYgyrXep
X-Received: by 2002:ac8:f91:: with SMTP id b17mr56292320qtk.352.1563959849091;
        Wed, 24 Jul 2019 02:17:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563959849; cv=none;
        d=google.com; s=arc-20160816;
        b=cPzbxroRh/GtyjUpboOybvLmzaVX2RTnmnkDfbNU5QyHIHRtgPJ0a8kAFlXGoBRYJM
         GYkNs04gVS6oLwUbF1xGvgaDZzQFYxakbM/Tmzz9IYuc1XyJWE/C59MxRs8GhAv/ft0n
         EZQ8twPBUHAO+20QQhpFuQZnFeo0Cv1N2fiVVd2xpPeCm/cmi7HZirm9RDZdV/3KqCIP
         AZeNTsGbeneke0/jDXY05AQ3iwOmCoTji5JimnYO81c1W/RoDxujyJGBxVX3Ts+9b55F
         nj3n8mQofo2cS3jOLMXJONXPf0kCM91rAj12e0VthdHdAM6JaI5iRjgOLzND9Bxs3CKL
         LHmg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=tuugOoBJw7nxB4oRweQBZ1Y2hf+P1zUQ2W+xilUNTVw=;
        b=lxRxjq+xdo4Cfdxw300lHqaG16U+XDGZmzGzD6/jgkbjQN4blJhCTBqVUS2s/PCiog
         0uTF9wZH7GX9nlFXtsbcT7pu7WwwrENuBxx8BXT435x5qBixXqb6B5lijA/tEAp/AgT0
         iszpc5Vz2eoSEgvLTd+MagN4NgUVTyvTU2vtRl5Mr9rmulw2cbcupN1ezL73hnw1ghAl
         84amr7FEIntzdHI7ERJG1XCpjRRFhm1fBnzLcXam8Lna0iaIeZ+jIB6ISjJAXoWUkJ5I
         7RlFwksgHaM5DByXBvu2QfId1QtyKfEN/cEXU6xWZou/c/4jeKZwrwrVsIVC4h1Juu6R
         lzew==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p11si26065892qkk.82.2019.07.24.02.17.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 02:17:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 473FB302246D;
	Wed, 24 Jul 2019 09:17:28 +0000 (UTC)
Received: from dhcp-27-174.brq.redhat.com (unknown [10.43.17.136])
	by smtp.corp.redhat.com (Postfix) with SMTP id 3F02619C67;
	Wed, 24 Jul 2019 09:17:26 +0000 (UTC)
Received: by dhcp-27-174.brq.redhat.com (nbSMTP-1.00) for uid 1000
	oleg@redhat.com; Wed, 24 Jul 2019 11:17:28 +0200 (CEST)
Date: Wed, 24 Jul 2019 11:17:25 +0200
From: Oleg Nesterov <oleg@redhat.com>
To: Song Liu <songliubraving@fb.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	akpm@linux-foundation.org, matthew.wilcox@oracle.com,
	kirill.shutemov@linux.intel.com, peterz@infradead.org,
	rostedt@goodmis.org, kernel-team@fb.com,
	william.kucharski@oracle.com
Subject: Re: [PATCH v8 2/4] uprobe: use original page when all uprobes are
 removed
Message-ID: <20190724091725.GC21599@redhat.com>
References: <20190724083600.832091-1-songliubraving@fb.com>
 <20190724083600.832091-3-songliubraving@fb.com>
 <20190724090734.GB21599@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190724090734.GB21599@redhat.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Wed, 24 Jul 2019 09:17:28 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 07/24, Oleg Nesterov wrote:
>
> On 07/24, Song Liu wrote:
> >
> > This patch allows uprobe to use original page when possible (all uprobes
> > on the page are already removed).
>
> and only if the original page is already in the page cache and uptodate,
> right?
>
> another reason why I think unmap makes more sense... but I won't argue.

but somehow I forgot we need to read the original page anyway to check
pages_identical(), so unmap is not really better, please forget.

Oleg.

