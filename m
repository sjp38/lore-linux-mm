Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4DCA68E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 02:36:10 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id d71so7986412pgc.1
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 23:36:10 -0800 (PST)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id b8si8853010pgi.575.2019.01.10.23.36.08
        for <linux-mm@kvack.org>;
        Thu, 10 Jan 2019 23:36:09 -0800 (PST)
Date: Fri, 11 Jan 2019 18:36:06 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
Message-ID: <20190111073606.GP27534@dastard>
References: <20190110004424.GH27534@dastard>
 <CAHk-=wg1jSQ-gq-M3+HeTBbDs1VCjyiwF4gqnnBhHeWizyrigg@mail.gmail.com>
 <20190110070355.GJ27534@dastard>
 <CAHk-=wigwXV_G-V1VxLs6BAvVkvW5=Oj+xrNHxE_7yxEVwoe3w@mail.gmail.com>
 <20190110122442.GA21216@nautica>
 <CAHk-=wip2CPrdOwgF0z4n2tsdW7uu+Egtcx9Mxxe3gPfPW_JmQ@mail.gmail.com>
 <20190111020340.GM27534@dastard>
 <CAHk-=wgLgAzs42=W0tPrTVpu7H7fQ=BP5gXKnoNxMxh9=9uXag@mail.gmail.com>
 <20190111040434.GN27534@dastard>
 <CAHk-=wh-kegfnPC_dmw0A72Sdk4B9tvce-cOR=jEfHDU1-4Eew@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHk-=wh-kegfnPC_dmw0A72Sdk4B9tvce-cOR=jEfHDU1-4Eew@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dominique Martinet <asmadeus@codewreck.org>, Jiri Kosina <jikos@kernel.org>, Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Thu, Jan 10, 2019 at 11:08:07PM -0800, Linus Torvalds wrote:
> On Thu, Jan 10, 2019 at 8:04 PM Dave Chinner <david@fromorbit.com> wrote:
> >
> > So it will only read the single page we tried to access and won't
> > perturb the rest of the message encoded into subsequent pages in
> > file.
> 
> Dave, you're being intentionally obtuse, aren't you?
> 
> It's only that single page that *matters*. That's the page that the
> probe reveals the status of - but it's also the page that the probe
> then *changes* the status of.

It changes the state of it /after/ we've already got the information
we need from it. It's not up to date, it has to come from disk, we
return EAGAIN, which means it was not in the cache.

i.e. if we return EAGAIN, we've leaked the inforation the attacker
wants regardless of how the act of initiating readahead on the page
change the state of the page.  Yes, it raises the complexity bar a
bit, and lowers the monitoring frequency somewhat, but that's about
it.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
