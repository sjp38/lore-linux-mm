Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id CA9C46B0006
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 09:01:07 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id d17so2017820wrc.9
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 06:01:07 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e123si9559474wma.186.2018.01.30.06.01.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 30 Jan 2018 06:01:06 -0800 (PST)
Date: Tue, 30 Jan 2018 15:01:04 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [netfilter-core] kernel panic: Out of memory and no killable
 processes... (2)
Message-ID: <20180130140104.GE21609@dhcp22.suse.cz>
References: <20180129072357.GD5906@breakpoint.cc>
 <20180129082649.sysf57wlp7i7ltb2@node.shutemov.name>
 <20180129165722.GF5906@breakpoint.cc>
 <20180129182811.fze4vrb5zd5cojmr@node.shutemov.name>
 <20180129223522.GG5906@breakpoint.cc>
 <20180130075226.GL21609@dhcp22.suse.cz>
 <20180130081127.GH5906@breakpoint.cc>
 <20180130082817.cbax5qj4mxancx4b@node.shutemov.name>
 <CACT4Y+bFKwoxopr1dwnc7OHUoHy28ksVguqtMY6tD=aRh-7LyQ@mail.gmail.com>
 <20180130095739.GV21609@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180130095739.GV21609@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Florian Westphal <fw@strlen.de>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, David Miller <davem@davemloft.net>, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, netdev <netdev@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Yang Shi <yang.s@alibaba-inc.com>, syzkaller-bugs@googlegroups.com, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@kernel.org>, Linux-MM <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, guro@fb.com, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue 30-01-18 10:57:39, Michal Hocko wrote:
> On Tue 30-01-18 10:02:34, Dmitry Vyukov wrote:
> > On Tue, Jan 30, 2018 at 9:28 AM, Kirill A. Shutemov
> > <kirill@shutemov.name> wrote:
> > > On Tue, Jan 30, 2018 at 09:11:27AM +0100, Florian Westphal wrote:
> > >> Michal Hocko <mhocko@kernel.org> wrote:
> > >> > On Mon 29-01-18 23:35:22, Florian Westphal wrote:
> > >> > > Kirill A. Shutemov <kirill@shutemov.name> wrote:
> > >> > [...]
> > >> > > > I hate what I'm saying, but I guess we need some tunable here.
> > >> > > > Not sure what exactly.
> > >> > >
> > >> > > Would memcg help?
> > >> >
> > >> > That really depends. I would have to check whether vmalloc path obeys
> > >> > __GFP_ACCOUNT (I suspect it does except for page tables allocations but
> > >> > that shouldn't be a big deal). But then the other potential problem is
> > >> > the life time of the xt_table_info (or other potentially large) data
> > >> > structures. Are they bound to any process life time.
> > >>
> > >> No.
> > >
> > > Well, IIUC they bound to net namespace life time, so killing all
> > > proccesses in the namespace would help to get memory back. :)
> > 
> > ... unless the namespace is mounted into file system.
> > 
> > Let's start with NOWARN as that's what kernel generally uses for
> > allocations with user-controllable size. ENOMEM is roughly as
> > informative as the WARNING message in this case.
> 
> You want __GFP_NORETRY but that is not _fully_ supported by kvmalloc
> right now. More specifically kvmalloc doesn't guanratee that the request
> will not trigger the OOM killer (like regular __GFP_NORETRY). This is
> because of internal vmalloc restrictions. If you are however OK to
> simply bail out in most cases then __GFP_NORETRY should work reasonably
> fine.
> 
> > I think we also need to consider setting up memory cgroup for
> > syzkaller test processes (we do RLIMIT_AS, but that's weak).
> 
> Well, this is not about syzkaller, it merely pointed out a potential
> DoS... And that has to be addressed somehow.

So how about this?
---
