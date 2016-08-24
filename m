Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 389B86B0038
	for <linux-mm@kvack.org>; Wed, 24 Aug 2016 02:33:49 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id k135so4516009lfb.2
        for <linux-mm@kvack.org>; Tue, 23 Aug 2016 23:33:49 -0700 (PDT)
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com. [74.125.82.53])
        by mx.google.com with ESMTPS id k3si2903034wjn.281.2016.08.23.23.32.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Aug 2016 23:32:18 -0700 (PDT)
Received: by mail-wm0-f53.google.com with SMTP id o80so11269540wme.1
        for <linux-mm@kvack.org>; Tue, 23 Aug 2016 23:32:17 -0700 (PDT)
Date: Wed, 24 Aug 2016 08:32:16 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: OOM detection regressions since 4.7
Message-ID: <20160824063216.GA31179@dhcp22.suse.cz>
References: <20160822093249.GA14916@dhcp22.suse.cz>
 <20160823045245.GC17039@js1304-P5Q-DELUXE>
 <20160823073318.GA23577@dhcp22.suse.cz>
 <CA+55aFyTnS6Z3UHcJfTO-dsNBS-ZXaDmYU42_fDWPO0qhc2xFg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFyTnS6Z3UHcJfTO-dsNBS-ZXaDmYU42_fDWPO0qhc2xFg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, greg@suse.cz, Markus Trippelsdorf <markus@trippelsdorf.de>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Jiri Slaby <jslaby@suse.com>, Olaf Hering <olaf@aepfle.de>, Vlastimil Babka <vbabka@suse.cz>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue 23-08-16 15:08:05, Linus Torvalds wrote:
> On Tue, Aug 23, 2016 at 3:33 AM, Michal Hocko <mhocko@kernel.org> wrote:
> >
> > I would argue that CONFIG_COMPACTION=n behaves so arbitrary for high
> > order workloads that calling any change in that behavior a regression
> > is little bit exaggerated.
> 
> Well, the thread info allocations certainly haven't been big problems
> before. So regressing those would seem to be a real regression.
> 
> What happened? We've done the order-2 allocation for the stack since
> May 2014, so that isn't new. Did we cut off retries for low orders?

Yes, with the original implementation the number of reclaim retries is
basically unbounded and as long as we have a reclaim progress. This has
changed to be a bounded process. Without the compaction this means that
we were reclaim as long as an order-2 page was formed.

> So I would not say that it's an exaggeration to say that order-2
> allocations failing is a regression.

I would agree with you with COMPACTION enabled but with compaction
disabled which should be really limited to !MMU configurations I think
there is not much we can do. Well, we could simply retry for ever
without invoking OOM killer for higher order request for this config
option and rely on order-0 to hit the OOM. Do we want that though?
I do not remember anybody with !MMU to complain. Markus had COMPACTION
disabled accidentally.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
