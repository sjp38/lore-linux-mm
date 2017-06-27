Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 359E66B02FD
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 11:50:39 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id 23so25217430wry.4
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 08:50:39 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 62si14848696wrh.283.2017.06.27.08.50.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 27 Jun 2017 08:50:37 -0700 (PDT)
Date: Tue, 27 Jun 2017 17:50:35 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: OOM kills with lots of free swap
Message-ID: <20170627155035.GA20189@dhcp22.suse.cz>
References: <CAA25o9T1WmkWJn1LA-vS=W_Qu8pBw3rfMtTreLNu8fLuZjTDsw@mail.gmail.com>
 <20170627071104.GB28078@dhcp22.suse.cz>
 <CAA25o9T1q9gWzb0BeXY3mvLOth-ow=yjVuwD9ct5f1giBWo=XQ@mail.gmail.com>
 <CAA25o9TUkHd9w+DNBdH_4w6LTEEb+Q6QAycHcqx-z3mwh+G=kA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA25o9TUkHd9w+DNBdH_4w6LTEEb+Q6QAycHcqx-z3mwh+G=kA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luigi Semenzato <semenzato@google.com>
Cc: Minchan Kim <minchan@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Tue 27-06-17 08:22:36, Luigi Semenzato wrote:
> (sorry, I forgot to turn off HTML formatting)
> 
> Thank you, I can try this on ToT, although I think that the problem is
> not with the OOM killer itself but earlier---i.e. invoking the OOM
> killer seems unnecessary and wrong.  Here's the question.
> 
> The general strategy for page allocation seems to be (please correct
> me as needed):
> 
> 1. look in the free lists
> 2. if that did not succeed, try to reclaim, then try again to allocate
> 3. keep trying as long as progress is made (i.e. something was reclaimed)
> 4. if no progress was made and no pages were found, invoke the OOM killer.

Yes that is the case very broadly speaking. The hard question really is
what "no progress" actually means. We use "no pages could be reclaimed"
as the indicator. We cannot blow up at the first such instance of
course because that could be too early (e.g. data under writeback
and many other details). With 4.7+ kernels this is implemented in
should_reclaim_retry. Prior to the rework we used to rely on
zone_reclaimable which simply checked how many pages we have scanned
since the last page has been freed and if that is 6 times the
reclaimable memory then we simply give up. It had some issues described
in 0a0337e0d1d1 ("mm, oom: rework oom detection").

> I'd like to know if that "progress is made" notion is possibly buggy.
> Specifically, does it mean "progress is made by this task"?  Is it
> possible that resource contention creates a situation where most tasks
> in most cases can reclaim and allocate, but one task randomly fails to
> make progress?

This can happen, alhtough it is quite unlikely. We are trying to
throttle allocations but you can hardly fight a consistent badluck ;)

In order to see what is going on in your particular case we need an oom
report though.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
