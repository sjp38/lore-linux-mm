Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 8D7576B0253
	for <linux-mm@kvack.org>; Sat, 19 Sep 2015 19:00:32 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so81821089pac.0
        for <linux-mm@kvack.org>; Sat, 19 Sep 2015 16:00:32 -0700 (PDT)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com. [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id d10si25250624pas.77.2015.09.19.16.00.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 19 Sep 2015 16:00:31 -0700 (PDT)
Received: by padhy16 with SMTP id hy16so81729555pad.1
        for <linux-mm@kvack.org>; Sat, 19 Sep 2015 16:00:31 -0700 (PDT)
Subject: Re: can't oom-kill zap the victim's memory?
References: <1442512783-14719-1-git-send-email-kwalker@redhat.com>
 <20150919150316.GB31952@redhat.com>
 <CA+55aFwkvbMrGseOsZNaxgP3wzDoVjkGasBKFxpn07SaokvpXA@mail.gmail.com>
From: Raymond Jennings <shentino@gmail.com>
Message-ID: <55FDE90D.1070402@gmail.com>
Date: Sat, 19 Sep 2015 16:00:29 -0700
MIME-Version: 1.0
In-Reply-To: <CA+55aFwkvbMrGseOsZNaxgP3wzDoVjkGasBKFxpn07SaokvpXA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>
Cc: Kyle Walker <kwalker@redhat.com>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Stanislav Kozina <skozina@redhat.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>

On 09/19/15 15:24, Linus Torvalds wrote:
> On Sat, Sep 19, 2015 at 8:03 AM, Oleg Nesterov <oleg@redhat.com> wrote:
>> +
>> +static void oom_unmap_func(struct work_struct *work)
>> +{
>> +       struct mm_struct *mm = xchg(&oom_unmap_mm, NULL);
>> +
>> +       if (!atomic_inc_not_zero(&mm->mm_users))
>> +               return;
>> +
>> +       // If this is not safe we can do use_mm() + unuse_mm()
>> +       down_read(&mm->mmap_sem);
> I don't think this is safe.
>
> What makes you sure that we might not deadlock on the mmap_sem here?
> For all we know, the process that is going out of memory is in the
> middle of a mmap(), and already holds the mmap_sem for writing. No?

Potentially stupid question that others may be asking: Is it legal to 
return EINTR from mmap() to let a SIGKILL from the OOM handler punch the 
task out of the kernel and back to userspace?

(sorry for the dupe btw, new email client snuck in html and I got bounced)

> So at the very least that needs to be a trylock, I think. And I'm not
> sure zap_page_range() is ok with the mmap_sem only held for reading.
> Normally our rule is that you can *populate* the page tables
> concurrently, but you can't tear the down.
>
>                  Linus
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
