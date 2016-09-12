Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id DAAF36B0069
	for <linux-mm@kvack.org>; Mon, 12 Sep 2016 18:21:49 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id g202so390207582pfb.3
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 15:21:49 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id pz3si14761071pac.95.2016.09.12.15.21.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Sep 2016 15:21:49 -0700 (PDT)
Date: Mon, 12 Sep 2016 15:21:48 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH, RESEND] ipc/shm: fix crash if CONFIG_SHMEM is not set
Message-Id: <20160912152148.0b8ef73e32bbc28104356bb7@linux-foundation.org>
In-Reply-To: <20160912102704.140442-1-kirill.shutemov@linux.intel.com>
References: <20160912102704.140442-1-kirill.shutemov@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: linux-mm@kvack.org, Hugh Dickins <hughd@google.com>

On Mon, 12 Sep 2016 13:27:04 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:

> Commit c01d5b300774 makes use of shm_get_unmapped_area() in
> shm_file_operations() unconditional to CONFIG_MMU.
> 
> As Tony Battersby pointed this can lead NULL-pointer dereference on
> machine with CONFIG_MMU=y and CONFIG_SHMEM=n. In this case ipc/shm is
> backed by ramfs which doesn't provide f_op->get_unmapped_area for
> configurations with MMU.
> 
> The solution is to provide dummy f_op->get_unmapped_area for ramfs when
> CONFIG_MMU=y, which just call current->mm->get_unmapped_area().
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Reported-and-Tested-by: Tony Battersby <tonyb@cybernetics.com>
> Fixes: c01d5b300774 ("shmem: get_unmapped_area align huge page")

I'll add

Cc: <stable@vger.kernel.org>    [4.7.x]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
