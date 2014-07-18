Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f54.google.com (mail-qa0-f54.google.com [209.85.216.54])
	by kanga.kvack.org (Postfix) with ESMTP id 78B6C6B0035
	for <linux-mm@kvack.org>; Fri, 18 Jul 2014 11:12:56 -0400 (EDT)
Received: by mail-qa0-f54.google.com with SMTP id k15so3131018qaq.27
        for <linux-mm@kvack.org>; Fri, 18 Jul 2014 08:12:56 -0700 (PDT)
Received: from mail-qa0-x22d.google.com (mail-qa0-x22d.google.com [2607:f8b0:400d:c00::22d])
        by mx.google.com with ESMTPS id w8si11940311qad.60.2014.07.18.08.12.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 18 Jul 2014 08:12:55 -0700 (PDT)
Received: by mail-qa0-f45.google.com with SMTP id cm18so3080931qab.32
        for <linux-mm@kvack.org>; Fri, 18 Jul 2014 08:12:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140718144554.GG29639@cmpxchg.org>
References: <1403124045-24361-1-git-send-email-hannes@cmpxchg.org>
	<1403124045-24361-14-git-send-email-hannes@cmpxchg.org>
	<20140715082545.GA9366@dhcp22.suse.cz>
	<20140715121935.GB9366@dhcp22.suse.cz>
	<20140718071246.GA21565@dhcp22.suse.cz>
	<20140718144554.GG29639@cmpxchg.org>
Date: Fri, 18 Jul 2014 17:12:54 +0200
Message-ID: <CAJfpegt9k+YULet3vhmG3br7zSiHy-DRL+MiEE=HRzcs+mLzbw@mail.gmail.com>
Subject: Re: [patch 13/13] mm: memcontrol: rewrite uncharge API
From: Miklos Szeredi <miklos@szeredi.hu>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, Kernel Mailing List <linux-kernel@vger.kernel.org>

On Fri, Jul 18, 2014 at 4:45 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:

> I assumed the source page would always be new, according to this part
> in fuse_try_move_page():
>
>         /*
>          * This is a new and locked page, it shouldn't be mapped or
>          * have any special flags on it
>          */
>         if (WARN_ON(page_mapped(oldpage)))
>                 goto out_fallback_unlock;
>         if (WARN_ON(page_has_private(oldpage)))
>                 goto out_fallback_unlock;
>         if (WARN_ON(PageDirty(oldpage) || PageWriteback(oldpage)))
>                 goto out_fallback_unlock;
>         if (WARN_ON(PageMlocked(oldpage)))
>                 goto out_fallback_unlock;
>
> However, it's in the page cache and I can't really convince myself
> that it's not also on the LRU.  Miklos, I have trouble pinpointing
> where oldpage is instantiated exactly and what state it might be in -
> can it already be on the LRU?

oldpage comes from ->readpages() (*NOT* ->readpage()), i.e. readahead.

AFAICS it is added to the LRU in read_cache_pages(), so it looks like
it is definitely on the LRU at that point.

Thanks,
Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
