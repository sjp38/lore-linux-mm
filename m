Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f171.google.com (mail-vc0-f171.google.com [209.85.220.171])
	by kanga.kvack.org (Postfix) with ESMTP id 008BC6B0035
	for <linux-mm@kvack.org>; Thu,  3 Jul 2014 14:22:45 -0400 (EDT)
Received: by mail-vc0-f171.google.com with SMTP id id10so616235vcb.2
        for <linux-mm@kvack.org>; Thu, 03 Jul 2014 11:22:45 -0700 (PDT)
Received: from mail-ve0-x22a.google.com (mail-ve0-x22a.google.com [2607:f8b0:400c:c01::22a])
        by mx.google.com with ESMTPS id ty10si14491932vdc.73.2014.07.03.11.22.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 03 Jul 2014 11:22:44 -0700 (PDT)
Received: by mail-ve0-f170.google.com with SMTP id i13so640402veh.15
        for <linux-mm@kvack.org>; Thu, 03 Jul 2014 11:22:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <53B59CB5.9060004@linux.vnet.ibm.com>
References: <1404392547-11648-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
	<CA+55aFxOTqUAqEF7+83s890Q18qCHSQqDOxWqWHNjG_25hVhXg@mail.gmail.com>
	<53B59CB5.9060004@linux.vnet.ibm.com>
Date: Thu, 3 Jul 2014 11:22:44 -0700
Message-ID: <CA+55aFyRgYW6Y8paYKGfqE205enhiPsZ1C8wrKpFavVXq7ZAtA@mail.gmail.com>
Subject: Re: [PATCH] mm readahead: Fix sys_readahead breakage by reverting 2MB
 limit (bug 79111)
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, Jan Kara <jack@suse.cz>, David Rientjes <rientjes@google.com>, Nishanth Aravamudan <nacc@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Jul 3, 2014 at 11:11 AM, Raghavendra K T
<raghavendra.kt@linux.vnet.ibm.com> wrote:
>>
>> What? Where did you find that insane sentence? And where did you find
>> an application that depends on that totally insane semantics that sure
>> as hell was never intentional.
>>
>> If this comes from some man-page,
>
> Yes it is.

Ok, googling actually finds a fairly recent patch to fix it

   http://www.spinics.net/lists/linux-mm/msg70517.html

and several much older "that's not true" comments.

I wonder how it ever happened, because it has never actually been true
that readahead() has been synchronous. It *has* been true that large
read-aheads have started so much IO that just the act of starting more
would wait for request allocations etc to free up, so it's not like it
has ever been entirely asynchonous either, but it definitely has
*never* been synchronous afaik.

The new behavior just means that you can't trigger the "request queues
are all so full that we end up blocking waiting for new request
allocations" quite as easily.

That said, the bugzilla entry you mentioned does mention "can't boot
3.14 now". I'm not sure what the meaning of that sentence is, though.
Does it mean "can't boot 3.14 to test it because the machine is busy",
or is it a typo and really meant 3.15, and that some bootup script
*depended* on readahead()? I don't know. It seems strange. It also
seems like it would be very hard to even show this semantically (aside
from timing, and looking at how much of the cache is used like the
test-program does).

So the bugzilla entry worries me a bit - we definitely do not want to
regress in case somebody really relied on timing - but without more
specific information I still think the real bug is just in the
man-page.

                Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
