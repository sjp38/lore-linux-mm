Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id E9C228E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 12:20:34 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id v4so2586182edm.18
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 09:20:34 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id cc8-v6si3710090ejb.248.2019.01.16.09.20.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 09:20:33 -0800 (PST)
Subject: Re: [PATCH] mm: hwpoison: use do_send_sig_info() instead of
 force_sig() (Re: PMEM error-handling forces SIGKILL causes kernel panic)
References: <e3c4c0e0-1434-4353-b893-2973c04e7ff7@oracle.com>
 <CAPcyv4j67n6H7hD6haXJqysbaauci4usuuj5c+JQ7VQBGngO1Q@mail.gmail.com>
 <20190111081401.GA5080@hori1.linux.bs1.fc.nec.co.jp>
 <20190116093046.GA29835@hori1.linux.bs1.fc.nec.co.jp>
 <CAPcyv4jnHqDp7s1SdqHePms2Z-8d0zk-+6meqKeMQUNArxHb_w@mail.gmail.com>
From: Jane Chu <jane.chu@oracle.com>
Message-ID: <bdf211ba-1429-fadb-9c0a-aa6dd52d48ab@oracle.com>
Date: Wed, 16 Jan 2019 09:20:12 -0800
MIME-Version: 1.0
In-Reply-To: <CAPcyv4jnHqDp7s1SdqHePms2Z-8d0zk-+6meqKeMQUNArxHb_w@mail.gmail.com>
Content-Type: multipart/alternative;
 boundary="------------0561E387B57A6939D37E0BC0"
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

This is a multi-part message in MIME format.
--------------0561E387B57A6939D37E0BC0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit


