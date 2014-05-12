Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f170.google.com (mail-vc0-f170.google.com [209.85.220.170])
	by kanga.kvack.org (Postfix) with ESMTP id 8A3F86B0035
	for <linux-mm@kvack.org>; Mon, 12 May 2014 11:08:16 -0400 (EDT)
Received: by mail-vc0-f170.google.com with SMTP id lf12so8929960vcb.15
        for <linux-mm@kvack.org>; Mon, 12 May 2014 08:08:16 -0700 (PDT)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTP id sq9si2109248vdc.179.2014.05.12.08.08.15
        for <linux-mm@kvack.org>;
        Mon, 12 May 2014 08:08:15 -0700 (PDT)
Message-ID: <5370E3E0.4050109@fb.com>
Date: Mon, 12 May 2014 09:08:16 -0600
From: Jens Axboe <axboe@fb.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Avoid always dirtying mapping->flags on O_DIRECT
References: <20140509213907.GA20698@kernel.dk> <x49r43z837o.fsf@segfault.boston.devel.redhat.com>
In-Reply-To: <x49r43z837o.fsf@segfault.boston.devel.redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org

On 05/12/2014 08:46 AM, Jeff Moyer wrote:
> Jens Axboe <axboe@fb.com> writes:
> 
>> Hi,
>>
>> In some testing I ran today, we end up spending 40% of the time in
>> filemap_check_errors(). That smells fishy. Looking further, this is
>> basically what happens:
>>
>> blkdev_aio_read()
>>     generic_file_aio_read()
>>         filemap_write_and_wait_range()
>>             if (!mapping->nr_pages)
>>                 filemap_check_errors()
>>
>> and filemap_check_errors() always attempts two test_and_clear_bit() on
>> the mapping flags, thus dirtying it for every single invocation. The
>> patch below tests each of these bits before clearing them, avoiding this
>> issue. In my test case (4-socket box), performance went from 1.7M IOPS
>> to 4.0M IOPS.
> 
> It might help to use the word cacheline somewhere in here.  ;-) Out of

I thought that was self-evident, but yes, I could add that :-)

> curiosity, what workload were you running?

Nothing fancy, just some fio jobs that spread over two nodes.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
