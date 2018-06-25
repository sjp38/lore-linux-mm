Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id B0B866B000A
	for <linux-mm@kvack.org>; Mon, 25 Jun 2018 04:08:32 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id 189-v6so6589728ita.1
        for <linux-mm@kvack.org>; Mon, 25 Jun 2018 01:08:32 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u189-v6sor2701861itd.29.2018.06.25.01.08.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Jun 2018 01:08:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALZtONBKSVfXe+RHOjgS=4VrDqFsxNRx3OuGctp0o1Hrtix3Ew@mail.gmail.com>
References: <20180530103936.17812-1-liwang@redhat.com> <CALZtONBKSVfXe+RHOjgS=4VrDqFsxNRx3OuGctp0o1Hrtix3Ew@mail.gmail.com>
From: Li Wang <wangli.ahau@gmail.com>
Date: Mon, 25 Jun 2018 16:08:30 +0800
Message-ID: <CAE1O6mir7Pco=QRBDFTFh7pkVQtXT=PtJ4R-o1RV9PPoY5-nLQ@mail.gmail.com>
Subject: Re: [PATCH v2] zswap: re-check zswap_is_full after do zswap_shrink
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Li Wang <liwang@redhat.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Seth Jennings <sjenning@redhat.com>, Huang Ying <huang.ying.caritas@gmail.com>, Yu Zhao <yuzhao@google.com>

On 30 May 2018 at 20:53, Dan Streetman <ddstreet@ieee.org> wrote:
> On Wed, May 30, 2018 at 6:39 AM, Li Wang <liwang@redhat.com> wrote:
>> The '/sys/../zswap/stored_pages:' keep raising in zswap test with
>> "zswap.max_pool_percent=0" parameter. But theoretically, it should
>> not compress or store pages any more since there is no space in
>> compressed pool.
>>
>> Reproduce steps:
>>   1. Boot kernel with "zswap.enabled=1"
>>   2. Set the max_pool_percent to 0
>>       # echo 0 > /sys/module/zswap/parameters/max_pool_percent
>>   3. Do memory stress test to see if some pages have been compressed
>>       # stress --vm 1 --vm-bytes $mem_available"M" --timeout 60s
>>   4. Watching the 'stored_pages' number increasing or not
>>
>> The root cause is:
>>   When zswap_max_pool_percent is setting to 0 via kernel parameter, the
>>   zswap_is_full() will always return true to do zswap_shrink(). But if
>>   the shinking is able to reclain a page successful, then proceeds to
>>   compress/store another page, so the value of stored_pages will keep
>>   changing.
>>
>> To solve the issue, this patch adds zswap_is_full() check again after
>> zswap_shrink() to make sure it's now under the max_pool_percent, and
>> not to compress/store if reach its limitaion.
>>
>> Signed-off-by: Li Wang <liwang@redhat.com>
>
> Acked-by: Dan Streetman <ddstreet@ieee.org>

ping~

Any possible to merge this in kernel-4.18-rcX? My zswap test always
fails on the upstream kernel.


-- 
Regards,
Li Wang
Email: wangli.ahau@gmail.com
