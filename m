Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id DD6D46B025F
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 07:01:04 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id 79so21967347ioi.10
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 04:01:04 -0800 (PST)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50109.outbound.protection.outlook.com. [40.107.5.109])
        by mx.google.com with ESMTPS id 62si12522243ioi.283.2017.11.22.04.01.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 22 Nov 2017 04:01:03 -0800 (PST)
Subject: Re: [PATCH 0/5] mm/kasan: advanced check
References: <20171117223043.7277-1-wen.gang.wang@oracle.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <08db0958-220a-f31e-0ddb-273d7126150e@virtuozzo.com>
Date: Wed, 22 Nov 2017 15:04:26 +0300
MIME-Version: 1.0
In-Reply-To: <20171117223043.7277-1-wen.gang.wang@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wengang Wang <wen.gang.wang@oracle.com>, linux-mm@kvack.org
Cc: glider@google.com, dvyukov@google.com

On 11/18/2017 01:30 AM, Wengang Wang wrote:
> Kasan advanced check, I'm going to add this feature.
> Currently Kasan provide the detection of use-after-free and out-of-bounds
> problems. It is not able to find the overwrite-on-allocated-memory issue.
> We sometimes hit this kind of issue: We have a messed up structure
> (usually dynamially allocated), some of the fields in the structure were
> overwritten with unreasaonable values. And kernel may panic due to those
> overeritten values. We know those fields were overwritten somehow, but we
> have no easy way to find out which path did the overwritten. The advanced
> check wants to help in this scenario.
> 
> The idea is to define the memory owner. When write accesses come from
> non-owner, error should be reported. Normally the write accesses on a given
> structure happen in only several or a dozen of functions if the structure
> is not that complicated. We call those functions "allowed functions".
> The work of defining the owner and binding memory to owner is expected to
> be done by the memory consumer. In the above case, memory consume register
> the owner as the functions which have write accesses to the structure then
> bind all the structures to the owner. Then kasan will do the "owner check"
> after the basic checks.
> 
> As implementation, kasan provides a API to it's user to register their
> allowed functions. The API returns a token to users.  At run time, users
> bind the memory ranges they are interested in to the check they registered.
> Kasan then checks the bound memory ranges with the allowed functions.
> 

NAK. We don't add APIs with no users in the kernel.
If nothing in the kernel uses this API than there is no way to tell if this works or not.

Besides, I'm bit skeptical about usefulness of this feature. Those kinds of issues that
advanced check is supposed to catch, is almost always is just some sort of longstanding
use after free, which eventually should be caught by kasan.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
