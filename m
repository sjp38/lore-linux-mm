Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id B12306B0007
	for <linux-mm@kvack.org>; Mon, 29 Jan 2018 17:38:33 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id g13so6763332wrh.19
        for <linux-mm@kvack.org>; Mon, 29 Jan 2018 14:38:33 -0800 (PST)
Received: from Chamillionaire.breakpoint.cc (Chamillionaire.breakpoint.cc. [2a01:7a0:2:106d:670::1])
        by mx.google.com with ESMTPS id y4si8173013wmy.148.2018.01.29.14.38.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jan 2018 14:38:32 -0800 (PST)
Date: Mon, 29 Jan 2018 23:35:22 +0100
From: Florian Westphal <fw@strlen.de>
Subject: Re: [netfilter-core] kernel panic: Out of memory and no killable
 processes... (2)
Message-ID: <20180129223522.GG5906@breakpoint.cc>
References: <001a1144b0caee2e8c0563d9de0a@google.com>
 <201801290020.w0T0KK8V015938@www262.sakura.ne.jp>
 <20180129072357.GD5906@breakpoint.cc>
 <20180129082649.sysf57wlp7i7ltb2@node.shutemov.name>
 <20180129165722.GF5906@breakpoint.cc>
 <20180129182811.fze4vrb5zd5cojmr@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180129182811.fze4vrb5zd5cojmr@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Florian Westphal <fw@strlen.de>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, davem@davemloft.net, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, netdev@vger.kernel.org, aarcange@redhat.com, yang.s@alibaba-inc.com, mhocko@suse.com, syzkaller-bugs@googlegroups.com, linux-kernel@vger.kernel.org, mingo@kernel.org, linux-mm@kvack.org, rientjes@google.com, akpm@linux-foundation.org, guro@fb.com, kirill.shutemov@linux.intel.com

Kirill A. Shutemov <kirill@shutemov.name> wrote:
> On Mon, Jan 29, 2018 at 05:57:22PM +0100, Florian Westphal wrote:
> > Kirill A. Shutemov <kirill@shutemov.name> wrote:
> > > On Mon, Jan 29, 2018 at 08:23:57AM +0100, Florian Westphal wrote:
> > > > > vmalloc() once became killable by commit 5d17a73a2ebeb8d1 ("vmalloc: back
> > > > > off when the current task is killed") but then became unkillable by commit
> > > > > b8c8a338f75e052d ("Revert "vmalloc: back off when the current task is
> > > > > killed""). Therefore, we can't handle this problem from MM side.
> > > > > Please consider adding some limit from networking side.
> > > > 
> > > > I don't know what "some limit" would be.  I would prefer if there was
> > > > a way to supress OOM Killer in first place so we can just -ENOMEM user.
> > > 
> > > Just supressing OOM kill is a bad idea. We still leave a way to allocate
> > > arbitrary large buffer in kernel.
> > 
> > Isn't that what we do everywhere in network stack?
> > 
> > I think we should try to allocate whatever amount of memory is needed
> > for the given xtables ruleset, given that is what admin requested us to do.
> 
> Is it correct that "admin" in this case is root in random container?

Yes.

> I mean, can we get access to it with CLONE_NEWUSER|CLONE_NEWNET?

Yes.

> This can be fun.

Do we prevent "admin in random container" to insert 2m ipv6 routes
(alternatively: ipsec tunnels, interfaces etc etc)?

> > I also would not know what limit is sane -- I've seen setups with as much
> > as 100k iptables rules, and that was 5 years ago.
> > 
> > And even if we add a "Xk rules" limit, it might be too much for
> > low-memory systems, or not enough for whatever other use case there
> > might be.
> 
> I hate what I'm saying, but I guess we need some tunable here.
> Not sure what exactly.

Would memcg help?

(I don't buy the "run untrusted binaries on linux is safe" thing, so
 I would not know).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
