Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id 2C7886B0038
	for <linux-mm@kvack.org>; Tue, 25 Nov 2014 06:48:52 -0500 (EST)
Received: by mail-la0-f47.google.com with SMTP id hz20so359355lab.6
        for <linux-mm@kvack.org>; Tue, 25 Nov 2014 03:48:51 -0800 (PST)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.203])
        by mx.google.com with ESMTP id qj3si1587722wjc.78.2014.11.25.03.48.50
        for <linux-mm@kvack.org>;
        Tue, 25 Nov 2014 03:48:50 -0800 (PST)
Date: Tue, 25 Nov 2014 13:48:46 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: add parameter to disable faultaround
Message-ID: <20141125114846.GA10150@node.dhcp.inet.fi>
References: <1416898318-17409-1-git-send-email-chanho.min@lge.com>
 <20141124230502.30f9b6f0.akpm@linux-foundation.org>
 <547465d2.0937460a.7739.fffff2baSMTPIN_ADDED_BROKEN@mx.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <547465d2.0937460a.7739.fffff2baSMTPIN_ADDED_BROKEN@mx.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chanho Min <chanho.min@lge.com>
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, "'Kirill A. Shutemov'" <kirill.shutemov@linux.intel.com>, 'Hugh Dickins' <hughd@google.com>, 'Michal Hocko' <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, 'HyoJun Im' <hyojun.im@lge.com>, 'Gunho Lee' <gunho.lee@lge.com>, 'Wonhong Kwon' <wonhong.kwon@lge.com>

On Tue, Nov 25, 2014 at 08:19:40PM +0900, Chanho Min wrote:
> > > The faultaround improves the file read performance, whereas pages which
> > > can be dropped by drop_caches are reduced. On some systems, The amount of
> > > freeable pages under memory pressure is more important than read
> > > performance.
> > 
> > The faultaround pages *are* freeable.  Perhaps you meant "free" here.
> > 
> > Please tell us a great deal about the problem which you are trying to
> > solve.  What sort of system, what sort of workload, what is bad about
> > the behaviour which you are observing, etc.
> 
> We are trying to solve two issues.
> 
> We drop page caches by writing to /proc/sys/vm/drop_caches at specific point
> and make suspend-to-disk image. The size of this image is increased if faultaround
> is worked.

drop_caches should never be used outside debugging process. If you use it
as part of usual workflow you're doing something wrong.

I'm not aware about details on how suspend-to-disk works, but I don't see
much point in saving page cache pages into suspend-to-disk image. Dirty
pages should be write out and we can read them back after resume on first
use. Possible exception is mlocked pages.

> Under memory pressure, we want to drop many page caches as possible.
> But, The number of dropped pages are reduced compared to non-faultaround kernel.

The reason why you see more pages in page cache after drop_pages with
faultaround enabled is that drop_pages doesn't touch mapped pages. And
with faultaround we obviously have more pages mapped.

It's not a reason to have faultaround disable. You should take a closer
look on suspend process.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
