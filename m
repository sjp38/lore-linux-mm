Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 18B906B0089
	for <linux-mm@kvack.org>; Thu,  5 Mar 2015 12:48:52 -0500 (EST)
Received: by igal13 with SMTP id l13so47793114iga.5
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 09:48:51 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id 37si9273042iok.100.2015.03.05.09.48.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Mar 2015 09:48:51 -0800 (PST)
Message-ID: <54F896E6.2010800@parallels.com>
Date: Thu, 5 Mar 2015 20:48:22 +0300
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 05/21] userfaultfd: add vm_userfaultfd_ctx to the vm_area_struct
References: <1425575884-2574-1-git-send-email-aarcange@redhat.com> <1425575884-2574-6-git-send-email-aarcange@redhat.com>
In-Reply-To: <1425575884-2574-6-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Android Kernel Team <kernel-team@android.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, zhang.zhanghailiang@huawei.com, Linus Torvalds <torvalds@linux-foundation.org>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave@sr71.net>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Christopher Covington <cov@codeaurora.org>, Johannes Weiner <hannes@cmpxchg.org>, Robert Love <rlove@google.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, Keith Packard <keithp@keithp.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Anthony Liguori <anthony@codemonkey.ws>, Stefan Hajnoczi <stefanha@gmail.com>, Wenchao Xia <wenchaoqemu@gmail.com>, Andrew Jones <drjones@redhat.com>, Juan Quintela <quintela@redhat.com>

> diff --git a/kernel/fork.c b/kernel/fork.c
> index cf65139..cb215c0 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -425,6 +425,7 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
>  			goto fail_nomem_anon_vma_fork;
>  		tmp->vm_flags &= ~VM_LOCKED;
>  		tmp->vm_next = tmp->vm_prev = NULL;
> +		tmp->vm_userfaultfd_ctx = NULL_VM_UFFD_CTX;

This creates an interesting effect when the userfaultfd is used outside of
the process which created and activated one. If I try to monitor the memory
usage of one task with another, once the first task fork()-s, its child
begins to see zero-pages in the places where the monitor task was supposed
to insert pages with data.

>  		file = tmp->vm_file;
>  		if (file) {
>  			struct inode *inode = file_inode(file);
> .
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
