Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6CD566B0005
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 04:02:56 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id o28so7209186pgn.6
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 01:02:56 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h132sor4745879pfe.34.2018.01.30.01.02.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Jan 2018 01:02:55 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180130082817.cbax5qj4mxancx4b@node.shutemov.name>
References: <001a1144b0caee2e8c0563d9de0a@google.com> <201801290020.w0T0KK8V015938@www262.sakura.ne.jp>
 <20180129072357.GD5906@breakpoint.cc> <20180129082649.sysf57wlp7i7ltb2@node.shutemov.name>
 <20180129165722.GF5906@breakpoint.cc> <20180129182811.fze4vrb5zd5cojmr@node.shutemov.name>
 <20180129223522.GG5906@breakpoint.cc> <20180130075226.GL21609@dhcp22.suse.cz>
 <20180130081127.GH5906@breakpoint.cc> <20180130082817.cbax5qj4mxancx4b@node.shutemov.name>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 30 Jan 2018 10:02:34 +0100
Message-ID: <CACT4Y+bFKwoxopr1dwnc7OHUoHy28ksVguqtMY6tD=aRh-7LyQ@mail.gmail.com>
Subject: Re: [netfilter-core] kernel panic: Out of memory and no killable
 processes... (2)
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Florian Westphal <fw@strlen.de>, Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, David Miller <davem@davemloft.net>, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, netdev <netdev@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Yang Shi <yang.s@alibaba-inc.com>, syzkaller-bugs@googlegroups.com, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@kernel.org>, Linux-MM <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, guro@fb.com, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue, Jan 30, 2018 at 9:28 AM, Kirill A. Shutemov
<kirill@shutemov.name> wrote:
> On Tue, Jan 30, 2018 at 09:11:27AM +0100, Florian Westphal wrote:
>> Michal Hocko <mhocko@kernel.org> wrote:
>> > On Mon 29-01-18 23:35:22, Florian Westphal wrote:
>> > > Kirill A. Shutemov <kirill@shutemov.name> wrote:
>> > [...]
>> > > > I hate what I'm saying, but I guess we need some tunable here.
>> > > > Not sure what exactly.
>> > >
>> > > Would memcg help?
>> >
>> > That really depends. I would have to check whether vmalloc path obeys
>> > __GFP_ACCOUNT (I suspect it does except for page tables allocations but
>> > that shouldn't be a big deal). But then the other potential problem is
>> > the life time of the xt_table_info (or other potentially large) data
>> > structures. Are they bound to any process life time.
>>
>> No.
>
> Well, IIUC they bound to net namespace life time, so killing all
> proccesses in the namespace would help to get memory back. :)

... unless the namespace is mounted into file system.

Let's start with NOWARN as that's what kernel generally uses for
allocations with user-controllable size. ENOMEM is roughly as
informative as the WARNING message in this case.

I think we also need to consider setting up memory cgroup for
syzkaller test processes (we do RLIMIT_AS, but that's weak).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
