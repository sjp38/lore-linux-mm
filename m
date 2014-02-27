Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f50.google.com (mail-ee0-f50.google.com [74.125.83.50])
	by kanga.kvack.org (Postfix) with ESMTP id 9E5F46B0072
	for <linux-mm@kvack.org>; Thu, 27 Feb 2014 16:19:13 -0500 (EST)
Received: by mail-ee0-f50.google.com with SMTP id t10so1719645eei.37
        for <linux-mm@kvack.org>; Thu, 27 Feb 2014 13:19:12 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id g5si1305500eew.21.2014.02.27.13.19.10
        for <linux-mm@kvack.org>;
        Thu, 27 Feb 2014 13:19:11 -0800 (PST)
Date: Thu, 27 Feb 2014 16:19:01 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <530fabcf.05300f0a.7f7e.ffffc80dSMTPIN_ADDED_BROKEN@mx.google.com>
In-Reply-To: <20140227130323.0d4f0a27b4327100805bab02@linux-foundation.org>
References: <1393475977-3381-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1393475977-3381-2-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20140227130323.0d4f0a27b4327100805bab02@linux-foundation.org>
Subject: Re: [PATCH 1/3] mm/pagewalk.c: fix end address calculation in
 walk_page_range()
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: sasha.levin@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Feb 27, 2014 at 01:03:23PM -0800, Andrew Morton wrote:
> On Wed, 26 Feb 2014 23:39:35 -0500 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:
> 
> > When we try to walk over inside a vma, walk_page_range() tries to walk
> > until vma->vm_end even if a given end is before that point.
> > So this patch takes the smaller one as an end address.
> > 
> > ...
> >
> > --- next-20140220.orig/mm/pagewalk.c
> > +++ next-20140220/mm/pagewalk.c
> > @@ -321,8 +321,9 @@ int walk_page_range(unsigned long start, unsigned long end,
> >  			next = vma->vm_start;
> >  		} else { /* inside the found vma */
> >  			walk->vma = vma;
> > -			next = vma->vm_end;
> > -			err = walk_page_test(start, end, walk);
> > +			next = min_t(unsigned long, end, vma->vm_end);
> 
> min_t is unneeded, isn't it?  Everything here has type unsigned long.

Yes, so simply (end < vma->vm_end ? end: vma->vm_end) is enough.
# I just considered min_t as simple minimum getter without thinking type check.

> > +			err = walk_page_test(start, next, walk);
> >  			if (skip_lower_level_walking(walk))
> >  				continue;
> >  			if (err)
> 
> I'm assuming this is a fix against
> pagewalk-update-page-table-walker-core.patch and shall eventually be
> folded into that patch.  

Yes, next-20140220 has this patch.

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
