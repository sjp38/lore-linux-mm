Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 78D236B004A
	for <linux-mm@kvack.org>; Wed,  6 Oct 2010 21:00:57 -0400 (EDT)
Date: Thu, 7 Oct 2010 09:54:58 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC] Restrict size of page_cgroup->flags
Message-Id: <20101007095458.a992969e.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20101006142314.GG4195@balbir.in.ibm.com>
References: <20101006142314.GG4195@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, containers@lists.linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Wed, 6 Oct 2010 19:53:14 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> I propose restricting page_cgroup.flags to 16 bits. The patch for the
> same is below. Comments?
> 
> 
> Restrict the bits usage in page_cgroup.flags
> 
> From: Balbir Singh <balbir@linux.vnet.ibm.com>
> 
> Restricting the flags helps control growth of the flags unbound.
> Restriciting it to 16 bits gives us the possibility of merging
> cgroup id with flags (atomicity permitting) and saving a whole
> long word in page_cgroup
> 
I agree that reducing the size of page_cgroup would be good and important.
But, wouldn't it be better to remove ->page, if possible ?

Thanks,
Daisuke Nishimura.

> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> ---
> 
>  include/linux/page_cgroup.h |    3 +++
>  mm/page_cgroup.c            |    1 +
>  2 files changed, 4 insertions(+), 0 deletions(-)
> 
> 
> diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
> index 872f6b1..10c37b4 100644
> --- a/include/linux/page_cgroup.h
> +++ b/include/linux/page_cgroup.h
> @@ -44,8 +44,11 @@ enum {
>  	PCG_FILE_WRITEBACK, /* page is under writeback */
>  	PCG_FILE_UNSTABLE_NFS, /* page is NFS unstable */
>  	PCG_MIGRATION, /* under page migration */
> +	PCG_MAX_NR,
>  };
>  
> +#define PCG_MAX_BIT_SIZE	16
> +
>  #define TESTPCGFLAG(uname, lname)			\
>  static inline int PageCgroup##uname(struct page_cgroup *pc)	\
>  	{ return test_bit(PCG_##lname, &pc->flags); }
> diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
> index 5bffada..e16ad2e 100644
> --- a/mm/page_cgroup.c
> +++ b/mm/page_cgroup.c
> @@ -258,6 +258,7 @@ void __init page_cgroup_init(void)
>  	unsigned long pfn;
>  	int fail = 0;
>  
> +	BUILD_BUG_ON(PCG_MAX_NR >= PCG_MAX_BIT_SIZE);
>  	if (mem_cgroup_disabled())
>  		return;
>  
> 
> -- 
> 	Three Cheers,
> 	Balbir
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
