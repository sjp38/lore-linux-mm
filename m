Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id E05E16B0035
	for <linux-mm@kvack.org>; Mon, 21 Apr 2014 21:01:48 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id v10so4266244pde.29
        for <linux-mm@kvack.org>; Mon, 21 Apr 2014 18:01:48 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id fd9si21750187pad.101.2014.04.21.18.01.47
        for <linux-mm@kvack.org>;
        Mon, 21 Apr 2014 18:01:47 -0700 (PDT)
Date: Mon, 21 Apr 2014 18:02:27 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/5] mm: extract code to fault in a page from
 __get_user_pages()
Message-Id: <20140421180227.e372200c.akpm@linux-foundation.org>
In-Reply-To: <20140422005036.GA27749@node.dhcp.inet.fi>
References: <1396535722-31108-1-git-send-email-kirill.shutemov@linux.intel.com>
	<1396535722-31108-5-git-send-email-kirill.shutemov@linux.intel.com>
	<20140421163522.41bba07f9e6ea11549383ad4@linux-foundation.org>
	<20140422005036.GA27749@node.dhcp.inet.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, Jan Kara <jack@suse.cz>

On Tue, 22 Apr 2014 03:50:36 +0300 "Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> On Mon, Apr 21, 2014 at 04:35:22PM -0700, Andrew Morton wrote:
> > > +				ret = faultin_page(tsk, vma, start, &foll_flags,
> > > +						nonblocking);
> > > +				switch (ret) {
> > > +				case 0:
> > > +					break;
> > > +				case -EFAULT:
> > > +				case -ENOMEM:
> > > +				case -EHWPOISON:
> > > +					return i ? i : ret;
> > > +				case -EBUSY:
> > >  					return i;
> > > +				case -ENOENT:
> > > +					goto next_page;
> > > +				default:
> > > +					BUILD_BUG();
> > 
> > hm, why the BUILD_BUG?
> 
> To be sure that we can catch and handle any value faultin_page() can
> return.

Well sure, but to do that we use BUG().

BUILD_BUG() will fail to build and that of course is what happened.

> Could you show resulting faultin_page() from you tree? Or I can just
> rebase it on top of your tree once it will be published if you wish.

It looked like this:

				ret = faultin_page(tsk, vma, start, &foll_flags,
						nonblocking);
				switch (ret) {
				case 0:
					break;
				case -EFAULT:
				case -ENOMEM:
				case -EHWPOISON:
					return i ? i : ret;
				case -EBUSY:
					return i;
				case -ENOENT:
					goto next_page;
				default:
					BUILD_BUG();
				}

is that what you tested?


I suspect what happened is that your gcc worked out that faultin_page()
cannot return anything other than one of those six values and so the
compiler elided the BUILD_BUG() code.  But my gcc-4.4.4 isn't that smart.

For example this:

--- a/fs/open.c~a
+++ a/fs/open.c
@@ -1101,3 +1101,9 @@ int nonseekable_open(struct inode *inode
 }
 
 EXPORT_SYMBOL(nonseekable_open);
+
+void foo(void)
+{
+	if (0)
+		BUILD_BUG();
+}

compiles OK with gcc-4.4.4.

No matter, let's just leave it as a BUG().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
