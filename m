Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f180.google.com (mail-ve0-f180.google.com [209.85.128.180])
	by kanga.kvack.org (Postfix) with ESMTP id A88996B00CE
	for <linux-mm@kvack.org>; Mon, 17 Mar 2014 16:53:58 -0400 (EDT)
Received: by mail-ve0-f180.google.com with SMTP id jz11so5975699veb.25
        for <linux-mm@kvack.org>; Mon, 17 Mar 2014 13:53:58 -0700 (PDT)
Received: from mail-ve0-x230.google.com (mail-ve0-x230.google.com [2607:f8b0:400c:c01::230])
        by mx.google.com with ESMTPS id dr8si2801385vcb.13.2014.03.17.13.53.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 17 Mar 2014 13:53:58 -0700 (PDT)
Received: by mail-ve0-f176.google.com with SMTP id cz12so6162856veb.35
        for <linux-mm@kvack.org>; Mon, 17 Mar 2014 13:53:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140317144020.GA13749@htj.dyndns.org>
References: <1392437537-27392-1-git-send-email-dbasehore@chromium.org>
	<20140218225548.GI31892@mtj.dyndns.org>
	<20140219092731.GA4849@quack.suse.cz>
	<20140219190139.GQ10134@htj.dyndns.org>
	<CAGAzgspTZnUh_qi=FeQ4hS4LRiexPccTyALMg3Gt1K0ZZq_MuQ@mail.gmail.com>
	<20140316145951.GB26026@htj.dyndns.org>
	<CAGAzgsqD0aRnDMMyDCUVii6Rv22f97G0irpzFBz4c_ukKsn2hg@mail.gmail.com>
	<20140317144020.GA13749@htj.dyndns.org>
Date: Mon, 17 Mar 2014 13:53:57 -0700
Message-ID: <CAGAzgsrQvJL8BFF1ADVvi9oWjyPaaKdFh20OGUg-BCvtNmMc1A@mail.gmail.com>
Subject: Re: [PATCH] backing_dev: Fix hung task on sync
From: "dbasehore ." <dbasehore@chromium.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Jan Kara <jack@suse.cz>, Alexander Viro <viro@zento.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, Kees Cook <keescook@chromium.org>, linux-fsdevel@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, bleung@chromium.org, sonnyrao@chromium.org, Luigi Semenzato <semenzato@chromium.org>

On Mon, Mar 17, 2014 at 7:40 AM, Tejun Heo <tj@kernel.org> wrote:
> Hello,
>
> On Sun, Mar 16, 2014 at 12:13:55PM -0700, dbasehore . wrote:
>> There's already behavior that is somewhat like that with the current
>> implementation. If there's an item on a workqueue, it could run at any
>> time. From the perspective of the driver/etc. that is using the
>> workqueue, there should be no difference between work being on the
>> workqueue and the kernel triggering a schedule right after the work is
>> removed from the workqueue, but before the work function has done
>> anything.
>
> It is different.  mod_delayed_work() *guarantees* that the target work
> item will become pending for execution at least after the specified
> time has passed.  What you're suggesting removes any semantically
> consistent meaning of the API.
>

It will still be at least be pending after the specified time has
passed. I'm proposing that we still set the timer. The difference is
that there is a possibility the work will already be pending when the
timer goes off. There will still at least be an execution after the
given time has past. We could still remove the work in the workqueue
from the timer function, but this would make the mod_delayed_work not
race with any work that was scheduled for immediate execution
previously.

If you make the timer function remove any pending work from the
workqueue when the timer goes off, this is still following the API.
The work will still become pending at least after the specified time
has passed.

>> So to reiterate, calling mod_delayed_work on something that is already
>> in the workqueue has two behaviors. One, the work is dispatched before
>> mod_delayed_work can remove it from the workqueue. Two,
>> mod_delayed_work removes it from the workqueue and sets the timer (or
>> not in the case of 0). The behavior of the proposed change should be
>> no different than the first behavior.
>
> No, mod_delayed_work() does *one* thing - the work item is queued for
> the specified delay no matter the current state of the work item.  It
> is *guaranteed* that the work item will go pending after the specified
> time.  That is the sole meaning of the API.
>
>> This should not introduce new behavior from the perspective of the
>> code using delayed_work. It is true that there is a larger window of
>> time between when you call mod_delayed_work and when an already queued
>> work item will run, but I don't believe that matters.
>
> You're completely misunderstanding the API.  Plesae re-read it and
> understand what it does first.
>
> Thanks.
>
> --
> tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
