Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id EA8A36B0253
	for <linux-mm@kvack.org>; Sat, 11 Jul 2015 10:53:51 -0400 (EDT)
Received: by pdbqm3 with SMTP id qm3so55611813pdb.0
        for <linux-mm@kvack.org>; Sat, 11 Jul 2015 07:53:51 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id y5si19561257par.87.2015.07.11.07.53.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 11 Jul 2015 07:53:51 -0700 (PDT)
Date: Sat, 11 Jul 2015 17:53:38 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm v6 5/6] proc: add kpageidle file
Message-ID: <20150711145338.GP2436@esperanza>
References: <cover.1434102076.git.vdavydov@parallels.com>
 <50b7cd0f35f651481ce32414fab5210de5dc1714.1434102076.git.vdavydov@parallels.com>
 <CAJu=L5-fwHMEKmL1Sp7owXyBa0GCrGR=TdKZbh15CJA3WrcwqA@mail.gmail.com>
 <20150709131900.GK2436@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150709131900.GK2436@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andres Lagar-Cavilla <andreslc@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Jul 09, 2015 at 04:19:00PM +0300, Vladimir Davydov wrote:
> On Wed, Jul 08, 2015 at 04:01:13PM -0700, Andres Lagar-Cavilla wrote:
> > On Fri, Jun 12, 2015 at 2:52 AM, Vladimir Davydov
> > > +#ifdef CONFIG_IDLE_PAGE_TRACKING
> > > +/*
> > > + * Idle page tracking only considers user memory pages, for other types of
> > > + * pages the idle flag is always unset and an attempt to set it is silently
> > > + * ignored.
> > > + *
> > > + * We treat a page as a user memory page if it is on an LRU list, because it is
> > > + * always safe to pass such a page to page_referenced(), which is essential for
> > > + * idle page tracking. With such an indicator of user pages we can skip
> > > + * isolated pages, but since there are not usually many of them, it will hardly
> > > + * affect the overall result.
> > > + *
> > > + * This function tries to get a user memory page by pfn as described above.
> > > + */
> > > +static struct page *kpageidle_get_page(unsigned long pfn)
> > > +{
> > > +       struct page *page;
> > > +       struct zone *zone;
> > > +
> > > +       if (!pfn_valid(pfn))
> > > +               return NULL;
> > > +
> > > +       page = pfn_to_page(pfn);
> > > +       if (!page || !PageLRU(page))
> > 
> > Isolation can race in while you're processing the page, after these
> > checks. This is ok, but worth a small comment.
> 
> Agree, will add one.

Oh, the comment is already present - it's in the description to this
function. Minchan asked me to add it long time ago, and so I did.
Completely forgot about it.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
