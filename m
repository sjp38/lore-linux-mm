Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f181.google.com (mail-ve0-f181.google.com [209.85.128.181])
	by kanga.kvack.org (Postfix) with ESMTP id 292896B0036
	for <linux-mm@kvack.org>; Sat, 15 Mar 2014 16:22:55 -0400 (EDT)
Received: by mail-ve0-f181.google.com with SMTP id oy12so4089706veb.26
        for <linux-mm@kvack.org>; Sat, 15 Mar 2014 13:22:54 -0700 (PDT)
Received: from mail-ve0-x22f.google.com (mail-ve0-x22f.google.com [2607:f8b0:400c:c01::22f])
        by mx.google.com with ESMTPS id nd7si1596239vec.211.2014.03.15.13.22.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 15 Mar 2014 13:22:53 -0700 (PDT)
Received: by mail-ve0-f175.google.com with SMTP id oz11so4189602veb.34
        for <linux-mm@kvack.org>; Sat, 15 Mar 2014 13:22:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140219190139.GQ10134@htj.dyndns.org>
References: <1392437537-27392-1-git-send-email-dbasehore@chromium.org>
	<20140218225548.GI31892@mtj.dyndns.org>
	<20140219092731.GA4849@quack.suse.cz>
	<20140219190139.GQ10134@htj.dyndns.org>
Date: Sat, 15 Mar 2014 13:22:53 -0700
Message-ID: <CAGAzgspTZnUh_qi=FeQ4hS4LRiexPccTyALMg3Gt1K0ZZq_MuQ@mail.gmail.com>
Subject: Re: [PATCH] backing_dev: Fix hung task on sync
From: "dbasehore ." <dbasehore@chromium.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Jan Kara <jack@suse.cz>, Alexander Viro <viro@zento.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, Kees Cook <keescook@chromium.org>, linux-fsdevel@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, bleung@chromium.org, sonnyrao@chromium.org, Luigi Semenzato <semenzato@chromium.org>

Resurrecting this for further discussion about the root of the problem.

mod_delayed_work_if_later addresses the problem one way, but the
problem is still there for mod_delayed_work. I think we could take
another approach that doesn't modify the API, but still addresses
(most of) the problem.

mod_delayed_work currently removes a work item from a workqueue if it
is on it. Correct me if I'm wrong, but I don't think that this is
necessarily required for mod_delayed_work to have the current
behavior. We should be able to set the timer while a delayed_work is
currently on a workqueue. If the delayed_work is still on the
workqueue when the timer goes off, everything is fine. If it has left
the workqueue, we can queue it again.

On Wed, Feb 19, 2014 at 11:01 AM, Tejun Heo <tj@kernel.org> wrote:
> Hello, Jan.
>
> On Wed, Feb 19, 2014 at 10:27:31AM +0100, Jan Kara wrote:
>>   You are the workqueue expert so you may know better ;) But the way I
>> understand it is that queue_delayed_work() does nothing if the timer is
>> already running. Since we queue flusher work to run either immediately or
>> after dirty_writeback_interval we are safe to run queue_delayed_work()
>> whenever we want it to run after dirty_writeback_interval and
>> mod_delayed_work() whenever we want to run it immediately.
>
> Ah, okay, so it's always mod on immediate and queue on delayed.  Yeah,
> that should work.
>
>> But it's subtle and some interface where we could say queue delayed work
>> after no later than X would be easier to grasp.
>
> Yeah, I think it'd be better if we had something like
> mod_delayed_work_if_later().  Hmm...
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
