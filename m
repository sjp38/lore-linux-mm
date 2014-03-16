Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f171.google.com (mail-ve0-f171.google.com [209.85.128.171])
	by kanga.kvack.org (Postfix) with ESMTP id BC7A86B0037
	for <linux-mm@kvack.org>; Sun, 16 Mar 2014 15:13:57 -0400 (EDT)
Received: by mail-ve0-f171.google.com with SMTP id cz12so4827049veb.16
        for <linux-mm@kvack.org>; Sun, 16 Mar 2014 12:13:57 -0700 (PDT)
Received: from mail-vc0-x22b.google.com (mail-vc0-x22b.google.com [2607:f8b0:400c:c03::22b])
        by mx.google.com with ESMTPS id xb4si4042876vdc.12.2014.03.16.12.13.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 16 Mar 2014 12:13:55 -0700 (PDT)
Received: by mail-vc0-f171.google.com with SMTP id lg15so4800580vcb.2
        for <linux-mm@kvack.org>; Sun, 16 Mar 2014 12:13:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140316145951.GB26026@htj.dyndns.org>
References: <1392437537-27392-1-git-send-email-dbasehore@chromium.org>
	<20140218225548.GI31892@mtj.dyndns.org>
	<20140219092731.GA4849@quack.suse.cz>
	<20140219190139.GQ10134@htj.dyndns.org>
	<CAGAzgspTZnUh_qi=FeQ4hS4LRiexPccTyALMg3Gt1K0ZZq_MuQ@mail.gmail.com>
	<20140316145951.GB26026@htj.dyndns.org>
Date: Sun, 16 Mar 2014 12:13:55 -0700
Message-ID: <CAGAzgsqD0aRnDMMyDCUVii6Rv22f97G0irpzFBz4c_ukKsn2hg@mail.gmail.com>
Subject: Re: [PATCH] backing_dev: Fix hung task on sync
From: "dbasehore ." <dbasehore@chromium.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Jan Kara <jack@suse.cz>, Alexander Viro <viro@zento.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, Kees Cook <keescook@chromium.org>, linux-fsdevel@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, bleung@chromium.org, sonnyrao@chromium.org, Luigi Semenzato <semenzato@chromium.org>

There's already behavior that is somewhat like that with the current
implementation. If there's an item on a workqueue, it could run at any
time. From the perspective of the driver/etc. that is using the
workqueue, there should be no difference between work being on the
workqueue and the kernel triggering a schedule right after the work is
removed from the workqueue, but before the work function has done
anything.

So to reiterate, calling mod_delayed_work on something that is already
in the workqueue has two behaviors. One, the work is dispatched before
mod_delayed_work can remove it from the workqueue. Two,
mod_delayed_work removes it from the workqueue and sets the timer (or
not in the case of 0). The behavior of the proposed change should be
no different than the first behavior.

This should not introduce new behavior from the perspective of the
code using delayed_work. It is true that there is a larger window of
time between when you call mod_delayed_work and when an already queued
work item will run, but I don't believe that matters.

The API will still make sense since we will only ever mod delayed work
but not work that is no longer delayed (on the workqueue).

On Sun, Mar 16, 2014 at 7:59 AM, Tejun Heo <tj@kernel.org> wrote:
> On Sat, Mar 15, 2014 at 01:22:53PM -0700, dbasehore . wrote:
>> mod_delayed_work currently removes a work item from a workqueue if it
>> is on it. Correct me if I'm wrong, but I don't think that this is
>> necessarily required for mod_delayed_work to have the current
>> behavior. We should be able to set the timer while a delayed_work is
>> currently on a workqueue. If the delayed_work is still on the
>> workqueue when the timer goes off, everything is fine. If it has left
>> the workqueue, we can queue it again.
>
> What different would that make w.r.t. this issue?  Plus, please note
> that a work item may wait non-insignificant amount of time pending if
> the workqueue is saturated to max_active.  Doing the above would make
> mod_delayed_work()'s behavior quite fuzzy - the work item is modified
> or queued to the specified time but if the timer has already expired,
> the work item may execute after unspecified amount of time which may
> be shorter than the new timeout.  What kind of interface would that
> be?
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
