Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id CED996B006C
	for <linux-mm@kvack.org>; Fri, 27 Mar 2015 18:00:48 -0400 (EDT)
Received: by wixm2 with SMTP id m2so43660930wix.0
        for <linux-mm@kvack.org>; Fri, 27 Mar 2015 15:00:48 -0700 (PDT)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id t4si5266159wix.72.2015.03.27.15.00.47
        for <linux-mm@kvack.org>;
        Fri, 27 Mar 2015 15:00:47 -0700 (PDT)
Date: Sat, 28 Mar 2015 00:00:42 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] thp: do not adjust zone water marks if khugepaged is not
 started
Message-ID: <20150327220042.GA26190@node.dhcp.inet.fi>
References: <1427456378-214780-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20150327144708.0223cc2e55862655259d2720@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150327144708.0223cc2e55862655259d2720@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org

On Fri, Mar 27, 2015 at 02:47:08PM -0700, Andrew Morton wrote:
> On Fri, 27 Mar 2015 13:39:38 +0200 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> 
> > set_recommended_min_free_kbytes() adjusts zone water marks to be suitable
> > for khugepaged. We avoid doing this if khugepaged is disabled, but don't
> > catch the case when khugepaged is failed to start.
> > 
> > Let's address this by checking khugepaged_thread instead of
> > khugepaged_enabled() in set_recommended_min_free_kbytes().
> > It's NULL if the kernel thread is stopped or failed to start.
> >
> 
> hm, why didn't khugepaged start up?  Is this a theoretical
> by-code-inspection thing or has the problem been observed in real life?

David mentioned this scenario in comment to my previous patch.

> 
> > --- a/mm/huge_memory.c
> > +++ b/mm/huge_memory.c
> > @@ -110,7 +110,8 @@ static int set_recommended_min_free_kbytes(void)
> >  	int nr_zones = 0;
> >  	unsigned long recommended_min;
> >  
> > -	if (!khugepaged_enabled())
> > +	/* khugepaged thread has stopped to failed to start */
> > +	if (!khugepaged_thread)
> >  		return 0;
> >  
> >  	for_each_populated_zone(zone)
> 
> Fair enough, but take a look at start_khugepaged():
> 
> : static int start_khugepaged(void)
> : {
> : 	int err = 0;
> : 	if (khugepaged_enabled()) {
> : 		if (!khugepaged_thread)
> : 			khugepaged_thread = kthread_run(khugepaged, NULL,
> : 							"khugepaged");
> : 		if (unlikely(IS_ERR(khugepaged_thread))) {
> : 			pr_err("khugepaged: kthread_run(khugepaged) failed\n");
> : 			err = PTR_ERR(khugepaged_thread);
> : 			khugepaged_thread = NULL;
> 
> -->> stop here 

Right, but set_recommended_min_free_kbytes() is also registered to
late_initcall() and will get called anyway.

It's not obvious why would we need it registered there. Call from
start_khugepaged() should be enough.

Andrea?

> : 		}
> : 
> : 		if (!list_empty(&khugepaged_scan.mm_head))
> : 			wake_up_interruptible(&khugepaged_wait);
> : 
> : 		set_recommended_min_free_kbytes();
> : 	} else if (khugepaged_thread) {
> : 		kthread_stop(khugepaged_thread);
> : 		khugepaged_thread = NULL;
> : 	}
> : 
> : 	return err;
> : }
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
