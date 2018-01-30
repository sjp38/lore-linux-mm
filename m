Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5D7D56B0005
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 02:52:31 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id y18so7384566wrh.12
        for <linux-mm@kvack.org>; Mon, 29 Jan 2018 23:52:31 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c6si8795013wme.13.2018.01.29.23.52.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 29 Jan 2018 23:52:30 -0800 (PST)
Date: Tue, 30 Jan 2018 08:52:26 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [netfilter-core] kernel panic: Out of memory and no killable
 processes... (2)
Message-ID: <20180130075226.GL21609@dhcp22.suse.cz>
References: <001a1144b0caee2e8c0563d9de0a@google.com>
 <201801290020.w0T0KK8V015938@www262.sakura.ne.jp>
 <20180129072357.GD5906@breakpoint.cc>
 <20180129082649.sysf57wlp7i7ltb2@node.shutemov.name>
 <20180129165722.GF5906@breakpoint.cc>
 <20180129182811.fze4vrb5zd5cojmr@node.shutemov.name>
 <20180129223522.GG5906@breakpoint.cc>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180129223522.GG5906@breakpoint.cc>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Westphal <fw@strlen.de>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, davem@davemloft.net, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, netdev@vger.kernel.org, aarcange@redhat.com, yang.s@alibaba-inc.com, syzkaller-bugs@googlegroups.com, linux-kernel@vger.kernel.org, mingo@kernel.org, linux-mm@kvack.org, rientjes@google.com, akpm@linux-foundation.org, guro@fb.com, kirill.shutemov@linux.intel.com

On Mon 29-01-18 23:35:22, Florian Westphal wrote:
> Kirill A. Shutemov <kirill@shutemov.name> wrote:
[...]
> > I hate what I'm saying, but I guess we need some tunable here.
> > Not sure what exactly.
> 
> Would memcg help?

That really depends. I would have to check whether vmalloc path obeys
__GFP_ACCOUNT (I suspect it does except for page tables allocations but
that shouldn't be a big deal). But then the other potential problem is
the life time of the xt_table_info (or other potentially large) data
structures. Are they bound to any process life time. Because if they are
not then the OOM killer will not help. The OOM panic earlier in this
thread suggests it doesn't because the test case managed to eat all the
available memory and killed all the eligible tasks which didn't help.

So in some sense the memcg would help to stop the excessive allocation,
but it wouldn't resolve it other than kill all tasks in the affected
memcg/container. Whether this is sufficient or not, I dunno. It sounds
quite suboptimal to me. But it is true this would be less tricky then
adding a global knob...
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
