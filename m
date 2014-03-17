Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id 94DD56B009E
	for <linux-mm@kvack.org>; Mon, 17 Mar 2014 10:40:24 -0400 (EDT)
Received: by mail-qg0-f42.google.com with SMTP id q107so16862697qgd.1
        for <linux-mm@kvack.org>; Mon, 17 Mar 2014 07:40:24 -0700 (PDT)
Received: from mail-qa0-x22a.google.com (mail-qa0-x22a.google.com [2607:f8b0:400d:c00::22a])
        by mx.google.com with ESMTPS id h5si8676891qas.116.2014.03.17.07.40.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 17 Mar 2014 07:40:23 -0700 (PDT)
Received: by mail-qa0-f42.google.com with SMTP id k15so5458836qaq.29
        for <linux-mm@kvack.org>; Mon, 17 Mar 2014 07:40:23 -0700 (PDT)
Date: Mon, 17 Mar 2014 10:40:20 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] backing_dev: Fix hung task on sync
Message-ID: <20140317144020.GA13749@htj.dyndns.org>
References: <1392437537-27392-1-git-send-email-dbasehore@chromium.org>
 <20140218225548.GI31892@mtj.dyndns.org>
 <20140219092731.GA4849@quack.suse.cz>
 <20140219190139.GQ10134@htj.dyndns.org>
 <CAGAzgspTZnUh_qi=FeQ4hS4LRiexPccTyALMg3Gt1K0ZZq_MuQ@mail.gmail.com>
 <20140316145951.GB26026@htj.dyndns.org>
 <CAGAzgsqD0aRnDMMyDCUVii6Rv22f97G0irpzFBz4c_ukKsn2hg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGAzgsqD0aRnDMMyDCUVii6Rv22f97G0irpzFBz4c_ukKsn2hg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "dbasehore ." <dbasehore@chromium.org>
Cc: Jan Kara <jack@suse.cz>, Alexander Viro <viro@zento.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, Kees Cook <keescook@chromium.org>, linux-fsdevel@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, bleung@chromium.org, sonnyrao@chromium.org, Luigi Semenzato <semenzato@chromium.org>

Hello,

On Sun, Mar 16, 2014 at 12:13:55PM -0700, dbasehore . wrote:
> There's already behavior that is somewhat like that with the current
> implementation. If there's an item on a workqueue, it could run at any
> time. From the perspective of the driver/etc. that is using the
> workqueue, there should be no difference between work being on the
> workqueue and the kernel triggering a schedule right after the work is
> removed from the workqueue, but before the work function has done
> anything.

It is different.  mod_delayed_work() *guarantees* that the target work
item will become pending for execution at least after the specified
time has passed.  What you're suggesting removes any semantically
consistent meaning of the API.

> So to reiterate, calling mod_delayed_work on something that is already
> in the workqueue has two behaviors. One, the work is dispatched before
> mod_delayed_work can remove it from the workqueue. Two,
> mod_delayed_work removes it from the workqueue and sets the timer (or
> not in the case of 0). The behavior of the proposed change should be
> no different than the first behavior.

No, mod_delayed_work() does *one* thing - the work item is queued for
the specified delay no matter the current state of the work item.  It
is *guaranteed* that the work item will go pending after the specified
time.  That is the sole meaning of the API.

> This should not introduce new behavior from the perspective of the
> code using delayed_work. It is true that there is a larger window of
> time between when you call mod_delayed_work and when an already queued
> work item will run, but I don't believe that matters.

You're completely misunderstanding the API.  Plesae re-read it and
understand what it does first.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
