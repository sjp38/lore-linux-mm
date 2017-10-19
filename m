Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 15CD66B0069
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 16:53:21 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id u27so6841163pfg.12
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 13:53:21 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q5si812930pgp.196.2017.10.19.13.53.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Oct 2017 13:53:20 -0700 (PDT)
Date: Thu, 19 Oct 2017 22:53:12 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: mlock: remove lru_add_drain_all()
Message-ID: <20171019205312.c4ghzdvk47oupvzl@dhcp22.suse.cz>
References: <20171018231730.42754-1-shakeelb@google.com>
 <20171019123206.3etacullgnarbnad@dhcp22.suse.cz>
 <CALvZod40MmJ6F9ecKHsCkxyxnf_QR4pNqh55GENqqKKYpendMw@mail.gmail.com>
 <20171019193542.l5baqknxnfhljjkr@dhcp22.suse.cz>
 <CALvZod5HcYVcGQff2Em_4uxqVm4rQMnO4RJYhJKQ-NtXzvO17g@mail.gmail.com>
 <20171019201306.u76wt3wgbt6sfhcj@dhcp22.suse.cz>
 <CALvZod6y6fBozZTJ=VEAXMoCaxB9Sjwp+L-JtTBAmyc53htxQw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALvZod6y6fBozZTJ=VEAXMoCaxB9Sjwp+L-JtTBAmyc53htxQw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Yisheng Xie <xieyisheng1@huawei.com>, Ingo Molnar <mingo@kernel.org>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu 19-10-17 13:14:52, Shakeel Butt wrote:
> On Thu, Oct 19, 2017 at 1:13 PM, Michal Hocko <mhocko@kernel.org> wrote:
> > On Thu 19-10-17 12:46:50, Shakeel Butt wrote:
> >> > [...]
> >> >>
> >> >> Sorry for the confusion. I wanted to say that if the pages which are
> >> >> being mlocked are on caches of remote cpus then lru_add_drain_all will
> >> >> move them to their corresponding LRUs and then remaining functionality
> >> >> of mlock will move them again from their evictable LRUs to unevictable
> >> >> LRU.
> >> >
> >> > yes, but the point is that we are draining pages which might be not
> >> > directly related to pages which _will_ be mlocked by the syscall. In
> >> > fact those will stay on the cache. This is the primary reason why this
> >> > draining doesn't make much sense.
> >> >
> >> > Or am I still misunderstanding what you are saying here?
> >> >
> >>
> >> lru_add_drain_all() will drain everything irrespective if those pages
> >> are being mlocked or not.
> >
> > yes, let me be more specific. lru_add_drain_all will drain everything
> > that has been cached at the time mlock is called. And that is not really
> > related to the memory which will be faulted in (and cached) and mlocked
> > by the syscall itself. Does it make more sense now?
> >
> 
> Yes, you are absolutely right. Sorry for the confusion.

So I think it would be much better to justify this change by arguing
that paying a random overhead for something that doesn't relate to the
work to be done is simply wrong.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
