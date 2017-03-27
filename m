Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id D3B106B0333
	for <linux-mm@kvack.org>; Mon, 27 Mar 2017 08:08:41 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id k6so6689504wre.3
        for <linux-mm@kvack.org>; Mon, 27 Mar 2017 05:08:41 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v21si510952wra.330.2017.03.27.05.08.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 27 Mar 2017 05:08:40 -0700 (PDT)
Date: Mon, 27 Mar 2017 14:08:37 +0200
From: Richard Palethorpe <rpalethorpe@suse.com>
Subject: Re: [LTP] Is MADV_HWPOISON supposed to work only on faulted-in
 pages?
Message-ID: <20170327140837.502b1296@linux-v3j5>
In-Reply-To: <20170227063308.GA14387@hori1.linux.bs1.fc.nec.co.jp>
References: <6a445beb-119c-9a9a-0277-07866afe4924@redhat.com>
	<20170220050016.GA15533@hori1.linux.bs1.fc.nec.co.jp>
	<20170223032342.GA18740@hori1.linux.bs1.fc.nec.co.jp>
	<1ba376aa-5e7c-915f-35d1-2d4eef0cad88@huawei.com>
	<20170227012029.GA28934@hori1.linux.bs1.fc.nec.co.jp>
	<22763879-C335-41E6-8102-2022EED75DAE@cs.rutgers.edu>
	<20170227063308.GA14387@hori1.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Zi Yan <zi.yan@cs.rutgers.edu>, Yisheng Xie <xieyisheng1@huawei.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "ltp@lists.linux.it" <ltp@lists.linux.it>

Hi Naoya,

On Mon, 27 Feb 2017 06:33:09 +0000
"Naoya Horiguchi" <n-horiguchi@ah.jp.nec.com> wrote:

> 
> > I expected either madvise should fail because HWPOISON does not work on
> > non-existing physical pages or madvise_hwpoison() should populate
> > some physical pages for that virtual address range and poison them.  
> 
> The latter is the current behavior. It just comes from get_user_pages_fast()
> which not only finds the page and takes refcount, but also touch the page.

To clarify, the current behaviour seems to be the following:

1st madvise_hwpoison() -> EBUSY,
2nd madvise_hwpoison() -> SUCCESS, but no SIGBUS when the memory is accessed.

So it touches the zero page and madvise succeeds on the second attempt because
it is now mapped, but still the memory is not poisoned.

This means that when I modify the LTP test to accept EBUSY, it still fails if
a user runs it twice. This is OK, but I will need to document it in the test.

Thank you,
Richard.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
