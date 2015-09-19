Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id CC5216B0253
	for <linux-mm@kvack.org>; Sat, 19 Sep 2015 18:24:03 -0400 (EDT)
Received: by igbni9 with SMTP id ni9so38036325igb.0
        for <linux-mm@kvack.org>; Sat, 19 Sep 2015 15:24:03 -0700 (PDT)
Received: from mail-io0-x234.google.com (mail-io0-x234.google.com. [2607:f8b0:4001:c06::234])
        by mx.google.com with ESMTPS id r5si3722062igm.76.2015.09.19.15.24.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 19 Sep 2015 15:24:02 -0700 (PDT)
Received: by iofh134 with SMTP id h134so88443918iof.0
        for <linux-mm@kvack.org>; Sat, 19 Sep 2015 15:24:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150919150316.GB31952@redhat.com>
References: <1442512783-14719-1-git-send-email-kwalker@redhat.com>
	<20150919150316.GB31952@redhat.com>
Date: Sat, 19 Sep 2015 15:24:02 -0700
Message-ID: <CA+55aFwkvbMrGseOsZNaxgP3wzDoVjkGasBKFxpn07SaokvpXA@mail.gmail.com>
Subject: Re: can't oom-kill zap the victim's memory?
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Kyle Walker <kwalker@redhat.com>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Stanislav Kozina <skozina@redhat.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>

On Sat, Sep 19, 2015 at 8:03 AM, Oleg Nesterov <oleg@redhat.com> wrote:
> +
> +static void oom_unmap_func(struct work_struct *work)
> +{
> +       struct mm_struct *mm = xchg(&oom_unmap_mm, NULL);
> +
> +       if (!atomic_inc_not_zero(&mm->mm_users))
> +               return;
> +
> +       // If this is not safe we can do use_mm() + unuse_mm()
> +       down_read(&mm->mmap_sem);

I don't think this is safe.

What makes you sure that we might not deadlock on the mmap_sem here?
For all we know, the process that is going out of memory is in the
middle of a mmap(), and already holds the mmap_sem for writing. No?

So at the very least that needs to be a trylock, I think. And I'm not
sure zap_page_range() is ok with the mmap_sem only held for reading.
Normally our rule is that you can *populate* the page tables
concurrently, but you can't tear the down.

                Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
