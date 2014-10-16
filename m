Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 6CAB16B006E
	for <linux-mm@kvack.org>; Fri, 17 Oct 2014 03:18:55 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id ft15so308980pdb.3
        for <linux-mm@kvack.org>; Fri, 17 Oct 2014 00:18:55 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id d9si406897pdj.139.2014.10.17.00.18.54
        for <linux-mm@kvack.org>;
        Fri, 17 Oct 2014 00:18:54 -0700 (PDT)
Date: Thu, 16 Oct 2014 17:44:10 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v11 12/21] vfs: Remove get_xip_mem
Message-ID: <20141016214410.GH11522@wil.cx>
References: <1411677218-29146-1-git-send-email-matthew.r.wilcox@intel.com>
 <1411677218-29146-13-git-send-email-matthew.r.wilcox@intel.com>
 <20141016121446.GJ19075@thinkos.etherlink>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141016121446.GJ19075@thinkos.etherlink>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Oct 16, 2014 at 02:14:46PM +0200, Mathieu Desnoyers wrote:
> > +++ b/fs/open.c
> > @@ -655,11 +655,8 @@ int open_check_o_direct(struct file *f)
> >  {
> >  	/* NB: we're sure to have correct a_ops only after f_op->open */
> >  	if (f->f_flags & O_DIRECT) {
> > -		if (!f->f_mapping->a_ops ||
> > -		    ((!f->f_mapping->a_ops->direct_IO) &&
> > -		    (!f->f_mapping->a_ops->get_xip_mem))) {
> > +		if (!f->f_mapping->a_ops || !f->f_mapping->a_ops->direct_IO)
> 
> Why is it OK to remove the check for get_xip_mem callback here, rather
> than replacing it with a IS_DAX check like the rest of this patch does ?
> I'm probably missing something.

XIP used to intercept I/Os by having the filesystem's ->read & ->write
methods call xip_file_read (/write).  That would do the I/O, and so there
was no need to have a ->direct_IO element in a_ops.  For DAX, we use the
generic VFS code to call back into the filesystem's ->direct_IO entry
point, so the check above for ->direct_IO now checks for both regular
and DAX support.

Or to put it another way, DAX now requires that the filesystem support
O_DIRECT.  Which is pretty much the way it has to be anyway, since DAX
is direct!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
