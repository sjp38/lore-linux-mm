Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 8A4915F0001
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 09:57:00 -0400 (EDT)
Date: Tue, 7 Apr 2009 15:57:46 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 0/4] ksm - dynamic page sharing driver for linux v2
Message-ID: <20090407135745.GA21874@random.random>
References: <1238855722-32606-1-git-send-email-ieidus@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1238855722-32606-1-git-send-email-ieidus@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Izik Eidus <ieidus@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org, avi@redhat.com, chrisw@redhat.com, mtosatti@redhat.com, hugh@veritas.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Sat, Apr 04, 2009 at 05:35:18PM +0300, Izik Eidus wrote:
> From v1 to v2:
> 
> 1)Fixed security issue found by Chris Wright:
>     Ksm was checking if page is a shared page by running !PageAnon.
>     Beacuse that Ksm scan only anonymous memory, all !PageAnons
>     inside ksm data strctures are shared page, however there might
>     be a case for do_wp_page() when the VM_SHARED is used where
>     do_wp_page() would instead of copying the page into new anonymos
>     page, would reuse the page, it was fixed by adding check for the
>     dirty_bit of the virtual addresses pointing into the shared page.
>     I was not finding any VM code tha would clear the dirty bit from
>     this virtual address (due to the fact that we allocate the page
>     using page_alloc() - kernel allocated pages), ~but i still want
>     confirmation about this from the vm guys - thanks.~

As far as I can tell this wasn't a bug and this change is
unnecessary. I already checked this bit but I may have missed
something, so I ask here to be sure.

As far as I can tell when VM_SHARED is set, no anonymous page can ever
be allocated by in that vma range, hence no KSM page can ever be
generated in that vma either. MAP_SHARED|MAP_ANONYMOUS is only a
different API for /dev/shm, IPCSHM backing, no anonymous pages can
live there. It surely worked like that in older 2.6, reading latest
code it seems to still work like that, but if something has changed
Hugh will surely correct me in a jiffy ;).

I still see this in the file=null path.
  
  } else if (vm_flags & VM_SHARED) {
    error = shmem_zero_setup(vma);
    	  if (error)
		goto free_vma;
		}


So you can revert your change for now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
