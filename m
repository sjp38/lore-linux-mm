Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 687136B0038
	for <linux-mm@kvack.org>; Tue, 23 Aug 2016 15:08:21 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id c189so117404650oia.1
        for <linux-mm@kvack.org>; Tue, 23 Aug 2016 12:08:21 -0700 (PDT)
Received: from mail-oi0-x236.google.com (mail-oi0-x236.google.com. [2607:f8b0:4003:c06::236])
        by mx.google.com with ESMTPS id c44si3347603otc.201.2016.08.23.12.08.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Aug 2016 12:08:06 -0700 (PDT)
Received: by mail-oi0-x236.google.com with SMTP id c15so209246417oig.0
        for <linux-mm@kvack.org>; Tue, 23 Aug 2016 12:08:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160823073318.GA23577@dhcp22.suse.cz>
References: <20160822093249.GA14916@dhcp22.suse.cz> <20160823045245.GC17039@js1304-P5Q-DELUXE>
 <20160823073318.GA23577@dhcp22.suse.cz>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 23 Aug 2016 15:08:05 -0400
Message-ID: <CA+55aFyTnS6Z3UHcJfTO-dsNBS-ZXaDmYU42_fDWPO0qhc2xFg@mail.gmail.com>
Subject: Re: OOM detection regressions since 4.7
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, greg@suse.cz, Markus Trippelsdorf <markus@trippelsdorf.de>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Jiri Slaby <jslaby@suse.com>, Olaf Hering <olaf@aepfle.de>, Vlastimil Babka <vbabka@suse.cz>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Aug 23, 2016 at 3:33 AM, Michal Hocko <mhocko@kernel.org> wrote:
>
> I would argue that CONFIG_COMPACTION=n behaves so arbitrary for high
> order workloads that calling any change in that behavior a regression
> is little bit exaggerated.

Well, the thread info allocations certainly haven't been big problems
before. So regressing those would seem to be a real regression.

What happened? We've done the order-2 allocation for the stack since
May 2014, so that isn't new. Did we cut off retries for low orders?

So I would not say that it's an exaggeration to say that order-2
allocations failing is a regression.

Yes, yes, for 4.9 we may well end up using vmalloc for the kernel
stack, but there are certainly other things that want low-order
(non-hugepage) allocations. Like kmalloc(), which often ends up using
small orders just to pack data more efficiently (allocating a single
page can be hugely wasteful even if the individual allocations are
smaller than that - so allocating a few pages and packing more
allocations into it helps fight internal fragmentation)

So this definitely needs to be fixed for 4.7 (and apparently there's a
few patches still pending even for 4.8)

                 Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
