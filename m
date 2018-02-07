Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3A5316B0353
	for <linux-mm@kvack.org>; Wed,  7 Feb 2018 12:44:45 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id r82so1081230wme.0
        for <linux-mm@kvack.org>; Wed, 07 Feb 2018 09:44:45 -0800 (PST)
Received: from mail.us.es (mail.us.es. [193.147.175.20])
        by mx.google.com with ESMTPS id k130si1581316wmg.169.2018.02.07.09.44.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Feb 2018 09:44:43 -0800 (PST)
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 239A73066AC
	for <linux-mm@kvack.org>; Wed,  7 Feb 2018 18:44:43 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 0FFB6DA786
	for <linux-mm@kvack.org>; Wed,  7 Feb 2018 18:44:43 +0100 (CET)
Date: Wed, 7 Feb 2018 18:44:39 +0100
From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [netfilter-core] kernel panic: Out of memory and no killable
 processes... (2)
Message-ID: <20180207174439.esm4djxb4trbotne@salvia>
References: <20180129182811.fze4vrb5zd5cojmr@node.shutemov.name>
 <20180129223522.GG5906@breakpoint.cc>
 <20180130075226.GL21609@dhcp22.suse.cz>
 <20180130081127.GH5906@breakpoint.cc>
 <20180130082817.cbax5qj4mxancx4b@node.shutemov.name>
 <CACT4Y+bFKwoxopr1dwnc7OHUoHy28ksVguqtMY6tD=aRh-7LyQ@mail.gmail.com>
 <20180130095739.GV21609@dhcp22.suse.cz>
 <20180130140104.GE21609@dhcp22.suse.cz>
 <20180130112745.934883e37e696ab7f875a385@linux-foundation.org>
 <20180131081916.GO21609@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180131081916.GO21609@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Yang Shi <yang.s@alibaba-inc.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, netdev <netdev@vger.kernel.org>, guro@fb.com, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@kernel.org>, syzkaller-bugs@googlegroups.com, Linux-MM <linux-mm@kvack.org>, coreteam@netfilter.org, netfilter-devel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, David Miller <davem@davemloft.net>, Dmitry Vyukov <dvyukov@google.com>

Hi,

On Wed, Jan 31, 2018 at 09:19:16AM +0100, Michal Hocko wrote:
[...]
> Yeah, we do not BUG but rather fail instead. See __vmalloc_node_range.
> My excavation tools pointed me to "VM: Rework vmalloc code to support mapping of arbitray pages"
> by Christoph back in 2002. So yes, we can safely remove it finally. Se
> below.
> 
> 
> From 8d52e1d939d101b0dafed6ae5c3c1376183e65bb Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Wed, 31 Jan 2018 09:16:56 +0100
> Subject: [PATCH] net/netfilter/x_tables.c: remove size check
> 
> Back in 2002 vmalloc used to BUG on too large sizes. We are much better
> behaved these days and vmalloc simply returns NULL for those. Remove
> the check as it simply not needed and the comment even misleading.
> 
> Suggested-by: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  net/netfilter/x_tables.c | 4 ----
>  1 file changed, 4 deletions(-)
> 
> diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
> index b55ec5aa51a6..48a6ff620493 100644
> --- a/net/netfilter/x_tables.c
> +++ b/net/netfilter/x_tables.c
> @@ -999,10 +999,6 @@ struct xt_table_info *xt_alloc_table_info(unsigned int size)
>  	if (sz < sizeof(*info))
>  		return NULL;
>  
> -	/* Pedantry: prevent them from hitting BUG() in vmalloc.c --RR */
> -	if ((SMP_ALIGN(size) >> PAGE_SHIFT) + 2 > totalram_pages)
> -		return NULL;
> -
>  	/* __GFP_NORETRY is not fully supported by kvmalloc but it should
>  	 * work reasonably well if sz is too large and bail out rather
>  	 * than shoot all processes down before realizing there is nothing

Patchwork didn't catch this patch for some reason, would you mind to
resend?

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
