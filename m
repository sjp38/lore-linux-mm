Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 6FB456B0038
	for <linux-mm@kvack.org>; Thu,  2 Apr 2015 08:08:30 -0400 (EDT)
Received: by wgdm6 with SMTP id m6so83163374wgd.2
        for <linux-mm@kvack.org>; Thu, 02 Apr 2015 05:08:29 -0700 (PDT)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.203])
        by mx.google.com with ESMTP id bz12si8432094wjb.80.2015.04.02.05.08.28
        for <linux-mm@kvack.org>;
        Thu, 02 Apr 2015 05:08:28 -0700 (PDT)
Date: Thu, 2 Apr 2015 15:08:24 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] thp: do not adjust zone water marks if khugepaged is not
 started
Message-ID: <20150402120824.GC24028@node.dhcp.inet.fi>
References: <1427456378-214780-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20150327144708.0223cc2e55862655259d2720@linux-foundation.org>
 <20150327150026.7500f1081e8c30c2303afecd@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150327150026.7500f1081e8c30c2303afecd@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org

On Fri, Mar 27, 2015 at 03:00:26PM -0700, Andrew Morton wrote:
> On Fri, 27 Mar 2015 14:47:08 -0700 Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > Fair enough, but take a look at start_khugepaged():
> > 
> > : static int start_khugepaged(void)
> > : {
> > : 	int err = 0;
> > : 	if (khugepaged_enabled()) {
> > : 		if (!khugepaged_thread)
> > : 			khugepaged_thread = kthread_run(khugepaged, NULL,
> > : 							"khugepaged");
> > : 		if (unlikely(IS_ERR(khugepaged_thread))) {
> > : 			pr_err("khugepaged: kthread_run(khugepaged) failed\n");
> > : 			err = PTR_ERR(khugepaged_thread);
> > : 			khugepaged_thread = NULL;
> > 
> > -->> stop here 
> > 
> > : 		}
> > : 
> > : 		if (!list_empty(&khugepaged_scan.mm_head))
> > : 			wake_up_interruptible(&khugepaged_wait);
> > : 
> > : 		set_recommended_min_free_kbytes();
> > : 	} else if (khugepaged_thread) {
> > : 		kthread_stop(khugepaged_thread);
> > : 		khugepaged_thread = NULL;
> > : 	}
> > : 
> > : 	return err;
> > : }
> 
> Looking more closely...  This code seems a bit screwy.
> 
> - why is set_recommended_min_free_kbytes() a late_initcall?  We've
>   already done that within
>   subsys_initcall->hugepage_init->set_recommended_min_free_kbytes()
> 
> - there isn't much point in running start_khugepaged() if we've just
>   set transparent_hugepage_flags to zero.
> 
> - start_khugepaged() is misnamed.
> 
> So something like this?

Looks like you didn't apply this. Here's proper patch:
