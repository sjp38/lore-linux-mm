Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id A45816B0071
	for <linux-mm@kvack.org>; Sun, 21 Nov 2010 22:06:43 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAM36d7A016678
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 22 Nov 2010 12:06:39 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id DCDBA45DE51
	for <linux-mm@kvack.org>; Mon, 22 Nov 2010 12:06:38 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B1E4C45DE4E
	for <linux-mm@kvack.org>; Mon, 22 Nov 2010 12:06:38 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9A7FEE08001
	for <linux-mm@kvack.org>; Mon, 22 Nov 2010 12:06:38 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 572301DB803A
	for <linux-mm@kvack.org>; Mon, 22 Nov 2010 12:06:38 +0900 (JST)
Date: Mon, 22 Nov 2010 12:01:02 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH] pagemap: set pagemap walk limit to PMD boundary
Message-Id: <20101122120102.e0e76373.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1290157665-17215-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1290157665-17215-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

On Fri, 19 Nov 2010 18:07:45 +0900
Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> Currently one pagemap_read() call walks in PAGEMAP_WALK_SIZE bytes
> (== 512 pages.)  But there is a corner case where walk_pmd_range()
> accidentally runs over a VMA associated with a hugetlbfs file.
> 
> For example, when a process has mappings to VMAs as shown below:
> 
>   # cat /proc/<pid>/maps
>   ...
>   3a58f6d000-3a58f72000 rw-p 00000000 00:00 0
>   7fbd51853000-7fbd51855000 rw-p 00000000 00:00 0
>   7fbd5186c000-7fbd5186e000 rw-p 00000000 00:00 0
>   7fbd51a00000-7fbd51c00000 rw-s 00000000 00:12 8614   /hugepages/test
> 
> then pagemap_read() goes into walk_pmd_range() path and walks in the range
> 0x7fbd51853000-0x7fbd51a53000, but the hugetlbfs VMA should be handled
> by walk_hugetlb_range(). Otherwise PMD for the hugepage is considered bad
> and cleared, which causes undesirable results.
> 
> This patch fixes it by separating pagemap walk range into one PMD.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Matt Mackall <mpm@selenic.com>
> ---
>  fs/proc/task_mmu.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index da6b01d..c126c83 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -706,6 +706,7 @@ static int pagemap_hugetlb_range(pte_t *pte, unsigned long hmask,
>   * skip over unmapped regions.
>   */
>  #define PAGEMAP_WALK_SIZE	(PMD_SIZE)
> +#define PAGEMAP_WALK_MASK	(PMD_MASK)
>  static ssize_t pagemap_read(struct file *file, char __user *buf,
>  			    size_t count, loff_t *ppos)
>  {
> @@ -776,7 +777,7 @@ static ssize_t pagemap_read(struct file *file, char __user *buf,
>  		unsigned long end;
>  
>  		pm.pos = 0;
> -		end = start_vaddr + PAGEMAP_WALK_SIZE;
> +		end = (start_vaddr + PAGEMAP_WALK_SIZE) & PAGEMAP_WALK_MASK;
>  		/* overflow ? */
>  		if (end < start_vaddr || end > end_vaddr)
>  			end = end_vaddr;

Ack. 

But ALIGN() can't be used ?

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
