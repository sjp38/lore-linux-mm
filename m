Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 620E9C04E53
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 15:24:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1756620873
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 15:24:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="HsFn1bjM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1756620873
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 86C056B0003; Wed, 15 May 2019 11:24:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 81B916B0006; Wed, 15 May 2019 11:24:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 70B916B0007; Wed, 15 May 2019 11:24:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0B2146B0003
	for <linux-mm@kvack.org>; Wed, 15 May 2019 11:24:27 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id g15so468124ljk.8
        for <linux-mm@kvack.org>; Wed, 15 May 2019 08:24:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:date:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=bp9aZsP8Ihx3GbkK6sVw6F2oBHeQXKwNHmb8Yt9P0/A=;
        b=J4XniYzMl8WiMkxHcyW/ieJukg3hgT3AqbfFdq0cZcoe3lN2/OuMdm6Jwt8qAyag2o
         giMpoYKCIwHACuoqB9sOriV/91JI8bP8EeA9o8beBllGfLZKRGCIwqY11EjzCwpExgNG
         Xpqh83SpJj3SfQ20UQ3UZivPzr5JU2Vsq/Mtsltw7U9BqUrvn684PFNUWGZA+QUh0EhY
         qnowjSm8lWZ96QxPa7H8H0dREZKYXCt6jSV4U5K3wBImFUt6TFCAeVDyqdWP+luah7h1
         GkutZBPGkW9PJLf/4tEIplLpC1GXtoQJ/DnD8fRjAbeQ3B9vrymwTx9Jvs+NsvtWz3WR
         fLuA==
X-Gm-Message-State: APjAAAWiJ2LkaPssv9hazv4gcsq+tSTufkzfIc3VeHgdjoiHHbbLo6dw
	Ln6WSZ7RVmHPnpQWbex2gPjL4d4Z5nCm/UlozG8PuNWiYVhFHvGrxRXSNsrBWRIkc22niWXlqOp
	X7kosc9G/UrDnJdPCsEJf6HfiCP22fLw4KpvoLo/0linBBsLyQsKGeXLRHcB/JdT3BQ==
X-Received: by 2002:ac2:528f:: with SMTP id q15mr3111482lfm.37.1557933866382;
        Wed, 15 May 2019 08:24:26 -0700 (PDT)
X-Received: by 2002:ac2:528f:: with SMTP id q15mr3111436lfm.37.1557933865495;
        Wed, 15 May 2019 08:24:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557933865; cv=none;
        d=google.com; s=arc-20160816;
        b=pgZrGxJ76RzKdm5+akjzUuIBYbgZpN9nP+8E0xtTCqQS84+RcV+Eq8hSwwFMhQX1+Z
         eDckmAxFES+8AURG3H4KOMu2zYAS/7Q7hPRsUOdAaraOoYBtkJVpAGEpXGRq2mTw4wKF
         pbyDmK4/RHQ9dsvfu9u24FW46UjWRnRcSy2uYJVu357Zcvzpe/xcmTLIrZfo54j9XIBo
         D9/ar0wdzqhVQEifID1DFYLO7TViFOmt/HCkqzfAoBsozegGFJWTNyzJMPes9SiJCswV
         bs3dE6fVYk8bBKjdnbMjSGECSJ9iYR3niOaf617+B2xCpPMJ+qU00Gch4KR/U6FwTact
         zNjg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:date:from:dkim-signature;
        bh=bp9aZsP8Ihx3GbkK6sVw6F2oBHeQXKwNHmb8Yt9P0/A=;
        b=vIA6qDBU+hfZZWtmhRNQhdyzVhHqSbKxKLqimU1MZS+fQmpWIRAL4KTsbSU+9q8mDp
         V5XfFqjsS7eF/EXTHTq+nlcc+KWjP7l3+vOSXUL6iAZ1d8gSe6u0Y2ISEDcx9kes/UA7
         +6pzZ980xUQsJGwkuGwfkX1LcISMTD8v5UIuqECfixFlewZWvgYxx7eJ5A9EzJ+C2B3v
         BGhoqnPNfrRNHKVqk/mfYMDvGmgz8PVGs81ogIqvkthhwnHBR+Fy1DfuQlJxxUivcVQd
         +G74ruXzcdFbwzzQGFYOUuD9xmRUZC+O5au2cHdir7aU8gxSxFJ1SHm4hRCwDgTQR7XL
         y6CA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=HsFn1bjM;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 8sor788850lfz.14.2019.05.15.08.24.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 15 May 2019 08:24:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=HsFn1bjM;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:date:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=bp9aZsP8Ihx3GbkK6sVw6F2oBHeQXKwNHmb8Yt9P0/A=;
        b=HsFn1bjMaUtH6jvwg7mjfmu3U0DtRpt953VIQJ/7/ad6c9WQN+io5di4dRZeS3BqEw
         FWsU1kKWqXgIihVIEKSV7Hp/aaja3i7d8aZ8iDK54Z+r5FpWx4wyfrDKdwtYpvEJIu4L
         mdmp2wGGaavoRnMbme7zB+9eHN0sYwRGd9mRYzfjKXIyyCUN/h9L0EuNU/gSc9eb09Or
         nHex62htpbDf4uSd+yEkV43l5gnYDOiq2MDu1p2vBx8x9Hjx7TOGyw0RPzGK35u9P1rQ
         7EAF52IqiycKQnEMUepkhO1xjmpVgdn6Dq2OoBNX4jLorYOnyC3tXJHdyquK3EbQ9gFg
         rUNg==
