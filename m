Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id E60676B0253
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 15:48:24 -0500 (EST)
Received: by mail-pf0-f175.google.com with SMTP id q63so107367755pfb.1
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 12:48:24 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id l81si4131311pfb.18.2016.01.26.12.48.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jan 2016 12:48:24 -0800 (PST)
Date: Tue, 26 Jan 2016 12:48:23 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: mm: VM_BUG_ON_PAGE(PageTail(page)) in mbind
Message-Id: <20160126124823.15b08f0a53dd9671fbc685d9@linux-foundation.org>
In-Reply-To: <20160126202829.GA21250@node.shutemov.name>
References: <CACT4Y+YK7or=W4RGpv1k1T5-xDHu3_PPVZWqsQU6nWoArsV5vA@mail.gmail.com>
	<20160126202829.GA21250@node.shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Dmitry Vyukov <dvyukov@google.com>, Doug Gilbert <dgilbert@interlog.com>, David Rientjes <rientjes@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Shiraz Hashim <shashim@codeaurora.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Sasha Levin <sasha.levin@oracle.com>, syzkaller <syzkaller@googlegroups.com>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>, linux-scsi@vger.kernel.org

On Tue, 26 Jan 2016 22:28:29 +0200 "Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> The patch below fixes the issue for me, but this bug makes me wounder how
> many bugs like this we have in kernel... :-/
> 
> Looks like we are too permissive about which VMA is migratable:
> vma_migratable() filters out VMA by VM_IO and VM_PFNMAP.
> I think VM_DONTEXPAND also correlate with VMA which cannot be migrated.
> 
> $ git grep VM_DONTEXPAND drivers | grep -v '\(VM_IO\|VM_PFNMAN\)' | wc -l 
> 33
> 
> Hm.. :-|
> 
> It worth looking on them closely... And I wouldn't be surprised if some
> VMAs without all of these flags are not migratable too.
> 
> Sigh.. Any thoughts?

Sigh indeed.  I think that both VM_DONTEXPAND and VM_DONTDUMP are
pretty good signs that mbind() should not be mucking with this vma.  If
such a policy sometimes results in mbind failing to set a policy then
that's not a huge loss - something runs a bit slower maybe.

I mean, we only really expect mbind() to operate against regular old
anon/pagecache memory, yes?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
