Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id DD8806B0005
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 19:08:44 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id q18-v6so632050pll.3
        for <linux-mm@kvack.org>; Tue, 19 Jun 2018 16:08:44 -0700 (PDT)
Received: from out30-133.freemail.mail.aliyun.com (out30-133.freemail.mail.aliyun.com. [115.124.30.133])
        by mx.google.com with ESMTPS id p18-v6si661945pgu.671.2018.06.19.16.08.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jun 2018 16:08:43 -0700 (PDT)
Subject: Re: [RFC v2 PATCH 2/2] mm: mmap: zap pages with read mmap_sem for
 large mapping
References: <1529364856-49589-1-git-send-email-yang.shi@linux.alibaba.com>
 <1529364856-49589-3-git-send-email-yang.shi@linux.alibaba.com>
 <3DDF2672-FCC4-4387-9624-92F33C309CAE@gmail.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <158a4e4c-d290-77c4-a595-71332ede392b@linux.alibaba.com>
Date: Tue, 19 Jun 2018 16:08:32 -0700
MIME-Version: 1.0
In-Reply-To: <3DDF2672-FCC4-4387-9624-92F33C309CAE@gmail.com>
Content-Type: multipart/alternative;
 boundary="------------705807C8FDEA83CB327E2211"
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: Michal Hocko <mhocko@kernel.org>, Matthew Wilcox <willy@infradead.org>, ldufour@linux.vnet.ibm.com, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

This is a multi-part message in MIME format.
--------------705807C8FDEA83CB327E2211
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit



On 6/19/18 3:17 PM, Nadav Amit wrote:
> at 4:34 PM, Yang Shi <yang.shi@linux.alibaba.com> wrote:
>
>> When running some mmap/munmap scalability tests with large memory (i.e.
>>> 300GB), the below hung task issue may happen occasionally.
>> INFO: task ps:14018 blocked for more than 120 seconds.
>>        Tainted: G            E 4.9.79-009.ali3000.alios7.x86_64 #1
>> "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this
>> message.
>> ps              D    0 14018      1 0x00000004
>>
> (snip)
>
>> Zapping pages is the most time consuming part, according to the
>> suggestion from Michal Hock [1], zapping pages can be done with holding
>> read mmap_sem, like what MADV_DONTNEED does. Then re-acquire write
>> mmap_sem to manipulate vmas.
> Does munmap() == MADV_DONTNEED + munmap() ?

Not exactly the same. So, I basically copied the page zapping used by 
munmap instead of calling MADV_DONTNEED.

>
> For example, what happens with userfaultfd in this case? Can you get an
> extra #PF, which would be visible to userspace, before the munmap is
> finished?

userfaultfd is handled by regular munmap path. So, no change to 
userfaultfd part.

>
> In addition, would it be ok for the user to potentially get a zeroed page in
> the time window after the MADV_DONTNEED finished removing a PTE and before
> the munmap() is done?

This should be undefined behavior according to Michal. This has been 
discussed in https://lwn.net/Articles/753269/.

Thanks,
Yang

>
> Regards,
> Nadav


--------------705807C8FDEA83CB327E2211
Content-Type: text/html; charset=utf-8
Content-Transfer-Encoding: 8bit

<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  </head>
  <body text="#000000" bgcolor="#FFFFFF">
    <p><br>
    </p>
    <br>
    <div class="moz-cite-prefix">On 6/19/18 3:17 PM, Nadav Amit wrote:<br>
    </div>
    <blockquote type="cite"
      cite="mid:3DDF2672-FCC4-4387-9624-92F33C309CAE@gmail.com">
      <pre wrap="">at 4:34 PM, Yang Shi <a class="moz-txt-link-rfc2396E" href="mailto:yang.shi@linux.alibaba.com">&lt;yang.shi@linux.alibaba.com&gt;</a> wrote:

</pre>
      <blockquote type="cite">
        <pre wrap="">When running some mmap/munmap scalability tests with large memory (i.e.
</pre>
        <blockquote type="cite">
          <pre wrap="">300GB), the below hung task issue may happen occasionally.
</pre>
        </blockquote>
        <pre wrap="">
INFO: task ps:14018 blocked for more than 120 seconds.
      Tainted: G            E 4.9.79-009.ali3000.alios7.x86_64 #1
"echo 0 &gt; /proc/sys/kernel/hung_task_timeout_secs" disables this
message.
ps              D    0 14018      1 0x00000004

</pre>
      </blockquote>
      <pre wrap="">(snip)

</pre>
      <blockquote type="cite">
        <pre wrap="">
Zapping pages is the most time consuming part, according to the
suggestion from Michal Hock [1], zapping pages can be done with holding
read mmap_sem, like what MADV_DONTNEED does. Then re-acquire write
mmap_sem to manipulate vmas.
</pre>
      </blockquote>
      <pre wrap="">
Does munmap() == MADV_DONTNEED + munmap() ?</pre>
    </blockquote>
    <br>
    Not exactly the same. So, I basically copied the page zapping used
    by munmap instead of calling MADV_DONTNEED.<br>
    <br>
    <blockquote type="cite"
      cite="mid:3DDF2672-FCC4-4387-9624-92F33C309CAE@gmail.com">
      <pre wrap="">

For example, what happens with userfaultfd in this case? Can you get an
extra #PF, which would be visible to userspace, before the munmap is
finished?</pre>
    </blockquote>
    <br>
    userfaultfd is handled by regular munmap path. So, no change to
    userfaultfd part.<br>
    <br>
    <blockquote type="cite"
      cite="mid:3DDF2672-FCC4-4387-9624-92F33C309CAE@gmail.com">
      <pre wrap="">

In addition, would it be ok for the user to potentially get a zeroed page in
the time window after the MADV_DONTNEED finished removing a PTE and before
the munmap() is done?</pre>
    </blockquote>
    <br>
    This should be undefined behavior according to Michal. This has been
    discussed inA  <a class="moz-txt-link-freetext"
      href="https://lwn.net/Articles/753269/">https://lwn.net/Articles/753269/.</a><br>
    <br>
    Thanks,<br>
    Yang<br>
    <br>
    <blockquote type="cite"
      cite="mid:3DDF2672-FCC4-4387-9624-92F33C309CAE@gmail.com">
      <pre wrap="">

Regards,
Nadav
</pre>
    </blockquote>
    <br>
  </body>
</html>

--------------705807C8FDEA83CB327E2211--
