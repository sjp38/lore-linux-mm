Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 10CFF9000BD
	for <linux-mm@kvack.org>; Thu, 29 Sep 2011 12:19:50 -0400 (EDT)
Received: by bkbzs2 with SMTP id zs2so1134750bkb.14
        for <linux-mm@kvack.org>; Thu, 29 Sep 2011 09:19:48 -0700 (PDT)
Date: Thu, 29 Sep 2011 20:18:48 +0400
From: Vasiliy Kulikov <segoon@openwall.com>
Subject: Re: [PATCH 2/2] mm: restrict access to /proc/meminfo
Message-ID: <20110929161848.GA16348@albatros>
References: <20110927175453.GA3393@albatros>
 <20110927175642.GA3432@albatros>
 <20110927193810.GA5416@albatros>
 <alpine.DEB.2.00.1109271459180.13797@router.home>
 <alpine.DEB.2.00.1109271328151.24402@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1109271328151.24402@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Christoph Lameter <cl@gentwo.org>, kernel-hardening@lists.openwall.com, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Kees Cook <kees@ubuntu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Valdis.Kletnieks@vt.edu, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@linux.intel.com>, linux-kernel@vger.kernel.org

On Tue, Sep 27, 2011 at 13:33 -0700, David Rientjes wrote:
> I'd much rather just convert everything to use MB rather than KB so you 
> can't determine things at a page level.  I think that gets us much closer 
> to what the patch is intending to restrict.  But I also expect some 
> breakage from things that just expect meminfo to be in KB units without 
> parsing what the kernel is exporting.

I'm not convinced with rounding the information to MBs.  The attacker
still may fill slabs with new objects to trigger new slab pages
allocations.  He will be able to see when this MB-granularity barrier is
overrun thus seeing how many kbs there were before:

    old = new - filled_obj_size_sum

As `new' is just increased, it means it is known with KB granularity,
not MB.  By counting used slab objects he learns filled_obj_size_sum.

So, rounding gives us nothing, but obscurity.

Thanks,

-- 
Vasiliy Kulikov
http://www.openwall.com - bringing security into open computing environments

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
