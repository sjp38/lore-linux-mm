Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id D88706B0038
	for <linux-mm@kvack.org>; Sun,  4 Sep 2016 23:58:59 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id ag5so356077754pad.2
        for <linux-mm@kvack.org>; Sun, 04 Sep 2016 20:58:59 -0700 (PDT)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id 205si15881752pfw.133.2016.09.04.20.58.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Sep 2016 20:58:59 -0700 (PDT)
Received: by mail-pa0-x231.google.com with SMTP id hb8so57903735pac.2
        for <linux-mm@kvack.org>; Sun, 04 Sep 2016 20:58:58 -0700 (PDT)
Date: Mon, 5 Sep 2016 12:59:08 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [RFC 0/4] ZRAM: make it just store the high compression rate page
Message-ID: <20160905035908.GA552@swordfish>
References: <1471854309-30414-1-git-send-email-zhuhui@xiaomi.com>
 <20160825060957.GA568@swordfish>
 <CANFwon3aXLz=EOdsArS5Ou4pMTr6nFuHfW1UKV6WGnCYNWk1kg@mail.gmail.com>
 <20160905021852.GB22701@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160905021852.GB22701@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Hui Zhu <teawater@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Hui Zhu <zhuhui@xiaomi.com>, ngupta@vflare.org, Hugh Dickins <hughd@google.com>, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, acme@kernel.org, alexander.shishkin@linux.intel.com, Andrew Morton <akpm@linux-foundation.org>, mhocko@suse.com, hannes@cmpxchg.org, mgorman@techsingularity.net, vbabka@suse.cz, redkoi@virtuozzo.com, luto@kernel.org, kirill.shutemov@linux.intel.com, geliangtang@163.com, baiyaowei@cmss.chinamobile.com, dan.j.williams@intel.com, vdavydov@virtuozzo.com, aarcange@redhat.com, dvlasenk@redhat.com, jmarchan@redhat.com, koct9i@gmail.com, yang.shi@linaro.org, dave.hansen@linux.intel.com, vkuznets@redhat.com, vitalywool@gmail.com, ross.zwisler@linux.intel.com, Thomas Gleixner <tglx@linutronix.de>, kwapulinski.piotr@gmail.com, axboe@fb.com, mchristi@redhat.com, Joe Perches <joe@perches.com>, namit@vmware.com, Rik van Riel <riel@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

Hello,

On (09/05/16 11:18), Minchan Kim wrote:
[..]
> If I understand Sergey's point right, he means there is no gain
> to save memory between before and after.
> 
> With your approach, you can prevent unnecessary pageout(i.e.,
> uncompressible page swap out) but it doesn't mean you save the
> memory compared to old so why does your patch decrease the number of
> lowmemory killing?

you are right Minchan, that was exactly my point. every compressed page
that does not end up in huge_object zspage should result in some memory
saving (somewhere in the range from bytes to kilobytes).

> A thing I can imagine is without this feature, zram could be full of
> uncompressible pages so good-compressible page cannot be swapped out.

a good theory.

in general, a selective compression of N first pages that fall under the
given compression limit is not the same as a selective compression of N
"best" compressible pages. so I'm a bit uncertain about the guarantees
that the patch can provide.

let's assume the following case.
- zram compression size limit set to 2400 bytes (only pages smaller than
  that will be stored in zsmalloc)
- first K pages to swapout have compression size of 2350 +/- 10%
- next L pages have compression size of 2500 +/- 10%
- last M pages are un-compressible - PAGE_SIZE.
- zram disksize can fit N pages
- N > K + L

so instead of compressing and swapping out K + L pages, you would compress
only K pages, leaving (L + M) * PAGE_SIZE untouched. thus I'd say that we
might have bigger chances of LMK/OOM/etc. in some cases.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