X-Google-Smtp-Source: APXvYqwY1WTXGYR3o8YWyC3tnZWmG25a3r9RgDDvY4fSzidz1fEOKxmhCfonNsCioDkWtFA/gCSy9Q==
X-Received: by 2002:a19:5513:: with SMTP id n19mr7074764lfe.21.1557933864947;
        Wed, 15 May 2019 08:24:24 -0700 (PDT)
Received: from pc636 ([37.139.158.167])
        by smtp.gmail.com with ESMTPSA id h24sm398640ljk.10.2019.05.15.08.24.23
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 15 May 2019 08:24:24 -0700 (PDT)
From: Uladzislau Rezki <urezki@gmail.com>
X-Google-Original-From: Uladzislau Rezki <urezki@pc636>
Date: Wed, 15 May 2019 17:24:15 +0200
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Uladzislau Rezki (Sony)" <urezki@gmail.com>,
	Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org,
	LKML <linux-kernel@vger.kernel.org>,
	Thomas Garnier <thgarnie@google.com>,
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Joel Fernandes <joelaf@google.com>,
	Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
	Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v4 1/3] mm/vmap: keep track of free blocks for vmap
 allocation
Message-ID: <20190515152415.lcbnqvcjppype7i5@pc636>
References: <20190406183508.25273-1-urezki@gmail.com>
 <20190406183508.25273-2-urezki@gmail.com>
 <20190514141942.23271725e5d1b8477a44f102@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190514141942.23271725e5d1b8477a44f102@linux-foundation.org>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello, Andrew.

> An earlier version of this patch was accused of crashing the kernel:
> 
> https://lists.01.org/pipermail/lkp/2019-April/010004.html
> 
> does the v4 series address this?
I tried before to narrow down that crash but i did not succeed, so
i have never seen that before on my test environment as well as
during running lkp-tests including trinity test case:

test-url: http://codemonkey.org.uk/projects/trinity/

But after analysis of the Call-trace and slob_alloc(): 

<snip>
[    0.395722] Call Trace:
[    0.395722]  slob_alloc+0x1c9/0x240
[    0.395722]  kmem_cache_alloc+0x70/0x80
[    0.395722]  acpi_ps_alloc_op+0xc0/0xca
[    0.395722]  acpi_ps_get_next_arg+0x3fa/0x6ed
<snip>

<snip>
    /* Attempt to alloc */
    prev = sp->lru.prev;
    b = slob_page_alloc(sp, size, align);
    if (!b)
        continue;

    /* Improve fragment distribution and reduce our average
     * search time by starting our next search here. (see
     * Knuth vol 1, sec 2.5, pg 449) */
    if (prev != slob_list->prev &&
            slob_list->next != prev->next)
        list_move_tail(slob_list, prev->next); <- Crash is here in __list_add_valid()
    break;
}
<snip>

i see that it tries to manipulate with "prev" node that may be removed
from the list by slob_page_alloc() earlier if whole page is used. I think
that crash has to be fixed by the below commit:

https://www.spinics.net/lists/mm-commits/msg137923.html

it was introduced into 5.1-rc3 kernel.

Why ("mm/vmalloc.c: keep track of free blocks for vmap allocation")
was accused is probably because it uses "kmem cache allocations with struct alignment"
instead of kmalloc()/kzalloc(). Maybe because of bigger size requests
it became easier to trigger the BUG. But that is theory.

--
Vlad Rezki

