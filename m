Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 635616B0253
	for <linux-mm@kvack.org>; Sat,  6 Aug 2016 04:12:59 -0400 (EDT)
Received: by mail-ua0-f197.google.com with SMTP id r91so437329582uar.2
        for <linux-mm@kvack.org>; Sat, 06 Aug 2016 01:12:59 -0700 (PDT)
Received: from mail-yb0-x233.google.com (mail-yb0-x233.google.com. [2607:f8b0:4002:c09::233])
        by mx.google.com with ESMTPS id k63si3462617ywg.14.2016.08.06.01.12.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 06 Aug 2016 01:12:58 -0700 (PDT)
Received: by mail-yb0-x233.google.com with SMTP id e125so21721136ybc.0
        for <linux-mm@kvack.org>; Sat, 06 Aug 2016 01:12:58 -0700 (PDT)
Date: Sat, 6 Aug 2016 01:12:45 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: shmem: Are we accounting block right?
In-Reply-To: <006b01d1eee6$338c0c40$9aa424c0$@alibaba-inc.com>
Message-ID: <alpine.LSU.2.11.1608060054240.9810@eggly.anvils>
References: <006b01d1eee6$338c0c40$9aa424c0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org

On Fri, 5 Aug 2016, Hillf Danton wrote:

> Hi all
> 
> Currently in mainline we do block account if the flags parameter 
> carries VM_NORESERVE. 

Yes.  (VM_NORESERVE being set in tmpfs file flags,
but usually not on SysV SHM and mmaps of /dev/zero.)

> 
> But blocks should be accounted if reserved, as shown by the
> following diff.

Blocks should be accounted one by one as they are instantiated
(tmpfs), unless the total size was all reserved upfront (SHM).

> 
> Am I missing anything?

Apparently, but I'm not sure what.  Maybe the comments
above shmem_acct_size() and shmem_acct_block() will help.

Hugh

> 
> thanks
> Hillf
> 
> --- a/mm/shmem.c	Fri Aug  5 14:01:59 2016
> +++ b/mm/shmem.c	Fri Aug  5 14:36:31 2016
> @@ -168,7 +168,7 @@ static inline int shmem_reacct_size(unsi
>   */
>  static inline int shmem_acct_block(unsigned long flags, long pages)
>  {
> -	if (!(flags & VM_NORESERVE))
> +	if (flags & VM_NORESERVE)
>  		return 0;
>  
>  	return security_vm_enough_memory_mm(current->mm,
> @@ -177,7 +177,7 @@ static inline int shmem_acct_block(unsig
>  
>  static inline void shmem_unacct_blocks(unsigned long flags, long pages)
>  {
> -	if (flags & VM_NORESERVE)
> +	if (!(flags & VM_NORESERVE))
>  		vm_unacct_memory(pages * VM_ACCT(PAGE_SIZE));
>  }
>  
> --

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
