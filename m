Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id 0B3256B0036
	for <linux-mm@kvack.org>; Mon, 15 Sep 2014 13:32:46 -0400 (EDT)
Received: by mail-qg0-f45.google.com with SMTP id j107so4271962qga.4
        for <linux-mm@kvack.org>; Mon, 15 Sep 2014 10:32:43 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r94si15630675qga.64.2014.09.15.10.32.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Sep 2014 10:32:40 -0700 (PDT)
Date: Mon, 15 Sep 2014 19:29:24 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [RFC PATCH v2 5/5] mm, shmem: Show location of non-resident
	shmem pages in smaps
Message-ID: <20140915172923.GA26275@redhat.com>
References: <1410791077-5300-1-git-send-email-jmarchan@redhat.com> <1410791077-5300-6-git-send-email-jmarchan@redhat.com> <20140915162131.GA22768@redhat.com> <54171829.3090108@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54171829.3090108@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Marchand <jmarchan@redhat.com>
Cc: linux-mm@kvack.org, Randy Dunlap <rdunlap@infradead.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux390@de.ibm.com, Hugh Dickins <hughd@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Mackerras <paulus@samba.org>, Ingo Molnar <mingo@redhat.com>, Arnaldo Carvalho de Melo <acme@kernel.org>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org

On 09/15, Jerome Marchand wrote:
>
> On 09/15/2014 06:21 PM, Oleg Nesterov wrote:
> > Hi Jerome,
> >
> > Not sure I understand this patch correctly, will try to read it later.
> > But a couple of nits/questions anyway,
> >
> > On 09/15, Jerome Marchand wrote:
> >>
> >> +The ShmXXX lines only appears for shmem mapping. They show the amount of memory
> >> +from the mapping that is currently:
> >> + - resident in RAM but not mapped into any process (ShmNotMapped)
> >
> > But how can we know that it is not mapped by another process?
>
> Its mapcount is zero.

Ah, yes, I missed the "!count" check. Thanks!

> > And in fact "not mapped" looks confusing (at least to me).
>
> "Not mapped" as "not present in a page table". It does belong to a
> userspace mapping though. I wonder if there is a less ambiguous terminology.

To me "not present in page tables" looks more understandable, but I won't
insist.

> > IIUC it is actually
> > mapped even by this process, just it never tried to fault these (resident or
> > swapped) pages in. Right?
>
> No these pages are in the page cache. This can happen when the only
> process which have accessed these exits or munmap() the mapping.

Yes, yes, I meant that this process didn't touch these pages and thus
pte_none() == T.

> > And I am not sure why we ignore SHMEM_SWAPCACHE...
>
> Hugh didn't like it as it is a small and transient value.

OK, but perhaps update_shmem_stats() should treat it as SHMEM_SWAP.
Nevermind, I leave this to you and Hugh.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
