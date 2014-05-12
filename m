Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f169.google.com (mail-we0-f169.google.com [74.125.82.169])
	by kanga.kvack.org (Postfix) with ESMTP id D38336B0037
	for <linux-mm@kvack.org>; Mon, 12 May 2014 10:46:28 -0400 (EDT)
Received: by mail-we0-f169.google.com with SMTP id u56so7083246wes.0
        for <linux-mm@kvack.org>; Mon, 12 May 2014 07:46:28 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id dq1si2661579wid.113.2014.05.12.07.46.26
        for <linux-mm@kvack.org>;
        Mon, 12 May 2014 07:46:27 -0700 (PDT)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [PATCH] Avoid always dirtying mapping->flags on O_DIRECT
References: <20140509213907.GA20698@kernel.dk>
Date: Mon, 12 May 2014 10:46:19 -0400
In-Reply-To: <20140509213907.GA20698@kernel.dk> (Jens Axboe's message of "Fri,
	9 May 2014 15:39:07 -0600")
Message-ID: <x49r43z837o.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org

Jens Axboe <axboe@fb.com> writes:

> Hi,
>
> In some testing I ran today, we end up spending 40% of the time in
> filemap_check_errors(). That smells fishy. Looking further, this is
> basically what happens:
>
> blkdev_aio_read()
>     generic_file_aio_read()
>         filemap_write_and_wait_range()
>             if (!mapping->nr_pages)
>                 filemap_check_errors()
>
> and filemap_check_errors() always attempts two test_and_clear_bit() on
> the mapping flags, thus dirtying it for every single invocation. The
> patch below tests each of these bits before clearing them, avoiding this
> issue. In my test case (4-socket box), performance went from 1.7M IOPS
> to 4.0M IOPS.

It might help to use the word cacheline somewhere in here.  ;-) Out of
curiosity, what workload were you running?

Acked-by: Jeff Moyer <jmoyer@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
