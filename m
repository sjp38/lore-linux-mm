Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id CFD8B6B0009
	for <linux-mm@kvack.org>; Tue, 27 Mar 2018 03:32:15 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id q29-v6so1969377lfg.4
        for <linux-mm@kvack.org>; Tue, 27 Mar 2018 00:32:15 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a1sor123020ljj.103.2018.03.27.00.32.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 27 Mar 2018 00:32:14 -0700 (PDT)
Date: Tue, 27 Mar 2018 10:32:12 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [v2 PATCH] mm: introduce arg_lock to protect arg_start|end and
 env_start|end in mm_struct
Message-ID: <20180327073212.GG2236@uranus>
References: <1522088439-105930-1-git-send-email-yang.shi@linux.alibaba.com>
 <20180326183725.GB27373@bombadil.infradead.org>
 <20180326192132.GE2236@uranus>
 <aef52c2a-4b75-f8a7-2083-f53f42bddab8@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <aef52c2a-4b75-f8a7-2083-f53f42bddab8@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Matthew Wilcox <willy@infradead.org>, adobriyan@gmail.com, mhocko@kernel.org, mguzik@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Mar 26, 2018 at 05:59:49PM -0400, Yang Shi wrote:
> > Say we've two syscalls running prctl_set_mm_map in parallel, and imagine
> > one have @start_brk = 20 @brk = 10 and second caller has @start_brk = 30
> > and @brk = 20. Since now the call is guarded by _read_ the both calls
> > unlocked and due to OO engine it may happen then when both finish
> > we have @start_brk = 30 and @brk = 10. In turn "write" semaphore
> > has been take to have consistent data on exit, either you have [20;10]
> > or [30;20] assigned not something mixed.
> > 
> > That said I think using read-lock here would be a bug.
> 
> Yes it sounds so. However, it was down_read before
> ddf1d398e517e660207e2c807f76a90df543a217 ("prctl: take mmap sem for writing
> to protect against others"). And, that commit is for fixing the concurrent
> writing to arg_* and env_*. I just checked that commit, but omitted the brk
> part. The potential issue mentioned by you should exist before that commit,
> but might be just not discovered or very rare to hit.
> 
> I will change it back to down_write.

down_read before was a bug ;) And it was not discovered earlier simply
because not that many users of this interface exist, namely only criu
as far as I know by now.
