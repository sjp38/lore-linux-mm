Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8D6646B0007
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 10:27:53 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id i3so2040337wmf.7
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 07:27:53 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y184si5747832wmg.189.2018.04.05.07.27.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 05 Apr 2018 07:27:52 -0700 (PDT)
Date: Thu, 5 Apr 2018 16:27:49 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v1] kernel/trace:check the val against the available mem
Message-ID: <20180405142749.GL6312@dhcp22.suse.cz>
References: <20180403093245.43e7e77c@gandalf.local.home>
 <20180403135607.GC5501@dhcp22.suse.cz>
 <CAGWkznH-yfAu=fMo1YWU9zo-DomHY8YP=rw447rUTgzvVH4RpQ@mail.gmail.com>
 <20180404062340.GD6312@dhcp22.suse.cz>
 <20180404101149.08f6f881@gandalf.local.home>
 <20180404142329.GI6312@dhcp22.suse.cz>
 <20180404114730.65118279@gandalf.local.home>
 <20180405025841.GA9301@bombadil.infradead.org>
 <CAJWu+oqP64QzvPM6iHtzowek6s4p+3rb7WDXs1z51mwW-9mLbA@mail.gmail.com>
 <20180405142258.GA28128@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180405142258.GA28128@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Joel Fernandes <joelaf@google.com>, Steven Rostedt <rostedt@goodmis.org>, Zhaoyang Huang <huangzhaoyang@gmail.com>, Ingo Molnar <mingo@kernel.org>, LKML <linux-kernel@vger.kernel.org>, kernel-patch-test@lists.linaro.org, Andrew Morton <akpm@linux-foundation.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Vlastimil Babka <vbabka@suse.cz>

On Thu 05-04-18 07:22:58, Matthew Wilcox wrote:
> On Wed, Apr 04, 2018 at 09:12:52PM -0700, Joel Fernandes wrote:
> > On Wed, Apr 4, 2018 at 7:58 PM, Matthew Wilcox <willy@infradead.org> wrote:
> > > On Wed, Apr 04, 2018 at 11:47:30AM -0400, Steven Rostedt wrote:
> > >> I originally was going to remove the RETRY_MAYFAIL, but adding this
> > >> check (at the end of the loop though) appears to have OOM consistently
> > >> kill this task.
> > >>
> > >> I still like to keep RETRY_MAYFAIL, because it wont trigger OOM if
> > >> nothing comes in and tries to do an allocation, but instead will fail
> > >> nicely with -ENOMEM.
> > >
> > > I still don't get why you want RETRY_MAYFAIL.  You know that tries
> > > *harder* to allocate memory than plain GFP_KERNEL does, right?  And
> > > that seems like the exact opposite of what you want.
> > 
> > No. We do want it to try harder but not if its already setup for failure.
> 
> I understand you don't want GFP_NORETRY.  But why is it more important for
> this allocation to succeed than other normal GFP_KERNEL allocations?

I guess they simply want a failure rather than OOM even when they can
shoot themselves into head by using oom_origin. It is still quite ugly
to see OOM report...

-- 
Michal Hocko
SUSE Labs
