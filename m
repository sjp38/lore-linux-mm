Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 64F8DC10F03
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 15:26:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 096962085A
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 15:26:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 096962085A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8FC758E0003; Fri,  1 Mar 2019 10:26:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8AB248E0001; Fri,  1 Mar 2019 10:26:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7C1348E0003; Fri,  1 Mar 2019 10:26:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3CD988E0001
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 10:26:19 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id f2so10038716edm.18
        for <linux-mm@kvack.org>; Fri, 01 Mar 2019 07:26:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=3QlOoVntXqw6RwtzidFqQC3ZX8v7YtuxUjndKl+5LYg=;
        b=nh/1lPBLX14XwP8R3cptUNlOf0sehBIzt8hWvapJHMtl8LUsf/5MYgSWDzn9PCElf7
         2S57ZZ7oQj211v15u4fySEOx0zTRhr68s21aoBqpY5lWHE3DV9aZ4o0ynbYQFdzvaDHW
         VW6J++a71zEdFGms5AXWfeHwqV6EUUQot541HYzaKb4IeUXf5LFmOHAk03wuQtStvbeN
         AsUKxTs5AE4oivtweNKAs9TLZEpGZGdjzCLmI22FBbrzsx4vJPgiPaqxbYg+jn8T5yVr
         JEDDYDF3ET7V+bp2A0f/GrzW+ggIufDpcjk7G3TUTnoupk4DlpneY4g98VtfW+OvvFFr
         Vmiw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of metan@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=metan@suse.de
X-Gm-Message-State: APjAAAU4HYvCgPhvJZ1V38db8Zba/z5XQO0sy167ONuM/TyD8g9gSMVp
	Ahyv0tk+BjGFh6CkmsDnJ7iHTDnE9FWE5pwJBP24WF7aeLCvwFUBf9mcAhUpzOnHXj1Ll9sI7Ya
	0MERHVs3nGdjL2CFwQdEnUYEY7S7vCPsRTyN4VmQ6ETOdyahStmkY5FZwXrAnxkQ=
X-Received: by 2002:a50:ae63:: with SMTP id c90mr4537129edd.285.1551453978807;
        Fri, 01 Mar 2019 07:26:18 -0800 (PST)
X-Google-Smtp-Source: APXvYqy8lE6IB4EVcjrTIHzoKTtnbhVe+iuHQx0KVCMaTv/bfn8IzgtUCOVCSBlPh/WpBBMlTed4
X-Received: by 2002:a50:ae63:: with SMTP id c90mr4537078edd.285.1551453977930;
        Fri, 01 Mar 2019 07:26:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551453977; cv=none;
        d=google.com; s=arc-20160816;
        b=x6ATGSF3xSJWoOlKz/rBbC2Kh6paEljcx6z4Hx0aUNfQ+wupYO33vmFBBecMi3qBi0
         jnx88pzCQSmDsDuzPfW67uSgF6h4NWwLzRJfwD1yGom+t4H497fWghgkMj3dKJIVh+Yr
         01HCcQiEi3zPqU/S9EV4API4kexm047qdSohnT3F/tiGli1bfC2KZaaedwyVUoZXPG9J
         Y8/OkJjVVbSeS8w9/gwL8dc4dy24kEiBcLoSUGilDKgYH9OCD+KPNKaq2dH5ivcyLhet
         LHNrw1N/I6msRigkcEHrvyb7AgkFS/AYGJQnDua1JsptyCXeDueXhTZxqolZjDeVVU26
         cUUw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=3QlOoVntXqw6RwtzidFqQC3ZX8v7YtuxUjndKl+5LYg=;
        b=NhAMIPmGZxYCG9fobfSV1HvdZcwkrv9KtHkKwdEdclGl/jXkxCGbbZNpASGlmcca0o
         zZWGz5b56kgG/ohHbEZUuVV9Tp/oHYUacQvwmTZqTXhrR1Ip1Hf3DYDJlnC4LPOrR+Vj
         Y99IWjQbbEFEGkKVf7AmG5hh+8HhmF4C5zIWGVG4t5bAO80uvP5I/VULtCsx6QvNvEpj
         fyF2qamMrXCAoQQbcieGJ1nacWCvK5YWvVtsy65ob/yMvs2qLoIEoY9ATq7qFR+d0X6E
         mLpCW8cHesHwOTonGjVT8uNb5R/bHAnroJosAmqybgWl00+p7QiWyWibn+HTl7t2QZu9
         Dw5g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of metan@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=metan@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t28si1447091eda.100.2019.03.01.07.26.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Mar 2019 07:26:17 -0800 (PST)
Received-SPF: pass (google.com: domain of metan@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of metan@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=metan@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 22603AB4D;
	Fri,  1 Mar 2019 15:26:17 +0000 (UTC)
Date: Fri, 1 Mar 2019 16:25:48 +0100
From: Cyril Hrubis <chrubis@suse.cz>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Oscar Salvador <osalvador@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, linux-api@vger.kernel.org,
	hughd@google.com, kirill@shutemov.name, joel@joelfernandes.org,
	jglisse@redhat.com, yang.shi@linux.alibaba.com,
	mgorman@techsingularity.net
Subject: Re: [PATCH] mm,mremap: Bail out earlier in mremap_to under map
 pressure
Message-ID: <20190301152547.GA25732@rei>
References: <20190226091314.18446-1-osalvador@suse.de>
 <20190226140428.3e7c8188eda6a54f9da08c43@linux-foundation.org>
 <20190227213205.5wdjucqdgfqx33tr@d104.suse.de>
 <5edcfeb8-4f53-0fe6-1e5b-c1e485f91d0d@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5edcfeb8-4f53-0fe6-1e5b-c1e485f91d0d@suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi!
> Hopefully the only program that would start failing would be a LTP test
> testing the current behavior near the limit (if such test exists). And
> that can be adjusted.

There does not seem to be a mremap() test that would do such a thing, so
we should be safe :-).

BTW there was a similar fix for mmap() with MAP_FIXED that caused a LTP
test to fail and was fixed in:

commit e8420a8ece80b3fe810415ecf061d54ca7fab266
Author: Cyril Hrubis <chrubis@suse.cz>
Date:   Mon Apr 29 15:08:33 2013 -0700

    mm/mmap: check for RLIMIT_AS before unmapping

And I haven't heard of any breakages so far so I guess that this very
similar situation and that the possibility of breaking real world
applications here is really low.

-- 
Cyril Hrubis
chrubis@suse.cz

