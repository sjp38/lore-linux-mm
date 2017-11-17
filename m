Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 736576B0275
	for <linux-mm@kvack.org>; Fri, 17 Nov 2017 17:33:16 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id s11so3827362pgc.13
        for <linux-mm@kvack.org>; Fri, 17 Nov 2017 14:33:16 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id e23si1105521pli.201.2017.11.17.14.33.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Nov 2017 14:33:15 -0800 (PST)
Subject: Re: [PATCH 0/5] mm/kasan: advanced check
References: <20171117223043.7277-1-wen.gang.wang@oracle.com>
From: Wengang Wang <wen.gang.wang@oracle.com>
Message-ID: <e3edbe62-253a-7bfb-807d-f43c9a64e55e@oracle.com>
Date: Fri, 17 Nov 2017 14:32:29 -0800
MIME-Version: 1.0
In-Reply-To: <20171117223043.7277-1-wen.gang.wang@oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, aryabinin@virtuozzo.com
Cc: glider@google.com, dvyukov@google.com

This patch seems only work for OUTLINE compile type. Anyway to make it 
work for INLINE type?

thanks,
Wengang


On 2017/11/17 14:30, Wengang Wang wrote:
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
>
> Signed-off-by: Wengang Wang <wen.gang.wang@oracle.com>
>
> 0001-mm-kasan-make-space-in-shadow-bytes-for-advanced-che.patch
> 0002-mm-kasan-pass-access-mode-to-poison-check-functions.patch
> 0003-mm-kasan-do-advanced-check.patch
> 0004-mm-kasan-register-check-and-bind-it-to-memory.patch
> 0005-mm-kasan-add-advanced-check-test-case.patch
>
>   include/linux/kasan.h |   16 ++
>   lib/test_kasan.c      |   73 ++++++++++++
>   mm/kasan/kasan.c      |  292 +++++++++++++++++++++++++++++++++++++++++++-------
>   mm/kasan/kasan.h      |   42 +++++++
>   mm/kasan/report.c     |   44 ++++++-
>   5 files changed, 424 insertions(+), 43 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
