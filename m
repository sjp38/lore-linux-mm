Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74668C282D4
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 06:26:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 389BC2175B
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 06:26:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 389BC2175B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A7DA28E0002; Wed, 30 Jan 2019 01:26:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A2C418E0001; Wed, 30 Jan 2019 01:26:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 91B168E0002; Wed, 30 Jan 2019 01:26:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 505108E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 01:26:28 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id h10so16091816plk.12
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 22:26:28 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=k2gKPKDitmevoAR7iBqR4mW/g/nPK5nF2FQllehM+aM=;
        b=X0WNc0119vRmHHbJvRJslrNzGe6KgDeEdpVmlN89hvK00+9ZJieJ+RmFMLRJ4UxkQx
         KPUVLvYBMCwiJ52gjrZaqFyHC8PJ6TdnGkrZcOEoYk47kuAiV0Dy6B4J29gcnQhyea62
         yDX/XwkZFcMCmsl2+SeBUS8hesDi/kYoPYIB5pZCsIq4NDPlRd+D50/YAUl+uDo0UYVm
         60+177EuiHkeEgC769SVw1mxs9x4RWeqHeC+eqBLl14kUEmXZIyAaw0qs9j/PRpZaMR5
         sOnicQqBBoaByPO03Fq/qyiN3i+zSMMC/Gbmk5l/AXk3o39KFWZqj5loY3OzIwDgY5mX
         2pew==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AJcUukdCeUPO64BpTW1VmJMAGFs6iS5C1X4t9M0+lPrXiW8+PXEBYRhC
	1jwtkFtav5hXaM1bzVAFFFY05cA6G44RO/poUBfZy3mX07CAQZ7gDqzgPpLlAni4tqaKq7Zd9NB
	EanFPTd0Palwa6yNbTtYWhUSw2fcsjLaGyn4/dHMCtQ+SavOW7HMXBeYZ7zPUPRqQHw==
X-Received: by 2002:a62:2082:: with SMTP id m2mr28628930pfj.163.1548829587986;
        Tue, 29 Jan 2019 22:26:27 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5UjZ274KKLvwx4IvRvcVURr/TgVKRWINOY4o7BuKg7wpj2oJL+oiOzNTc2pnsfAmC93bgl
X-Received: by 2002:a62:2082:: with SMTP id m2mr28628897pfj.163.1548829587148;
        Tue, 29 Jan 2019 22:26:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548829587; cv=none;
        d=google.com; s=arc-20160816;
        b=xx9EuIRMbUL0eznZ0LeEo6FbiV02p0PKHK7/OxNmBLvihbeOJ0zhjzvSGEQrOOhCbp
         RuBmm8E6JNVYBuHIfv+zBplaVhi1dBERp/m/KdvAMX7jejoseSOANa7aSxdEDSZ65yLg
         pnZFboHirsmsXmpCzIFIUCb4OyfDe3Fm0HKS6/L327CHdjVV+UWnVmUXVYV/eTAsBRte
         9ai8ph2eqXJt8x1v8oZkLDbl27Owsf9ebdtOM6UqE8+FYtEh2Rp7QrY28BzrCPZu7An2
         1rpJPQVO943Z7QtKIduDjbkQksjqGAFbe8fbx9DpPXLK+T8q8Gm/H7YvK8RAxzLlLeW7
         vKuQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=k2gKPKDitmevoAR7iBqR4mW/g/nPK5nF2FQllehM+aM=;
        b=pOfBzCOg56K4XzFxOKFHir6zkMCJ+DnsJmctUJ21/oQMyW3l5hmnrM5DtI9bzQkruZ
         T0BgkRyMGATtQzFa1bfEm7324Keta5T7fX4xCYW5sLpWjKcrjE72ADXXTEKZyvxUENXx
         p5tulO/sdZaG4MbZ5Hy+56cta8HOyLs36a/MGFLj8Uep34F6HiaaRM88IbabytvPeaBl
         ks7bNH5hRZ9UXl4oTUdGn2Ce6qXvAE22xNpkcHPxrjj/3QNg5/PK6PzCPomuplXLzH3D
         hFgH6HD0/4TVRnTcau8DYDRIBZdGY2HkBWjpxj6sdA/oGhHQwFpiw3eAzofOidO57DGD
         yLMg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id w10si646069pgj.214.2019.01.29.22.26.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 22:26:27 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 925F63A0D;
	Wed, 30 Jan 2019 06:26:25 +0000 (UTC)
Date: Tue, 29 Jan 2019 22:26:22 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: dan.carpenter@oracle.com, andrea.parri@amarulasolutions.com,
 shli@kernel.org, ying.huang@intel.com, dave.hansen@linux.intel.com,
 sfr@canb.auug.org.au, osandov@fb.com, tj@kernel.org, ak@linux.intel.com,
 linux-mm@kvack.org, kernel-janitors@vger.kernel.org, paulmck@linux.ibm.com,
 stern@rowland.harvard.edu, peterz@infradead.org, will.deacon@arm.com
Subject: Re: [PATCH] mm, swap: bounds check swap_info accesses to avoid NULL
 derefs
Message-Id: <20190129222622.440a6c3af63c57f0aa5c09ca@linux-foundation.org>
In-Reply-To: <20190115002305.15402-1-daniel.m.jordan@oracle.com>
References: <20190114222529.43zay6r242ipw5jb@ca-dmjordan1.us.oracle.com>
	<20190115002305.15402-1-daniel.m.jordan@oracle.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 14 Jan 2019 19:23:05 -0500 Daniel Jordan <daniel.m.jordan@oracle.com> wrote:

> Dan Carpenter reports a potential NULL dereference in
> get_swap_page_of_type:
> 
>   Smatch complains that the NULL checks on "si" aren't consistent.  This
>   seems like a real bug because we have not ensured that the type is
>   valid and so "si" can be NULL.
> 
> Add the missing check for NULL, taking care to use a read barrier to
> ensure CPU1 observes CPU0's updates in the correct order:
> 
>         CPU0                           CPU1
>         alloc_swap_info()              if (type >= nr_swapfiles)
>           swap_info[type] = p              /* handle invalid entry */
>           smp_wmb()                    smp_rmb()
>           ++nr_swapfiles               p = swap_info[type]
> 
> Without smp_rmb, CPU1 might observe CPU0's write to nr_swapfiles before
> CPU0's write to swap_info[type] and read NULL from swap_info[type].
> 
> Ying Huang noticed that other places don't order these reads properly.
> Introduce swap_type_to_swap_info to encourage correct usage.
> 
> Use READ_ONCE and WRITE_ONCE to follow the Linux Kernel Memory Model
> (see tools/memory-model/Documentation/explanation.txt).
> 
> This ordering need not be enforced in places where swap_lock is held
> (e.g. si_swapinfo) because swap_lock serializes updates to nr_swapfiles
> and the swap_info array.
> 
> This is a theoretical problem, no actual reports of it exist.
> 

LGTM, but like most people I'm afraid to ack it ;)

mm-swap-fix-race-between-swapoff-and-some-swap-operations.patch is very
stuck so can you please redo this against mainline?

