Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 107D66B0069
	for <linux-mm@kvack.org>; Fri, 25 Nov 2016 03:47:29 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id g23so20508086wme.4
        for <linux-mm@kvack.org>; Fri, 25 Nov 2016 00:47:29 -0800 (PST)
Received: from mout.kundenserver.de (mout.kundenserver.de. [217.72.192.73])
        by mx.google.com with ESMTPS id jw9si34063445wjb.145.2016.11.25.00.47.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Nov 2016 00:47:27 -0800 (PST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] z3fold: use %z modifier for format string
Date: Fri, 25 Nov 2016 09:41:53 +0100
Message-ID: <3177176.drX8hSSUx4@wuerfel>
In-Reply-To: <CAMJBoFN=32B3aaU2XyJO7dNmZ3gMxmOYboVoWH3z7ALosSdmUQ@mail.gmail.com>
References: <20161124163158.3939337-1-arnd@arndb.de> <1480007330.19726.11.camel@perches.com> <CAMJBoFN=32B3aaU2XyJO7dNmZ3gMxmOYboVoWH3z7ALosSdmUQ@mail.gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Joe Perches <joe@perches.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Streetman <ddstreet@ieee.org>, zhong jiang <zhongjiang@huawei.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Friday, November 25, 2016 8:38:25 AM CET Vitaly Wool wrote:
> >> diff --git a/mm/z3fold.c b/mm/z3fold.c
> >> index e282ba073e77..66ac7a7dc934 100644
> >> --- a/mm/z3fold.c
> >> +++ b/mm/z3fold.c
> >> @@ -884,7 +884,7 @@ static int __init init_z3fold(void)
> >>  {
> >>       /* Fail the initialization if z3fold header won't fit in one chunk */
> >>       if (sizeof(struct z3fold_header) > ZHDR_SIZE_ALIGNED) {
> >> -             pr_err("z3fold: z3fold_header size (%d) is bigger than "
> >> +             pr_err("z3fold: z3fold_header size (%zd) is bigger than "
> >>                       "the chunk size (%d), can't proceed\n",
> >>                       sizeof(struct z3fold_header) , ZHDR_SIZE_ALIGNED);
> >>               return -E2BIG;
> >
> > The embedded "z3fold: " prefix here should be removed
> > as there's a pr_fmt that also adds it.
> >
> > The test looks like it should be a BUILD_BUG_ON rather
> > than any runtime test too.
> 
> It used to be BUILD_BUG_ON but we deliberately changed that because
> sizeof(spinlock_t) gets bloated in debug builds, so it just won't
> build with default CHUNK_SIZE.

Could this be improved by making the CHUNK_SIZE bigger depending on
the debug options?

Alternatively, how about using a bit_spin_lock instead of raw_spin_lock?
That would guarantee a fixed size for the lock and make z3fold_header
always 24 bytes (on 32-bit architectures) or 40 bytes
(on 64-bit architectures). You could even play some tricks with the
first_num field to make it fit in the same word as the lock and make the
structure fit into 32 bytes if you care about that.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