On 1/16/2019 8:55 AM, Dan Williams wrote:
> On Wed, Jan 16, 2019 at 1:33 AM Naoya Horiguchi
> <n-horiguchi@ah.jp.nec.com> wrote:
>> [ CCed Andrew and linux-mm ]
>>
>> On Fri, Jan 11, 2019 at 08:14:02AM +0000, Horiguchi Naoya(堀口 直也) wrote:
>>> Hi Dan, Jane,
>>>
>>> Thanks for the report.
>>>
>>> On Wed, Jan 09, 2019 at 03:49:32PM -0800, Dan Williams wrote:
>>>> [ switch to text mail, add lkml and Naoya ]
>>>>
>>>> On Wed, Jan 9, 2019 at 12:19 PM Jane Chu <jane.chu@oracle.com> wrote:
>>> ...
>>>>> 3. The hardware consists the latest revision CPU and Intel NVDIMM, we suspected
>>>>>     the CPU faulty because it generated MCE over PMEM UE in a unlikely high
>>>>>     rate for any reasonable NVDIMM (like a few per 24hours).
>>>>>
>>>>> After swapping the CPU, the problem stopped reproducing.
>>>>>
>>>>> But one could argue that perhaps the faulty CPU exposed a small race window
>>>>> from collect_procs() to unmap_mapping_range() and to kill_procs(), hence
>>>>> caught the kernel  PMEM error handler off guard.
>>>> There's definitely a race, and the implementation is buggy as can be
>>>> seen in __exit_signal:
>>>>
>>>>          sighand = rcu_dereference_check(tsk->sighand,
>>>>                                          lockdep_tasklist_lock_is_held());
>>>>          spin_lock(&sighand->siglock);
>>>>
>>>> ...the memory-failure path needs to hold the proper locks before it
>>>> can assume that de-referencing tsk->sighand is valid.
>>>>
>>>>> Also note, the same workload on the same faulty CPU were run on Linux prior to
>>>>> the 4.19 PMEM error handling and did not encounter kernel crash, probably because
>>>>> the prior HWPOISON handler did not force SIGKILL?
>>>> Before 4.19 this test should result in a machine-check reboot, not
>>>> much better than a kernel crash.
>>>>
>>>>> Should we not to force the SIGKILL, or find a way to close the race window?
>>>> The race should be closed by holding the proper tasklist and rcu read lock(s).
>>> This reasoning and proposal sound right to me. I'm trying to reproduce
>>> this race (for non-pmem case,) but no luck for now. I'll investigate more.
>> I wrote/tested a patch for this issue.
>> I think that switching signal API effectively does proper locking.
>>
>> Thanks,
>> Naoya Horiguchi
>> ---
>>  From 16dbf6105ff4831f73276d79d5df238ab467de76 Mon Sep 17 00:00:00 2001
>> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>> Date: Wed, 16 Jan 2019 16:59:27 +0900
>> Subject: [PATCH] mm: hwpoison: use do_send_sig_info() instead of force_sig()
>>
>> Currently memory_failure() is racy against process's exiting,
>> which results in kernel crash by null pointer dereference.
>>
>> The root cause is that memory_failure() uses force_sig() to forcibly
>> kill asynchronous (meaning not in the current context) processes.  As
>> discussed in thread https://lkml.org/lkml/2010/6/8/236 years ago for
>> OOM fixes, this is not a right thing to do.  OOM solves this issue by
>> using do_send_sig_info() as done in commit d2d393099de2 ("signal:
>> oom_kill_task: use SEND_SIG_FORCED instead of force_sig()"), so this
>> patch is suggesting to do the same for hwpoison.  do_send_sig_info()
>> properly accesses to siglock with lock_task_sighand(), so is free from
>> the reported race.
>>
>> I confirmed that the reported bug reproduces with inserting some delay
>> in kill_procs(), and it never reproduces with this patch.
>>
>> Note that memory_failure() can send another type of signal using
>> force_sig_mceerr(), and the reported race shouldn't happen on it
>> because force_sig_mceerr() is called only for synchronous processes
>> (i.e. BUS_MCEERR_AR happens only when some process accesses to the
>> corrupted memory.)
>>
>> Reported-by: Jane Chu <jane.chu@oracle.com>
>> Cc: Dan Williams <dan.j.williams@intel.com>
>> Cc: stable@vger.kernel.org
>> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>> ---
> Looks good to me.
>
> Reviewed-by: Dan Williams <dan.j.williams@intel.com>
>
> ...but it would still be good to get a Tested-by from Jane.

Sure, will let you know how the test goes.

Thanks!
-jane


--------------0561E387B57A6939D37E0BC0
Content-Type: text/html; charset=utf-8
Content-Transfer-Encoding: 8bit

<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
  </head>
  <body text="#000000" bgcolor="#FFFFFF">
    <p><br>
    </p>
    <div class="moz-cite-prefix">On 1/16/2019 8:55 AM, Dan Williams
      wrote:<br>
    </div>
    <blockquote type="cite"
cite="mid:CAPcyv4jnHqDp7s1SdqHePms2Z-8d0zk-+6meqKeMQUNArxHb_w@mail.gmail.com">
      <pre class="moz-quote-pre" wrap="">On Wed, Jan 16, 2019 at 1:33 AM Naoya Horiguchi
<a class="moz-txt-link-rfc2396E" href="mailto:n-horiguchi@ah.jp.nec.com">&lt;n-horiguchi@ah.jp.nec.com&gt;</a> wrote:
</pre>
      <blockquote type="cite">
        <pre class="moz-quote-pre" wrap="">
[ CCed Andrew and linux-mm ]

On Fri, Jan 11, 2019 at 08:14:02AM +0000, Horiguchi Naoya(堀口 直也) wrote:
</pre>
        <blockquote type="cite">
          <pre class="moz-quote-pre" wrap="">Hi Dan, Jane,

Thanks for the report.

On Wed, Jan 09, 2019 at 03:49:32PM -0800, Dan Williams wrote:
</pre>
          <blockquote type="cite">
            <pre class="moz-quote-pre" wrap="">[ switch to text mail, add lkml and Naoya ]

On Wed, Jan 9, 2019 at 12:19 PM Jane Chu <a class="moz-txt-link-rfc2396E" href="mailto:jane.chu@oracle.com">&lt;jane.chu@oracle.com&gt;</a> wrote:
</pre>
          </blockquote>
          <pre class="moz-quote-pre" wrap="">...
</pre>
          <blockquote type="cite">
            <blockquote type="cite">
              <pre class="moz-quote-pre" wrap="">3. The hardware consists the latest revision CPU and Intel NVDIMM, we suspected
   the CPU faulty because it generated MCE over PMEM UE in a unlikely high
   rate for any reasonable NVDIMM (like a few per 24hours).

After swapping the CPU, the problem stopped reproducing.

But one could argue that perhaps the faulty CPU exposed a small race window
from collect_procs() to unmap_mapping_range() and to kill_procs(), hence
caught the kernel  PMEM error handler off guard.
</pre>
            </blockquote>
            <pre class="moz-quote-pre" wrap="">
There's definitely a race, and the implementation is buggy as can be
seen in __exit_signal:

        sighand = rcu_dereference_check(tsk-&gt;sighand,
                                        lockdep_tasklist_lock_is_held());
        spin_lock(&amp;sighand-&gt;siglock);

...the memory-failure path needs to hold the proper locks before it
can assume that de-referencing tsk-&gt;sighand is valid.

</pre>
            <blockquote type="cite">
              <pre class="moz-quote-pre" wrap="">Also note, the same workload on the same faulty CPU were run on Linux prior to
the 4.19 PMEM error handling and did not encounter kernel crash, probably because
the prior HWPOISON handler did not force SIGKILL?
</pre>
            </blockquote>
            <pre class="moz-quote-pre" wrap="">
Before 4.19 this test should result in a machine-check reboot, not
much better than a kernel crash.

</pre>
            <blockquote type="cite">
              <pre class="moz-quote-pre" wrap="">Should we not to force the SIGKILL, or find a way to close the race window?
</pre>
            </blockquote>
            <pre class="moz-quote-pre" wrap="">
The race should be closed by holding the proper tasklist and rcu read lock(s).
</pre>
          </blockquote>
          <pre class="moz-quote-pre" wrap="">
This reasoning and proposal sound right to me. I'm trying to reproduce
this race (for non-pmem case,) but no luck for now. I'll investigate more.
</pre>
        </blockquote>
        <pre class="moz-quote-pre" wrap="">
I wrote/tested a patch for this issue.
I think that switching signal API effectively does proper locking.

Thanks,
Naoya Horiguchi
---
>From 16dbf6105ff4831f73276d79d5df238ab467de76 Mon Sep 17 00:00:00 2001
From: Naoya Horiguchi <a class="moz-txt-link-rfc2396E" href="mailto:n-horiguchi@ah.jp.nec.com">&lt;n-horiguchi@ah.jp.nec.com&gt;</a>
Date: Wed, 16 Jan 2019 16:59:27 +0900
Subject: [PATCH] mm: hwpoison: use do_send_sig_info() instead of force_sig()

Currently memory_failure() is racy against process's exiting,
which results in kernel crash by null pointer dereference.

The root cause is that memory_failure() uses force_sig() to forcibly
kill asynchronous (meaning not in the current context) processes.  As
discussed in thread <a class="moz-txt-link-freetext" href="https://lkml.org/lkml/2010/6/8/236">https://lkml.org/lkml/2010/6/8/236</a> years ago for
OOM fixes, this is not a right thing to do.  OOM solves this issue by
using do_send_sig_info() as done in commit d2d393099de2 ("signal:
oom_kill_task: use SEND_SIG_FORCED instead of force_sig()"), so this
patch is suggesting to do the same for hwpoison.  do_send_sig_info()
properly accesses to siglock with lock_task_sighand(), so is free from
the reported race.

I confirmed that the reported bug reproduces with inserting some delay
in kill_procs(), and it never reproduces with this patch.

Note that memory_failure() can send another type of signal using
force_sig_mceerr(), and the reported race shouldn't happen on it
because force_sig_mceerr() is called only for synchronous processes
(i.e. BUS_MCEERR_AR happens only when some process accesses to the
corrupted memory.)

Reported-by: Jane Chu <a class="moz-txt-link-rfc2396E" href="mailto:jane.chu@oracle.com">&lt;jane.chu@oracle.com&gt;</a>
Cc: Dan Williams <a class="moz-txt-link-rfc2396E" href="mailto:dan.j.williams@intel.com">&lt;dan.j.williams@intel.com&gt;</a>
Cc: <a class="moz-txt-link-abbreviated" href="mailto:stable@vger.kernel.org">stable@vger.kernel.org</a>
Signed-off-by: Naoya Horiguchi <a class="moz-txt-link-rfc2396E" href="mailto:n-horiguchi@ah.jp.nec.com">&lt;n-horiguchi@ah.jp.nec.com&gt;</a>
---
</pre>
      </blockquote>
      <pre class="moz-quote-pre" wrap="">
Looks good to me.

Reviewed-by: Dan Williams <a class="moz-txt-link-rfc2396E" href="mailto:dan.j.williams@intel.com">&lt;dan.j.williams@intel.com&gt;</a>

...but it would still be good to get a Tested-by from Jane.</pre>
    </blockquote>
    <pre>Sure, will let you know how the test goes.

Thanks!
-jane
</pre>
    <blockquote type="cite"
cite="mid:CAPcyv4jnHqDp7s1SdqHePms2Z-8d0zk-+6meqKeMQUNArxHb_w@mail.gmail.com">
      <pre class="moz-quote-pre" wrap="">
</pre>
    </blockquote>
  </body>
</html>

--------------0561E387B57A6939D37E0BC0--
