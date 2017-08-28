Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 544B66B0292
	for <linux-mm@kvack.org>; Mon, 28 Aug 2017 07:30:26 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id q77so261968wmd.9
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 04:30:26 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o98si136602wrc.529.2017.08.28.04.30.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 28 Aug 2017 04:30:25 -0700 (PDT)
Date: Mon, 28 Aug 2017 13:30:23 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH RFC v2] Add /proc/pid/smaps_rollup
Message-ID: <20170828113023.GH17097@dhcp22.suse.cz>
References: <20170808132554.141143-1-dancol@google.com>
 <20170810001557.147285-1-dancol@google.com>
 <20170810043831.GB2249@bbox>
 <20170810084617.GI23863@dhcp22.suse.cz>
 <r0251soju3fo.fsf@dancol.org>
 <20170810105852.GM23863@dhcp22.suse.cz>
 <CAPz6YkUNu1uH057ENuH+Umq5J=J24my0p91mvYMtEb4Vy6Dhqg@mail.gmail.com>
 <CAEe=SxkgPUEkHdQm+M49EBc_Y_bEnNbe5fed3yALUx2eUbMrGQ@mail.gmail.com>
 <20170824085553.GB5943@dhcp22.suse.cz>
 <20170825141637.f11a36a9997b4b705d5b6481@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170825141637.f11a36a9997b4b705d5b6481@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tim Murray <timmurray@google.com>, Sonny Rao <sonnyrao@chromium.org>, Daniel Colascione <dancol@google.com>, Minchan Kim <minchan@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Joel Fernandes <joelaf@google.com>, Al Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, Robert Foss <robert.foss@collabora.com>, linux-api@vger.kernel.org, Luigi Semenzato <semenzato@google.com>

On Fri 25-08-17 14:16:37, Andrew Morton wrote:
> On Thu, 24 Aug 2017 10:55:53 +0200 Michal Hocko <mhocko@kernel.org> wrote:
> 
> > > If we assume that the number of VMAs is going to increase over time,
> > > then doing anything we can do to reduce the overhead of each VMA
> > > during PSS collection seems like the right way to go, and that means
> > > outputting an aggregate statistic (to avoid whatever overhead there is
> > > per line in writing smaps and in reading each line from userspace).
> > > 
> > > Also, Dan sent me some numbers from his benchmark measuring PSS on
> > > system_server (the big Android process) using smaps vs smaps_rollup:
> > > 
> > > using smaps:
> > > iterations:1000 pid:1163 pss:220023808
> > >  0m29.46s real 0m08.28s user 0m20.98s system
> > > 
> > > using smaps_rollup:
> > > iterations:1000 pid:1163 pss:220702720
> > >  0m04.39s real 0m00.03s user 0m04.31s system
> > 
> > I would assume we would do all we can to reduce this kernel->user
> > overhead first before considering a new user visible file. I haven't
> > seen any attempts except from the low hanging fruid I have tried.
> 
> It's hard to believe that we'll get anything like a 5x speedup via
> optimization of the existing code?

Maybe we will not get that much of a boost but having misleading numbers
really quick is not something we should aim for. Just try to think what
the cumulative numbers actually mean. How can you even consider
cumulative PSS when you have no idea about mappings that were
considered?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
