Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 5BB7F6B0032
	for <linux-mm@kvack.org>; Thu, 30 Apr 2015 02:55:43 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so51745326pdb.1
        for <linux-mm@kvack.org>; Wed, 29 Apr 2015 23:55:43 -0700 (PDT)
Received: from mail-pd0-x233.google.com (mail-pd0-x233.google.com. [2607:f8b0:400e:c02::233])
        by mx.google.com with ESMTPS id sj10si2087452pac.198.2015.04.29.23.55.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Apr 2015 23:55:42 -0700 (PDT)
Received: by pdbnk13 with SMTP id nk13so51782624pdb.0
        for <linux-mm@kvack.org>; Wed, 29 Apr 2015 23:55:42 -0700 (PDT)
Date: Thu, 30 Apr 2015 15:55:33 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v3 3/3] proc: add kpageidle file
Message-ID: <20150430065533.GC21771@blaptop>
References: <cover.1430217477.git.vdavydov@parallels.com>
 <4c24a6bf2c9711dd4dbb72a43a16eba6867527b7.1430217477.git.vdavydov@parallels.com>
 <20150429045759.GA27051@blaptop>
 <20150429083148.GA11497@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150429083148.GA11497@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Hi,

On Wed, Apr 29, 2015 at 11:31:49AM +0300, Vladimir Davydov wrote:
> On Wed, Apr 29, 2015 at 01:57:59PM +0900, Minchan Kim wrote:
> > On Tue, Apr 28, 2015 at 03:24:42PM +0300, Vladimir Davydov wrote:
> > > @@ -69,6 +69,14 @@ There are four components to pagemap:
> > >     memory cgroup each page is charged to, indexed by PFN. Only available when
> > >     CONFIG_MEMCG is set.
> > >  
> > > + * /proc/kpageidle.  For each page this file contains a 64-bit number, which
> > > +   equals 1 if the page is idle or 0 otherwise, indexed by PFN. A page is
> > > +   considered idle if it has not been accessed since it was marked idle. To
> > > +   mark a page idle one should write 1 to this file at the offset corresponding
> > > +   to the page. Only user memory pages can be marked idle, for other page types
> > > +   input is silently ignored. Writing to this file beyond max PFN results in
> > > +   the ENXIO error. Only available when CONFIG_IDLE_PAGE_TRACKING is set.
> > > +
> > 
> > How about using kpageflags for reading part?
> > 
> > I mean PG_idle is one of the page flags and we already have a feature to
> > parse of each PFN flag so we could reuse existing feature for reading
> > idleness.
> 
> Reading PG_idle implies clearing all pte references to make sure the
> page was not referenced via a pte. This means that exporting it via
> /proc/kpageflags would increase the cost of reading this file, even for
> users that don't care about PG_idle. I'm not sure all users of
> /proc/kpageflags will be fine with it.

It triggers rmap traverse so it would be horrible overhead sometime
so I agree every kpageflags users don't want it but I didn't mean
reading of PG_idle via kpageflags should clear all pte references.
Reset should be still part of kpageidle but we can just read idlenss
without reset by kpageflags(IOW, Reset and reading is orthogoal)

A benefit via reading kpageflags, we could parse it's idle page
and not dirty page so we could reclaim it easy.
Anyway, it could be further improvement.

> 
> Thanks,
> Vladimir

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
