Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f170.google.com (mail-yk0-f170.google.com [209.85.160.170])
	by kanga.kvack.org (Postfix) with ESMTP id 320406B0070
	for <linux-mm@kvack.org>; Thu,  5 Mar 2015 13:07:52 -0500 (EST)
Received: by ykr79 with SMTP id 79so23954310ykr.0
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 10:07:50 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id 188si4102269ykj.103.2015.03.05.10.07.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Mar 2015 10:07:50 -0800 (PST)
Message-ID: <54F89B61.308@parallels.com>
Date: Thu, 5 Mar 2015 21:07:29 +0300
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 14/21] userfaultfd: mcopy_atomic|mfill_zeropage: UFFDIO_COPY|UFFDIO_ZEROPAGE
 preparation
References: <1425575884-2574-1-git-send-email-aarcange@redhat.com> <1425575884-2574-15-git-send-email-aarcange@redhat.com>
In-Reply-To: <1425575884-2574-15-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Android Kernel Team <kernel-team@android.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, zhang.zhanghailiang@huawei.com, Linus Torvalds <torvalds@linux-foundation.org>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave@sr71.net>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Christopher Covington <cov@codeaurora.org>, Johannes Weiner <hannes@cmpxchg.org>, Robert Love <rlove@google.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, Keith Packard <keithp@keithp.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Anthony Liguori <anthony@codemonkey.ws>, Stefan Hajnoczi <stefanha@gmail.com>, Wenchao Xia <wenchaoqemu@gmail.com>, Andrew Jones <drjones@redhat.com>, Juan Quintela <quintela@redhat.com>

> +static int mcopy_atomic_pte(struct mm_struct *dst_mm,
> +			    pmd_t *dst_pmd,
> +			    struct vm_area_struct *dst_vma,
> +			    unsigned long dst_addr,
> +			    unsigned long src_addr)
> +{
> +	struct mem_cgroup *memcg;
> +	pte_t _dst_pte, *dst_pte;
> +	spinlock_t *ptl;
> +	struct page *page;
> +	void *page_kaddr;
> +	int ret;
> +
> +	ret = -ENOMEM;
> +	page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, dst_vma, dst_addr);
> +	if (!page)
> +		goto out;

Not a fatal thing, but still quite inconvenient. If there are two tasks that
have anonymous private VMAs that are still not COW-ed from each other, then
it will be impossible to keep the pages shared with userfault. Thus if we do
post-copy memory migration for tasks, then these guys will have their
memory COW-ed.


Thanks,
Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
