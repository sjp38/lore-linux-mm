Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3CBB26B0269
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 09:57:50 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id a26-v6so7509665pgw.7
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 06:57:50 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r65-v6si11414036pfe.298.2018.07.30.06.57.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jul 2018 06:57:49 -0700 (PDT)
Date: Mon, 30 Jul 2018 15:57:44 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [Bug 200651] New: cgroups iptables-restor: vmalloc: allocation
 failure
Message-ID: <20180730135744.GT24267@dhcp22.suse.cz>
References: <cd474b37-263f-b186-2024-507a9a4e12ae@suse.cz>
 <20180726072622.GS28386@dhcp22.suse.cz>
 <67d5e4ef-c040-6852-ad93-6f2528df0982@suse.cz>
 <20180726074219.GU28386@dhcp22.suse.cz>
 <36043c6b-4960-8001-4039-99525dcc3e05@suse.cz>
 <20180726080301.GW28386@dhcp22.suse.cz>
 <ed7090ad-5004-3133-3faf-607d2a9fa90a@suse.cz>
 <d69d7a82-5b70-051f-a517-f602c3ef1fd7@suse.cz>
 <98788618-94dc-5837-d627-8bbfa1ddea57@icdsoft.com>
 <ff19099f-e0f5-d2b2-e124-cc12d2e05dc1@icdsoft.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <ff19099f-e0f5-d2b2-e124-cc12d2e05dc1@icdsoft.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Georgi Nikolov <gnikolov@icdsoft.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, netfilter-devel@vger.kernel.org

On Mon 30-07-18 16:37:07, Georgi Nikolov wrote:
> On 07/26/2018 12:02 PM, Georgi Nikolov wrote:
[...]
> > Here is the patch applied to this version which masks errors:
> >
> > --- net/netfilter/x_tables.c    2018-06-18 14:18:21.138347416 +0300
> > +++ net/netfilter/x_tables.c    2018-07-26 11:58:01.721932962 +0300
> > @@ -1059,9 +1059,19 @@
> >       * than shoot all processes down before realizing there is nothing
> >       * more to reclaim.
> >       */
> > -    info = kvmalloc(sz, GFP_KERNEL | __GFP_NORETRY);
> > +/*    info = kvmalloc(sz, GFP_KERNEL | __GFP_NORETRY);
> >      if (!info)
> >          return NULL;
> > +*/
> > +
> > +    if (sz <= (PAGE_SIZE << PAGE_ALLOC_COSTLY_ORDER))
> > +        info = kmalloc(sz, GFP_KERNEL | __GFP_NOWARN | __GFP_NORETRY);
> > +    if (!info) {
> > +        info = __vmalloc(sz, GFP_KERNEL | __GFP_NOWARN | __GFP_NORETRY,
> > +         PAGE_KERNEL);
> > +        if (!info)
> > +        return NULL;
> > +    }
> >  
> >      memset(info, 0, sizeof(*info));
> >      info->size = size;
> >
> >
> > I will try to reproduce it with only
> >
> > info = kvmalloc(sz, GFP_KERNEL);
> >
> > Regards,
> >
> > --
> > Georgi Nikolov
> >
> 
> Hello,
> 
> Without GFP_NORETRY problem disappears.

Hmm, there are two allocation paths which have __GFP_NORETRY here.
I expect you have removed both of them, right?

kvmalloc implicitly performs __GFP_NORETRY on kmalloc path but it
doesn't have it for the vmalloc fallback. This would match
kvmalloc(GFP_KERNEL). I thought you were testing this code path
previously but there is some confusion flying around because you have
claimed that the regressions started with eacd86ca3b036. If the
regression is really with __GFP_NORETRY being used for the vmalloc
fallback which would be kvmalloc(GFP_KERNEL | __GFP_NORETRY) then
I am still confused because that would match the original code.

> What is correct way to fix it.
> - inside xt_alloc_table_info remove GFP_NORETRY from kvmalloc or add
> this flag only for sizes bigger than some threshold

This would reintroduce issue fixed by 0537250fdc6c8. Note that
kvmalloc(GFP_KERNEL | __GFP_NORETRY) is more or less equivalent to the
original code (well, except for __GFP_NOWARN).

> - inside kvmalloc_node remove GFP_NORETRY from
> __vmalloc_node_flags_caller (i don't know if it honors this flag, or
> the problem is elsewhere)

No, not really. This is basically equivalent to kvmalloc(GFP_KERNEL).

I strongly suspect that this is not a regression in this code but rather
a side effect of larger memory fragmentation caused by something else.
In any case do you see this failure also without artificial test case
with a standard workload?
-- 
Michal Hocko
SUSE Labs
