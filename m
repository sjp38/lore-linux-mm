Received: by rv-out-0708.google.com with SMTP id f25so1289679rvb.26
        for <linux-mm@kvack.org>; Sun, 20 Jul 2008 17:09:27 -0700 (PDT)
Message-ID: <2f11576a0807201709q45aeec3cvb99b0049421245ae@mail.gmail.com>
Date: Mon, 21 Jul 2008 09:09:26 +0900
From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH -mm] mm: more likely reclaim MADV_SEQUENTIAL mappings
In-Reply-To: <87y73x4w6y.fsf@saeurebad.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <87y73x4w6y.fsf@saeurebad.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Johannes Weiner <hannes@saeurebad.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Nossum <vegard.nossum@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi Johannes,

> File pages accessed only once through sequential-read mappings between
> fault and scan time are perfect candidates for reclaim.
>
> This patch makes page_referenced() ignore these singular references and
> the pages stay on the inactive list where they likely fall victim to the
> next reclaim phase.
>
> Already activated pages are still treated normally.  If they were
> accessed multiple times and therefor promoted to the active list, we
> probably want to keep them.
>
> Benchmarks show that big (relative to the system's memory)
> MADV_SEQUENTIAL mappings read sequentially cause much less kernel
> activity.  Especially less LRU moving-around because we never activate
> read-once pages in the first place just to demote them again.
>
> And leaving these perfect reclaim candidates on the inactive list makes
> it more likely for the real working set to survive the next reclaim
> scan.

looks good to me.
Actually, I made similar patch half year ago.

in my experience,
  - page_referenced_one is performance critical point.
    you should test some benchmark.
  - its patch improved mmaped-copy performance about 5%.
    (Of cource, you should test in current -mm. MM code was changed widely)

So, I'm looking for your test result :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
