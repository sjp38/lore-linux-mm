Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua1-f69.google.com (mail-ua1-f69.google.com [209.85.222.69])
	by kanga.kvack.org (Postfix) with ESMTP id EFB0F6B21FE
	for <linux-mm@kvack.org>; Tue, 21 Aug 2018 22:25:25 -0400 (EDT)
Received: by mail-ua1-f69.google.com with SMTP id d22-v6so184584uaq.11
        for <linux-mm@kvack.org>; Tue, 21 Aug 2018 19:25:25 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id w12-v6si169020uad.339.2018.08.21.19.25.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Aug 2018 19:25:24 -0700 (PDT)
Subject: Re: [PATCH v2 0/2] mm: soft-offline: fix race against page allocation
References: <1531805552-19547-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20180815154334.f3eecd1029a153421631413a@linux-foundation.org>
 <20180822013748.GA10343@hori1.linux.bs1.fc.nec.co.jp>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <c692fd0b-d282-f2e7-b42f-b3204ad35938@oracle.com>
Date: Tue, 21 Aug 2018 19:25:12 -0700
MIME-Version: 1.0
In-Reply-To: <20180822013748.GA10343@hori1.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset=iso-2022-jp
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>, "xishi.qiuxishi@alibaba-inc.com" <xishi.qiuxishi@alibaba-inc.com>, "zy.zhengyi@alibaba-inc.com" <zy.zhengyi@alibaba-inc.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 08/21/2018 06:37 PM, Naoya Horiguchi wrote:
> On Wed, Aug 15, 2018 at 03:43:34PM -0700, Andrew Morton wrote:
>> On Tue, 17 Jul 2018 14:32:30 +0900 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:
>>
>>> I've updated the patchset based on feedbacks:
>>>
>>> - updated comments (from Andrew),
>>> - moved calling set_hwpoison_free_buddy_page() from mm/migrate.c to mm/memory-failure.c,
>>>   which is necessary to check the return code of set_hwpoison_free_buddy_page(),
>>> - lkp bot reported a build error when only 1/2 is applied.
>>>
>>>   >    mm/memory-failure.c: In function 'soft_offline_huge_page':
>>>   > >> mm/memory-failure.c:1610:8: error: implicit declaration of function
>>>   > 'set_hwpoison_free_buddy_page'; did you mean 'is_free_buddy_page'?
>>>   > [-Werror=implicit-function-declaration]
>>>   >        if (set_hwpoison_free_buddy_page(page))
>>>   >            ^~~~~~~~~~~~~~~~~~~~~~~~~~~~
>>>   >            is_free_buddy_page
>>>   >    cc1: some warnings being treated as errors
>>>
>>>   set_hwpoison_free_buddy_page() is defined in 2/2, so we can't use it
>>>   in 1/2. Simply doing s/set_hwpoison_free_buddy_page/!TestSetPageHWPoison/
>>>   will fix this.
>>>
>>> v1: https://lkml.org/lkml/2018/7/12/968
>>>
>>
>> Quite a bit of discussion on these two, but no actual acks or
>> review-by's?
> 
> Really sorry for late response.
> Xishi provided feedback on previous version, but no final ack/reviewed-by.
> This fix should work on the reported issue, but rewriting soft-offlining
> without PageHWPoison flag would be the better fix (no actual patch yet.)
> I'm not sure this patch should go to mainline immediately.

FWIW - The 'migration of huge PMD shared pages' issue I am working was
originally triggered via soft-offline.  While working the issue, I tried
to exercise huge page soft-offline really hard to recreate the issue and
validate a fix.  However, I was more likely to hit the soft-offline race(s)
your patches address.  Therefore, I applied your patches to focus my testing
and validation on the migration of huge PMD shared pages issue.  That is sort
of a Tested-by :).

Just wanted to point out that it was pretty easy to hit this issue.  It
was easier than the issue I am working.  And, the issue I am trying to
address was seen in a real customer environment.  So, I would not be
surprised to see this issue in real customer environments as well.

If you (or others) think we should go forward with these patches, I can
spend some time doing a review.  Already did a 'quick look' some time back.
-- 
Mike Kravetz
