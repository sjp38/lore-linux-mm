Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8F0EDC169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 23:33:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 459EF2082C
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 23:33:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 459EF2082C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E21F28E0002; Tue, 29 Jan 2019 18:33:53 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DA99E8E0001; Tue, 29 Jan 2019 18:33:53 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C4B2D8E0002; Tue, 29 Jan 2019 18:33:53 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 952B98E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 18:33:53 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id w185so23738256qka.9
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 15:33:53 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=JyTTiq3DsYgJwx1ukkljmz+cEbvAGg9xFARwWuJQvds=;
        b=Ue1X5JhNEl+ott4PeoNlWrLioq6u3MYqjEpF2YOaY2eCWoI8rnSm8MvrcxI8KZk2eX
         Zimls/0pYSL6tcbSvJZ45VFyyJFu6SnsR+m4nuD9lrGfS9CGRpxmCF8cfocd8OHq6h3p
         AF4gAYKcWH42ln35I/M/y0KVd/5+cHto/B1qs3YFYa4ggrDNbUj0Npoi4I46ZmAEzpWZ
         ahX4T7/3aotGVHSc/PGIhX26ucGCoxrMqqq3vjf50EmL/QDNAjXKfJ+7bRE2sYxVJNzX
         AEcyZf3LRsa0UG+3VuzVvD4dXstsFus7jRx63FSJVGX5++y65Lpm3hXJ4FmNaqTWZiXl
         YKIQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukebSh6V6pdNet96z3bnnR4ktxT+j+1Xu630Lz/dz0QxF592GTrk
	pGAmfmugPPjj2319G9H1JhNlTKJLwbakHrjV2p6LgammI6oUf+/EOHsLD1YHxrrcVfLzJ4G5Hqc
	R0orcWtZwcFkTGHBAdsQLykzGHiwrJL8hkLX/mGm1TktwN7C3IYDYHzNZriEbA1zQSA==
X-Received: by 2002:a37:81c4:: with SMTP id c187mr25489347qkd.114.1548804833388;
        Tue, 29 Jan 2019 15:33:53 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6ChWNuZMw2A63IbBeW+fAk0nwq4J9WOtIBXYDiXdAP8V892hI4cB3DaJJG9vPBhTnMGgRV
X-Received: by 2002:a37:81c4:: with SMTP id c187mr25489321qkd.114.1548804832805;
        Tue, 29 Jan 2019 15:33:52 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548804832; cv=none;
        d=google.com; s=arc-20160816;
        b=qxhpYPfgU1OJIUI/eS97KFpuNGxdYfzLsAy4kp6KG8p7ZKnwNtjxxapS8d5MEiCeWB
         gbfCVlZH/vykexuBi3q6QLnQf4+glR8RGvj9rauCHTRUYBnj8EfUAPcl/cgqcOgGlb9P
         D1hEudmlnxMgQG7f5896UjGe3HQNlgZ4WzC2AdZx53NyLhNFNYpYe4l4rs7RVUJjz5YM
         EI8I4EPyAowCd0JgwSY/RvSA+DrWNrjFDTC5fl5xoS79MPB2xez6vdhwJd41F//+/00/
         HVZ+VPzy8YVcZxSFfui/BEcMSOWWbfMmj8hXz8Ha9XhqrIzGtB/oyN8yo3HDc5PVSZpb
         yswA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=JyTTiq3DsYgJwx1ukkljmz+cEbvAGg9xFARwWuJQvds=;
        b=1EEJLifnG01Egs8NRlGcbLIv8sGkeJ+6140leETEQ6l4jbeI6b1pp2RRHttvsgnVzk
         BxyRbCb1IzAqMLUNWKlHgjueEEr7qD7p2dhQzBq5/6SzUHfv1aORouXPRO3TfG46/fTK
         TnYuIeDAXrfg9y0nhXmgAXXEBk71EjI6gbx0TFS0m5auyFhQxeIpXipjiLTJ8Q/HmyJB
         DjInrlXH0zS6bgz6SZCbjSgcOoaeDly27FHTgtg28KoEu2ayrQzDRz+6HsX8HoKQck6E
         QwYB5tYve8+qkaYOGecHQePcmeue81WrsrkHCgsrGxL8RAk/DD2yI3slTf8a1vokaXlL
         lZrA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l15si8606824qti.7.2019.01.29.15.33.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 15:33:52 -0800 (PST)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id C191C132699;
	Tue, 29 Jan 2019 23:33:51 +0000 (UTC)
