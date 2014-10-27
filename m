Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 5198C900021
	for <linux-mm@kvack.org>; Mon, 27 Oct 2014 16:49:13 -0400 (EDT)
Received: by mail-wg0-f50.google.com with SMTP id z12so4047100wgg.33
        for <linux-mm@kvack.org>; Mon, 27 Oct 2014 13:49:12 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id ew3si11813780wib.48.2014.10.27.13.49.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 27 Oct 2014 13:49:11 -0700 (PDT)
Date: Mon, 27 Oct 2014 21:49:01 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v9 11/12] x86, mpx: cleanup unused bound tables
In-Reply-To: <544DB873.1010207@intel.com>
Message-ID: <alpine.DEB.2.11.1410272138540.5308@nanos>
References: <1413088915-13428-1-git-send-email-qiaowei.ren@intel.com> <1413088915-13428-12-git-send-email-qiaowei.ren@intel.com> <alpine.DEB.2.11.1410241451280.5308@nanos> <544DB873.1010207@intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ren Qiaowei <qiaowei.ren@intel.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, Dave Hansen <dave.hansen@intel.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org

On Mon, 27 Oct 2014, Ren Qiaowei wrote:
> If so, I guess that there are some questions needed to be considered:
> 
> 1) Almost all palces which call do_munmap() will need to add
> mpx_pre_unmap/post_unmap calls, like vm_munmap(), mremap(), shmdt(), etc..

What's the problem with that?
 
> 2) before mpx_post_unmap() call, it is possible for those bounds tables within
> mm->bd_remove_vmas to be re-used.
>
> In this case, userspace may do new mapping and access one address which will
> cover one of those bounds tables. During this period, HW will check if one
> bounds table exist, if yes one fault won't be produced.

Errm. Before user space can use the bounds table for the new mapping
it needs to add the entries, right? So:

CPU 0					CPU 1

down_write(mm->bd_sem);
mpx_pre_unmap();
   clear bounds directory entries	
unmap();
					map()
					write_bounds_entry()
					trap()
					  down_read(mm->bd_sem);
mpx_post_unmap(); 
up_write(mm->bd_sem);
					  allocate_bounds_table();

That's the whole point of bd_sem.

> 3) According to Dave, those bounds tables related to adjacent VMAs within the
> start and the end possibly don't have to be fully unmmaped, and we only need
> free the part of backing physical memory.

Care to explain why that's a problem?
 
Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
