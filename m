Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id A992B6B0069
	for <linux-mm@kvack.org>; Mon, 27 Oct 2014 03:03:53 -0400 (EDT)
Received: by mail-ig0-f181.google.com with SMTP id l13so5805799iga.14
        for <linux-mm@kvack.org>; Mon, 27 Oct 2014 00:03:53 -0700 (PDT)
Received: from e28smtp05.in.ibm.com (e28smtp05.in.ibm.com. [122.248.162.5])
        by mx.google.com with ESMTPS id uf1si11184857igc.19.2014.10.27.00.03.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 27 Oct 2014 00:03:52 -0700 (PDT)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Mon, 27 Oct 2014 12:33:44 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id E6ABDE0059
	for <linux-mm@kvack.org>; Mon, 27 Oct 2014 12:33:34 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay01.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id s9R73Qla35061936
	for <linux-mm@kvack.org>; Mon, 27 Oct 2014 12:33:26 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s9R73TL6023525
	for <linux-mm@kvack.org>; Mon, 27 Oct 2014 12:33:30 +0530
Date: Mon, 27 Oct 2014 12:33:29 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH 05/10] uprobes: share the i_mmap_rwsem
Message-ID: <20141027070329.GA10867@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <1414188380-17376-1-git-send-email-dave@stgolabs.net>
 <1414188380-17376-6-git-send-email-dave@stgolabs.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1414188380-17376-6-git-send-email-dave@stgolabs.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>, Oleg Nesterov <oleg@redhat.com>
Cc: akpm@linux-foundation.org, hughd@google.com, riel@redhat.com, mgorman@suse.de, peterz@infradead.org, mingo@kernel.org, linux-kernel@vger.kernel.org, dbueso@suse.de, linux-mm@kvack.org

* Davidlohr Bueso <dave@stgolabs.net> [2014-10-24 15:06:15]:

> Both register and unregister call build_map_info() in order
> to create the list of mappings before installing or removing
> breakpoints for every mm which maps file backed memory. As
> such, there is no reason to hold the i_mmap_rwsem exclusively,
> so share it and allow concurrent readers to build the mapping
> data.
> 
> Signed-off-by: Davidlohr Bueso <dbueso@suse.de>


Copying Oleg (since he should have been copied on this one)

Please see one comment below.

Acked-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com> 

> ---
>  kernel/events/uprobes.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
> index 045b649..7a9e620 100644
> --- a/kernel/events/uprobes.c
> +++ b/kernel/events/uprobes.c
> @@ -724,7 +724,7 @@ build_map_info(struct address_space *mapping, loff_t offset, bool is_register)
>  	int more = 0;
>  
>   again:
> -	i_mmap_lock_write(mapping);
> +	i_mmap_lock_read(mapping);
>  	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
>  		if (!valid_vma(vma, is_register))
>  			continue;


Just after this, we have
if (!prev && !more) {
	/*
	 * Needs GFP_NOWAIT to avoid i_mmap_mutex recursion through
	 * reclaim. This is optimistic, no harm done if it fails.
	 */
	prev = kmalloc(sizeof(struct map_info),
			GFP_NOWAIT | __GFP_NOMEMALLOC | __GFP_NOWARN);
	if (prev)
		prev->next = NULL;
}

However in patch 02/10
I dont think the comment referring to i_mmap_mutex was modified to
refer i_mmap_lock_write.

When thats taken care off, this patch should change that part accordingly.


-- 
Thanks and Regards
Srikar Dronamraju

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
