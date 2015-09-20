Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id BBB8D6B0255
	for <linux-mm@kvack.org>; Sun, 20 Sep 2015 14:23:51 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so97382370pac.2
        for <linux-mm@kvack.org>; Sun, 20 Sep 2015 11:23:51 -0700 (PDT)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com. [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id ls16si31605106pab.206.2015.09.20.11.23.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 Sep 2015 11:23:51 -0700 (PDT)
Received: by pacfv12 with SMTP id fv12so97382269pac.2
        for <linux-mm@kvack.org>; Sun, 20 Sep 2015 11:23:50 -0700 (PDT)
Subject: Re: can't oom-kill zap the victim's memory?
References: <1442512783-14719-1-git-send-email-kwalker@redhat.com>
 <20150919150316.GB31952@redhat.com>
 <CA+55aFwkvbMrGseOsZNaxgP3wzDoVjkGasBKFxpn07SaokvpXA@mail.gmail.com>
 <20150920125642.GA2104@redhat.com>
 <CA+55aFyajHq2W9HhJWbLASFkTx_kLSHtHuY6mDHKxmoW-LnVEw@mail.gmail.com>
From: Raymond Jennings <shentino@gmail.com>
Message-ID: <55FEF9B4.7030806@gmail.com>
Date: Sun, 20 Sep 2015 11:23:48 -0700
MIME-Version: 1.0
In-Reply-To: <CA+55aFyajHq2W9HhJWbLASFkTx_kLSHtHuY6mDHKxmoW-LnVEw@mail.gmail.com>
Content-Type: multipart/alternative;
 boundary="------------020508030403080103040706"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>
Cc: Kyle Walker <kwalker@redhat.com>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Stanislav Kozina <skozina@redhat.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>

This is a multi-part message in MIME format.
--------------020508030403080103040706
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit



On 09/20/15 11:05, Linus Torvalds wrote:
> On Sun, Sep 20, 2015 at 5:56 AM, Oleg Nesterov <oleg@redhat.com> wrote:
>> In this case the workqueue thread will block.
> What workqueue thread?
>
>     pagefault_out_of_memory ->
>        out_of_memory ->
>           oom_kill_process
>
> as far as I can tell, this can be called by any task. Now, that
> pagefault case should only happen when the page fault comes from user
> space, but we also have
>
>     __alloc_pages_slowpath ->
>        __alloc_pages_may_oom ->
>           out_of_memory ->
>              oom_kill_process
>
> which can be called from just about any context (but atomic
> allocations will never get here, so it can schedule etc).
>
> So what's your point? Explain again just how do you guarantee that you
> can take the mmap_sem.
>
>                         Linus
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .dadsf
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
Would it be a cleaner design in general to require all threads to 
completely exit kernel space before being terminated?  Possibly 
expedited by noticing fatal signals and riding the EINTR rocket back up 
the stack?

My two cents:  If we do that we won't have to worry about fatally 
wounded tasks slipping into a coma before they cough up any semaphores 
or locks.


--------------020508030403080103040706
Content-Type: text/html; charset=utf-8
Content-Transfer-Encoding: 8bit

<html>
  <head>
    <meta content="text/html; charset=utf-8" http-equiv="Content-Type">
  </head>
  <body text="#000000" bgcolor="#FFFFFF">
    <br>
    <br>
    <div class="moz-cite-prefix">On 09/20/15 11:05, Linus Torvalds
      wrote:<br>
    </div>
    <blockquote
cite="mid:CA+55aFyajHq2W9HhJWbLASFkTx_kLSHtHuY6mDHKxmoW-LnVEw@mail.gmail.com"
      type="cite">
      <pre wrap="">On Sun, Sep 20, 2015 at 5:56 AM, Oleg Nesterov <a class="moz-txt-link-rfc2396E" href="mailto:oleg@redhat.com">&lt;oleg@redhat.com&gt;</a> wrote:
</pre>
      <blockquote type="cite">
        <pre wrap="">
In this case the workqueue thread will block.
</pre>
      </blockquote>
      <pre wrap="">
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
the body to <a class="moz-txt-link-abbreviated" href="mailto:majordomo@kvack.org">majordomo@kvack.org</a>.  For more info on Linux MM,
see: <a class="moz-txt-link-freetext" href="http://www.linux-mm.org/">http://www.linux-mm.org/</a> .dadsf
Don't email: &lt;a href=mailto:<a class="moz-txt-link-rfc2396E" href="mailto:dont@kvack.org">"dont@kvack.org"</a>&gt; <a class="moz-txt-link-abbreviated" href="mailto:email@kvack.org">email@kvack.org</a> &lt;/a&gt;
</pre>
    </blockquote>
    <meta http-equiv="content-type" content="text/html; charset=utf-8">
    <div style="color: rgb(0, 0, 0); font-family: Sans; font-size:
      medium; font-style: normal; font-variant: normal; font-weight:
      normal; letter-spacing: normal; line-height: normal; orphans:
      auto; text-align: start; text-indent: 0px; text-transform: none;
      white-space: normal; widows: auto; word-spacing: 0px;
      -webkit-text-stroke-width: 0px; background-color: rgb(255, 255,
      255);">Would it be a cleaner design in general to require all
      threads to completely exit kernel space before being terminated?
      A Possibly expedited by noticing fatal signals and riding the EINTR
      rocket back up the stack?</div>
    <div style="color: rgb(0, 0, 0); font-family: Sans; font-size:
      medium; font-style: normal; font-variant: normal; font-weight:
      normal; letter-spacing: normal; line-height: normal; orphans:
      auto; text-align: start; text-indent: 0px; text-transform: none;
      white-space: normal; widows: auto; word-spacing: 0px;
      -webkit-text-stroke-width: 0px; background-color: rgb(255, 255,
      255);"><br>
    </div>
    <div style="color: rgb(0, 0, 0); font-family: Sans; font-size:
      medium; font-style: normal; font-variant: normal; font-weight:
      normal; letter-spacing: normal; line-height: normal; orphans:
      auto; text-align: start; text-indent: 0px; text-transform: none;
      white-space: normal; widows: auto; word-spacing: 0px;
      -webkit-text-stroke-width: 0px; background-color: rgb(255, 255,
      255);">My two cents: A If we do that we won't have to worry about
      fatally wounded tasks slipping into a coma before they cough up
      any semaphores or locks.<br>
      <br>
    </div>
  </body>
</html>

--------------020508030403080103040706--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
