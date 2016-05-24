Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 088E56B0005
	for <linux-mm@kvack.org>; Tue, 24 May 2016 04:47:40 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id n2so7250281wma.0
        for <linux-mm@kvack.org>; Tue, 24 May 2016 01:47:39 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id a9si2791492wjw.98.2016.05.24.01.47.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 May 2016 01:47:39 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id 67so3910374wmg.0
        for <linux-mm@kvack.org>; Tue, 24 May 2016 01:47:38 -0700 (PDT)
Date: Tue, 24 May 2016 10:47:37 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: memcontrol: fix possible css ref leak on oom
Message-ID: <20160524084737.GC8259@dhcp22.suse.cz>
References: <1464019330-7579-1-git-send-email-vdavydov@virtuozzo.com>
 <20160523174441.GA32715@dhcp22.suse.cz>
 <20160524084319.GH7917@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160524084319.GH7917@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 24-05-16 11:43:19, Vladimir Davydov wrote:
> On Mon, May 23, 2016 at 07:44:43PM +0200, Michal Hocko wrote:
> > On Mon 23-05-16 19:02:10, Vladimir Davydov wrote:
> > > mem_cgroup_oom may be invoked multiple times while a process is handling
> > > a page fault, in which case current->memcg_in_oom will be overwritten
> > > leaking the previously taken css reference.
> > 
> > Have you seen this happening? I was under impression that the page fault
> > paths that have oom enabled will not retry allocations.
> 
> filemap_fault will, for readahead.

I thought that the readahead is __GFP_NORETRY so we do not trigger OOM
killer.

> This is rather unlikely, just like the whole oom scenario, so I haven't
> faced this leak in production yet, although it's pretty easy to
> reproduce using a contrived test. However, even if this leak happened on
> my host, I would probably not notice, because currently we have no clear
> means of catching css leaks. I'm thinking about adding a file to debugfs
> containing brief information about all memory cgroups, including dead
> ones, so that we could at least see how many dead memory cgroups are
> dangling out there.

Yeah, debugfs interface would make some sense.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
