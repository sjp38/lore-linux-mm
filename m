Date: Mon, 16 Jun 2003 12:13:22 +0530
From: Suparna Bhattacharya <suparna@in.ibm.com>
Subject: Re: use_mm/unuse_mm correctness
Message-ID: <20030616121322.A10735@in.ibm.com>
Reply-To: suparna@in.ibm.com
References: <20030616092944.A10463@in.ibm.com> <Pine.LNX.4.44.0306160714360.1524-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0306160714360.1524-100000@localhost.localdomain>; from hugh@veritas.com on Mon, Jun 16, 2003 at 07:16:12AM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

get_cpu() would be the right thing to do - thanks for 
pointing that out.

However, in the aio case, use_mm and unuse_mm are called 
only by workqueue threads, so there shouldn't be any 
migration even if a pre-empt occurs (cpus_allowed is fixed 
to a particular cpu), should it ?

Regards
Suparna 

On Mon, Jun 16, 2003 at 07:16:12AM +0100, Hugh Dickins wrote:
> On Mon, 16 Jun 2003, Suparna Bhattacharya wrote:
> > Can anyone spot a problem in the following routines ?
> 
> If CONFIG_PREEMPT=y, then this might help:
> 
> --- 2.5.71-mm1/fs/aio.c	Sun Jun 15 12:36:09 2003
> +++ linux/fs/aio.c	Mon Jun 16 07:05:53 2003
> @@ -582,7 +582,8 @@ void unuse_mm(struct mm_struct *mm)
>  {
>  	current->mm = NULL;
>  	/* active_mm is still 'mm' */
> -	enter_lazy_tlb(mm, current, smp_processor_id());
> +	enter_lazy_tlb(mm, current, get_cpu());
> +	put_cpu();
>  }
>  
>  /*
> 

-- 
Suparna Bhattacharya (suparna@in.ibm.com)
Linux Technology Center
IBM Software Labs, India

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
