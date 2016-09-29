Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 74E8A6B0038
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 17:20:46 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id b4so4582520wmb.0
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 14:20:46 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d90si751704wma.120.2016.09.29.14.20.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 29 Sep 2016 14:20:45 -0700 (PDT)
Subject: Re: More OOM problems (sorry fro the mail bomb)
References: <CA+55aFwu30Yz52yW+MRHt_JgpqZkq4DHdWR-pX4+gO_OK7agCQ@mail.gmail.com>
 <20160921000458.15fdd159@metalhead.dragonrealms>
 <20160928231229.55d767c1@metalhead.dragonrealms>
 <f35c1c03-c1ef-e4fb-44c8-187b75180130@suse.cz>
 <1475179704.7681.0@smtp.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <1ea311ce-f8cf-979c-b25c-e894cf089f23@suse.cz>
Date: Thu, 29 Sep 2016 23:20:10 +0200
MIME-Version: 1.0
In-Reply-To: <1475179704.7681.0@smtp.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Raymond Jennings <shentino@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Markus Trippelsdorf <markus@trippelsdorf.de>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Jiri Slaby <jslaby@suse.com>, Olaf Hering <olaf@aepfle.de>, Joonsoo Kim <js1304@gmail.com>, linux-mm <linux-mm@kvack.org>

On 09/29/2016 10:08 PM, Raymond Jennings wrote:
> Suggestion:
> 
> 1.  Make it a background process "kcompactd"
> 2.  It is activated/woke up/semaphored awake any time a page is freed.
> 3.  Once it is activated, it enters a loop:
> 3.1.  Reset the semaphore.
> 3.2.  Once a cycle, it takes the highest movable page
> 3.3.  It then finds the lowest free page
> 3.4.  Then, it migrates the highest used page to the lowest free space
> 3.5.  maybe pace itself by sleeping for a teensy, then go back to step 
> 3.2
> 3.6.  Do one page at a time to keep it neatly interruptible and keep it 
> from blocking other stuff.  Since compaction is a housekeeping task, it 
> should probably be eager to yield to other things.
> 3.7.  Probably leave hugepages alone if detected since they are by 
> definition fairly defragmented already.
> 4.  Once all gaps are backfilled, go back to sleep and park back at 
> step 2 waiting for the next wakeup.
> 
> Would this be a good way to do it?

Yes, that's pretty much how it already works, except movable pages are
taken from low pfn and free pages from high. Then there's ton of subtle
issues to tackle, mostly the balance between overhead and benefit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
