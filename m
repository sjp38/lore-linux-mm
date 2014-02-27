Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f171.google.com (mail-we0-f171.google.com [74.125.82.171])
	by kanga.kvack.org (Postfix) with ESMTP id 466D86B0073
	for <linux-mm@kvack.org>; Thu, 27 Feb 2014 16:55:03 -0500 (EST)
Received: by mail-we0-f171.google.com with SMTP id u56so3357991wes.2
        for <linux-mm@kvack.org>; Thu, 27 Feb 2014 13:55:02 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id gj10si13789wib.86.2014.02.27.13.55.00
        for <linux-mm@kvack.org>;
        Thu, 27 Feb 2014 13:55:01 -0800 (PST)
Date: Thu, 27 Feb 2014 16:54:54 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <530fb435.2a69b40a.4ef1.0608SMTPIN_ADDED_BROKEN@mx.google.com>
In-Reply-To: <20140227212034.GA6106@node.dhcp.inet.fi>
References: <1393475977-3381-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1393475977-3381-2-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20140227130323.0d4f0a27b4327100805bab02@linux-foundation.org>
 <530fabcf.05300f0a.7f7e.ffffc80dSMTPIN_ADDED_BROKEN@mx.google.com>
 <20140227212034.GA6106@node.dhcp.inet.fi>
Subject: Re: [PATCH 1/3] mm/pagewalk.c: fix end address calculation in
 walk_page_range()
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kirill@shutemov.name
Cc: akpm@linux-foundation.org, sasha.levin@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Feb 27, 2014 at 11:20:34PM +0200, Kirill A. Shutemov wrote:
> On Thu, Feb 27, 2014 at 04:19:01PM -0500, Naoya Horiguchi wrote:
> > On Thu, Feb 27, 2014 at 01:03:23PM -0800, Andrew Morton wrote:
> > > On Wed, 26 Feb 2014 23:39:35 -0500 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:
> > > 
> > > > When we try to walk over inside a vma, walk_page_range() tries to walk
> > > > until vma->vm_end even if a given end is before that point.
> > > > So this patch takes the smaller one as an end address.
> > > > 
> > > > ...
> > > >
> > > > --- next-20140220.orig/mm/pagewalk.c
> > > > +++ next-20140220/mm/pagewalk.c
> > > > @@ -321,8 +321,9 @@ int walk_page_range(unsigned long start, unsigned long end,
> > > >  			next = vma->vm_start;
> > > >  		} else { /* inside the found vma */
> > > >  			walk->vma = vma;
> > > > -			next = vma->vm_end;
> > > > -			err = walk_page_test(start, end, walk);
> > > > +			next = min_t(unsigned long, end, vma->vm_end);
> > > 
> > > min_t is unneeded, isn't it?  Everything here has type unsigned long.
> > 
> > Yes, so simply (end < vma->vm_end ? end: vma->vm_end) is enough.
> > # I just considered min_t as simple minimum getter without thinking type check.
> 
> We have non-typed min() for that.

Thanks. This is what I wanted :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
