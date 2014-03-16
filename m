Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id 32FB06B0035
	for <linux-mm@kvack.org>; Sun, 16 Mar 2014 10:59:55 -0400 (EDT)
Received: by mail-qg0-f41.google.com with SMTP id i50so13578946qgf.0
        for <linux-mm@kvack.org>; Sun, 16 Mar 2014 07:59:54 -0700 (PDT)
Received: from mail-qg0-x22a.google.com (mail-qg0-x22a.google.com [2607:f8b0:400d:c04::22a])
        by mx.google.com with ESMTPS id u4si6937985qat.76.2014.03.16.07.59.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 16 Mar 2014 07:59:54 -0700 (PDT)
Received: by mail-qg0-f42.google.com with SMTP id q107so13555379qgd.1
        for <linux-mm@kvack.org>; Sun, 16 Mar 2014 07:59:54 -0700 (PDT)
Date: Sun, 16 Mar 2014 10:59:51 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] backing_dev: Fix hung task on sync
Message-ID: <20140316145951.GB26026@htj.dyndns.org>
References: <1392437537-27392-1-git-send-email-dbasehore@chromium.org>
 <20140218225548.GI31892@mtj.dyndns.org>
 <20140219092731.GA4849@quack.suse.cz>
 <20140219190139.GQ10134@htj.dyndns.org>
 <CAGAzgspTZnUh_qi=FeQ4hS4LRiexPccTyALMg3Gt1K0ZZq_MuQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGAzgspTZnUh_qi=FeQ4hS4LRiexPccTyALMg3Gt1K0ZZq_MuQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "dbasehore ." <dbasehore@chromium.org>
Cc: Jan Kara <jack@suse.cz>, Alexander Viro <viro@zento.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, Kees Cook <keescook@chromium.org>, linux-fsdevel@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, bleung@chromium.org, sonnyrao@chromium.org, Luigi Semenzato <semenzato@chromium.org>

On Sat, Mar 15, 2014 at 01:22:53PM -0700, dbasehore . wrote:
> mod_delayed_work currently removes a work item from a workqueue if it
> is on it. Correct me if I'm wrong, but I don't think that this is
> necessarily required for mod_delayed_work to have the current
> behavior. We should be able to set the timer while a delayed_work is
> currently on a workqueue. If the delayed_work is still on the
> workqueue when the timer goes off, everything is fine. If it has left
> the workqueue, we can queue it again.

What different would that make w.r.t. this issue?  Plus, please note
that a work item may wait non-insignificant amount of time pending if
the workqueue is saturated to max_active.  Doing the above would make
mod_delayed_work()'s behavior quite fuzzy - the work item is modified
or queued to the specified time but if the timer has already expired,
the work item may execute after unspecified amount of time which may
be shorter than the new timeout.  What kind of interface would that
be?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
