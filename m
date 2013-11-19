Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id 19AEF6B0031
	for <linux-mm@kvack.org>; Tue, 19 Nov 2013 12:04:25 -0500 (EST)
Received: by mail-pb0-f53.google.com with SMTP id ma3so8530504pbc.26
        for <linux-mm@kvack.org>; Tue, 19 Nov 2013 09:04:24 -0800 (PST)
Received: from psmtp.com ([74.125.245.121])
        by mx.google.com with SMTP id pl7si1707389pac.281.2013.11.19.09.04.21
        for <linux-mm@kvack.org>;
        Tue, 19 Nov 2013 09:04:22 -0800 (PST)
Date: Tue, 19 Nov 2013 17:04:16 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH] Reimplement old functionality of vm_munmap to
 vm_munmap_mm
Message-ID: <20131119170416.GD10323@ZenIV.linux.org.uk>
References: <1384878592-194909-1-git-send-email-jcuster@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1384878592-194909-1-git-send-email-jcuster@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Custer <jcuster@sgi.com>
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jiang Liu <jiang.liu@huawei.com>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>, linux-kernel@vger.kernel.org

On Tue, Nov 19, 2013 at 10:29:52AM -0600, James Custer wrote:
> Commit bfce281c287a427d0841fadf5d59242757b4e620 killed the mm parameter to
> vm_munmap. Although the mm parameter was not used in any in-tree kernel
> modules, it is used by some out-of-tree modules.
> 
> We create a new function vm_munmap_mm that has the same functionality as
> vm_munmap, whereas vm_munmap uses current->mm, vm_munmap_mm takes the mm as
> a paramter.
> 
> Since this is a newly exported symbol it is marked EXPORT_SYMBOL_GPL.

Which modules and what are they doing with it?  More to the point,
what prevents races with e.g. dumping core?  And that's not an idle
question - for example, fs/aio.c used to contain very unpleasant
races of that kind exactly because it was playing games with modifying
->mm other than current->mm.

In other words, NAK.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
