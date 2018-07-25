Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 969766B0294
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 07:29:43 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id t23-v6so4855510ioa.9
        for <linux-mm@kvack.org>; Wed, 25 Jul 2018 04:29:43 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d3-v6sor1591970itj.7.2018.07.25.04.29.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 25 Jul 2018 04:29:42 -0700 (PDT)
MIME-Version: 1.0
References: <20180530103936.17812-1-liwang@redhat.com> <CALZtONBKSVfXe+RHOjgS=4VrDqFsxNRx3OuGctp0o1Hrtix3Ew@mail.gmail.com>
 <CAE1O6mir7Pco=QRBDFTFh7pkVQtXT=PtJ4R-o1RV9PPoY5-nLQ@mail.gmail.com>
In-Reply-To: <CAE1O6mir7Pco=QRBDFTFh7pkVQtXT=PtJ4R-o1RV9PPoY5-nLQ@mail.gmail.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Wed, 25 Jul 2018 07:29:05 -0400
Message-ID: <CALZtONArdk0UQv2UqamqT2OE-x1GVDruUs2UT=0iun0gsy+52g@mail.gmail.com>
Subject: Re: [PATCH v2] zswap: re-check zswap_is_full after do zswap_shrink
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: wangli.ahau@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: Li Wang <liwang@redhat.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Seth Jennings <sjenning@redhat.com>, huang ying <huang.ying.caritas@gmail.com>, Yu Zhao <yuzhao@google.com>

On Mon, Jun 25, 2018 at 4:08 AM Li Wang <wangli.ahau@gmail.com> wrote:
>
> On 30 May 2018 at 20:53, Dan Streetman <ddstreet@ieee.org> wrote:
> > On Wed, May 30, 2018 at 6:39 AM, Li Wang <liwang@redhat.com> wrote:
> >> The '/sys/../zswap/stored_pages:' keep raising in zswap test with
> >> "zswap.max_pool_percent=0" parameter. But theoretically, it should
> >> not compress or store pages any more since there is no space in
> >> compressed pool.
> >>
> >> Reproduce steps:
> >>   1. Boot kernel with "zswap.enabled=1"
> >>   2. Set the max_pool_percent to 0
> >>       # echo 0 > /sys/module/zswap/parameters/max_pool_percent
> >>   3. Do memory stress test to see if some pages have been compressed
> >>       # stress --vm 1 --vm-bytes $mem_available"M" --timeout 60s
> >>   4. Watching the 'stored_pages' number increasing or not
> >>
> >> The root cause is:
> >>   When zswap_max_pool_percent is setting to 0 via kernel parameter, the
> >>   zswap_is_full() will always return true to do zswap_shrink(). But if
> >>   the shinking is able to reclain a page successful, then proceeds to
> >>   compress/store another page, so the value of stored_pages will keep
> >>   changing.
> >>
> >> To solve the issue, this patch adds zswap_is_full() check again after
> >> zswap_shrink() to make sure it's now under the max_pool_percent, and
> >> not to compress/store if reach its limitaion.
> >>
> >> Signed-off-by: Li Wang <liwang@redhat.com>
> >
> > Acked-by: Dan Streetman <ddstreet@ieee.org>
>
> ping~
>
> Any possible to merge this in kernel-4.18-rcX? My zswap test always
> fails on the upstream kernel.

cc'ing Andrew as he may have missed this.

>
>
> --
> Regards,
> Li Wang
> Email: wangli.ahau@gmail.com
