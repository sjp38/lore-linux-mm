Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6B803C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 16:05:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 18C6E2184C
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 16:05:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 18C6E2184C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BB7468E0003; Thu, 14 Mar 2019 12:05:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B663D8E0001; Thu, 14 Mar 2019 12:05:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A306A8E0003; Thu, 14 Mar 2019 12:05:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4BADB8E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 12:05:37 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id o9so2591636edh.10
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 09:05:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=I/ckSIzBE8yCbshubRBim1DJj67fgX77TITdDpRh6mE=;
        b=Nn9CawfMiS+xt7bFC4yUpovSslUVIeGjN4WI/LddEGyUdRFUvoOBNdIdOag6p4Zo0G
         ggCLq8o0Cl3UZS0xx5rMNziO3Z1YnV8JeJCJgQ7IOuPa8h2HAogcwewp/v7feRTqEV+t
         m7BhzLTNGf4AczVTBZicDXSAo2EXrZ+d6xCQng2tVhsf1gOf6Ol3fa/AvNu1c5ziOXJX
         tI+fkqpQRQyjAGPHfZqeNMWKNEbtkPjJRuQ6NEc+s1r1Z4l+X3yMaECaDUDc4d79jOdH
         n6/QIIMG0Ew2JpaAGYPr//mwIQwUj2sII1jIcqAMmtkCz2l71kR4Z6BV6f4hsyQLqf2o
         dzow==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
X-Gm-Message-State: APjAAAUCkRhrLy+GlN1Ukpn5xg6M1E1wDYMi7V02evM0brVuaTqVoEO8
	g5QvU5FNZknCfVwHXBfCZlWvVdb9tKy4hkARUNgRbpilZmOtp2Fn4UeEuNLLFFrYE+WJSbiQBfJ
	gMjGMJ5jDN7F5mRblZ/Urpprv46bmGH86ZEPraf0fsSpBXJoReuktk1JAxsvl0/ivIQ==
X-Received: by 2002:aa7:ccce:: with SMTP id y14mr12314463edt.160.1552579536900;
        Thu, 14 Mar 2019 09:05:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwFMX3aBWkJ03u6YWBa591eRdOc5AsErw/6uZq+dNup/Qdwoq34jCOUZIfwKNGyhL/GKHQj
X-Received: by 2002:aa7:ccce:: with SMTP id y14mr12314404edt.160.1552579536004;
        Thu, 14 Mar 2019 09:05:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552579535; cv=none;
        d=google.com; s=arc-20160816;
        b=VTCShGEvdcv9dPfq3Nuz+UFo1Pqj7pBwgGg4A6JZSIWB8M38HVX2vUUfawSyHj3kaR
         xtz6bsgyrbptpSXEIk1DoekEHtDxfF/A4kX4Cb/0D6gehrXH8/cVGvJjmtLqYWZNNnk6
         tdmWkBRbnUPGzcLFjnTjCJFdJOQRt/ycVAikTqdcRbqe+xLKjFvD4RgrsROnZO3AQ4tl
         tIpD3B2wt0y6VlOF5MQsltyy+/qIQnXsMDKupgeasARxS7eyhiAaPIMiItKc0QBxB3ac
         GoM3CQWA4LYniQ6herWfKXn9ows6CX3PEOZdet0Llnkc7uoWseFugXGhmpt+9wGK7GJA
         y22A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=I/ckSIzBE8yCbshubRBim1DJj67fgX77TITdDpRh6mE=;
        b=wdBCgL2nPAq75EEhuV8YdgjymTphjvgx5ZvitETc9Ia9eqwIqiqyGq9ZYGtaodGL9P
         6DavYJjvISUenHZKiDiMhsEmbyjbKhNDhlo9HurPAf7RLzjwGSa8eKWj6hGZKbJmCqM4
         yiuq78HR9/mZAPjqX5Heabt/EXMXYTajjwIkjIzLdNqQ7KHbDbo1mBU0wjtk69SGJk6+
         I/QfeQyQ0x+7Dplh8t9Xzgtp+Cph5gSY0zOl6MaR7na7rNNDR2d0opnoPISVRJdL5BPb
         JAwcxIlY8Q86/F7RytGiHx2AJZtP4J1olqxGJLC6YxXZAkupK3peuHpnoZZ5n71hMLAX
         F06Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s13si1519316edr.111.2019.03.14.09.05.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Mar 2019 09:05:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 2472FAD05;
	Thu, 14 Mar 2019 16:05:35 +0000 (UTC)
Subject: Re: [PATCH v2] xen/balloon: Fix mapping PG_offline pages to user
 space
To: David Hildenbrand <david@redhat.com>, xen-devel@lists.xenproject.org
Cc: linux-kernel@vger.kernel.org, Boris Ostrovsky
 <boris.ostrovsky@oracle.com>, Stefano Stabellini <sstabellini@kernel.org>,
 Julien Grall <julien.grall@arm.com>, Matthew Wilcox <willy@infradead.org>,
 Nadav Amit <namit@vmware.com>, Andrew Cooper <andrew.cooper3@citrix.com>,
 akpm@linux-foundation.org, linux-mm@kvack.org,
 Oscar Salvador <osalvador@suse.de>, Jan Beulich <JBeulich@suse.com>
References: <20190314160256.21713-1-david@redhat.com>
From: Juergen Gross <jgross@suse.com>
Openpgp: preference=signencrypt
Autocrypt: addr=jgross@suse.com; prefer-encrypt=mutual; keydata=
 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
Message-ID: <d02a354b-6b40-6fd9-b09b-debfee7d2071@suse.com>
Date: Thu, 14 Mar 2019 17:05:33 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190314160256.21713-1-david@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: de-DE
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 14/03/2019 17:02, David Hildenbrand wrote:
> The XEN balloon driver - in contrast to other balloon drivers - allows
> to map some inflated pages to user space. Such pages are allocated via
> alloc_xenballooned_pages() and freed via free_xenballooned_pages().
> The pfn space of these allocated pages is used to map other things
> by the hypervisor using hypercalls.
> 
> Pages marked with PG_offline must never be mapped to user space (as
> this page type uses the mapcount field of struct pages).
> 
> So what we can do is, clear/set PG_offline when allocating/freeing an
> inflated pages. This way, most inflated pages can be excluded by
> dumping tools and the "reused for other purpose" balloon pages are
> correctly not marked as PG_offline.
> 
> Fixes: 77c4adf6a6df (xen/balloon: mark inflated pages PG_offline)
> Reported-by: Julien Grall <julien.grall@arm.com>
> Tested-by: Julien Grall <julien.grall@arm.com>
> Signed-off-by: David Hildenbrand <david@redhat.com>

Reviewed-by: Juergen Gross <jgross@suse.com>


Juergen