Received: from [10.36.116.48] (ovpn-116-48.ams2.redhat.com [10.36.116.48])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 679D7112C1B6;
	Tue, 29 Jan 2019 23:33:46 +0000 (UTC)
Subject: Re: [PATCH v1] mm: migrate: don't rely on PageMovable() of newpage
 after unlocking it
To: Sasha Levin <sashal@kernel.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
 Mel Gorman <mgorman@techsingularity.net>,
 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
 Michal Hocko <mhocko@suse.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
 Jan Kara <jack@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>,
 Dominik Brodowski <linux@dominikbrodowski.net>,
 Matthew Wilcox <willy@infradead.org>, Vratislav Bendel <vbendel@redhat.com>,
 Rafael Aquini <aquini@redhat.com>,
 Konstantin Khlebnikov <k.khlebnikov@samsung.com>,
 Minchan Kim <minchan@kernel.org>, stable@vger.kernel.org
References: <20190128160403.16657-1-david@redhat.com>
 <20190129231601.A97972175B@mail.kernel.org>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <9049df9c-296e-0ec7-5ee0-1a6978063ae7@redhat.com>
Date: Wed, 30 Jan 2019 00:33:45 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.3.1
MIME-Version: 1.0
In-Reply-To: <20190129231601.A97972175B@mail.kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Tue, 29 Jan 2019 23:33:52 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 30.01.19 00:16, Sasha Levin wrote:
> Hi,
> 
> [This is an automated email]
> 
> This commit has been processed because it contains a "Fixes:" tag,
> fixing commit: d6d86c0a7f8d mm/balloon_compaction: redesign ballooned pages management.
> 
> The bot has tested the following trees: v4.20.5, v4.19.18, v4.14.96, v4.9.153, v4.4.172, v3.18.133.
> 
> v4.20.5: Build OK!
> v4.19.18: Build OK!
> v4.14.96: Build OK!
> v4.9.153: Build OK!
> v4.4.172: Failed to apply! Possible dependencies:
>     1031bc589228 ("lib/vsprintf: add %*pg format specifier")
>     14e0a214d62d ("tools, perf: make gfp_compact_table up to date")
>     1f7866b4aebd ("mm, tracing: make show_gfp_flags() up to date")
>     420adbe9fc1a ("mm, tracing: unify mm flags handling in tracepoints and printk")
>     53f9263baba6 ("mm: rework mapcount accounting to enable 4k mapping of THPs")
>     7cd12b4abfd2 ("mm, page_owner: track and print last migrate reason")
>     7d2eba0557c1 ("mm: add tracepoint for scanning pages")
>     c6c919eb90e0 ("mm: use put_page() to free page instead of putback_lru_page()")
>     d435edca9288 ("mm, page_owner: copy page owner info during migration")
>     d8c1bdeb5d6b ("page-flags: trivial cleanup for PageTrans* helpers")
>     eca56ff906bd ("mm, shmem: add internal shmem resident memory accounting")
>     edf14cdbf9a0 ("mm, printk: introduce new format string for flags")
> 
> v3.18.133: Failed to apply! Possible dependencies:
>     2847cf95c68f ("mm/debug-pagealloc: cleanup page guard code")
>     48c96a368579 ("mm/page_owner: keep track of page owners")
>     7cd12b4abfd2 ("mm, page_owner: track and print last migrate reason")
>     94f759d62b2c ("mm/page_owner.c: remove unnecessary stack_trace field")
>     c6c919eb90e0 ("mm: use put_page() to free page instead of putback_lru_page()")
>     d435edca9288 ("mm, page_owner: copy page owner info during migration")
>     e2cfc91120fa ("mm/page_owner: set correct gfp_mask on page_owner")
>     e30825f1869a ("mm/debug-pagealloc: prepare boottime configurable on/off")
>     eefa864b701d ("mm/page_ext: resurrect struct page extending code for debugging")
> 
> 
> How should we proceed with this patch?

I just sent a v2 and will send separate backports for 4.4 and 3.18 once
we agreed on the new patch. Thanks!

> 
> --
> Thanks,
> Sasha
> 


-- 

Thanks,

David / dhildenb

