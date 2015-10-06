Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 040A56B0038
	for <linux-mm@kvack.org>; Tue,  6 Oct 2015 11:00:50 -0400 (EDT)
Received: by pablk4 with SMTP id lk4so211934274pab.3
        for <linux-mm@kvack.org>; Tue, 06 Oct 2015 08:00:49 -0700 (PDT)
Received: from out01.mta.xmission.com (out01.mta.xmission.com. [166.70.13.231])
        by mx.google.com with ESMTPS id ys5si49563031pbb.23.2015.10.06.08.00.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA256 bits=128/128);
        Tue, 06 Oct 2015 08:00:49 -0700 (PDT)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <20150922160608.GA2716@redhat.com>
	<20150923205923.GB19054@dhcp22.suse.cz>
	<alpine.DEB.2.10.1509241359100.32488@chino.kir.corp.google.com>
	<20150925093556.GF16497@dhcp22.suse.cz>
	<201509260114.ADI35946.OtHOVFOMJQFLFS@I-love.SAKURA.ne.jp>
	<201509290118.BCJ43256.tSFFFMOLHVOJOQ@I-love.SAKURA.ne.jp>
	<20151002123639.GA13914@dhcp22.suse.cz>
	<CA+55aFw=OLSdh-5Ut2vjy=4Yf1fTXqpzoDHdF7XnT5gDHs6sYA@mail.gmail.com>
	<87k2r0ph21.fsf@x220.int.ebiederm.org>
	<CA+55aFxxfbCuTjnK_TpxrTftQOXeTi4PBawbv27P_Xqz4Y5ibw@mail.gmail.com>
	<CA+55aFz1HFLVNeAaOWK=-Wyq8FF5bhWpWk8Dnwpa-8vD2k+b+A@mail.gmail.com>
Date: Tue, 06 Oct 2015 09:52:50 -0500
In-Reply-To: <CA+55aFz1HFLVNeAaOWK=-Wyq8FF5bhWpWk8Dnwpa-8vD2k+b+A@mail.gmail.com>
	(Linus Torvalds's message of "Tue, 6 Oct 2015 09:55:33 +0100")
Message-ID: <87lhbgf3r1.fsf@x220.int.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: can't oom-kill zap the victim's memory?
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Kyle Walker <kwalker@redhat.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Stanislav Kozina <skozina@redhat.com>

Linus Torvalds <torvalds@linux-foundation.org> writes:

> On Tue, Oct 6, 2015 at 9:49 AM, Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
>>
>> The basic fact remains: kernel allocations are so important that
>> rather than fail, you should kill user space. Only kernel allocations
>> that *explicitly* know that they have fallback code should fail, and
>> they should just do the __GFP_NORETRY.

If you have reached the point of killing userspace you might as well
panic the box.  Userspace will recover more cleanly and more quickly.
The oom-killer is like an oops.  Nice for debugging but not something
you want on a production workload.

> To be clear: "big" orders (I forget if the limit is at order-3 or
> order-4) do fail much more aggressively. But no, we do not limit retry
> to just order-0, because even small kmalloc sizes tend to often do
> order-1 or order-2 just because of memory packing issues (ie trying to
> pack into a single page wastes too much memory if the allocation sizes
> don't come out right).

I am not asking that we limit retry to just order-0 pages.  I am asking
that we limit the oom-killer on failure to just order-0 pages.

> So no, order-0 isn't special. 1/2 are rather important too.

That is a justification for retrying.  That is not a justification for
killing the box.

> [ Checking /proc/slabinfo: it looks like several slabs are order-3,
> for things like files_cache, signal_cache and sighand_cache for me at
> least. So I think it's up to order-3 that we basically need to
> consider "we'll need to shrink user space aggressively unless we have
> an explicit fallback for the allocation" ]

What I know is that order-3 is definitely too big.  I had 4G of RAM
free.  I needed 16K to exapand the fd table.  The box died.  That is
not good.

We have static checkers now, failure to check and handle errors tends to
be caught.

So yes for the rare case of order-[123] allocations failing we should
return the failure to the caller.  The kernel can handle it.  Userspace
can handle just about anything better than random processes dying.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
