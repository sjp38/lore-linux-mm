Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f180.google.com (mail-io0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id D37846B0253
	for <linux-mm@kvack.org>; Sun, 20 Sep 2015 14:21:34 -0400 (EDT)
Received: by ioiz6 with SMTP id z6so100229594ioi.2
        for <linux-mm@kvack.org>; Sun, 20 Sep 2015 11:21:34 -0700 (PDT)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id qc6si6000269igb.23.2015.09.20.11.21.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 Sep 2015 11:21:34 -0700 (PDT)
Received: by padhk3 with SMTP id hk3so95290356pad.3
        for <linux-mm@kvack.org>; Sun, 20 Sep 2015 11:21:34 -0700 (PDT)
Date: Sun, 20 Sep 2015 11:21:30 -0700
From: Raymond Jennings <shentino@gmail.com>
Subject: Re: can't oom-kill zap the victim's memory?
Message-Id: <1442773290.10833.1@smtp.gmail.com>
In-Reply-To: 
 <CA+55aFyajHq2W9HhJWbLASFkTx_kLSHtHuY6mDHKxmoW-LnVEw@mail.gmail.com>
References: <1442512783-14719-1-git-send-email-kwalker@redhat.com>
	<20150919150316.GB31952@redhat.com>
	<CA+55aFwkvbMrGseOsZNaxgP3wzDoVjkGasBKFxpn07SaokvpXA@mail.gmail.com>
	<20150920125642.GA2104@redhat.com>
	<CA+55aFyajHq2W9HhJWbLASFkTx_kLSHtHuY6mDHKxmoW-LnVEw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/alternative; boundary="=-NAmRf6DRjM5VZqWXCDng"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, Kyle Walker <kwalker@redhat.com>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Stanislav Kozina <skozina@redhat.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>

--=-NAmRf6DRjM5VZqWXCDng
Content-Type: text/plain; charset=utf-8; format=flowed

On Sun, Sep 20, 2015 at 11:05 AM, Linus Torvalds 
<torvalds@linux-foundation.org> wrote:
> On Sun, Sep 20, 2015 at 5:56 AM, Oleg Nesterov <oleg@redhat.com> 
> wrote:
>> 
>>  In this case the workqueue thread will block.
> 
> What workqueue thread?
> 
>    pagefault_out_of_memory ->
>       out_of_memory ->
>          oom_kill_process
> 
> as far as I can tell, this can be called by any task. Now, that
> pagefault case should only happen when the page fault comes from user
> space, but we also have
> 
>    __alloc_pages_slowpath ->
>       __alloc_pages_may_oom ->
>          out_of_memory ->
>             oom_kill_process
> 
> which can be called from just about any context (but atomic
> allocations will never get here, so it can schedule etc).
> 
> So what's your point? Explain again just how do you guarantee that you
> can take the mmap_sem.
> 
>                        Linus
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Would it be a cleaner design in general to require all threads to 
completely exit kernel space before being terminated?  Possibly 
expedited by noticing fatal signals and riding the EINTR rocket back up 
the stack?

My two cents:  If we do that we won't have to worry about fatally 
wounded tasks slipping into a coma before they cough up any semaphores 
or locks.



--=-NAmRf6DRjM5VZqWXCDng
Content-Type: text/html; charset=utf-8

On Sun, Sep 20, 2015 at 11:05 AM, Linus Torvalds &lt;torvalds@linux-foundation.org&gt; wrote:<br>
<blockquote type="cite"><div class="plaintext" style="white-space: pre-wrap;">On Sun, Sep 20, 2015 at 5:56 AM, Oleg Nesterov &lt;<a href="mailto:oleg@redhat.com">oleg@redhat.com</a>&gt; wrote:
<blockquote>
 In this case the workqueue thread will block.
</blockquote>
What workqueue thread?

   pagefault_out_of_memory -&gt;
      out_of_memory -&gt;
         oom_kill_process

as far as I can tell, this can be called by any task. Now, that
pagefault case should only happen when the page fault comes from user
space, but we also have

   __alloc_pages_slowpath -&gt;
      __alloc_pages_may_oom -&gt;
         out_of_memory -&gt;
            oom_kill_process

which can be called from just about any context (but atomic
allocations will never get here, so it can schedule etc).

So what's your point? Explain again just how do you guarantee that you
can take the mmap_sem.

                       Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to <a href="mailto:majordomo@kvack.org">majordomo@kvack.org</a>.  For more info on Linux MM,
see: <a href="http://www.linux-mm.org/">http://www.linux-mm.org/</a> .
Don't email: &lt;a href=mailto:"dont@kvack.org"&gt; email@kvack.org &lt;/a&gt;</div></blockquote><br><div>Would it be a cleaner design in general to require all threads to completely exit kernel space before being terminated? &nbsp;Possibly expedited by noticing fatal signals and riding the EINTR rocket back up the stack?</div><div><br></div><div>My two cents: &nbsp;If we do that we won't have to worry about fatally wounded tasks slipping into a coma before they cough up any semaphores or locks.</div><div><br></div>
--=-NAmRf6DRjM5VZqWXCDng--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
