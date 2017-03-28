Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7EC006B0390
	for <linux-mm@kvack.org>; Mon, 27 Mar 2017 20:51:20 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 37so77279264pgx.8
        for <linux-mm@kvack.org>; Mon, 27 Mar 2017 17:51:20 -0700 (PDT)
Received: from shells.gnugeneration.com (shells.gnugeneration.com. [66.240.222.126])
        by mx.google.com with ESMTP id v63si2249363pgd.13.2017.03.27.17.51.19
        for <linux-mm@kvack.org>;
        Mon, 27 Mar 2017 17:51:19 -0700 (PDT)
Date: Mon, 27 Mar 2017 17:52:27 -0700
From: vcaputo@pengaru.com
Subject: Re: [PATCH] shmem: fix __shmem_file_setup error path leaks
Message-ID: <20170328005227.GW802@shells.gnugeneration.com>
References: <20170327170534.GA16903@shells.gnugeneration.com>
 <20170327212127.GF29622@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170327212127.GF29622@ZenIV.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: hughd@google.com, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Mon, Mar 27, 2017 at 10:21:27PM +0100, Al Viro wrote:
> On Mon, Mar 27, 2017 at 10:05:34AM -0700, Vito Caputo wrote:
> > The existing path and memory cleanups appear to be in reverse order, and
> > there's no iput() potentially leaking the inode in the last two error gotos.
> > 
> > Also make put_memory shmem_unacct_size() conditional on !inode since if we
> > entered cleanup at put_inode, shmem_evict_inode() occurs via
> > iput()->iput_final(), which performs the shmem_unacct_size() for us.
> > 
> > Signed-off-by: Vito Caputo <vcaputo@pengaru.com>
> > ---
> > 
> > This caught my eye while looking through the memfd_create() implementation.
> > Included patch was compile tested only...
> 
> Obviously so, since you've just introduced a double iput() there.  After
>         d_instantiate(path.dentry, inode);
> dropping the reference to path.dentry (done by path_put(&path)) will drop
> the reference to inode transferred into that dentry by d_instantiate().
> NAK.

I see, so it's correct as-is, thanks for the review and apologies for the
noise!

Cheers,
Vito Caputo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
