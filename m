Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 219416B0072
	for <linux-mm@kvack.org>; Wed, 16 Nov 2011 18:22:20 -0500 (EST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Wed, 16 Nov 2011 18:22:17 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pAGNMFe8224578
	for <linux-mm@kvack.org>; Wed, 16 Nov 2011 18:22:15 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pAGNMDeN010329
	for <linux-mm@kvack.org>; Wed, 16 Nov 2011 21:22:14 -0200
Subject: Re: [Patch] tmpfs: add fallocate support
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <4EC36494.30803@redhat.com>
References: <1321346525-10187-1-git-send-email-amwang@redhat.com>
	 <4EC23DB0.3020306@redhat.com> <1321379039.12374.11.camel@nimitz>
	 <4EC36494.30803@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 16 Nov 2011 15:21:55 -0800
Message-ID: <1321485715.12374.56.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cong Wang <amwang@redhat.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Lennart Poettering <lennart@poettering.net>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Wed, 2011-11-16 at 15:21 +0800, Cong Wang wrote:
> ao? 2011a1'11ae??16ae?JPY 01:43, Dave Hansen a??e??:
> > On Tue, 2011-11-15 at 18:23 +0800, Cong Wang wrote:
> >>> +	if (!(mode&   FALLOC_FL_KEEP_SIZE)) {
> >>> +		ret = inode_newsize_ok(inode, (offset + len));
> >>> +		if (ret)
> >>> +			return ret;
> >>> +	}
> >
> > inode_newsize_ok()'s comments say:
> >
> >   * inode_newsize_ok must be called with i_mutex held.
> >
> > But I don't see any trace of it.
> 
> Hmm, even for tmpfs? I see none of the tmpfs code takes
> i_mutex lock though...

Look harder. :)

ramfs/tmpfs for a large part just used the generic VFS functions to do
their work since they're page-cache based.  For instance:

static const struct file_operations shmem_file_operations = {
...
        .aio_write      = generic_file_aio_write,

IOW, you need to check beyond mm/shmem.c.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
