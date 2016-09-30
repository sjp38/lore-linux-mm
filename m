Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id DEEE66B0069
	for <linux-mm@kvack.org>; Fri, 30 Sep 2016 15:48:57 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 7so93404927pfa.2
        for <linux-mm@kvack.org>; Fri, 30 Sep 2016 12:48:57 -0700 (PDT)
Received: from mail-pf0-x22e.google.com (mail-pf0-x22e.google.com. [2607:f8b0:400e:c00::22e])
        by mx.google.com with ESMTPS id e9si21422924pay.179.2016.09.30.12.48.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Sep 2016 12:48:57 -0700 (PDT)
Received: by mail-pf0-x22e.google.com with SMTP id u78so17894584pfa.1
        for <linux-mm@kvack.org>; Fri, 30 Sep 2016 12:48:56 -0700 (PDT)
Date: Fri, 30 Sep 2016 12:48:53 -0700
From: Raymond Jennings <shentino@gmail.com>
Subject: Re: More OOM problems (sorry fro the mail bomb)
Message-Id: <1475264933.8647.0@smtp.gmail.com>
In-Reply-To: <1ea311ce-f8cf-979c-b25c-e894cf089f23@suse.cz>
References: 
	<CA+55aFwu30Yz52yW+MRHt_JgpqZkq4DHdWR-pX4+gO_OK7agCQ@mail.gmail.com>
	<20160921000458.15fdd159@metalhead.dragonrealms>
	<20160928231229.55d767c1@metalhead.dragonrealms>
	<f35c1c03-c1ef-e4fb-44c8-187b75180130@suse.cz>
	<1475179704.7681.0@smtp.gmail.com>
	<1ea311ce-f8cf-979c-b25c-e894cf089f23@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Markus Trippelsdorf <markus@trippelsdorf.de>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Jiri Slaby <jslaby@suse.com>, Olaf Hering <olaf@aepfle.de>, Joonsoo Kim <js1304@gmail.com>, linux-mm <linux-mm@kvack.org>

On Thu, Sep 29, 2016 at 2:20 PM, Vlastimil Babka <vbabka@suse.cz> wrote:
> On 09/29/2016 10:08 PM, Raymond Jennings wrote:
>>  Suggestion:
>> 
>>  1.  Make it a background process "kcompactd"
>>  2.  It is activated/woke up/semaphored awake any time a page is 
>> freed.
>>  3.  Once it is activated, it enters a loop:
>>  3.1.  Reset the semaphore.
>>  3.2.  Once a cycle, it takes the highest movable page
>>  3.3.  It then finds the lowest free page
>>  3.4.  Then, it migrates the highest used page to the lowest free 
>> space
>>  3.5.  maybe pace itself by sleeping for a teensy, then go back to 
>> step
>>  3.2
>>  3.6.  Do one page at a time to keep it neatly interruptible and 
>> keep it
>>  from blocking other stuff.  Since compaction is a housekeeping 
>> task, it
>>  should probably be eager to yield to other things.
>>  3.7.  Probably leave hugepages alone if detected since they are by
>>  definition fairly defragmented already.
>>  4.  Once all gaps are backfilled, go back to sleep and park back at
>>  step 2 waiting for the next wakeup.
>> 
>>  Would this be a good way to do it?
> 
> Yes, that's pretty much how it already works, except movable pages are
> taken from low pfn and free pages from high. Then there's ton of 
> subtle
> issues to tackle, mostly the balance between overhead and benefit.

Besides the kswapd hook, what would nudge kcompactd to run?  If its not 
proactively nudged after a page is freed how will it know that there's 
fragmentation that could be taken care of in advance before being 
shoved by kswapd?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
