Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3C3AB6B0005
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 02:23:43 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id v11so10697173wri.13
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 23:23:43 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z12si3356675wmh.127.2018.04.03.23.23.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 03 Apr 2018 23:23:41 -0700 (PDT)
Date: Wed, 4 Apr 2018 08:23:40 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v1] kernel/trace:check the val against the available mem
Message-ID: <20180404062340.GD6312@dhcp22.suse.cz>
References: <1522320104-6573-1-git-send-email-zhaoyang.huang@spreadtrum.com>
 <20180330102038.2378925b@gandalf.local.home>
 <20180403110612.GM5501@dhcp22.suse.cz>
 <20180403075158.0c0a2795@gandalf.local.home>
 <20180403121614.GV5501@dhcp22.suse.cz>
 <20180403082348.28cd3c1c@gandalf.local.home>
 <20180403123514.GX5501@dhcp22.suse.cz>
 <20180403093245.43e7e77c@gandalf.local.home>
 <20180403135607.GC5501@dhcp22.suse.cz>
 <CAGWkznH-yfAu=fMo1YWU9zo-DomHY8YP=rw447rUTgzvVH4RpQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGWkznH-yfAu=fMo1YWU9zo-DomHY8YP=rw447rUTgzvVH4RpQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhaoyang Huang <huangzhaoyang@gmail.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@kernel.org>, linux-kernel@vger.kernel.org, kernel-patch-test@lists.linaro.org, Andrew Morton <akpm@linux-foundation.org>, Joel Fernandes <joelaf@google.com>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>

On Wed 04-04-18 10:58:39, Zhaoyang Huang wrote:
> On Tue, Apr 3, 2018 at 9:56 PM, Michal Hocko <mhocko@kernel.org> wrote:
> > On Tue 03-04-18 09:32:45, Steven Rostedt wrote:
> >> On Tue, 3 Apr 2018 14:35:14 +0200
> >> Michal Hocko <mhocko@kernel.org> wrote:
> > [...]
> >> > Being clever is OK if it doesn't add a tricky code. And relying on
> >> > si_mem_available is definitely tricky and obscure.
> >>
> >> Can we get the mm subsystem to provide a better method to know if an
> >> allocation will possibly succeed or not before trying it? It doesn't
> >> have to be free of races. Just "if I allocate this many pages right
> >> now, will it work?" If that changes from the time it asks to the time
> >> it allocates, that's fine. I'm not trying to prevent OOM to never
> >> trigger. I just don't want to to trigger consistently.
> >
> > How do you do that without an actuall allocation request? And more
> > fundamentally, what if your _particular_ request is just fine but it
> > will get us so close to the OOM edge that the next legit allocation
> > request simply goes OOM? There is simply no sane interface I can think
> > of that would satisfy a safe/sensible "will it cause OOM" semantic.
> >
> The point is the app which try to allocate the size over the line will escape
> the OOM and let other innocent to be sacrificed. However, the one which you
> mentioned above will be possibly selected by OOM that triggered by consequnce
> failed allocation.

If you are afraid of that then you can have a look at {set,clear}_current_oom_origin()
which will automatically select the current process as an oom victim and
kill it.
-- 
Michal Hocko
SUSE Labs
