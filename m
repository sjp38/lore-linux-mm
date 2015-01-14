Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f179.google.com (mail-ie0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id 048346B0032
	for <linux-mm@kvack.org>; Tue, 13 Jan 2015 19:11:48 -0500 (EST)
Received: by mail-ie0-f179.google.com with SMTP id rp18so5994893iec.10
        for <linux-mm@kvack.org>; Tue, 13 Jan 2015 16:11:47 -0800 (PST)
Received: from vapor.isi.edu (vapor.isi.edu. [128.9.64.64])
        by mx.google.com with ESMTPS id d17si612792ics.13.2015.01.13.16.11.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 13 Jan 2015 16:11:46 -0800 (PST)
Date: Tue, 13 Jan 2015 16:10:57 -0800
From: Craig Milo Rogers <rogers@isi.edu>
Subject: Re: [PATCH 0/5] kstrdup optimization
Message-ID: <20150114001057.GA30408@isi.edu>
References: <1421054323-14430-1-git-send-email-a.hajda@samsung.com> <CAMuHMdV74n3v81xaLRDN_Mn_QGg14yUkXNn6JYaGH4MGgLRM2A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAMuHMdV74n3v81xaLRDN_Mn_QGg14yUkXNn6JYaGH4MGgLRM2A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrzej Hajda <a.hajda@samsung.com>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>, Linux MM <linux-mm@kvack.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>, Andreas Mohr <andi@lisas.de>, Mike Turquette <mturquette@linaro.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>

> As kfree_const() has the exact same signature as kfree(), the risk of
> accidentally passing pointers returned from kstrdup_const() to kfree() seems
> high, which may lead to memory corruption if the pointer doesn't point to
> allocated memory.
...
>> To verify if the source is in .rodata function checks if the address is between
>> sentinels __start_rodata, __end_rodata. I guess it should work with all
>> architectures.

	kfree() could also check if the region being freed is in .rodata, and
ignore the call; kfree_const() would not be needed.  If making this check all
the time leads to a significant decrease in performance (numbers needed here),
another option is to keep kfree_const() but add a check to kfree(), when
compiled for debugging, that issues a suitable complaint if the region being
freed is in .rodata.

					Craig Milo Rogers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
