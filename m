Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id B6F8C6B0035
	for <linux-mm@kvack.org>; Wed, 23 Jul 2014 17:02:58 -0400 (EDT)
Received: by mail-wg0-f52.google.com with SMTP id a1so1722378wgh.23
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 14:02:58 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id mw6si7462101wib.99.2014.07.23.14.02.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 23 Jul 2014 14:02:53 -0700 (PDT)
Date: Wed, 23 Jul 2014 17:02:41 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 13/13] mm: memcontrol: rewrite uncharge API
Message-ID: <20140723210241.GH1725@cmpxchg.org>
References: <20140715121935.GB9366@dhcp22.suse.cz>
 <20140718071246.GA21565@dhcp22.suse.cz>
 <20140718144554.GG29639@cmpxchg.org>
 <CAJfpegt9k+YULet3vhmG3br7zSiHy-DRL+MiEE=HRzcs+mLzbw@mail.gmail.com>
 <20140719173911.GA1725@cmpxchg.org>
 <20140722150825.GA4517@dhcp22.suse.cz>
 <CAJfpegscT-ptQzq__uUV2TOn7Uvs6x4FdWGTQb9Fe9MEJr2KjA@mail.gmail.com>
 <20140723143847.GB16721@dhcp22.suse.cz>
 <20140723150608.GF1725@cmpxchg.org>
 <CAJfpegs-k5QC+42SzLKUSaHrdPxWBaT_dF+SOPqoDvg8h5p_Tw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJfpegs-k5QC+42SzLKUSaHrdPxWBaT_dF+SOPqoDvg8h5p_Tw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, Kernel Mailing List <linux-kernel@vger.kernel.org>

Hi Miklos,

On Wed, Jul 23, 2014 at 08:08:57PM +0200, Miklos Szeredi wrote:
> On Wed, Jul 23, 2014 at 5:06 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> > Can the new page be anything else than previous page cache?
> 
> It could be an ordinary pipe buffer too.  Stealable as well (see
> generic_pipe_buf_steal()).

Okay, they need charging, so we can't get rid of mem_cgroup_migrate()
in replace_page_cache().  With the fuse example mount you described I
can trigger the current code to blow up, so below is a fix to check if
the target page is already charged.

On an unrelated note, while playing around with the fuse example mount
and heavy swapping workloads I get the following in dmesg (changed
fuse_check_page() to use dump_page(), will send a patch later):

[  298.771921] page:ffffea000468cb80 count:1 mapcount:0 mapping:          (null) index:0x1e852f8
[  298.780517] page flags: 0x5fffc000080029(locked|uptodate|lru|swapbacked)
[  298.787385] page dumped because: fuse: trying to steal weird page
[  298.793500] pc:ffff880215f232e0 pc->flags:7 pc->mem_cgroup:ffff880216c23000

[  298.801031] page:ffffea0004662f00 count:1 mapcount:0 mapping:          (null) index:0x1e85324
[  298.809689] page flags: 0x5fffc000080029(locked|uptodate|lru|swapbacked)
[  298.816615] page dumped because: fuse: trying to steal weird page
[  298.822791] pc:ffff880215f18bc0 pc->flags:7 pc->mem_cgroup:ffff880216c23000

etc.

Somehow the page stealing ends up taking out anonymous pages, but it
must be a race condition as it happens rarely and irregularly.

---
