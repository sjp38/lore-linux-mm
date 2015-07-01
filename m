Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 2ABE06B0257
	for <linux-mm@kvack.org>; Wed,  1 Jul 2015 17:34:36 -0400 (EDT)
Received: by wgqq4 with SMTP id q4so47409459wgq.1
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 14:34:35 -0700 (PDT)
Received: from johanna4.inet.fi (mta-out1.inet.fi. [62.71.2.229])
        by mx.google.com with ESMTP id og6si6170962wic.45.2015.07.01.14.34.34
        for <linux-mm@kvack.org>;
        Wed, 01 Jul 2015 14:34:34 -0700 (PDT)
Date: Thu, 2 Jul 2015 00:34:30 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 05/11] mm: debug: dump page into a string rather than
 directly on screen
Message-ID: <20150701213430.GA21490@node.dhcp.inet.fi>
References: <1431623414-1905-1-git-send-email-sasha.levin@oracle.com>
 <1431623414-1905-6-git-send-email-sasha.levin@oracle.com>
 <alpine.DEB.2.10.1506301627030.5359@chino.kir.corp.google.com>
 <55943DC1.6010209@oracle.com>
 <alpine.DEB.2.10.1507011422070.14014@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1507011422070.14014@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On Wed, Jul 01, 2015 at 02:25:56PM -0700, David Rientjes wrote:
> On Wed, 1 Jul 2015, Sasha Levin wrote:
> 
> > On 06/30/2015 07:35 PM, David Rientjes wrote:
> > > I don't know how others feel, but this looks strange to me and seems like 
> > > it's only a result of how we must now dump page information 
> > > (dump_page(page) is no longer available, we must do pr_alert("%pZp", 
> > > page)).
> > > 
> > > Since we're relying on print formats, this would arguably be better as
> > > 
> > > 	pr_alert("Not movable balloon page:\n");
> > > 	pr_alert("%pZp", page);
> > > 
> > > to avoid introducing newlines into potentially lengthy messages that need 
> > > a specified loglevel like you've done above.
> > > 
> > > But that's not much different than the existing dump_page() 
> > > implementation.
> > > 
> > > So for this to be worth it, it seems like we'd need a compelling usecase 
> > > for something like pr_alert("%pZp %pZv", page, vma) and I'm not sure we're 
> > > ever actually going to see that.  I would argue that
> > > 
> > > 	dump_page(page);
> > > 	dump_vma(vma);
> > > 
> > > would be simpler in such circumstances.
> > 
> > I think we can find usecases where we want to dump more information than what's
> > contained in just one page/vma/mm struct. Things like the following from mm/gup.c:
> > 
> > 	VM_BUG_ON_PAGE(compound_head(page) != head, page);
> > 
> > Where seeing 'head' would be interesting as well.
> > 
> 
> I think it's a debate about whether this would be better off handled as
> 
> 	if (VM_BUG_ON(compound_head(page) != head)) {
> 		dump_page(page);
> 		dump_page(head);

Huh? How would we reach this, if VM_BUG_ON() will trigger BUG()?

> 	}
> 
> and avoid VM_BUG_ON_PAGE() and the new print formats entirely.  We can 
> improve upon existing VM_BUG_ON(), and BUG_ON() itself since the VM isn't 
> anything special in this regard, to print diagnostic information that may 
> be helpful, but I don't feel like adding special VM_BUG_ON_*() macros or 
> printing formats makes any of this simpler.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
