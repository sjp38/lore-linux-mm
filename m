Return-Path: <SRS0=d6aY=VB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 10A82C46486
	for <linux-mm@archiver.kernel.org>; Thu,  4 Jul 2019 16:00:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D6294218A3
	for <linux-mm@archiver.kernel.org>; Thu,  4 Jul 2019 16:00:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D6294218A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 559696B0003; Thu,  4 Jul 2019 12:00:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 50A7C8E0003; Thu,  4 Jul 2019 12:00:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3FA968E0001; Thu,  4 Jul 2019 12:00:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 200686B0003
	for <linux-mm@kvack.org>; Thu,  4 Jul 2019 12:00:30 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id c207so7185995qkb.11
        for <linux-mm@kvack.org>; Thu, 04 Jul 2019 09:00:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=WMVNT3LN3fIl8Tf3vwPupFLmmeqnTWObXXHkwWjFt0M=;
        b=LLQCOhDjztQYL6sEduz8HNLDGHZEbSYFGSEMQSJyfpWLUy/oS4galFD7LY4FaeDvgO
         5vQM194S8lgX1s9AyjR+XGbQzSsXDHOkyvKZzFNy/tAdABaaivnaeKZIYiTnYvFXS2Ta
         OJsiTKNo4jnTk0inkefXaYgNN+lwdmXdW226Ifb8Wq3whaJmISXGApRxXKj1VZT3jDjc
         r1Kqyamyx8c/clUAO2qfvqli7phIKJ2rkA05AUz0JGUqv+dCF9D55JMGG8/5lZosiD2v
         oS3ax7sTYczSStTqTFzbatQ72fBJWKrgesDmLytwme7gytc8Rb/x2BkkyNj+OH4X1fI8
         ziGg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW7HruiuB9j7o+AZjiptifsMDjW/SH2TDIZ+/j2U2tVd2+PNFeK
	1TDKwegIp+sHHjWRuYYxCm5xdIbSGXsZ/w/ogVhbBi0M62Zm7OOjylocVNeX6+35QwnDhvGx4vZ
	ONOGHTeKo5pr9vRyB3QjveZJrcfGSROg39AjTQW6n2HRP8y6jes0mSn+b3reFle/Iuw==
X-Received: by 2002:a0c:c3c7:: with SMTP id p7mr37026349qvi.125.1562256029873;
        Thu, 04 Jul 2019 09:00:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxzV49XPNVQ9kWUXc9CsisySZw6LL5OC6rfO2vzFcPbXE6Iryl/gUqQ8KL3zte8JmLp3EPn
X-Received: by 2002:a0c:c3c7:: with SMTP id p7mr37026304qvi.125.1562256029299;
        Thu, 04 Jul 2019 09:00:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562256029; cv=none;
        d=google.com; s=arc-20160816;
        b=X1LBhsB08mP3HVAYbxnwLHVoV2uU6Wg9QKyD3Cyb6vBBNPs28KA8HSE810RSqbyzcE
         msbeFgCelqpjrak+VfGjvjDfyzjjsH3Rfrgf/YOHoVps6of8xrfjOBVQ222pORveJqUy
         A2nuAnJroRo/0nQUD+pdvYpN1DT3dbexPxVPVmRuoUhDfGmb+JSqi2rxCGEUhgCeC3LJ
         SKe5b/52YzMnecszIeZxRZeE2imEMgx2xftjK9/kkd8/J6OLVw9Aaa5xR7eLnqrErFsj
         qxa+NxxJO1udMzIS02+41JHrPHm+2HN8qYiqS7Z+Tq8njuEkG5NpGBmSTdafnBgvjaJI
         +scg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=WMVNT3LN3fIl8Tf3vwPupFLmmeqnTWObXXHkwWjFt0M=;
        b=kE2YHnSVFJjIeVVov9z9vmsb1Qq8hzIdYNkh0f/x/n2kB1aFXxYOsYs+A4f+UG87/3
         ITCj6iCytBcxYcPpeTli8AwC32w5v1tL6n2+0USuhOhmYoli70b2xOr1n4I9XMoeOtP/
         +6S/0LGZXfZA80IUFqUi9xkEZMZBW3CmmLLxeYpGmpE0Tni6WJ7m7GGUeux6Yw1ONHkN
         ddCGXfaqcVUVmS1wzHSVWG4zf/ERmK0CrDmvqZjV2aLUTOLICajsvbs9v9OT9CaNIhEo
         imKYgAcFLoWtZMOLwlwE0nC3V7M8eR/V/369Dc+pYx00fCxhBewMSjF90Ct4YXjNFgKE
         Zz8w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q16si4374979qtc.362.2019.07.04.09.00.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Jul 2019 09:00:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 419D5C01DE89;
	Thu,  4 Jul 2019 16:00:22 +0000 (UTC)
Received: from dhcp-27-174.brq.redhat.com (unknown [10.43.17.136])
	by smtp.corp.redhat.com (Postfix) with SMTP id BE18D99AFF;
	Thu,  4 Jul 2019 16:00:18 +0000 (UTC)
Received: by dhcp-27-174.brq.redhat.com (nbSMTP-1.00) for uid 1000
	oleg@redhat.com; Thu,  4 Jul 2019 18:00:21 +0200 (CEST)
Date: Thu, 4 Jul 2019 18:00:18 +0200
From: Oleg Nesterov <oleg@redhat.com>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>,
	Peter Zijlstra <peterz@infradead.org>, Qian Cai <cai@lca.pw>,
	hch@lst.de, gkohli@codeaurora.org, mingo@redhat.com,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] block: fix a crash in do_task_dead()
Message-ID: <20190704160017.GB29995@redhat.com>
References: <1559161526-618-1-git-send-email-cai@lca.pw>
 <20190530080358.GG2623@hirez.programming.kicks-ass.net>
 <82e88482-1b53-9423-baad-484312957e48@kernel.dk>
 <20190603123705.GB3419@hirez.programming.kicks-ass.net>
 <ddf9ee34-cd97-a62b-6e91-6b4511586339@kernel.dk>
 <alpine.LSU.2.11.1906301542410.1105@eggly.anvils>
 <97d2f5cc-fe98-f28e-86ce-6fbdeb8b67bd@kernel.dk>
 <20190702150615.1dfbbc2345c1c8f4d2a235c0@linux-foundation.org>
 <20190703173546.GB21672@redhat.com>
 <alpine.LSU.2.11.1907031039180.1132@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1907031039180.1132@eggly.anvils>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Thu, 04 Jul 2019 16:00:28 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 07/03, Hugh Dickins wrote:
>
> Thank you, Oleg. But, with respect, I'd caution against making it cleverer
> at the last minute: what you posted already is understandable, works, has
> Jen's Reviewed-by and my Acked-by: it just lacks a description and signoff.

OK, agreed. I am sending that patch as-is with yours and Jen's acks applied.

Oleg.

