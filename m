Received: by nz-out-0506.google.com with SMTP id s1so810715nze
        for <linux-mm@kvack.org>; Thu, 01 Nov 2007 01:02:44 -0700 (PDT)
Message-ID: <45a44e480711010102s6ef51f67wff4a796deab0910b@mail.gmail.com>
Date: Thu, 1 Nov 2007 04:02:44 -0400
From: "Jaya Kumar" <jayakumar.lkml@gmail.com>
Subject: Re: vm_ops.page_mkwrite() fails with vmalloc on 2.6.23
In-Reply-To: <Pine.LNX.4.64.0710301535270.9322@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <1193064057.16541.1.camel@matrix> <1193677302.27652.56.camel@twins>
	 <45a44e480710291051s7ffbb582x64ea9524c197b48a@mail.gmail.com>
	 <1193681839.27652.60.camel@twins> <1193696211.5644.100.camel@lappy>
	 <45a44e480710291822w5864b3beofcf432930d3e68d3@mail.gmail.com>
	 <1193738177.27652.69.camel@twins>
	 <45a44e480710300616p34b0a159m87de78d0a4d43028@mail.gmail.com>
	 <1193750751.27652.86.camel@twins>
	 <Pine.LNX.4.64.0710301535270.9322@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, stefani@seibold.net, linux-kernel@vger.kernel.org, David Howells <dhowells@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Oct 30, 2007 11:47 AM, Hugh Dickins <hugh@veritas.com> wrote:
>
> I don't understand why you suggested an anon_vma, nor why Jaya is
> suggesting a private list.  All vmas mapping /dev/fb0 will be kept
> in the prio_tree rooted in its struct address_space (__vma_link_file
> in mm/mmap.c).  And page_mkclean gets page_mkclean_file to walk that
> very tree.  The missing part is just the setting of page->mapping to
> point to that struct address_space (and clearing it before finally
> freeing the pages), and the setting of page->index as you described.
> Isn't it?

Oops, sorry that I missed that. Now I understand. I think:

page->mapping = vma->vm_file->f_mapping
page->index = ((addr - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff

at nopage time and then before the driver vfrees, I'll clear mapping
for all those pages.

Thanks,
jaya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
