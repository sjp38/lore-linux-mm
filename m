Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 4D7486B0031
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 16:46:54 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id r10so3103316pdi.28
        for <linux-mm@kvack.org>; Fri, 27 Sep 2013 13:46:53 -0700 (PDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Fri, 27 Sep 2013 16:46:51 -0400
Received: from b01cxnp23034.gho.pok.ibm.com (b01cxnp23034.gho.pok.ibm.com [9.57.198.29])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 2BD806E8048
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 16:46:48 -0400 (EDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by b01cxnp23034.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8RKkmAl62390478
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 20:46:48 GMT
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r8RKkjiS022117
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 14:46:48 -0600
Message-ID: <5245EEAD.7010901@linux.vnet.ibm.com>
Date: Fri, 27 Sep 2013 13:46:37 -0700
From: Cody P Schafer <cody@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCHv4 02/10] mm: convert mm->nr_ptes to atomic_t
References: <1380287787-30252-1-git-send-email-kirill.shutemov@linux.intel.com> <1380287787-30252-3-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1380287787-30252-3-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Alex Thorlton <athorlton@sgi.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "Eric W . Biederman" <ebiederm@xmission.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Al Viro <viro@zeniv.linux.org.uk>, Andi Kleen <ak@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Dave Jones <davej@redhat.com>, David Howells <dhowells@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Kees Cook <keescook@chromium.org>, Mel Gorman <mgorman@suse.de>, Michael Kerrisk <mtk.manpages@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Robin Holt <robinmholt@gmail.com>, Sedat Dilek <sedat.dilek@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 09/27/2013 06:16 AM, Kirill A. Shutemov wrote:
> With split page table lock for PMD level we can't hold
> mm->page_table_lock while updating nr_ptes.
>
> Let's convert it to atomic_t to avoid races.
>

> ---

> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 84e0c56e1e..99f19e850d 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -339,6 +339,7 @@ struct mm_struct {
>   	pgd_t * pgd;
>   	atomic_t mm_users;			/* How many users with user space? */
>   	atomic_t mm_count;			/* How many references to "struct mm_struct" (users count as 1) */
> +	atomic_t nr_ptes;			/* Page table pages */
>   	int map_count;				/* number of VMAs */
>
>   	spinlock_t page_table_lock;		/* Protects page tables and some counters */
> @@ -360,7 +361,6 @@ struct mm_struct {
>   	unsigned long exec_vm;		/* VM_EXEC & ~VM_WRITE */
>   	unsigned long stack_vm;		/* VM_GROWSUP/DOWN */
>   	unsigned long def_flags;
> -	unsigned long nr_ptes;		/* Page table pages */
>   	unsigned long start_code, end_code, start_data, end_data;
>   	unsigned long start_brk, brk, start_stack;
>   	unsigned long arg_start, arg_end, env_start, env_end;

Will 32bits always be enough here? Should atomic_long_t be used instead?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
