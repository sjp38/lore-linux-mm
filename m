Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 69D546B0009
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 16:18:47 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id a4so2653700wme.1
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 13:18:47 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id uv9si47079768wjc.29.2016.02.23.13.18.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Feb 2016 13:18:46 -0800 (PST)
Date: Tue, 23 Feb 2016 13:18:44 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/1] mm: thp: fix SMP race condition between THP page
 fault and MADV_DONTNEED
Message-Id: <20160223131844.d5d2767a0cc44bd8cbb78221@linux-foundation.org>
In-Reply-To: <1456253350-3959-2-git-send-email-aarcange@redhat.com>
References: <20160223154950.GA22449@node.shutemov.name>
	<1456253350-3959-1-git-send-email-aarcange@redhat.com>
	<1456253350-3959-2-git-send-email-aarcange@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: "\\\"Kirill A. Shutemov\\\"" <kirill@shutemov.name>, linux-mm@kvack.org, stable@vger.kernel.org

On Tue, 23 Feb 2016 19:49:10 +0100 Andrea Arcangeli <aarcange@redhat.com> wrote:

> pmd_trans_unstable()/pmd_none_or_trans_huge_or_clear_bad() were
> introduced to locklessy (but atomically) detect when a pmd is a
> regular (stable) pmd or when the pmd is unstable and can infinitely
> transition from pmd_none() and pmd_trans_huge() from under us, while
> only holding the mmap_sem for reading (for writing not).
> 
> While holding the mmap_sem only for reading, MADV_DONTNEED can run
> from under us and so before we can assume the pmd to be a regular
> stable pmd we need to compare it against pmd_none() and
> pmd_trans_huge() in an atomic way, with pmd_trans_unstable(). The old
> pmd_trans_huge() left a tiny window for a race.
> 
> Useful applications are unlikely to notice the difference as doing
> MADV_DONTNEED concurrently with a page fault would lead to undefined
> behavior.

Thanks.

I put a cc:stable on this as it appears to be applicable to 4.4 and
perhaps earlier.

It generates a reject against 4.4 because of the recently-added
pmd_devmap() test.  It's easily fixed but I don't have a process to
handle -stable rejects.  This means that when Greg hits the reject
he'll ask us for a fixed up version.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
