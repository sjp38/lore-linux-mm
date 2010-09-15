Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id F34746B0047
	for <linux-mm@kvack.org>; Tue, 14 Sep 2010 20:26:40 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o8F0Qb9m010595
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 15 Sep 2010 09:26:38 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7B9AB45DE54
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 09:26:37 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5284245DE4C
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 09:26:37 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3186AE38001
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 09:26:37 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id E6D7F1DB8013
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 09:26:36 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH v2] After swapout/swapin private dirty mappings are reported clean in smaps
In-Reply-To: <201009142244.59080.knikanth@suse.de>
References: <201009142242.29245.knikanth@suse.de> <201009142244.59080.knikanth@suse.de>
Message-Id: <20100915092504.C9DC.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 15 Sep 2010 09:26:36 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Nikanth Karthikesan <knikanth@suse.de>
Cc: kosaki.motohiro@jp.fujitsu.com, Richard Guenther <rguenther@suse.de>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, balbir@linux.vnet.ibm.com, Michael Matz <matz@novell.com>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 439fc1f..06fc468 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -368,7 +368,11 @@ static int smaps_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
>  				mss->shared_clean += PAGE_SIZE;
>  			mss->pss += (PAGE_SIZE << PSS_SHIFT) / mapcount;
>  		} else {
> -			if (pte_dirty(ptent))
> +			/*
> +			 * File-backed pages, now anonymous are dirty
> +			 * with respect to the file.
> +			 */
> +			if (pte_dirty(ptent) || (vma->vm_file && PageAnon(page)))
>  				mss->private_dirty += PAGE_SIZE;
>  			else
>  				mss->private_clean += PAGE_SIZE;

This is risky than v1. number of dirties are used a lot of application. 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
