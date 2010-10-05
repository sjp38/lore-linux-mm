Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 1E42B6B0047
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 02:25:52 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o956Pn5o026600
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 5 Oct 2010 15:25:49 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id F0C5D45DE51
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 15:25:48 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B407F45DE4F
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 15:25:48 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8DD261DB8055
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 15:25:48 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4ACB61DB804E
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 15:25:48 +0900 (JST)
Date: Tue, 5 Oct 2010 15:20:28 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 01/10] memcg: add page_cgroup flags for dirty page
 tracking
Message-Id: <20101005152028.32c8c5ba.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1286175485-30643-2-git-send-email-gthelen@google.com>
References: <1286175485-30643-1-git-send-email-gthelen@google.com>
	<1286175485-30643-2-git-send-email-gthelen@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Sun,  3 Oct 2010 23:57:56 -0700
Greg Thelen <gthelen@google.com> wrote:

> Add additional flags to page_cgroup to track dirty pages
> within a mem_cgroup.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: Andrea Righi <arighi@develer.com>
> Signed-off-by: Greg Thelen <gthelen@google.com>

Ack...oh, but it seems I've signed. Thanks.
-Kame

> ---
>  include/linux/page_cgroup.h |   23 +++++++++++++++++++++++
>  1 files changed, 23 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
> index 5bb13b3..b59c298 100644
> --- a/include/linux/page_cgroup.h
> +++ b/include/linux/page_cgroup.h
> @@ -40,6 +40,9 @@ enum {
>  	PCG_USED, /* this object is in use. */
>  	PCG_ACCT_LRU, /* page has been accounted for */
>  	PCG_FILE_MAPPED, /* page is accounted as "mapped" */
> +	PCG_FILE_DIRTY, /* page is dirty */
> +	PCG_FILE_WRITEBACK, /* page is under writeback */
> +	PCG_FILE_UNSTABLE_NFS, /* page is NFS unstable */
>  	PCG_MIGRATION, /* under page migration */
>  };
>  
> @@ -59,6 +62,10 @@ static inline void ClearPageCgroup##uname(struct page_cgroup *pc)	\
>  static inline int TestClearPageCgroup##uname(struct page_cgroup *pc)	\
>  	{ return test_and_clear_bit(PCG_##lname, &pc->flags);  }
>  
> +#define TESTSETPCGFLAG(uname, lname)			\
> +static inline int TestSetPageCgroup##uname(struct page_cgroup *pc)	\
> +	{ return test_and_set_bit(PCG_##lname, &pc->flags);  }
> +
>  TESTPCGFLAG(Locked, LOCK)
>  
>  /* Cache flag is set only once (at allocation) */
> @@ -80,6 +87,22 @@ SETPCGFLAG(FileMapped, FILE_MAPPED)
>  CLEARPCGFLAG(FileMapped, FILE_MAPPED)
>  TESTPCGFLAG(FileMapped, FILE_MAPPED)
>  
> +SETPCGFLAG(FileDirty, FILE_DIRTY)
> +CLEARPCGFLAG(FileDirty, FILE_DIRTY)
> +TESTPCGFLAG(FileDirty, FILE_DIRTY)
> +TESTCLEARPCGFLAG(FileDirty, FILE_DIRTY)
> +TESTSETPCGFLAG(FileDirty, FILE_DIRTY)
> +
> +SETPCGFLAG(FileWriteback, FILE_WRITEBACK)
> +CLEARPCGFLAG(FileWriteback, FILE_WRITEBACK)
> +TESTPCGFLAG(FileWriteback, FILE_WRITEBACK)
> +
> +SETPCGFLAG(FileUnstableNFS, FILE_UNSTABLE_NFS)
> +CLEARPCGFLAG(FileUnstableNFS, FILE_UNSTABLE_NFS)
> +TESTPCGFLAG(FileUnstableNFS, FILE_UNSTABLE_NFS)
> +TESTCLEARPCGFLAG(FileUnstableNFS, FILE_UNSTABLE_NFS)
> +TESTSETPCGFLAG(FileUnstableNFS, FILE_UNSTABLE_NFS)
> +
>  SETPCGFLAG(Migration, MIGRATION)
>  CLEARPCGFLAG(Migration, MIGRATION)
>  TESTPCGFLAG(Migration, MIGRATION)
> -- 
> 1.7.1
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
