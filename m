Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1FE9B6B0253
	for <linux-mm@kvack.org>; Tue, 26 Jul 2016 15:23:45 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id c52so38353570qte.2
        for <linux-mm@kvack.org>; Tue, 26 Jul 2016 12:23:45 -0700 (PDT)
Received: from mail-qt0-f180.google.com (mail-qt0-f180.google.com. [209.85.216.180])
        by mx.google.com with ESMTPS id s5si541187ybf.337.2016.07.26.12.23.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jul 2016 12:23:44 -0700 (PDT)
Received: by mail-qt0-f180.google.com with SMTP id 52so16658316qtq.3
        for <linux-mm@kvack.org>; Tue, 26 Jul 2016 12:23:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160725134732.b21912c54ef1ffe820ccdbca@linux-foundation.org>
References: <1469457565-22693-1-git-send-email-kwalker@redhat.com> <20160725134732.b21912c54ef1ffe820ccdbca@linux-foundation.org>
From: Kyle Walker <kwalker@redhat.com>
Date: Tue, 26 Jul 2016 15:23:42 -0400
Message-ID: <CAEPKNTJjqcmap70nEaVVixK9486mp=-MKuDBCCdHdP4cx-D2Yw@mail.gmail.com>
Subject: Re: [PATCH] mm: Move readahead limit outside of readahead, and
 advisory syscalls
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.com>, Geliang Tang <geliangtang@163.com>, Vlastimil Babka <vbabka@suse.cz>, Roman Gushchin <klamm@yandex-team.ru>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>

On Mon, Jul 25, 2016 at 4:47 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
>
> Can this suffering be quantified please?
>

The observed suffering is primarily visible within an IBM Qradar
installation. From a high level, the lower limit to the amount of advisory
readahead pages results in a 3-5x increase in time necessary to complete
an identical query within the application.

Note, all of the below values are with Readahead configured to 64Kib.

Baseline behaviour - Prior to:
 600e19af ("mm: use only per-device readahead limit")
 6d2be915 ("mm/readahead.c: fix readahead failure for memoryless NUMA
           nodes and limit readahead pages")

Result:
 Qradar - Command: "username equals root" - 57.3s to complete search


New performance - With:
 600e19af ("mm: use only per-device readahead limit")
 6d2be915 ("mm/readahead.c: fix readahead failure for memoryless NUMA
           nodes and limit readahead pages")

Result:
 Qradar - "username equals root" query - 245.7s to complete search


Proposed behaviour - With the proposed patch in place.

Result:
 Qradar - "username equals root" query - 57s to complete search


In narrowing the source of the performance deficit, it was observed that
the amount of data loaded into pagecache via madvise was quite a bit lower
following the noted commits. As simply reverting those lower limits were
not accepted previously, the proposed alternative strategy seemed like the
most beneficial path forwards.

>
> Linus probably has opinions ;)
>

I understand that changes to readahead that are very similar have been
proposed quite a bit lately. If there are any changes or testing needed,
I'm more than happy to tackle that.


Thank you in advance!
-- 
Kyle Walker

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
