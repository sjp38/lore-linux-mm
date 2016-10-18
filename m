Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 499676B025E
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 17:01:52 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id z82so3827423qkb.7
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 14:01:52 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0034.hostedemail.com. [216.40.44.34])
        by mx.google.com with ESMTPS id j59si22160260qtb.16.2016.10.18.14.01.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Oct 2016 14:01:51 -0700 (PDT)
Date: Tue, 18 Oct 2016 17:01:47 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 6/6] mm: add preempt points into __purge_vmap_area_lazy
Message-ID: <20161018170147.232aed1e@gandalf.local.home>
In-Reply-To: <20161018205648.GB7021@home.goodmis.org>
References: <1476773771-11470-1-git-send-email-hch@lst.de>
	<1476773771-11470-7-git-send-email-hch@lst.de>
	<20161018205648.GB7021@home.goodmis.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: akpm@linux-foundation.org, joelaf@google.com, jszhang@marvell.com, chris@chris-wilson.co.uk, joaodias@google.com, linux-mm@kvack.org, linux-rt-users@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, 18 Oct 2016 16:56:48 -0400
Steven Rostedt <rostedt@goodmis.org> wrote:


> Is releasing the lock within a llist_for_each_entry_safe() actually safe? Is
> vmap_area_lock the one to protect the valist?
> 
> That is llist_for_each_entry_safe(va, n_va, valist, purg_list) does:
> 
> 	for (va = llist_entry(valist, typeof(*va), purge_list);
> 	     &va->purge_list != NULL &&
> 	     n_va = llist_entry(va->purge_list.next, typeof(*n_va),
> 				purge_list, true);
> 	     pos = n)
> 
> Thus n_va is pointing to the next element to process when we release the
> lock. Is it possible for another task to get into this same path and process
> the item that n_va is pointing to? Then when the preempted task comes back,
> grabs the vmap_area_lock, and then continues the loop with what n_va has,
> could that cause problems? That is, the next iteration after releasing the
> lock does va = n_va. What happens if n_va no longer exits?
> 
> I don't know this code that well, and perhaps vmap_area_lock is not protecting
> the list and this is all fine.
> 

Bah, nevermind. I missed the:

	valist = llist_del_all(&vmap_purge_list);

so yeah, all should be good.

Nothing to see here, move along please.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
