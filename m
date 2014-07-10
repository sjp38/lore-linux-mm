Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id B9C226B0035
	for <linux-mm@kvack.org>; Thu, 10 Jul 2014 12:36:10 -0400 (EDT)
Received: by mail-la0-f47.google.com with SMTP id s18so6332031lam.20
        for <linux-mm@kvack.org>; Thu, 10 Jul 2014 09:36:09 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id ov6si78709986lbb.52.2014.07.10.09.36.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jul 2014 09:36:09 -0700 (PDT)
Date: Thu, 10 Jul 2014 20:35:45 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH RFC 0/5] Virtual Memory Resource Controller for cgroups
Message-ID: <20140710163545.GA835@esperanza>
References: <cover.1404383187.git.vdavydov@parallels.com>
 <20140709075252.GB31067@esperanza>
 <CAAAKZwsRDb6a062SFZYv-1SDYyD12uTzVMpdZt0CtdDjoddNVg@mail.gmail.com>
 <20140709163631.GG6685@esperanza>
 <CAHH2K0Y2OH9scJ8FGkL3M124RSfoUFiELNhGNTHJEsaCEm+hiQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <CAHH2K0Y2OH9scJ8FGkL3M124RSfoUFiELNhGNTHJEsaCEm+hiQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Tim Hockin <thockin@hockin.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cgroups <cgroups@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Balbir Singh <bsingharora@gmail.com>

Hi Greg,

On Wed, Jul 09, 2014 at 10:04:21AM -0700, Greg Thelen wrote:
> On Wed, Jul 9, 2014 at 9:36 AM, Vladimir Davydov <vdavydov@parallels.com> wrote:
> > Hi Tim,
> >
> > On Wed, Jul 09, 2014 at 08:08:07AM -0700, Tim Hockin wrote:
> >> How is this different from RLIMIT_AS?  You specifically mentioned it
> >> earlier but you don't explain how this is different.
> >
> > The main difference is that RLIMIT_AS is per process while this
> > controller is per cgroup. RLIMIT_AS doesn't allow us to limit VSIZE for
> > a group of unrelated or cooperating through shmem processes.
> >
> > Also RLIMIT_AS accounts for total VM usage (including file mappings),
> > while this only charges private writable and shared mappings, whose
> > faulted-in pages always occupy mem+swap and therefore cannot be just
> > synced and dropped like file pages. In other words, this controller
> > works exactly as the global overcommit control.
> >
> >> From my perspective, this is pointless.  There's plenty of perfectly
> >> correct software that mmaps files without concern for VSIZE, because
> >> they never fault most of those pages in.
> >
> > But there's also software that correctly handles ENOMEM returned by
> > mmap. For example, mongodb keeps growing its buffers until mmap fails.
> > Therefore, if there's no overcommit control, it will be OOM-killed
> > sooner or later, which may be pretty annoying. And we did have customers
> > complaining about that.
> 
> Is mongodb's buffer growth causing the oom kills?

We saw this happened on our customer's node some time ago. A container
running mongodb and several other services got OOM-kills from time to
time, which made the customer unhappy. Limiting overcommit helped then.

> If yes, I wonder if apps, like mongodb, that want ENOMEM should (1)
> use MAP_POPULATE and (2) we change vm_map_pgoff() to propagate
> mm_populate() ENOMEM failures back to mmap()?

This way we may fault-in lots of pages, evicting someone's working set
along the way, only to get ENOMEM eventually. This doesn't look optimal.
Also, this requires modifications of userspace apps, which isn't always
possible.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
