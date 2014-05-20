Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id 1ECB46B0035
	for <linux-mm@kvack.org>; Tue, 20 May 2014 13:55:17 -0400 (EDT)
Received: by mail-qg0-f48.google.com with SMTP id i50so1326762qgf.21
        for <linux-mm@kvack.org>; Tue, 20 May 2014 10:55:16 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id k9si11061810qan.219.2014.05.20.10.55.16
        for <linux-mm@kvack.org>;
        Tue, 20 May 2014 10:55:16 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 1/2] memory-failure: Send right signal code to correct thread
Date: Tue, 20 May 2014 13:54:48 -0400
Message-Id: <537b9704.4961e00a.583e.4734SMTPIN_ADDED_BROKEN@mx.google.com>
In-Reply-To: <eb791998a8ada97b204dddf2719a359149e9ae31.1400607328.git.tony.luck@intel.com>
References: <cover.1400607328.git.tony.luck@intel.com> <eb791998a8ada97b204dddf2719a359149e9ae31.1400607328.git.tony.luck@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>, bp@suse.de, gong.chen@linux.jf.intel.com

On Tue, May 20, 2014 at 09:28:00AM -0700, Tony Luck wrote:
> When a thread in a multi-threaded application hits a machine
> check because of an uncorrectable error in memory - we want to
> send the SIGBUS with si.si_code = BUS_MCEERR_AR to that thread.
> Currently we fail to do that if the active thread is not the
> primary thread in the process. collect_procs() just finds primary
> threads and this test:
> 	if ((flags & MF_ACTION_REQUIRED) && t == current) {
> will see that the thread we found isn't the current thread
> and so send a si.si_code = BUS_MCEERR_AO to the primary
> (and nothing to the active thread at this time).
> 
> We can fix this by checking whether "current" shares the same
> mm with the process that collect_procs() said owned the page.
> If so, we send the SIGBUS to current (with code BUS_MCEERR_AR).
> 
> Reported-by: Otto Bruggeman <otto.g.bruggeman@intel.com>
> Signed-off-by: Tony Luck <tony.luck@intel.com>

Looks good to me, thank you.
Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

and I think this is worth going into stable trees.

Naoya

> ---
>  mm/memory-failure.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index 35ef28acf137..642c8434b166 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -204,9 +204,9 @@ static int kill_proc(struct task_struct *t, unsigned long addr, int trapno,
>  #endif
>  	si.si_addr_lsb = compound_order(compound_head(page)) + PAGE_SHIFT;
>  
> -	if ((flags & MF_ACTION_REQUIRED) && t == current) {
> +	if ((flags & MF_ACTION_REQUIRED) && t->mm == current->mm) {
>  		si.si_code = BUS_MCEERR_AR;
> -		ret = force_sig_info(SIGBUS, &si, t);
> +		ret = force_sig_info(SIGBUS, &si, current);
>  	} else {
>  		/*
>  		 * Don't use force here, it's convenient if the signal
> -- 
> 1.8.4.1
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
