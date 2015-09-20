Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 5A81D6B0253
	for <linux-mm@kvack.org>; Sun, 20 Sep 2015 05:33:36 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so76329715wic.0
        for <linux-mm@kvack.org>; Sun, 20 Sep 2015 02:33:35 -0700 (PDT)
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com. [209.85.212.179])
        by mx.google.com with ESMTPS id m20si9754707wiv.101.2015.09.20.02.33.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 Sep 2015 02:33:35 -0700 (PDT)
Received: by wicgb1 with SMTP id gb1so79264557wic.1
        for <linux-mm@kvack.org>; Sun, 20 Sep 2015 02:33:34 -0700 (PDT)
Date: Sun, 20 Sep 2015 11:33:33 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: can't oom-kill zap the victim's memory?
Message-ID: <20150920093332.GA20562@dhcp22.suse.cz>
References: <1442512783-14719-1-git-send-email-kwalker@redhat.com>
 <20150919150316.GB31952@redhat.com>
 <CA+55aFwkvbMrGseOsZNaxgP3wzDoVjkGasBKFxpn07SaokvpXA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFwkvbMrGseOsZNaxgP3wzDoVjkGasBKFxpn07SaokvpXA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, Kyle Walker <kwalker@redhat.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Stanislav Kozina <skozina@redhat.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>

On Sat 19-09-15 15:24:02, Linus Torvalds wrote:
> On Sat, Sep 19, 2015 at 8:03 AM, Oleg Nesterov <oleg@redhat.com> wrote:
> > +
> > +static void oom_unmap_func(struct work_struct *work)
> > +{
> > +       struct mm_struct *mm = xchg(&oom_unmap_mm, NULL);
> > +
> > +       if (!atomic_inc_not_zero(&mm->mm_users))
> > +               return;
> > +
> > +       // If this is not safe we can do use_mm() + unuse_mm()
> > +       down_read(&mm->mmap_sem);
> 
> I don't think this is safe.
> 
> What makes you sure that we might not deadlock on the mmap_sem here?
> For all we know, the process that is going out of memory is in the
> middle of a mmap(), and already holds the mmap_sem for writing. No?
> 
> So at the very least that needs to be a trylock, I think.

Agreed.

> And I'm not
> sure zap_page_range() is ok with the mmap_sem only held for reading.
> Normally our rule is that you can *populate* the page tables
> concurrently, but you can't tear the down

Actually mmap_sem for reading should be sufficient because we do not
alter the layout. Both MADV_DONTNEED and MADV_FREE require read mmap_sem
for example.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
