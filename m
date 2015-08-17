Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id C67016B0253
	for <linux-mm@kvack.org>; Mon, 17 Aug 2015 18:05:23 -0400 (EDT)
Received: by qged69 with SMTP id d69so104083448qge.0
        for <linux-mm@kvack.org>; Mon, 17 Aug 2015 15:05:23 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id n127si19671852qhb.62.2015.08.17.15.05.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Aug 2015 15:05:23 -0700 (PDT)
Date: Mon, 17 Aug 2015 15:05:21 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/memblock: validate the creation of debugfs files
Message-Id: <20150817150521.4f353d130a2d67e89b7ac1ad@linux-foundation.org>
In-Reply-To: <20150815160730.GB25186@kroah.com>
References: <1439579011-14918-1-git-send-email-kuleshovmail@gmail.com>
	<20150814141944.4172fee6c9d7ae02a6258c80@linux-foundation.org>
	<20150815072636.GA2539@localhost>
	<20150815003830.c87afaff.akpm@linux-foundation.org>
	<20150815160730.GB25186@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Alexander Kuleshov <kuleshovmail@gmail.com>, Tony Luck <tony.luck@intel.com>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Baoquan He <bhe@redhat.com>, Tang Chen <tangchen@cn.fujitsu.com>, Robin Holt <holt@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, 15 Aug 2015 09:07:30 -0700 Greg Kroah-Hartman <gregkh@linuxfoundation.org> wrote:

> > > in the kernel/kprobes and etc.), besides this, the memblock API is used
> > > mostly at early stage, so we will have some output if something going wrong.
> > 
> > The debugfs error-handling rules are something Greg cooked up after one
> > too many beers.  I've never understood them, but maybe I continue to
> > miss the point.
> 
> The "point" is that it should be easy to use, and you don't care if the
> file fails to be created because your normal code flow / functionality
> does not care if a debugfs file fails to be created.
> 
> The only way a debugfs file will fail to be created is if you name
> something the same as a file is present, or you passed in the wrong
> options, or if you are out of memory, and in all of those cases, there's
> nothing a user can do about it.  Yes, when writing your code the first
> time, check the error if you want to figure out your logic, but after
> that, you don't care.
> 
> If debugfs is not enabled, yes, an error will be returned, but you don't
> have to care about that, because again, you don't care, and your main
> code path is just fine.
> 
> So just ignore the return value of debugfs functions, except to save off
> pointers that you need to pass back in them later.
> 
> > Yes, I agree that if memblock's debugfs_create_file() fails, we want to
> > know about it because something needs fixing.
> 
> What can be fixed?  Out of memory?  Identical file name?  Nothing a user
> can do about that.

wha?  We have thousands and thousands of assertions in the kernel and
there's nothing the user can do about any them, apart from sending us a
bug report.

If debugfs_create_file() fails then something is messed up in the
kernel.  The kernel error shouldn't just be ignored!  It should be
reported and fixed.

> > But that's true of
> > all(?) debugfs_create_file callsites, so it's a bit silly to add
> > warnings to them all.  Why not put the warning into
> > debugfs_create_file() itself?  And add a debugfs_create_file_no_warn()
> > if there are callsites which have reason to go it alone.  Or add a
> > debugfs_create_file_warn() wrapper.
> 
> No, it's really not worth it.  The goal of debugfs was to make an api
> that is easier to use than procfs which required a bunch of odd return
> error checks and you could never tell if the error was due to something
> real or if the procfs was not enabled in the kernel.
> 
> And it's for debugging files, again, nothing that should be something
> you rely on.  If you rely on debugfs files for something, well, you are
> using the wrong api (yes, I know all about the trace nightmare...)

Yeah.  That's just wrong.  debugfs is just kernel code.  If it goes
wrong we should handle that in the usual way, so it gets fixed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
