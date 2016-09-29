Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 37BEB6B0038
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 16:08:28 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 2so110026996pfs.1
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 13:08:28 -0700 (PDT)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id x22si15788101pff.113.2016.09.29.13.08.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Sep 2016 13:08:27 -0700 (PDT)
Received: by mail-pa0-x22d.google.com with SMTP id qn7so30795049pac.3
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 13:08:27 -0700 (PDT)
Date: Thu, 29 Sep 2016 13:08:24 -0700
From: Raymond Jennings <shentino@gmail.com>
Subject: Re: More OOM problems (sorry fro the mail bomb)
Message-Id: <1475179704.7681.0@smtp.gmail.com>
In-Reply-To: <f35c1c03-c1ef-e4fb-44c8-187b75180130@suse.cz>
References: 
	<CA+55aFwu30Yz52yW+MRHt_JgpqZkq4DHdWR-pX4+gO_OK7agCQ@mail.gmail.com>
	<20160921000458.15fdd159@metalhead.dragonrealms>
	<20160928231229.55d767c1@metalhead.dragonrealms>
	<f35c1c03-c1ef-e4fb-44c8-187b75180130@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Markus Trippelsdorf <markus@trippelsdorf.de>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Jiri Slaby <jslaby@suse.com>, Olaf Hering <olaf@aepfle.de>, Joonsoo Kim <js1304@gmail.com>, linux-mm <linux-mm@kvack.org>

On Thu, Sep 29, 2016 at 12:03 AM, Vlastimil Babka <vbabka@suse.cz> 
wrote:
> On 09/29/2016 08:12 AM, Raymond Jennings wrote:
>> On Wed, 21 Sep 2016 00:04:58 -0700
>> Raymond Jennings <shentino@gmail.com> wrote:
>> 
>> I would like to apologize to everyone for the mailbombing.  Something
>> went screwy with my email client and I had to bitchslap my 
>> installation
>> when I saw my gmail box full of half-composed messages being sent 
>> out.
> 
> FWIW, I apparently didn't receive any.

Trying geary this time, keeping my fingers crossed

>> For the curious, by the by, how does kcompactd work?  Does it just 
>> get
>> run on request or is it a continuous background process akin to
>> khugepaged?  Is there a way to keep it running in the background
>> defragmenting on a continuous trickle basis?
> 
> Right now it gets run on request. Kswapd is woken up when watermarks 
> get between "min" and "low" and when it finishes reclaim and it was a 
> high-order request, it wakes up kcompactd, which compacts until page 
> of given order is available. That mimics how it was before when 
> kswapd did the compaction itself, but I know it's not ideal and plan 
> to make kcompactd more proactive.

Suggestion:

1.  Make it a background process "kcompactd"
2.  It is activated/woke up/semaphored awake any time a page is freed.
3.  Once it is activated, it enters a loop:
3.1.  Reset the semaphore.
3.2.  Once a cycle, it takes the highest movable page
3.3.  It then finds the lowest free page
3.4.  Then, it migrates the highest used page to the lowest free space
3.5.  maybe pace itself by sleeping for a teensy, then go back to step 
3.2
3.6.  Do one page at a time to keep it neatly interruptible and keep it 
from blocking other stuff.  Since compaction is a housekeeping task, it 
should probably be eager to yield to other things.
3.7.  Probably leave hugepages alone if detected since they are by 
definition fairly defragmented already.
4.  Once all gaps are backfilled, go back to sleep and park back at 
step 2 waiting for the next wakeup.

Would this be a good way to do it?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
