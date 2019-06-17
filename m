Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EEEF9C31E44
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 06:59:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AC4A421855
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 06:59:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ztpYbwNu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AC4A421855
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3E35C8E0005; Mon, 17 Jun 2019 02:59:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3941E8E0001; Mon, 17 Jun 2019 02:59:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 25B4E8E0005; Mon, 17 Jun 2019 02:59:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 07C428E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 02:59:40 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id y5so11120785ioj.10
        for <linux-mm@kvack.org>; Sun, 16 Jun 2019 23:59:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=y7piXdmBDL/x4wKUpL4yfLcfRL1V1CU2X+sNEky1E+A=;
        b=qCK7eayBIUcSt2G21BCL/Fv0yQ3C76yh3vdXKrDu9swyE3F94h8OUnCpD+VKS7403N
         6SvHy/OR7If4iRv6ezqyx3+sM/0lWYBObyn+PJT8mFEV8oHn3Q11zsAFeMXW0rfYXA4G
         m0BY9yu/TwNe//nrMAV0e9Y35xAOUcbw4gIUinMNu3936ZO15cgl5arvddCRc/3EOJyc
         8vOScdh5psu29vwzS4564CYhF+3/0Y16/A9yEVRPv/12xsCYMM4/Dap/lW/YMHjYRniP
         tKBbe3YIUPrdbYbb/G02p7+oYz9jD9705L7hazZFQhdmYvSScJfFJNlPm+WS92/t9zRi
         O8sw==
X-Gm-Message-State: APjAAAW8rVcxX5F1CmRJK9gKl3+NRB0mX+r7anHUBXZLe+IcIZsnGjmv
	2yJDtz1/0PanF8tHHOyZs2Dl5hcCWDGlzQRa1Ii/0ao9FVhSCnNA2lkTUJE35eQK0/SpSJAS7+F
	11TApP1jxDjn9Y7ZErTAM8I742iAr+iD4CFzckPdGpzSIsdrVHAB/sflJOvwSZAzsCQ==
X-Received: by 2002:a6b:5115:: with SMTP id f21mr20512233iob.173.1560754779779;
        Sun, 16 Jun 2019 23:59:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzFMm01EJ4n0tbmgS4yBcjP8VPwZm27IH83RX1HLDaC3jV1f1rabi4OuydoNsF0gk3NypbD
X-Received: by 2002:a6b:5115:: with SMTP id f21mr20512207iob.173.1560754779290;
        Sun, 16 Jun 2019 23:59:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560754779; cv=none;
        d=google.com; s=arc-20160816;
        b=B3srxPgMSPK1bqR3QDO2F2iF9WfFzUXoZ+8n7GsC3tpQVYJuSMqQiQYNM+KOsvHn0i
         YpITcwQ7k9mRVuJIsgd3hzkQWOlAHFVwr8F71SlhjN9MVHuY5DyFOAUiusLuVShDLJV2
         3UUz199HnbZn0WYmj7xWRyJ5OuSRGZizRhp/cbJX9rcYQvbD/LsE1VxgSeYzxmp13Sep
         4Z7uRQoNtGot8khruOB/Bws1J6vpgAi4GDu3yZypGkJjWCHo6yvt2NeYqJXbYIgucp1i
         TfNWSNws4e+8tFllSFWYWthzuQ917VzHyPtR3BPTxa+hkzUO3rFEuKeFiuH1S2xsVyZM
         L3Fg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=y7piXdmBDL/x4wKUpL4yfLcfRL1V1CU2X+sNEky1E+A=;
        b=Piod58SjQsGGEucq4qtH2LiVcNb1ARDmNSuw3STBOytB5CrArbsyA89IdbdmYYkHuK
         Up3xkz4qU/xYkaWJuKcBZKjOrWPa9FBb0ndDPgMV/KdoCOaVzMLK77ZI9LatTRXMhTLf
         Cysse6iICMwi7dzw0j88fZzMlAaTZZvSKY1hjgcgqZ6txEdnjvvYhcrcTMRqN6XNPNkP
         TZ2LVNXNVmjhZbHNsUIyb378MgaZt4bHM4qGIC9Byw8sSiL1r1LmrVBE33f3qjh+mTc7
         dTHAlAcWhyjd0ChIZwlLUlUIK1R9iwZ1pXxsSyIXWesnAVFd2FrZXhapyxrV51BxUuQO
         Doyw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=ztpYbwNu;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id i15si15167570jan.87.2019.06.16.23.59.39
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 16 Jun 2019 23:59:39 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=ztpYbwNu;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=y7piXdmBDL/x4wKUpL4yfLcfRL1V1CU2X+sNEky1E+A=; b=ztpYbwNu1Ix6JsNAwF1thhxZp
	51JnJFP3opu9FapixnXOBLQISn3bIavs5VwpOYDraUSlDoeXdYRQ3ZKcOv6eh8IxSs/IQic82Tctj
	HqNh+CjbbpBr5h04zyqMq6Scc/stYKykNm/yKcqrOrbSgTtgat5tE4ylmM4f+oYSHndAa4iDAmUCh
	zNsP6y7VbP9c7NUBTt/yCMw0riLgsVHrGYhp0QMObC3JycTTOP35x3Gta+8QKau8fG+umGiptNgXQ
	XiXgqhQUPUJdkTf+sPcQZHasypJfYyXQ4UhnLrwqwAwGfleIQNJweY+FyQIgqKnQwhk3lzwkbice4
	tqolYkaDg==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hclbw-0005DX-5c; Mon, 17 Jun 2019 06:59:24 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 686772025A802; Mon, 17 Jun 2019 08:59:21 +0200 (CEST)
Date: Mon, 17 Jun 2019 08:59:21 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Alastair D'Silva <alastair@au1.ibm.com>
Cc: alastair@d-silva.org, Andrew Morton <akpm@linux-foundation.org>,
	David Hildenbrand <david@redhat.com>,
	Oscar Salvador <osalvador@suse.com>, Michal Hocko <mhocko@suse.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Arun KS <arunks@codeaurora.org>, Qian Cai <cai@lca.pw>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@kernel.org>,
	Josh Poimboeuf <jpoimboe@redhat.com>, Jiri Kosina <jkosina@suse.cz>,
	Mukesh Ojha <mojha@codeaurora.org>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Baoquan He <bhe@redhat.com>, Logan Gunthorpe <logang@deltatee.com>,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 5/5] mm/hotplug: export try_online_node
Message-ID: <20190617065921.GV3436@hirez.programming.kicks-ass.net>
References: <20190617043635.13201-1-alastair@au1.ibm.com>
 <20190617043635.13201-6-alastair@au1.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190617043635.13201-6-alastair@au1.ibm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 17, 2019 at 02:36:31PM +1000, Alastair D'Silva wrote:
> From: Alastair D'Silva <alastair@d-silva.org>
> 
> If an external driver module supplies physical memory and needs to expose

Why would you ever want to allow a module to do such a thing?

