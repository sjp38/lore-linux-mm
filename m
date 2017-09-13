Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 85C546B0033
	for <linux-mm@kvack.org>; Wed, 13 Sep 2017 09:46:37 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id g128so301013qke.5
        for <linux-mm@kvack.org>; Wed, 13 Sep 2017 06:46:37 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q2si3157483qkb.240.2017.09.13.06.46.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Sep 2017 06:46:35 -0700 (PDT)
Date: Wed, 13 Sep 2017 15:46:32 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] ksm: Fix unlocked iteration over vmas in
 cmp_and_merge_page()
Message-ID: <20170913134632.GB12833@redhat.com>
References: <150512788393.10691.8868381099691121308.stgit@localhost.localdomain>
 <20170913112509.mus2fuccajoe2l25@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170913112509.mus2fuccajoe2l25@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>, akpm@linux-foundation.org, minchan@kernel.org, zhongjiang@huawei.com, mingo@kernel.org, imbrenda@linux.vnet.ibm.com, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, sioh Lee <solee@os.korea.ac.kr>

On Wed, Sep 13, 2017 at 01:25:09PM +0200, Michal Hocko wrote:
> [CC Claudio and Hugh]

Cc'ed Sioh as well.

> 
> On Mon 11-09-17 14:05:05, Kirill Tkhai wrote:
> > In this place mm is unlocked, so vmas or list may change.
> > Down read mmap_sem to protect them from modifications.
> > 
> > Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
> > (and compile-tested-by)
> 
> Fixes: e86c59b1b12d ("mm/ksm: improve deduplication of zero pages with colouring")
> AFAICS. Maybe even CC: stable as unstable vma can cause large variety of
> issues including memory corruption.
> 
> The fix lookds good to me
> Acked-by: Michal Hocko <mhocko@suse.com>

Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>

ksm_use_zero_pages is off by default, this is probably why it went
unnoticed.

Wondering if we should consider enabling ksm_use_zero_pages by default
on those arches that have few physical cache colors.

If we change the jhash2 to crc32c-intel like Sioh suggested (to
speedup the background scan), the chance of false positive and waste
of try_to_merge_one_page here will increase to one every 100k or so if
comparing random data against the zeropage (instead of the current
insignificant amount of false positives provided by jhash2 great
random uniformity).

So the ksm_use_zero_pages branch is currently missing a memcmp against
the ZERO_PAGE zeroes before calling write_protect_page. It's not a
functional bug because there's one last memcmp mandatory to run after
write protection, so this isn't destabilizing anything, but especially
if using crc32c (I suppose crc32cbe-vx is going to be much faster for
the background scan on s390 too) it would be a potential inefficiency
that wrprotects non zero pages by mistake once every 100k or more.

We never care about the cksum actual value, we only care if it changed
since the last pass, this is why ultimately I believe crc32c would
suffice for this purpose, it's extremely unlikely it won't change over
a data change. But it's definitely not suitable to find equality
across million of pages on large systems because it has a not suitable
random uniformity.

In short the "zero_checksum" variable should be dropped and the memcmp
will then materialize naturally after removing it.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
