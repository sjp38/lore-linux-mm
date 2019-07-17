Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5C654C76186
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 08:47:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D5A9C2173E
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 08:47:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D5A9C2173E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 249786B0003; Wed, 17 Jul 2019 04:47:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1FB0C6B0005; Wed, 17 Jul 2019 04:47:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0C3568E0001; Wed, 17 Jul 2019 04:47:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id ABEAF6B0003
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 04:47:55 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id c31so17576120ede.5
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 01:47:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=tMif6scUcVOD5tufGJPvW/JWbwIousm6EXgBXItmd84=;
        b=mGSqXYfg8Tjuhov2NhQVi5TdlDQvGgUFSUFtsbxKizkYwli2yFzqygmRgZ3pz4DgNI
         dQqeN3OuSpVzLA6pKZymm4/mqHYqz4uJDYCqGasJfP0FbHRlW5MGVZFnqtObVLCm62qQ
         zbXEd+xIHPKUhPwuZ50pvNN4vEBrrsww8rXlSi3H13v/wSafJiso7POSEOY+r5U37XfE
         URVkVWXMppjvoHwCwbmrOHR0hEuhSOKW7c+PWbxJpCjTxPRvkQl5LLMOrHAiLgIrizoH
         Iz5UuriM1ib/R1Tw2hZ3NA4X7Tlz2+1YTVaG01q/zHFzxqPKf18IaXn36ZH5PVhp6H6F
         mynA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAX8IHo6tNBpQMwDnHwyy6e3mOoy5IFKmIT1O/omGlCzq7Z8Tvi3
	BgIltYwP3xbUcBxVtWMspoOQJe3uMRadrpXCZeCBRhk7nQXN+p+fubx+V/AgnN2HQ6vLcWC6/kW
	zOURK/mfwTyMXthGFUmlIe6x2yzc1XZ1MPjYJ0vDV5HxjnL6OnK6Mcm8dd4scthrRuw==
X-Received: by 2002:a50:d1d7:: with SMTP id i23mr34207656edg.151.1563353275263;
        Wed, 17 Jul 2019 01:47:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxCQOdQWsfP8tCyt5ZbXglfTUa1trkqnAjYF92pE2TepsPUZyWad7gspyO873AlhHa/ZGws
X-Received: by 2002:a50:d1d7:: with SMTP id i23mr34207610edg.151.1563353274359;
        Wed, 17 Jul 2019 01:47:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563353274; cv=none;
        d=google.com; s=arc-20160816;
        b=k5lqGPqJ5cgND7IVM6UJ/OJ8Y24S3MfrjfGrwxY6JRnptJzYwFm+UINvAih2NJgRrY
         a1U5gfw5T/UD8nEOhlmaX6lMBX0hmcK01/wFTfzl0Tn6HrsY+sBg9h4QwwlFdZ9IdTsN
         U0VQQKWo//f7Vz8+532I0iB4I8OYccgzlyAxBuoCkHjZ74SQKs3CVPwaP7Nv93p3IRWp
         zPlzHmmr3XkbFy26if1PzVoLlRfU+WbkCk5R6LAnzNBajsakR7nrAHCAoerg7gtRQawZ
         lX0GPA7lZAeIP6W4eoR8zaIiOlcL7FQJ6P4WhHDoWYXkvm4+ZOGMjO4buAs51yMx9Flk
         vaCw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=tMif6scUcVOD5tufGJPvW/JWbwIousm6EXgBXItmd84=;
        b=WHK2BB1NTvh8V6aKpGDc7CzZu6I6UvF3txmqdhiY/9/HZOQ3UexIzd08hgL4EiSPvS
         GHbNRqietG0G3IcwDSBVbowGRfVdPQxiO3ZnxGVuJ/7HpRxrCVWsjPmEBMEz8jttfBxD
         OXn4TqKp7RFY0J9tjbjnsD4bejAUz0rnQXjVFiQu6x0NPqoWtYDuX0X5IiJ1kMflQaDI
         6IZ5gBJQNvruUtb8+D6sKB7v3opwSorQ/tmtM85SYt+cONliLCDJRMmI7HxyJrC1Upaa
         YNXG/8roqT51BeCd8d2jkJd0kcMxWRlDXiZAE46aQEWHTbAIU0HT+4k1TeE8J0cCMfsy
         Rm2A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l11si14398912edb.116.2019.07.17.01.47.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jul 2019 01:47:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 8B0C0AE34;
	Wed, 17 Jul 2019 08:47:53 +0000 (UTC)
Subject: Re: incoming
To: linux-kernel@vger.kernel.org,
 Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, Jonathan Corbet <corbet@lwn.net>,
 Thorsten Leemhuis <linux@leemhuis.info>, LKML <linux-kernel@vger.kernel.org>
References: <20190716162536.bb52b8f34a8ecf5331a86a42@linux-foundation.org>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=vbabka@suse.cz; prefer-encrypt=mutual; keydata=
 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
Message-ID: <8056ff9c-1ff2-6b6d-67c0-f62e66064428@suse.cz>
Date: Wed, 17 Jul 2019 10:47:51 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190716162536.bb52b8f34a8ecf5331a86a42@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/17/19 1:25 AM, Andrew Morton wrote:
> 
> Most of the rest of MM and just about all of the rest of everything
> else.

Hi,

as I've mentioned at LSF/MM [1], I think it would be nice if mm pull
requests had summaries similar to other subsystems. I see they are now
more structured (thanks!), but they are now probably hitting the limit
of what scripting can do to produce a high-level summary for human
readers (unless patch authors themselves provide a blurb that can be
extracted later?).

So I've tried now to provide an example what I had in mind, below. Maybe
it's too concise - if there were "larger" features in this pull request,
they would probably benefit from more details. I'm CCing the known (to
me) consumers of these mails to judge :) Note I've only covered mm, and
core stuff that I think will be interesting to wide audience (change in
LIST_POISON2 value? I'm sure as hell glad to know about that one :)

Feel free to include this in the merge commit, if you find it useful.

Thanks,
Vlastimil

[1] https://lwn.net/Articles/787705/

-----

- z3fold fixes and enhancements by Henry Burns and Vitaly Wool
- more accurate reclaimed slab caches calculations by Yafang Shao
- fix MAP_UNINITIALIZED UAPI symbol to not depend on config, by
Christoph Hellwig
- !CONFIG_MMU fixes by Christoph Hellwig
- new novmcoredd parameter to omit device dumps from vmcore, by Kairui Song
- new test_meminit module for testing heap and pagealloc initialization,
by Alexander Potapenko
- ioremap improvements for huge mappings, by Anshuman Khandual
- generalize kprobe page fault handling, by Anshuman Khandual
- device-dax hotplug fixes and improvements, by Pavel Tatashin
- enable synchronous DAX fault on powerpc, by Aneesh Kumar K.V
- add pte_devmap() support for arm64, by Robin Murphy
- unify locked_vm accounting with a helper, by Daniel Jordan
- several misc fixes

core/lib
- new typeof_member() macro including some users, by Alexey Dobriyan
- make BIT() and GENMASK() available in asm, by Masahiro Yamada
- changed LIST_POISON2 on x86_64 to 0xdead000000000122 for better code
generation, by Alexey Dobriyan
- rbtree code size optimizations, by Michel Lespinasse
- convert struct pid count to refcount_t, by Joel Fernandes

get_maintainer.pl
- add --no-moderated switch to skip moderated ML's, by Joe Perches


