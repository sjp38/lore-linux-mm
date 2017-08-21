Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1B596280310
	for <linux-mm@kvack.org>; Mon, 21 Aug 2017 09:18:56 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id z91so25042073wrc.4
        for <linux-mm@kvack.org>; Mon, 21 Aug 2017 06:18:56 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m10si9637989wrb.254.2017.08.21.06.18.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 21 Aug 2017 06:18:54 -0700 (PDT)
Date: Mon, 21 Aug 2017 15:18:52 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH v2] mm, oom: task_will_free_mem(current) should ignore
 MMF_OOM_SKIP for once.
Message-ID: <20170821131851.GJ25956@dhcp22.suse.cz>
References: <1501718104-8099-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <201708191523.BJH90621.MHOOFFQSOLJFtV@I-love.SAKURA.ne.jp>
 <20170821084307.GB25956@dhcp22.suse.cz>
 <201708212041.GAJ05272.VOMOJOFSQLFtHF@I-love.SAKURA.ne.jp>
 <20170821121022.GF25956@dhcp22.suse.cz>
 <201708212157.DFB00801.tLMOFFSOOVQFJH@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201708212157.DFB00801.tLMOFFSOOVQFJH@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, rientjes@google.com, mjaggi@caviumnetworks.com, oleg@redhat.com, vdavydov.dev@gmail.com

On Mon 21-08-17 21:57:44, Tetsuo Handa wrote:
> Michal Hocko wrote:
[...]
> > Sigh... Let me repeat for the last time (this whole thread is largely a
> > waste of time to be honest). Find a _robust_ solution rather than
> > fiddling with try-once-more kind of hacks. E.g. do an allocation attempt
> > _before_ we do any disruptive action (aka kill a victim). This would
> > help other cases when we race with an exiting tasks or somebody managed
> > to free memory while we were selecting an oom victim which can take
> > quite some time.
> 
> I did not get your answer to my question:
> 
>   You don't want to call get_page_from_freelist() from out_of_memory(), do you?
> 
> Since David Rientjes wrote "how sloppy this would be because it's blurring
> the line between oom killer and page allocator." and you responded as
> "Yes the layer violation is definitely not nice." at
> http://lkml.kernel.org/r/20160129152307.GF32174@dhcp22.suse.cz ,
> I assumed that you don't want to call get_page_from_freelist() from out_of_memory().

Yes that would be a layering violation and I do not like that very much.
And that is why I keep repeating that this is something to handle only _if_
the problem is real and happens with _sensible_ workloads so often that
we really have to care. If this happens only under oom stress testing
then I would be tempted to not care all that much.

Please try to understand that OOM killer will never be perfect and
adding more kludges and hacks make it more fragile so each additional
heuristic should be considered carefully.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
