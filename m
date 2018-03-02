Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6925F6B0006
	for <linux-mm@kvack.org>; Fri,  2 Mar 2018 14:40:00 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id c37so7035382wra.5
        for <linux-mm@kvack.org>; Fri, 02 Mar 2018 11:40:00 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id a8si4815837wri.214.2018.03.02.11.39.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Mar 2018 11:39:59 -0800 (PST)
Date: Fri, 2 Mar 2018 11:39:56 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/1] mm: gup: teach get_user_pages_unlocked to handle
 FOLL_NOWAIT
Message-Id: <20180302113956.0c0763f6c7cd47e104a59118@linux-foundation.org>
In-Reply-To: <20180302174343.5421-2-aarcange@redhat.com>
References: <20180302174343.5421-1-aarcange@redhat.com>
	<20180302174343.5421-2-aarcange@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, qemu-devel@nongnu.org, linux-mm@kvack.org

On Fri,  2 Mar 2018 18:43:43 +0100 Andrea Arcangeli <aarcange@redhat.com> wrote:

> KVM is hanging during postcopy live migration with userfaultfd because
> get_user_pages_unlocked is not capable to handle FOLL_NOWAIT.
> 
> Earlier FOLL_NOWAIT was only ever passed to get_user_pages.
> 
> Specifically faultin_page (the callee of get_user_pages_unlocked
> caller) doesn't know that if FAULT_FLAG_RETRY_NOWAIT was set in the
> page fault flags, when VM_FAULT_RETRY is returned, the mmap_sem wasn't
> actually released (even if nonblocking is not NULL). So it sets
> *nonblocking to zero and the caller won't release the mmap_sem
> thinking it was already released, but it wasn't because of
> FOLL_NOWAIT.
> 
> Reported-by: Dr. David Alan Gilbert <dgilbert@redhat.com>
> Tested-by: Dr. David Alan Gilbert <dgilbert@redhat.com>
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

I added

Fixes: ce53053ce378c ("kvm: switch get_user_page_nowait() to get_user_pages_unlocked()")
Cc: <stable@vger.kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
