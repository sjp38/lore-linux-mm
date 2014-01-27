Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f53.google.com (mail-bk0-f53.google.com [209.85.214.53])
	by kanga.kvack.org (Postfix) with ESMTP id 358066B0031
	for <linux-mm@kvack.org>; Mon, 27 Jan 2014 00:03:27 -0500 (EST)
Received: by mail-bk0-f53.google.com with SMTP id my13so2572225bkb.26
        for <linux-mm@kvack.org>; Sun, 26 Jan 2014 21:03:26 -0800 (PST)
Received: from mail-pd0-x22d.google.com (mail-pd0-x22d.google.com [2607:f8b0:400e:c02::22d])
        by mx.google.com with ESMTPS id ob9si12677120bkb.90.2014.01.26.21.03.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 26 Jan 2014 21:03:26 -0800 (PST)
Received: by mail-pd0-f173.google.com with SMTP id y10so5256137pdj.4
        for <linux-mm@kvack.org>; Sun, 26 Jan 2014 21:03:24 -0800 (PST)
Date: Sun, 26 Jan 2014 21:02:44 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: bring back /sys/kernel/mm
In-Reply-To: <20140127040330.GA17584@windriver.com>
Message-ID: <alpine.LSU.2.11.1401262053510.1002@eggly.anvils>
References: <alpine.LSU.2.11.1401261849120.1259@eggly.anvils> <20140127040330.GA17584@windriver.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, 26 Jan 2014, Paul Gortmaker wrote:
> [[PATCH] mm: bring back /sys/kernel/mm] On 26/01/2014 (Sun 18:52) Hugh Dickins wrote:
> 
> > Commit da29bd36224b ("mm/mm_init.c: make creation of the mm_kobj happen
> > earlier than device_initcall") changed to pure_initcall(mm_sysfs_init).
> > 
> > That's too early: mm_sysfs_init() depends on core_initcall(ksysfs_init)
> > to have made the kernel_kobj directory "kernel" in which to create "mm".
> > 
> > Make it postcore_initcall(mm_sysfs_init).  We could use core_initcall(),
> > and depend upon Makefile link order kernel/ mm/ fs/ ipc/ security/ ...
> > as core_initcall(debugfs_init) and core_initcall(securityfs_init) do;
> > but better not.
> 
> Agreed, N+1 is better than link order.  I guess it silently fails then,
> with /sys/kernel/mm missing as the symptom?  I'd booted i386 and ppc
> and didn't spot this, unfortunately...  wondering now if there was a
> hint in dmesg that I simply failed to notice.

No, nothing in dmesg at all: both mm_sysfs_init() and ksm_init()
(it was /sys/kernel/mm/ksm/run that I was looking for) thought
they had succeeded.

Ah, I get it: it's normal to pass NULL parent to kobject_create_and_add(),
that just means create at the root.  And when I look at an unfixed box,
yes, there's /sys/mm with all the right contents.

Given /sys/block and /sys/fs and /sys/kernel, I think /sys/mm is a better
location; but we're a few years too late to be making that change now ;)

Hugh

> 
> > 
> > Signed-off-by: Hugh Dickins <hughd@google.com>
> 
> Acked-by: Paul Gortmaker <paul.gortmaker@windriver.com>
> 
> Thanks,
> Paul.
> 
> > ---
> > 
> >  mm/mm_init.c |    2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > --- 3.13.0+/mm/mm_init.c	2014-01-23 21:51:26.004001378 -0800
> > +++ linux/mm/mm_init.c	2014-01-26 18:06:40.488488209 -0800
> > @@ -202,4 +202,4 @@ static int __init mm_sysfs_init(void)
> >  
> >  	return 0;
> >  }
> > -pure_initcall(mm_sysfs_init);
> > +postcore_initcall(mm_sysfs_init);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
