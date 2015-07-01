Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f177.google.com (mail-ie0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id 180D56B0253
	for <linux-mm@kvack.org>; Wed,  1 Jul 2015 17:25:59 -0400 (EDT)
Received: by iecuq6 with SMTP id uq6so43729673iec.2
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 14:25:58 -0700 (PDT)
Received: from mail-ig0-x22e.google.com (mail-ig0-x22e.google.com. [2607:f8b0:4001:c05::22e])
        by mx.google.com with ESMTPS id th17si3845820icb.46.2015.07.01.14.25.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Jul 2015 14:25:58 -0700 (PDT)
Received: by igblr2 with SMTP id lr2so43974083igb.0
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 14:25:58 -0700 (PDT)
Date: Wed, 1 Jul 2015 14:25:56 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 05/11] mm: debug: dump page into a string rather than
 directly on screen
In-Reply-To: <55943DC1.6010209@oracle.com>
Message-ID: <alpine.DEB.2.10.1507011422070.14014@chino.kir.corp.google.com>
References: <1431623414-1905-1-git-send-email-sasha.levin@oracle.com> <1431623414-1905-6-git-send-email-sasha.levin@oracle.com> <alpine.DEB.2.10.1506301627030.5359@chino.kir.corp.google.com> <55943DC1.6010209@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, kirill@shutemov.name

On Wed, 1 Jul 2015, Sasha Levin wrote:

> On 06/30/2015 07:35 PM, David Rientjes wrote:
> > I don't know how others feel, but this looks strange to me and seems like 
> > it's only a result of how we must now dump page information 
> > (dump_page(page) is no longer available, we must do pr_alert("%pZp", 
> > page)).
> > 
> > Since we're relying on print formats, this would arguably be better as
> > 
> > 	pr_alert("Not movable balloon page:\n");
> > 	pr_alert("%pZp", page);
> > 
> > to avoid introducing newlines into potentially lengthy messages that need 
> > a specified loglevel like you've done above.
> > 
> > But that's not much different than the existing dump_page() 
> > implementation.
> > 
> > So for this to be worth it, it seems like we'd need a compelling usecase 
> > for something like pr_alert("%pZp %pZv", page, vma) and I'm not sure we're 
> > ever actually going to see that.  I would argue that
> > 
> > 	dump_page(page);
> > 	dump_vma(vma);
> > 
> > would be simpler in such circumstances.
> 
> I think we can find usecases where we want to dump more information than what's
> contained in just one page/vma/mm struct. Things like the following from mm/gup.c:
> 
> 	VM_BUG_ON_PAGE(compound_head(page) != head, page);
> 
> Where seeing 'head' would be interesting as well.
> 

I think it's a debate about whether this would be better off handled as

	if (VM_BUG_ON(compound_head(page) != head)) {
		dump_page(page);
		dump_page(head);
	}

and avoid VM_BUG_ON_PAGE() and the new print formats entirely.  We can 
improve upon existing VM_BUG_ON(), and BUG_ON() itself since the VM isn't 
anything special in this regard, to print diagnostic information that may 
be helpful, but I don't feel like adding special VM_BUG_ON_*() macros or 
printing formats makes any of this simpler.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
