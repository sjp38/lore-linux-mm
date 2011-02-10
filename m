Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id F3B738D0039
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 14:32:53 -0500 (EST)
Received: from d01dlp02.pok.ibm.com (d01dlp02.pok.ibm.com [9.56.224.85])
	by e9.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p1AJ7YZa010131
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 14:07:37 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id EB7FA4DE8040
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 14:31:59 -0500 (EST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p1AJWpBF475546
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 14:32:51 -0500
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p1AJWoih009273
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 12:32:50 -0700
Subject: Re: [PATCH 4/5] teach smaps_pte_range() about THP pmds
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20110210180801.GA3347@random.random>
References: <20110209195406.B9F23C9F@kernel>
	 <20110209195411.816D55A7@kernel>  <20110210180801.GA3347@random.random>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Thu, 10 Feb 2011 11:32:48 -0800
Message-ID: <1297366368.6737.14780.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael J Wolf <mjwolf@us.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>

On Thu, 2011-02-10 at 19:08 +0100, Andrea Arcangeli wrote:
> the locking looks wrong, who is taking the &walk->mm->page_table_lock,
> and isn't this going to deadlock on the pte_offset_map_lock for
> NR_CPUS < 4, and where is it released? This spin_lock don't seem
> necessary to me.
> 
> The right locking would be:
> 
>  spin_lock(&walk->mm->page_table_lock);
>  if (pmd_trans_huge(*pmd)) {
>    if (pmd_trans_splitting(*pmd)) {
>     spin_unlock(&walk->mm->page_table_lock);
>     wait_split_huge_page(vma->anon_vma, pmd);
>    } else {
>     smaps_pte_entry(*(pte_t *)pmd, addr, HPAGE_SIZE, walk);
>     spin_unlock(&walk->mm->page_table_lock);
>     return 0;
>   } 

I was under the assumption that the mm->page_table_lock was already held
here, but I think that's wrong.  I'll go back, take another look, and
retest.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
