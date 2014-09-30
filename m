Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id BA8026B0035
	for <linux-mm@kvack.org>; Tue, 30 Sep 2014 12:08:57 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id g10so2071022pdj.18
        for <linux-mm@kvack.org>; Tue, 30 Sep 2014 09:08:57 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id na4si27134312pbc.235.2014.09.30.09.08.56
        for <linux-mm@kvack.org>;
        Tue, 30 Sep 2014 09:08:56 -0700 (PDT)
Date: Tue, 30 Sep 2014 12:08:41 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v11 00/21] Add support for NV-DIMMs to ext4
Message-ID: <20140930160841.GB5098@wil.cx>
References: <1411677218-29146-1-git-send-email-matthew.r.wilcox@intel.com>
 <15705.1412070301@turing-police.cc.vt.edu>
 <20140930144854.GA5098@wil.cx>
 <123795.1412088827@turing-police.cc.vt.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <123795.1412088827@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Valdis.Kletnieks@vt.edu
Cc: Matthew Wilcox <willy@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Sep 30, 2014 at 10:53:47AM -0400, Valdis.Kletnieks@vt.edu wrote:
> On Tue, 30 Sep 2014 10:48:54 -0400, Matthew Wilcox said:
> 
> > No, it doesn't try to do that.  Wouldn't you be better served with an
> > LD_PRELOAD that forces O_DIRECT on?
> 
> Not when you don't want it on every file, and users are creating and
> deleting files once in a while.  A chattr-like command is easier and
> more scalable than rebuilding the LD_PRELOAD every time the list of
> files gets changed....

The more I think about this, the more I think this is a bad idea.
When you have a file open with O_DIRECT, your I/O has to be done in
512-byte multiples, and it has to be aligned to 512-byte boundaries
in memory.  If an unsuspecting application has O_DIRECT forced on it,
it isn't going to know to do that, and so all its I/Os will fail.
It'll also be horribly inefficient if a program has the file mmaped.

What problem are you really trying to solve?  Some big files hogging
the page cache?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
