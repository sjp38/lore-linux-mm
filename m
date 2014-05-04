Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f175.google.com (mail-vc0-f175.google.com [209.85.220.175])
	by kanga.kvack.org (Postfix) with ESMTP id 2A5606B0036
	for <linux-mm@kvack.org>; Sun,  4 May 2014 17:19:09 -0400 (EDT)
Received: by mail-vc0-f175.google.com with SMTP id lh4so7606311vcb.20
        for <linux-mm@kvack.org>; Sun, 04 May 2014 14:19:08 -0700 (PDT)
Received: from mail-ve0-x22f.google.com (mail-ve0-x22f.google.com [2607:f8b0:400c:c01::22f])
        by mx.google.com with ESMTPS id sl10si1217989vdc.21.2014.05.04.14.19.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 04 May 2014 14:19:08 -0700 (PDT)
Received: by mail-ve0-f175.google.com with SMTP id jw12so964449veb.20
        for <linux-mm@kvack.org>; Sun, 04 May 2014 14:19:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5366A63F.9030401@nod.at>
References: <alpine.LSU.2.11.1404161239320.6778@eggly.anvils>
	<1399160247-32093-1-git-send-email-richard@nod.at>
	<CA+55aFzbSUPGWyO42KM7geAy8WrP8e=q+KoqdOBY68zay0jrZA@mail.gmail.com>
	<5365FB8A.8080303@nod.at>
	<CA+55aFw9SLeE1fv1-nKMeB7o0YAFZ85mskYy_izCb7Nh3AiicQ@mail.gmail.com>
	<5366A63F.9030401@nod.at>
Date: Sun, 4 May 2014 14:19:08 -0700
Message-ID: <CA+55aFwcKfyuyMNV37c_JT00039P_VgmOXU_u3gm_RnUR=LGdQ@mail.gmail.com>
Subject: Re: [PATCH] mm: Fix force_flush behavior in zap_pte_range()
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Weinberger <richard@nod.at>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>, =?UTF-8?Q?Toralf_F=C3=B6rster?= <toralf.foerster@gmx.de>

On Sun, May 4, 2014 at 1:42 PM, Richard Weinberger <richard@nod.at> wrote:
>
> I cannot tell why UML has it's own tlb gather logic, I suspect nobody
> cared so far to clean up the code.
> That said, I've converted it today to the generic gather logic and it works.
> Sadly I'm still facing the same issues (sigh!).

Ok, so it's not the gathering.

I'm guessing it's because the tlb flush patterns change (we now flush
partial areas for shared mappings with dirty pages - it used to be
that you'd only ever see full ranges before), and that shows some
issue with the whole "fix_range()" thing. So then the kill(9) results
in stopping the page table zapping in the middle, and then you end up
with that "Bad rss-counter" for the file mapping.

Can you try to debug it to see where that "ret" gets set in
fix_range_common() (well, likely deeper, I presume it comes from
update_pte_range() or whatever), to see exactly _what_ it is that
starts failing?

           Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
