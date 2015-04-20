Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id D5C146B0032
	for <linux-mm@kvack.org>; Mon, 20 Apr 2015 17:30:16 -0400 (EDT)
Received: by pabsx10 with SMTP id sx10so218903425pab.3
        for <linux-mm@kvack.org>; Mon, 20 Apr 2015 14:30:16 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ew2si20687905pbb.152.2015.04.20.14.30.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Apr 2015 14:30:16 -0700 (PDT)
Date: Mon, 20 Apr 2015 14:30:14 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/memory-failure: call shake_page() when error hits
 thp tail page
Message-Id: <20150420143014.bd6c683d159758db1815799f@linux-foundation.org>
In-Reply-To: <1429082714-26115-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1429082714-26115-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Dean Nelson <dnelson@redhat.com>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, Jin Dongming <jin.dongming@np.css.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, 15 Apr 2015 07:25:46 +0000 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> Currently memory_failure() calls shake_page() to sweep pages out from pcplists
> only when the victim page is 4kB LRU page or thp head page. But we should do
> this for a thp tail page too.
> Consider that a memory error hits a thp tail page whose head page is on a
> pcplist when memory_failure() runs. Then, the current kernel skips shake_pages()
> part, so hwpoison_user_mappings() returns without calling split_huge_page() nor
> try_to_unmap() because PageLRU of the thp head is still cleared due to the skip
> of shake_page().
> As a result, me_huge_page() runs for the thp, which is a broken behavior.
> 
> This patch fixes this problem by calling shake_page() for thp tail case.
> 
> Fixes: 385de35722c9 ("thp: allow a hwpoisoned head page to be put back to LRU")
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: stable@vger.kernel.org  # v3.4+

What are the userspace-visible effects of the bug?  This info is needed
for backporting into -stable and other kernels, please.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
