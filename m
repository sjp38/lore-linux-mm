Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 519886B0253
	for <linux-mm@kvack.org>; Sat, 19 Sep 2015 18:54:53 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so83116973pac.2
        for <linux-mm@kvack.org>; Sat, 19 Sep 2015 15:54:53 -0700 (PDT)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id it8si25231955pbc.103.2015.09.19.15.54.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 19 Sep 2015 15:54:52 -0700 (PDT)
Received: by pacex6 with SMTP id ex6so81756431pac.0
        for <linux-mm@kvack.org>; Sat, 19 Sep 2015 15:54:52 -0700 (PDT)
Date: Sat, 19 Sep 2015 15:54:40 -0700
From: Raymond Jennings <shentino@gmail.com>
Subject: Re: can't oom-kill zap the victim's memory?
Message-Id: <1442703280.10833.0@smtp.gmail.com>
In-Reply-To: 
 <CA+55aFwkvbMrGseOsZNaxgP3wzDoVjkGasBKFxpn07SaokvpXA@mail.gmail.com>
References: <1442512783-14719-1-git-send-email-kwalker@redhat.com>
	<20150919150316.GB31952@redhat.com>
	<CA+55aFwkvbMrGseOsZNaxgP3wzDoVjkGasBKFxpn07SaokvpXA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/alternative; boundary="=-Qn8st9Ake0m5uwhQ4RKK"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, Kyle Walker <kwalker@redhat.com>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Stanislav Kozina <skozina@redhat.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>

--=-Qn8st9Ake0m5uwhQ4RKK
Content-Type: text/plain; charset=utf-8; format=flowed

On Sat, Sep 19, 2015 at 3:24 PM, Linus Torvalds 
<torvalds@linux-foundation.org> wrote:
> On Sat, Sep 19, 2015 at 8:03 AM, Oleg Nesterov <oleg@redhat.com> 
> wrote:
>>  +
>>  +static void oom_unmap_func(struct work_struct *work)
>>  +{
>>  +       struct mm_struct *mm = xchg(&oom_unmap_mm, NULL);
>>  +
>>  +       if (!atomic_inc_not_zero(&mm->mm_users))
>>  +               return;
>>  +
>>  +       // If this is not safe we can do use_mm() + unuse_mm()
>>  +       down_read(&mm->mmap_sem);
> 
> I don't think this is safe.
> 
> What makes you sure that we might not deadlock on the mmap_sem here?
> For all we know, the process that is going out of memory is in the
> middle of a mmap(), and already holds the mmap_sem for writing. No?
> 
> So at the very least that needs to be a trylock, I think. And I'm not
> sure zap_page_range() is ok with the mmap_sem only held for reading.
> Normally our rule is that you can *populate* the page tables
> concurrently, but you can't tear the down.

Is it also possible to have mmap fail with EINTR?  Presumably that 
would let a pending SIGKILL from the oom handler punch it out of the 
kernel and back to userspace.

> 
> 
>                 Linus
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--=-Qn8st9Ake0m5uwhQ4RKK
Content-Type: text/html; charset=utf-8

On Sat, Sep 19, 2015 at 3:24 PM, Linus Torvalds &lt;torvalds@linux-foundation.org&gt; wrote:<br>
<blockquote type="cite"><div class="plaintext" style="white-space: pre-wrap;">On Sat, Sep 19, 2015 at 8:03 AM, Oleg Nesterov &lt;<a href="mailto:oleg@redhat.com">oleg@redhat.com</a>&gt; wrote:
<blockquote> +
 +static void oom_unmap_func(struct work_struct *work)
 +{
 +       struct mm_struct *mm = xchg(&amp;oom_unmap_mm, NULL);
 +
 +       if (!atomic_inc_not_zero(&amp;mm-&gt;mm_users))
 +               return;
 +
 +       // If this is not safe we can do use_mm() + unuse_mm()
 +       down_read(&amp;mm-&gt;mmap_sem);
</blockquote>
I don't think this is safe.

What makes you sure that we might not deadlock on the mmap_sem here?
For all we know, the process that is going out of memory is in the
middle of a mmap(), and already holds the mmap_sem for writing. No?

So at the very least that needs to be a trylock, I think. And I'm not
sure zap_page_range() is ok with the mmap_sem only held for reading.
Normally our rule is that you can *populate* the page tables
concurrently, but you can't tear the down.</div></blockquote><div><br></div>Is it also possible to have mmap fail with EINTR? &nbsp;Presumably that would let a pending SIGKILL from the oom handler punch it out of the kernel and back to userspace.<div><br><blockquote type="cite"><div class="plaintext" style="white-space: pre-wrap;">

                Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to <a href="mailto:majordomo@kvack.org">majordomo@kvack.org</a>.  For more info on Linux MM,
see: <a href="http://www.linux-mm.org/">http://www.linux-mm.org/</a> .
Don't email: &lt;a href=mailto:"dont@kvack.org"&gt; email@kvack.org &lt;/a&gt;
</div></blockquote></div>
--=-Qn8st9Ake0m5uwhQ4RKK--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
