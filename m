Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id C18256B0005
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 20:43:07 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id C9AFB3EE0BD
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 09:43:05 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A4C1945DE53
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 09:43:05 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8CCD845DDCF
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 09:43:05 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7CE3BE08008
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 09:43:05 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2E7ABE08001
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 09:43:05 +0900 (JST)
Message-ID: <515CCC8C.5030007@jp.fujitsu.com>
Date: Thu, 04 Apr 2013 09:42:52 +0900
From: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 2/3] fix hugetlb memory check in vma_dump_size()
References: <1365014138-19589-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1365014138-19589-3-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1365014138-19589-3-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

(2013/04/04 3:35), Naoya Horiguchi wrote:
> Documentation/filesystems/proc.txt says about coredump_filter bitmask,
> 
>    Note bit 0-4 doesn't effect any hugetlb memory. hugetlb memory are only
>    effected by bit 5-6.
> 
> However current code can go into the subsequent flag checks of bit 0-4
> for vma(VM_HUGETLB). So this patch inserts 'return' and makes it work
> as written in the document.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: stable@vger.kernel.org
> ---
>   fs/binfmt_elf.c | 1 +
>   1 file changed, 1 insertion(+)
> 
> diff --git v3.9-rc3.orig/fs/binfmt_elf.c v3.9-rc3/fs/binfmt_elf.c
> index 3939829..86af964 100644
> --- v3.9-rc3.orig/fs/binfmt_elf.c
> +++ v3.9-rc3/fs/binfmt_elf.c
> @@ -1137,6 +1137,7 @@ static unsigned long vma_dump_size(struct vm_area_struct *vma,
>   			goto whole;
>   		if (!(vma->vm_flags & VM_SHARED) && FILTER(HUGETLB_PRIVATE))
>   			goto whole;
> +		return 0;
>   	}
>   
>   	/* Do not dump I/O mapped devices or special mappings */
> 

Thanks for splitting this fix. Now it's easier to keep track of this fix.

Reviewed-by: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>

Thanks.
HATAYAMA, Daisuke


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
