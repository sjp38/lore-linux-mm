Date: Thu, 11 Oct 2007 14:47:40 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: msync(2) bug(?), returns AOP_WRITEPAGE_ACTIVATE to userland
Message-Id: <20071011144740.136b31a8.akpm@linux-foundation.org>
In-Reply-To: <200710071920.l97JKJX5018871@agora.fsl.cs.sunysb.edu>
References: <200710071920.l97JKJX5018871@agora.fsl.cs.sunysb.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Erez Zadok <ezk@cs.sunysb.edu>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, ryan@finnie.org, cjwatson@ubuntu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 7 Oct 2007 15:20:19 -0400
Erez Zadok <ezk@cs.sunysb.edu> wrote:

> According to vfs.txt, ->writepage() may return AOP_WRITEPAGE_ACTIVATE back
> to the VFS/VM.  Indeed some filesystems such as tmpfs can return
> AOP_WRITEPAGE_ACTIVATE; and stackable file systems (e.g., Unionfs) also
> return AOP_WRITEPAGE_ACTIVATE if the lower f/s returned it.
> 
> Anyway, some Ubuntu users of Unionfs reported that msync(2) sometimes
> returns AOP_WRITEPAGE_ACTIVATE (decimal 524288) back to userland.
> Therefore, some user programs fail, esp. if they're written such as this:
> 
>      err = msync(...);
>      if (err != 0)
> 	// fail
> 
> They temporarily fixed the specific program in question (apt-get) to check
> 
>      if (err < 0)
> 	// fail
> 
> Is this a bug indeed, or are user programs supposed to handle
> AOP_WRITEPAGE_ACTIVATE (I hope not the latter).  If it's a kernel bug, what
> should the kernel return: a zero, or an -errno (and which one)?
> 

shit.  That's a nasty bug.  Really userspace should be testing for -1, but
the msync() library function should only ever return 0 or -1.

Does this fix it?

--- a/mm/page-writeback.c~a
+++ a/mm/page-writeback.c
@@ -850,8 +850,10 @@ retry:
 
 			ret = (*writepage)(page, wbc, data);
 
-			if (unlikely(ret == AOP_WRITEPAGE_ACTIVATE))
+			if (unlikely(ret == AOP_WRITEPAGE_ACTIVATE)) {
 				unlock_page(page);
+				ret = 0;
+			}
 			if (ret || (--(wbc->nr_to_write) <= 0))
 				done = 1;
 			if (wbc->nonblocking && bdi_write_congested(bdi)) {
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
