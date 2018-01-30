Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 602F36B0005
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 14:27:50 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id w102so8847653wrb.21
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 11:27:50 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id a1si13691499wrf.227.2018.01.30.11.27.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jan 2018 11:27:49 -0800 (PST)
Date: Tue, 30 Jan 2018 11:27:45 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [netfilter-core] kernel panic: Out of memory and no killable
 processes... (2)
Message-Id: <20180130112745.934883e37e696ab7f875a385@linux-foundation.org>
In-Reply-To: <20180130140104.GE21609@dhcp22.suse.cz>
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
	<20180130140104.GE21609@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Dmitry Vyukov <dvyukov@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Florian Westphal <fw@strlen.de>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, David Miller <davem@davemloft.net>, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, netdev <netdev@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Yang Shi <yang.s@alibaba-inc.com>, syzkaller-bugs@googlegroups.com, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@kernel.org>, Linux-MM <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, guro@fb.com, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue, 30 Jan 2018 15:01:04 +0100 Michal Hocko <mhocko@kernel.org> wrote:

> > Well, this is not about syzkaller, it merely pointed out a potential
> > DoS... And that has to be addressed somehow.
> 
> So how about this?
> ---

argh ;)

> >From d48e950f1b04f234b57b9e34c363bdcfec10aeee Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Tue, 30 Jan 2018 14:51:07 +0100
> Subject: [PATCH] net/netfilter/x_tables.c: make allocation less aggressive
> 
> syzbot has noticed that xt_alloc_table_info can allocate a lot of
> memory. This is an admin only interface but an admin in a namespace
> is sufficient as well. eacd86ca3b03 ("net/netfilter/x_tables.c: use
> kvmalloc() in xt_alloc_table_info()") has changed the opencoded
> kmalloc->vmalloc fallback into kvmalloc. It has dropped __GFP_NORETRY on
> the way because vmalloc has simply never fully supported __GFP_NORETRY
> semantic. This is still the case because e.g. page tables backing the
> vmalloc area are hardcoded GFP_KERNEL.
> 
> Revert back to __GFP_NORETRY as a poors man defence against excessively
> large allocation request here. We will not rule out the OOM killer
> completely but __GFP_NORETRY should at least stop the large request
> in most cases.
> 
> Fixes: eacd86ca3b03 ("net/netfilter/x_tables.c: use kvmalloc() in xt_alloc_table_info()")
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  net/netfilter/x_tables.c | 8 +++++++-
>  1 file changed, 7 insertions(+), 1 deletion(-)
> 
> diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
> index d8571f414208..a5f5c29bcbdc 100644
> --- a/net/netfilter/x_tables.c
> +++ b/net/netfilter/x_tables.c
> @@ -1003,7 +1003,13 @@ struct xt_table_info *xt_alloc_table_info(unsigned int size)
>  	if ((SMP_ALIGN(size) >> PAGE_SHIFT) + 2 > totalram_pages)
>  		return NULL;

offtopic: preceding comment here is "prevent them from hitting BUG() in
vmalloc.c".  I suspect this is ancient code and vmalloc sure as heck
shouldn't go BUG with this input.  And it should be using `sz' ;)

So I suspect and hope that this code can be removed.  If not, let's fix
vmalloc!

> -	info = kvmalloc(sz, GFP_KERNEL);
> +	/*
> +	 * __GFP_NORETRY is not fully supported by kvmalloc but it should
> +	 * work reasonably well if sz is too large and bail out rather
> +	 * than shoot all processes down before realizing there is nothing
> +	 * more to reclaim.
> +	 */
> +	info = kvmalloc(sz, GFP_KERNEL | __GFP_NORETRY);
>  	if (!info)
>  		return NULL;

checkpatch sayeth

networking block comments don't use an empty /* line, use /* Comment...

So I'll do that and shall scoot the patch Davewards.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
