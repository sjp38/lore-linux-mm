Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0C9136B0025
	for <linux-mm@kvack.org>; Tue, 27 Mar 2018 14:44:23 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id b2-v6so15953643plz.17
        for <linux-mm@kvack.org>; Tue, 27 Mar 2018 11:44:23 -0700 (PDT)
Received: from out30-130.freemail.mail.aliyun.com (out30-130.freemail.mail.aliyun.com. [115.124.30.130])
        by mx.google.com with ESMTPS id q9-v6si1799735plr.21.2018.03.27.11.44.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Mar 2018 11:44:21 -0700 (PDT)
Subject: Re: [v2 PATCH] mm: introduce arg_lock to protect arg_start|end and
 env_start|end in mm_struct
References: <1522088439-105930-1-git-send-email-yang.shi@linux.alibaba.com>
 <20180326183725.GB27373@bombadil.infradead.org>
 <20180326192132.GE2236@uranus>
 <aef52c2a-4b75-f8a7-2083-f53f42bddab8@linux.alibaba.com>
 <20180327073212.GG2236@uranus>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <73559b36-b55b-429a-285f-c05b45129b51@linux.alibaba.com>
Date: Tue, 27 Mar 2018 14:44:09 -0400
MIME-Version: 1.0
In-Reply-To: <20180327073212.GG2236@uranus>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Matthew Wilcox <willy@infradead.org>, adobriyan@gmail.com, mhocko@kernel.org, mguzik@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 3/27/18 3:32 AM, Cyrill Gorcunov wrote:
> On Mon, Mar 26, 2018 at 05:59:49PM -0400, Yang Shi wrote:
>>> Say we've two syscalls running prctl_set_mm_map in parallel, and imagine
>>> one have @start_brk = 20 @brk = 10 and second caller has @start_brk = 30
>>> and @brk = 20. Since now the call is guarded by _read_ the both calls
>>> unlocked and due to OO engine it may happen then when both finish
>>> we have @start_brk = 30 and @brk = 10. In turn "write" semaphore
>>> has been take to have consistent data on exit, either you have [20;10]
>>> or [30;20] assigned not something mixed.
>>>
>>> That said I think using read-lock here would be a bug.
>> Yes it sounds so. However, it was down_read before
>> ddf1d398e517e660207e2c807f76a90df543a217 ("prctl: take mmap sem for writing
>> to protect against others"). And, that commit is for fixing the concurrent
>> writing to arg_* and env_*. I just checked that commit, but omitted the brk
>> part. The potential issue mentioned by you should exist before that commit,
>> but might be just not discovered or very rare to hit.
>>
>> I will change it back to down_write.
> down_read before was a bug ;) And it was not discovered earlier simply
> because not that many users of this interface exist, namely only criu
> as far as I know by now.

Thanks for confirming this. I assumed so :-)
