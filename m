Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1A77D6B0006
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 22:58:41 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id x20so3952431wmc.0
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 19:58:41 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id l10sor1786209edn.47.2018.04.03.19.58.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 03 Apr 2018 19:58:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180403135607.GC5501@dhcp22.suse.cz>
References: <1522320104-6573-1-git-send-email-zhaoyang.huang@spreadtrum.com>
 <20180330102038.2378925b@gandalf.local.home> <20180403110612.GM5501@dhcp22.suse.cz>
 <20180403075158.0c0a2795@gandalf.local.home> <20180403121614.GV5501@dhcp22.suse.cz>
 <20180403082348.28cd3c1c@gandalf.local.home> <20180403123514.GX5501@dhcp22.suse.cz>
 <20180403093245.43e7e77c@gandalf.local.home> <20180403135607.GC5501@dhcp22.suse.cz>
From: Zhaoyang Huang <huangzhaoyang@gmail.com>
Date: Wed, 4 Apr 2018 10:58:39 +0800
Message-ID: <CAGWkznH-yfAu=fMo1YWU9zo-DomHY8YP=rw447rUTgzvVH4RpQ@mail.gmail.com>
Subject: Re: [PATCH v1] kernel/trace:check the val against the available mem
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@kernel.org>, linux-kernel@vger.kernel.org, kernel-patch-test@lists.linaro.org, Andrew Morton <akpm@linux-foundation.org>, Joel Fernandes <joelaf@google.com>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>

On Tue, Apr 3, 2018 at 9:56 PM, Michal Hocko <mhocko@kernel.org> wrote:
> On Tue 03-04-18 09:32:45, Steven Rostedt wrote:
>> On Tue, 3 Apr 2018 14:35:14 +0200
>> Michal Hocko <mhocko@kernel.org> wrote:
> [...]
>> > Being clever is OK if it doesn't add a tricky code. And relying on
>> > si_mem_available is definitely tricky and obscure.
>>
>> Can we get the mm subsystem to provide a better method to know if an
>> allocation will possibly succeed or not before trying it? It doesn't
>> have to be free of races. Just "if I allocate this many pages right
>> now, will it work?" If that changes from the time it asks to the time
>> it allocates, that's fine. I'm not trying to prevent OOM to never
>> trigger. I just don't want to to trigger consistently.
>
> How do you do that without an actuall allocation request? And more
> fundamentally, what if your _particular_ request is just fine but it
> will get us so close to the OOM edge that the next legit allocation
> request simply goes OOM? There is simply no sane interface I can think
> of that would satisfy a safe/sensible "will it cause OOM" semantic.
>
The point is the app which try to allocate the size over the line will escape
the OOM and let other innocent to be sacrificed. However, the one which you
mentioned above will be possibly selected by OOM that triggered by consequnce
failed allocation.

>> > > Perhaps I should try to allocate a large group of pages with
>> > > RETRY_MAYFAIL, and if that fails go back to NORETRY, with the thinking
>> > > that the large allocation may reclaim some memory that would allow the
>> > > NORETRY to succeed with smaller allocations (one page at a time)?
>> >
>> > That again relies on a subtle dependencies of the current
>> > implementation. So I would rather ask whether this is something that
>> > really deserves special treatment. If admin asks for a buffer of a
>> > certain size then try to do so. If we get OOM then bad luck you cannot
>> > get large memory buffers for free...
>>
>> That is not acceptable to me nor to the people asking for this.
>>
>> The problem is known. The ring buffer allocates memory page by page,
>> and this can allow it to easily take all memory in the system before it
>> fails to allocate and free everything it had done.
>
> Then do not allow buffers that are too large. How often do you need
> buffers that are larger than few megs or small % of the available
> memory? Consuming excessive amount of memory just to trace workload
> which will need some memory on its own sounds just dubious to me.
>
>> If you don't like the use of si_mem_available() I'll do the larger
>> pages method. Yes it depends on the current implementation of memory
>> allocation. It will depend on RETRY_MAYFAIL trying to allocate a large
>> number of pages, and fail if it can't (leaving memory for other
>> allocations to succeed).
>>
>> The allocation of the ring buffer isn't critical. It can fail to
>> expand, and we can tell the user -ENOMEM. I original had NORETRY
>> because I rather have it fail than cause an OOM. But there's folks
>> (like Joel) that want it to succeed when there's available memory in
>> page caches.
>
> Then implement a retry logic on top of NORETRY. You can control how hard
> to retry to satisfy the request yourself. You still risk that your
> allocation will get us close to OOM for _somebody_ else though.
>
>> I'm fine if the admin shoots herself in the foot if the ring buffer
>> gets big enough to start causing OOMs, but I don't want it to cause
>> OOMs if there's not even enough memory to fulfill the ring buffer size
>> itself.
>
> I simply do not see the difference between the two. Both have the same
> deadly effect in the end. The direct OOM has an arguable advantage that
> the effect is immediate rather than subtle with potential performance
> side effects until the machine OOMs after crawling for quite some time.
>
> --
> Michal Hocko
> SUSE Labs
