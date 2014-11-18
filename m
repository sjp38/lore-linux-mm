Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id B203B6B0038
	for <linux-mm@kvack.org>; Tue, 18 Nov 2014 17:15:47 -0500 (EST)
Received: by mail-wg0-f52.google.com with SMTP id a1so5406759wgh.25
        for <linux-mm@kvack.org>; Tue, 18 Nov 2014 14:15:47 -0800 (PST)
Received: from mail-wg0-x236.google.com (mail-wg0-x236.google.com. [2a00:1450:400c:c00::236])
        by mx.google.com with ESMTPS id aq2si122186wjc.52.2014.11.18.14.15.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 18 Nov 2014 14:15:47 -0800 (PST)
Received: by mail-wg0-f54.google.com with SMTP id y10so7440666wgg.13
        for <linux-mm@kvack.org>; Tue, 18 Nov 2014 14:15:46 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20141118121936.07b02545a0684b2cc839a10c@linux-foundation.org>
References: <502D42E5.7090403@redhat.com>
	<20120818000312.GA4262@evergreen.ssec.wisc.edu>
	<502F100A.1080401@redhat.com>
	<alpine.LSU.2.00.1208200032450.24855@eggly.anvils>
	<CANN689Ej7XLh8VKuaPrTttDrtDGQbXuYJgS2uKnZL2EYVTM3Dg@mail.gmail.com>
	<20120822032057.GA30871@google.com>
	<50345232.4090002@redhat.com>
	<20130603195003.GA31275@evergreen.ssec.wisc.edu>
	<20141114163053.GA6547@cosmos.ssec.wisc.edu>
	<20141117160212.b86d031e1870601240b0131d@linux-foundation.org>
	<20141118014135.GA17252@cosmos.ssec.wisc.edu>
	<546AB1F5.6030306@redhat.com>
	<20141118121936.07b02545a0684b2cc839a10c@linux-foundation.org>
Date: Wed, 19 Nov 2014 02:15:46 +0400
Message-ID: <CALYGNiMxnxmy-LyJ4OT9OoFeKwTPPkZMF-bJ-eJDBFXgZQ6AEA@mail.gmail.com>
Subject: Re: [PATCH] Repeated fork() causes SLAB to grow without bound
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Tim Hartrick <tim@edgecast.com>, Michal Hocko <mhocko@suse.cz>

On Tue, Nov 18, 2014 at 11:19 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Mon, 17 Nov 2014 21:41:57 -0500 Rik van Riel <riel@redhat.com> wrote:
>
>> > Because of the serial forking there does indeed end up being an
>> > infinite number of vmas.  The initial vma can never be deleted
>> > (even though the initial parent process has long since terminated)
>> > because the initial vma is referenced by the children.
>>
>> There is a finite number of VMAs, but an infite number of
>> anon_vmas.
>>
>> Subtle, yet deadly...
>
> Well, we clearly have the data structures screwed up.  I've forgotten
> enough about this code for me to be unable to work out what the fixed
> up data structures would look like :( But surely there is some proper
> solution here.  Help?

Not sure if it's right but probably we could reuse on fork an old anon_vma
from the chain if it's already lost all vmas which points to it.
For endlessly forking exploit this should work mostly like proposed patch
which stops branching after some depth but without magic constant.

>
>> > I can't say, but it only affects users who fork more than five
>> > levels deep without doing an exec.  On the other hand, there are at
>> > least three users (Tim Hartrick, Michal Hocko, and myself) who have
>> > real world applications where the consequence of no patch is a
>> > crashed system.
>> >
>> > I would suggest reading the thread starting with my initial bug
>> > report for what others have had to say about this.
>>
>> I suspect what Andrew is hinting at is that the
>> changelog for the patch should contain a detailed
>> description of exactly what the bug is, how it is
>> triggered, what the symptoms are, and how the
>> patch avoids it.
>>
>> That way people can understand what the code does
>> simply by looking at the changelog - no need to go
>> find old linux-kernel mailing list threads.
>
> Yes please, there's a ton of stuff here which we should attempt to
> capture.
>
> https://lkml.org/lkml/2012/8/15/765 is useful.
>
> I'm assuming that with the "foo < 5" hack, an application which forked
> 5 times then did a lot of work would still trigger the "catastrophic
> issue at page reclaim time" issue which Rik identified at
> https://lkml.org/lkml/2012/8/20/265?
>
> There are real-world workloads which are triggering this slab growth
> problem, yes?  (Detail them in the changelog, please).
>
> This bug snuck under my radar last time - we're permitting unprivileged
> userspace to exhaust memory and that's bad.  I'm OK with the foo<5
> thing for -stable kernels, as it is simple.  But I'm reluctant to merge
> (or at least to retain) it in mainline because then everyone will run
> away and think about other stuff and this bug will never get fixed
> properly.
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
