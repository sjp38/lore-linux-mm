Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f171.google.com (mail-ob0-f171.google.com [209.85.214.171])
	by kanga.kvack.org (Postfix) with ESMTP id 369396B0253
	for <linux-mm@kvack.org>; Wed,  1 Jul 2015 15:30:22 -0400 (EDT)
Received: by obdbs4 with SMTP id bs4so35198204obd.3
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 12:30:22 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id ou13si2431341oeb.43.2015.07.01.12.30.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Jul 2015 12:30:21 -0700 (PDT)
Message-ID: <55943DC1.6010209@oracle.com>
Date: Wed, 01 Jul 2015 15:21:37 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH 05/11] mm: debug: dump page into a string rather than
 directly on screen
References: <1431623414-1905-1-git-send-email-sasha.levin@oracle.com> <1431623414-1905-6-git-send-email-sasha.levin@oracle.com> <alpine.DEB.2.10.1506301627030.5359@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1506301627030.5359@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, kirill@shutemov.name

On 06/30/2015 07:35 PM, David Rientjes wrote:
> I don't know how others feel, but this looks strange to me and seems like 
> it's only a result of how we must now dump page information 
> (dump_page(page) is no longer available, we must do pr_alert("%pZp", 
> page)).
> 
> Since we're relying on print formats, this would arguably be better as
> 
> 	pr_alert("Not movable balloon page:\n");
> 	pr_alert("%pZp", page);
> 
> to avoid introducing newlines into potentially lengthy messages that need 
> a specified loglevel like you've done above.
> 
> But that's not much different than the existing dump_page() 
> implementation.
> 
> So for this to be worth it, it seems like we'd need a compelling usecase 
> for something like pr_alert("%pZp %pZv", page, vma) and I'm not sure we're 
> ever actually going to see that.  I would argue that
> 
> 	dump_page(page);
> 	dump_vma(vma);
> 
> would be simpler in such circumstances.

I think we can find usecases where we want to dump more information than what's
contained in just one page/vma/mm struct. Things like the following from mm/gup.c:

	VM_BUG_ON_PAGE(compound_head(page) != head, page);

Where seeing 'head' would be interesting as well.

Or for VMAs, from include/linux/rmap.h:

	VM_BUG_ON_VMA(vma->anon_vma != next->anon_vma, vma);

Would it be interesting to see both vma, and next? Probably.

Or opportunities to add information from other variables, such as in:

	VM_BUG_ON_PAGE(stable_node->kpfn != page_to_pfn(oldpage), oldpage);

Is stable_node->kpfn interesting? Might be.


We *could* go ahead and open code all of that, but that's not happening, It's not
intuitive and people just slap VM_BUG_ON()s and hope they can figure it out when
those VM_BUG_ON()s happen.

Are there any pieces of code that open code what you suggested?


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
