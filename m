Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id A4C746B03A6
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 02:20:08 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id e5so44387518pgk.1
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 23:20:08 -0800 (PST)
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id q77si2421330pfi.41.2017.03.07.23.20.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Mar 2017 23:20:07 -0800 (PST)
Subject: Re: [RFC 08/11] mm: make ttu's return boolean
References: <1488436765-32350-1-git-send-email-minchan@kernel.org>
 <1488436765-32350-9-git-send-email-minchan@kernel.org>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <70f60783-e098-c1a9-11b4-544530bcd809@nvidia.com>
Date: Tue, 7 Mar 2017 23:13:26 -0800
MIME-Version: 1.0
In-Reply-To: <1488436765-32350-9-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: kernel-team@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On 03/01/2017 10:39 PM, Minchan Kim wrote:
> try_to_unmap returns SWAP_SUCCESS or SWAP_FAIL so it's suitable for
> boolean return. This patch changes it.

Hi Minchan,

So, up until this patch, I definitely like the cleanup, because as you observed, the 
return values didn't need so many different values. However, at this point, I think 
you should stop, and keep the SWAP_SUCCESS and SWAP_FAIL (or maybe even rename them 
to UNMAP_* or TTU_RESULT_*, to match their functions' names better), because 
removing them makes the code considerably less readable.

And since this is billed as a cleanup, we care here, even though this is a minor 
point. :)

Bool return values are sometimes perfect, such as when asking a question:

    bool mode_changed = needs_modeset(crtc_state);

The above is very nice. However, for returning success or failure, bools are not as 
nice, because *usually* success == true, except when you use the errno-based system, 
in which success == 0 (which would translate to false, if you mistakenly treated it 
as a bool). That leads to the reader having to remember which system is in use, 
usually with no visual cues to help.

>
[...]
>  	if (PageSwapCache(p)) {
> @@ -971,7 +971,7 @@ static int hwpoison_user_mappings(struct page *p, unsigned long pfn,
>  		collect_procs(hpage, &tokill, flags & MF_ACTION_REQUIRED);
>
>  	ret = try_to_unmap(hpage, ttu);
> -	if (ret != SWAP_SUCCESS)
> +	if (!ret)
>  		pr_err("Memory failure: %#lx: failed to unmap page (mapcount=%d)\n",
>  		       pfn, page_mapcount(hpage));
>
> @@ -986,8 +986,7 @@ static int hwpoison_user_mappings(struct page *p, unsigned long pfn,
>  	 * any accesses to the poisoned memory.
>  	 */
>  	forcekill = PageDirty(hpage) || (flags & MF_MUST_KILL);
> -	kill_procs(&tokill, forcekill, trapno,
> -		      ret != SWAP_SUCCESS, p, pfn, flags);
> +	kill_procs(&tokill, forcekill, trapno, !ret , p, pfn, flags);

The kill_procs() invocation was a little more readable before.

>
[...]
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 170c61f..e4b74f1 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -966,7 +966,6 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  		int may_enter_fs;
>  		enum page_references references = PAGEREF_RECLAIM_CLEAN;
>  		bool dirty, writeback;
> -		int ret = SWAP_SUCCESS;
>
>  		cond_resched();
>
> @@ -1139,13 +1138,9 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  		 * processes. Try to unmap it here.
>  		 */
>  		if (page_mapped(page)) {
> -			switch (ret = try_to_unmap(page,
> -				ttu_flags | TTU_BATCH_FLUSH)) {
> -			case SWAP_FAIL:

Again: the SWAP_FAIL makes it crystal clear which case we're in.

I also wonder if UNMAP_FAIL or TTU_RESULT_FAIL is a better name?

thanks,
John Hubbard
NVIDIA

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
