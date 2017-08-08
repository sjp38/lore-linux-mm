Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3ADED6B0292
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 09:15:54 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id 6so15306470qts.7
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 06:15:54 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o129si1039605qkd.433.2017.08.08.06.15.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 06:15:53 -0700 (PDT)
Message-ID: <1502198148.6577.18.camel@redhat.com>
Subject: Re: [PATCH v2 0/2] mm,fork,security: introduce MADV_WIPEONFORK
From: Rik van Riel <riel@redhat.com>
Date: Tue, 08 Aug 2017 09:15:48 -0400
In-Reply-To: <bfdab709-e5b2-0d26-1c0f-31535eda1678@redhat.com>
References: <20170806140425.20937-1-riel@redhat.com>
	 <a0d79f77-f916-d3d6-1d61-a052581dbd4a@oracle.com>
	 <bfdab709-e5b2-0d26-1c0f-31535eda1678@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, colm@allcosts.net, akpm@linux-foundation.org, keescook@chromium.org, luto@amacapital.net, wad@chromium.org, mingo@kernel.org, kirill@shutemov.name, dave.hansen@intel.com

On Tue, 2017-08-08 at 11:58 +0200, Florian Weimer wrote:
> On 08/07/2017 08:23 PM, Mike Kravetz wrote:
> > If my thoughts above are correct, what about returning EINVAL if
> > one
> > attempts to set MADV_DONTFORK on mappings set up for sharing?
> 
> That's my preference as well.A A If there is a use case for shared or
> non-anonymous mappings, then we can implement MADV_DONTFORK with the
> semantics for this use case.A A If we pick some arbitrary semantics
> now,
> without any use case, we might end up with something that's not
> actually
> useful.

MADV_DONTFORK is existing semantics, and it is enforced
on shared, non-anonymous mappings. It is frequently used
for things like device mappings, which should not be
inherited by a child process, because the device can only
be used by one process at a time.

When someone requests MADV_DONTFORK on a shared VMA, they
will get it. The later madvise request overrides the mmap
flags that were used earlier.

The question is, should MADV_WIPEONFORK (introduced by
this series) have not just different semantics, but also
totally different behavior from MADV_DONTFORK?

Does the principle of least surprise dictate that the
last request determines the policy on an area, or should
later requests not be able to override policy that was
set at mmap time?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
