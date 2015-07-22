Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 74DBD9003C8
	for <linux-mm@kvack.org>; Wed, 22 Jul 2015 18:03:21 -0400 (EDT)
Received: by pdrg1 with SMTP id g1so145104377pdr.2
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 15:03:21 -0700 (PDT)
Received: from mail-pd0-x235.google.com (mail-pd0-x235.google.com. [2607:f8b0:400e:c02::235])
        by mx.google.com with ESMTPS id u9si6646013pdp.186.2015.07.22.15.03.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jul 2015 15:03:20 -0700 (PDT)
Received: by pdbbh15 with SMTP id bh15so99405430pdb.1
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 15:03:20 -0700 (PDT)
Date: Wed, 22 Jul 2015 15:03:18 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mmap.2: document the munmap exception for underlying
 page size
In-Reply-To: <55AFD009.6080706@gmail.com>
Message-ID: <alpine.DEB.2.10.1507221457300.21468@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1507211736300.24133@chino.kir.corp.google.com> <55AFD009.6080706@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: Hugh Dickins <hughd@google.com>, Davide Libenzi <davidel@xmailserver.org>, Eric B Munson <emunson@akamai.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-man@vger.kernel.org

On Wed, 22 Jul 2015, Michael Kerrisk (man-pages) wrote:

> > diff --git a/man2/mmap.2 b/man2/mmap.2
> > --- a/man2/mmap.2
> > +++ b/man2/mmap.2
> > @@ -383,6 +383,10 @@ All pages containing a part
> >  of the indicated range are unmapped, and subsequent references
> >  to these pages will generate
> >  .BR SIGSEGV .
> > +An exception is when the underlying memory is not of the native page
> > +size, such as hugetlb page sizes, whereas
> > +.I length
> > +must be a multiple of the underlying page size.
> >  It is not an error if the
> >  indicated range does not contain any mapped pages.
> >  .SS Timestamps changes for file-backed mappings
> 
> I'm struggling a bit to understand your text. Is the point this:
> 
>     If we have a hugetlb area, then the munmap() length
>     must be a multiple of the page size.
> 
> ?
> 

Of the hugetlb page size, yes, which was meant by the "underlying page 
size" since we have configurable hugetlb sizes.  This is different from 
the native page size, whereas the length is rounded up to be page aligned 
per POSIX.

> Are there any requirements about 'addr'? Must it also me huge-page-aligned?
> 

Yes, so it looks like we need to fix up the reference to "address addr 
must be a multiple of the page size" to something like "address addr must 
be a multiple of the underlying page size" but I think the distinction 
isn't explicit enough as I'd like it.  I think it's better to explicitly 
show the exception for hugetlb page sizes and compare the underlying page 
size to the native page size to define how the behavior differs.

Would something like

	An exception is when the underlying memory, such as hugetlb 
	memory, is not of the native page size: the address addr and
	the length must be a multiple of the underlying page size.

suffice?

Also, is it typical to reference the commit of the documentation change 
in the kernel source that defines this?  I see this done with .\" blocks 
for MAP_STACK in the same man page.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
