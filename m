Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 714346B00EA
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 02:46:37 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 0F3E93EE0BB
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 15:46:36 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id EA26845DE4F
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 15:46:35 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id CCE5345DE4E
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 15:46:35 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C01ADE08001
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 15:46:35 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7D18A1DB802F
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 15:46:35 +0900 (JST)
Message-ID: <4F83D6E5.4080309@jp.fujitsu.com>
Date: Tue, 10 Apr 2012 15:44:53 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: Question on i_mmap_mutex locking rule
References: <877gxygx11.fsf@skywalker.in.ibm.com>
In-Reply-To: <877gxygx11.fsf@skywalker.in.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>

(2012/04/02 21:04), Aneesh Kumar K.V wrote:

> 
> Hi,
> 
> I started looking at unmap_hugepage_range. unmap_hugepage_range takes
> i_mmap_mutex. But then the same lock is also taken higher up in the
> stack. ie via the below chain
> 
> unmap_mapping_range (i_mmap_mutex)
>  -> unmap_mapping_range_tree
>     -> unmap_mapping_range_vma
>        -> zap_page_range_single
>           -> unmap_single_vma
>              -> unmap_hugepage_range (i_mmap_mutex)
> 


why not deadlock ?

> But there are other code path that doesn't take i_mmap_mutex. For ex:
> -> madvise_dontneed
>    -> zap_page_range
>       -> unmap_vmas
>          -> unmap_single_vma
>             -> unmap_page_range
>       
> 


IIUC, DONTNEED will not change vma layout...so it doesn't require
i_mmap_mutex.

Thanks,
-Kame 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
