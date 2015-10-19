Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 6CB4D6B028C
	for <linux-mm@kvack.org>; Mon, 19 Oct 2015 19:30:37 -0400 (EDT)
Received: by wicll6 with SMTP id ll6so4065765wic.1
        for <linux-mm@kvack.org>; Mon, 19 Oct 2015 16:30:37 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x1si861476wia.29.2015.10.19.16.30.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 19 Oct 2015 16:30:36 -0700 (PDT)
Date: Mon, 19 Oct 2015 16:30:22 -0700
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: Re: [PATCH 2/12] mm: rmap use pte lock not mmap_sem to set
 PageMlocked
Message-ID: <20151019233022.GA27292@linux-uzut.site>
References: <alpine.LSU.2.11.1510182132470.2481@eggly.anvils>
 <alpine.LSU.2.11.1510182148040.2481@eggly.anvils>
 <56248C5B.3040505@suse.cz>
 <alpine.LSU.2.11.1510190341490.3809@eggly.anvils>
 <20151019131308.GB15819@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20151019131308.GB15819@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Hugh Dickins <hughd@google.com>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Oleg Nesterov <oleg@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Andrey Konovalov <andreyknvl@google.com>, Dmitry Vyukov <dvyukov@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org

On Mon, 19 Oct 2015, Kirill A. Shutemov wrote:

>I think we need to have at lease WRITE_ONCE() everywhere we update
>vm_flags and READ_ONCE() where we read it without mmap_sem taken.

Given the CPU-CPU interaction, lockless/racy vm_flag checks should
actually be using barrier pairing, afaict. This is expensive obviously,
but I cannot recall what other places we do lockless games with vm_flags.

Perhaps its time to introduce formal helpers around vma->vm_flags such
that we can encapsulate such things: __vma_[set/read]_vmflags() or whatever
that would be used for those racy scenarios.

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
