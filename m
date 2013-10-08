Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id BA6B86B0031
	for <linux-mm@kvack.org>; Tue,  8 Oct 2013 15:48:39 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id up15so9106109pbc.12
        for <linux-mm@kvack.org>; Tue, 08 Oct 2013 12:48:39 -0700 (PDT)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rcj@linux.vnet.ibm.com>;
	Wed, 9 Oct 2013 05:48:34 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 650822BB0053
	for <linux-mm@kvack.org>; Wed,  9 Oct 2013 06:48:31 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r98JVJRI35979382
	for <linux-mm@kvack.org>; Wed, 9 Oct 2013 06:31:26 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r98JmM6k029313
	for <linux-mm@kvack.org>; Wed, 9 Oct 2013 06:48:23 +1100
Date: Tue, 8 Oct 2013 14:48:19 -0500
From: Robert Jennings <rcj@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/2] vmsplice: unmap gifted pages for recipient
Message-ID: <20131008194819.GB6129@linux.vnet.ibm.com>
References: <1381177293-27125-1-git-send-email-rcj@linux.vnet.ibm.com>
 <1381177293-27125-2-git-send-email-rcj@linux.vnet.ibm.com>
 <52542F53.4020807@sr71.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52542F53.4020807@sr71.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Matt Helsley <matt.helsley@gmail.com>, Anthony Liguori <anthony@codemonkey.ws>, Michael Roth <mdroth@linux.vnet.ibm.com>, Lei Li <lilei@linux.vnet.ibm.com>, Leonardo Garcia <lagarcia@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>

* Dave Hansen (dave@sr71.net) wrote:
> On 10/07/2013 01:21 PM, Robert C Jennings wrote:
> > +					} else {
> > +						if (vma)
> > +							zap_page_range(vma,
> > +								user_start,
> > +								(user_end -
> > +								 user_start),
> > +								NULL);
> > +						vma = find_vma_intersection(
> > +								current->mm,
> > +								useraddr,
> > +								(useraddr +
> > +								 PAGE_SIZE));
> > +						if (!IS_ERR_OR_NULL(vma)) {
> > +							user_start = useraddr;
> > +							user_end = (useraddr +
> > +								    PAGE_SIZE);
> > +						} else
> > +							vma = NULL;
> > +					}
> 
> This is pretty unspeakably hideous.  Was there truly no better way to do
> this?

I was hoping to find a better way to coalesce pipe buffers and zap
entire VMAs (and it needs better documentation but your argument is with
structure and I agree). I would love suggestions for improving this but
that is not to say that I've abandoned it; I'm still looking for ways
to make this cleaner.

Doing find_vma() on a single page in the VMA rather than on each and
then zapping once provides a 50% runtime reduction for the writer when
tested with a 256MB vmsplice operation.  Based on the result I felt that
coalescing was justfied but the implementation is ugly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
