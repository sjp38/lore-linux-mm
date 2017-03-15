Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1D07C6B0389
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 07:54:33 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id y17so28963436pgh.2
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 04:54:33 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id q72si1343766pfj.362.2017.03.15.04.54.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Mar 2017 04:54:32 -0700 (PDT)
Date: Wed, 15 Mar 2017 19:54:40 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: Re: [PATCH v2 2/5] mm: parallel free pages
Message-ID: <20170315115440.GE2442@aaronlu.sh.intel.com>
References: <1489568404-7817-1-git-send-email-aaron.lu@intel.com>
 <1489568404-7817-3-git-send-email-aaron.lu@intel.com>
 <0a2501d29d70$7eb0f530$7c12df90$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0a2501d29d70$7eb0f530$7c12df90$@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, 'Dave Hansen' <dave.hansen@intel.com>, 'Tim Chen' <tim.c.chen@intel.com>, 'Andrew Morton' <akpm@linux-foundation.org>, 'Ying Huang' <ying.huang@intel.com>

On Wed, Mar 15, 2017 at 05:42:42PM +0800, Hillf Danton wrote:
> 
> On March 15, 2017 5:00 PM Aaron Lu wrote: 
> >  void tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long end)
> >  {
> > +	struct batch_free_struct *batch_free, *n;
> > +
> s/*n/*next/
> 
> >  	tlb_flush_mmu(tlb);
> > 
> >  	/* keep the page table cache within bounds */
> >  	check_pgt_cache();
> > 
> > +	list_for_each_entry_safe(batch_free, n, &tlb->worker_list, list) {
> > +		flush_work(&batch_free->work);
> 
> Not sure, list_del before free?

I think this is a good idea, it makes code look saner.
I just did a search of list_for_each_entry_safe and found list_del is
usually(I didn't check every one of them) used before free.

So I'll add that in the next revision, probably some days later in case
there are other comments.

Thanks for your time to review the patch.

Regards,
Aaron
 
> > +		kfree(batch_free);
> > +	}
> > +
> >  	tlb_flush_mmu_free_batches(tlb->local.next, true);
> >  	tlb->local.next = NULL;
> >  }
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
