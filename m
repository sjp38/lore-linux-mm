Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5E9566B042A
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 10:09:58 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id l8so29724470iti.6
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 07:09:58 -0800 (PST)
Received: from mail-it0-x22b.google.com (mail-it0-x22b.google.com. [2607:f8b0:4001:c0b::22b])
        by mx.google.com with ESMTPS id p187si2322743itd.7.2016.11.18.07.09.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Nov 2016 07:09:57 -0800 (PST)
Received: by mail-it0-x22b.google.com with SMTP id y23so35914770itc.0
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 07:09:57 -0800 (PST)
Subject: Re: [PATCH v4] mm: don't cap request size based on read-ahead setting
References: <e4271a04-35cf-b082-34ea-92649f5111be@kernel.dk>
 <007401d24160$cc2442c0$646cc840$@alibaba-inc.com>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <6010891c-e4a2-e19b-9042-128670fd8fff@kernel.dk>
Date: Fri, 18 Nov 2016 08:09:55 -0700
MIME-Version: 1.0
In-Reply-To: <007401d24160$cc2442c0$646cc840$@alibaba-inc.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>, 'Andrew Morton' <akpm@linux-foundation.org>, 'Johannes Weiner' <hannes@cmpxchg.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, 'Linus Torvalds' <torvalds@linux-foundation.org>

On 11/17/2016 10:58 PM, Hillf Danton wrote:
> On Friday, November 18, 2016 5:23 AM Jens Axboe wrote:
>>
>> We ran into a funky issue, where someone doing 256K buffered reads saw
>> 128K requests at the device level. Turns out it is read-ahead capping
>> the request size, since we use 128K as the default setting. This doesn't
>> make a lot of sense - if someone is issuing 256K reads, they should see
>> 256K reads, regardless of the read-ahead setting, if the underlying
>> device can support a 256K read in a single command.
>>
>> To make matters more confusing, there's an odd interaction with the
>> fadvise hint setting. If we tell the kernel we're doing sequential IO on
>> this file descriptor, we can get twice the read-ahead size. But if we
>> tell the kernel that we are doing random IO, hence disabling read-ahead,
>> we do get nice 256K requests at the lower level. This is because
>> ondemand and forced read-ahead behave differently, with the latter doing
>> the right thing.
>
> As far as I read, forced RA is innocent but it is corrected below.
> And with RA disabled, we should drop care of ondemand.
>
> I'm scratching.

The changelog should have been updated. Forced read-ahead is also
affected, the patch is correct. We want to use the min of 'nr_to_read'
and the proper read-ahead request size, the latter being the max of
ra->ra_pages and bdi->io_pages.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
