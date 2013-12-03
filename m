Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id EB91D6B0037
	for <linux-mm@kvack.org>; Tue,  3 Dec 2013 17:38:44 -0500 (EST)
Received: by mail-pd0-f180.google.com with SMTP id q10so20900111pdj.25
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 14:38:44 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id nu5si12851646pbc.58.2013.12.03.14.38.43
        for <linux-mm@kvack.org>;
        Tue, 03 Dec 2013 14:38:43 -0800 (PST)
Date: Tue, 3 Dec 2013 14:38:41 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH RFC] mm readahead: Fix the readahead fail in case of
 empty numa node
Message-Id: <20131203143841.11b71e387dc1db3a8ab0974c@linux-foundation.org>
In-Reply-To: <1386066977-17368-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
References: <1386066977-17368-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue,  3 Dec 2013 16:06:17 +0530 Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com> wrote:

> On a cpu with an empty numa node,

This makes no sense - numa nodes don't reside on CPUs.

I think you mean "on a CPU which resides on a memoryless NUMA node"?

> readahead fails because max_sane_readahead
> returns zero. The reason is we look into number of inactive + free pages 
> available on the current node.
> 
> The following patch tries to fix the behaviour by checking for potential
> empty numa node cases.
> The rationale for the patch is, readahead may be worth doing on a remote
> node instead of incuring costly disk faults later.
> 
> I still feel we may have to sanitize the nr below, (for e.g., nr/8)
> to avoid serious consequences of malicious application trying to do
> a big readahead on a empty numa node causing unnecessary load on remote nodes.
> ( or it may even be that current behaviour is right in not going ahead with
> readahead to avoid the memory load on remote nodes).
> 

I don't recall the rationale for the current code and of course we
didn't document it.  It might be in the changelogs somewhere - could
you please do the git digging and see if you can find out?

I don't immediately see why readahead into a different node is
considered a bad thing.

> --- a/mm/readahead.c
> +++ b/mm/readahead.c
> @@ -243,8 +243,11 @@ int force_page_cache_readahead(struct address_space *mapping, struct file *filp,
>   */
>  unsigned long max_sane_readahead(unsigned long nr)
>  {
> -	return min(nr, (node_page_state(numa_node_id(), NR_INACTIVE_FILE)
> -		+ node_page_state(numa_node_id(), NR_FREE_PAGES)) / 2);
> +	unsigned long numa_free_page;
> +	numa_free_page = (node_page_state(numa_node_id(), NR_INACTIVE_FILE)
> +			   + node_page_state(numa_node_id(), NR_FREE_PAGES));
> +
> +	return numa_free_page ? min(nr, numa_free_page / 2) : nr;

Well even if this CPU's node has very little pagecache at all, what's
wrong with permitting readahead?  We don't know that the new pagecache
will be allocated exclusively from this CPU's node anyway.  All very
odd.

Whatever we do, we should leave behind some good code comments which
explain the rationale(s), please.  Right now it's rather opaque.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
