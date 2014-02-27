Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id A0DD06B0072
	for <linux-mm@kvack.org>; Thu, 27 Feb 2014 16:20:43 -0500 (EST)
Received: by mail-wi0-f182.google.com with SMTP id f8so4050594wiw.3
        for <linux-mm@kvack.org>; Thu, 27 Feb 2014 13:20:43 -0800 (PST)
Received: from jenni1.inet.fi (mta-out.inet.fi. [195.156.147.13])
        by mx.google.com with ESMTP id p10si3576592wik.1.2014.02.27.13.20.42
        for <linux-mm@kvack.org>;
        Thu, 27 Feb 2014 13:20:42 -0800 (PST)
Date: Thu, 27 Feb 2014 23:20:34 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 1/3] mm/pagewalk.c: fix end address calculation in
 walk_page_range()
Message-ID: <20140227212034.GA6106@node.dhcp.inet.fi>
References: <1393475977-3381-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1393475977-3381-2-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20140227130323.0d4f0a27b4327100805bab02@linux-foundation.org>
 <530fabcf.05300f0a.7f7e.ffffc80dSMTPIN_ADDED_BROKEN@mx.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <530fabcf.05300f0a.7f7e.ffffc80dSMTPIN_ADDED_BROKEN@mx.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: akpm@linux-foundation.org, sasha.levin@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Feb 27, 2014 at 04:19:01PM -0500, Naoya Horiguchi wrote:
> On Thu, Feb 27, 2014 at 01:03:23PM -0800, Andrew Morton wrote:
> > On Wed, 26 Feb 2014 23:39:35 -0500 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:
> > 
> > > When we try to walk over inside a vma, walk_page_range() tries to walk
> > > until vma->vm_end even if a given end is before that point.
> > > So this patch takes the smaller one as an end address.
> > > 
> > > ...
> > >
> > > --- next-20140220.orig/mm/pagewalk.c
> > > +++ next-20140220/mm/pagewalk.c
> > > @@ -321,8 +321,9 @@ int walk_page_range(unsigned long start, unsigned long end,
> > >  			next = vma->vm_start;
> > >  		} else { /* inside the found vma */
> > >  			walk->vma = vma;
> > > -			next = vma->vm_end;
> > > -			err = walk_page_test(start, end, walk);
> > > +			next = min_t(unsigned long, end, vma->vm_end);
> > 
> > min_t is unneeded, isn't it?  Everything here has type unsigned long.
> 
> Yes, so simply (end < vma->vm_end ? end: vma->vm_end) is enough.
> # I just considered min_t as simple minimum getter without thinking type check.

We have non-typed min() for that.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
