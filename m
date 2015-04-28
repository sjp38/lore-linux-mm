Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 275F96B0038
	for <linux-mm@kvack.org>; Mon, 27 Apr 2015 23:04:25 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so149102028pdb.1
        for <linux-mm@kvack.org>; Mon, 27 Apr 2015 20:04:24 -0700 (PDT)
Received: from us-alimail-mta1.hst.scl.en.alidc.net (mail113-248.mail.alibaba.com. [205.204.113.248])
        by mx.google.com with ESMTP id ci6si32564312pad.52.2015.04.27.20.04.22
        for <linux-mm@kvack.org>;
        Mon, 27 Apr 2015 20:04:24 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <001901d0815e$f438b390$dcaa1ab0$@alibaba-inc.com>
In-Reply-To: <001901d0815e$f438b390$dcaa1ab0$@alibaba-inc.com>
Subject: Re: [PATCHv5 04/28] mm, thp: adjust conditions when we can reuse the page on WP fault
Date: Tue, 28 Apr 2015 11:02:46 +0800
Message-ID: <002001d0815f$ce928750$6bb795f0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

> 
> With new refcounting we will be able map the same compound page with
> PTEs and PMDs. It requires adjustment to conditions when we can reuse
> the page on write-protection fault.
> 
> For PTE fault we can't reuse the page if it's part of huge page.
> 
> For PMD we can only reuse the page if nobody else maps the huge page or
> it's part. We can do it by checking page_mapcount() on each sub-page,
> but it's expensive.
> 
> The cheaper way is to check page_count() to be equal 1: every mapcount
> takes page reference, so this way we can guarantee, that the PMD is the
> only mapping.
> 
> This approach can give false negative if somebody pinned the page, but
> that doesn't affect correctness.
>
Then we have to try more to allocate THP if pinned?
Are we adding new cost?

Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
