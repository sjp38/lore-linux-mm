Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id C018B6B0311
	for <linux-mm@kvack.org>; Mon,  1 May 2017 14:34:19 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id d46so5668008wrd.17
        for <linux-mm@kvack.org>; Mon, 01 May 2017 11:34:19 -0700 (PDT)
Received: from mail-wr0-x242.google.com (mail-wr0-x242.google.com. [2a00:1450:400c:c0c::242])
        by mx.google.com with ESMTPS id f131si9827788wme.164.2017.05.01.11.34.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 May 2017 11:34:18 -0700 (PDT)
Received: by mail-wr0-x242.google.com with SMTP id v42so14495663wrc.3
        for <linux-mm@kvack.org>; Mon, 01 May 2017 11:34:18 -0700 (PDT)
Subject: Re: [PATCH man-pages 1/2] userfaultfd.2: start documenting
 non-cooperative events
References: <1493302474-4701-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1493302474-4701-2-git-send-email-rppt@linux.vnet.ibm.com>
 <a95f9ae6-f7db-1ed9-6e25-99ced1fd37a3@gmail.com>
 <190E3CFC-492F-4672-9385-9C3D8F57F26C@linux.vnet.ibm.com>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Message-ID: <3cff5638-cb15-50e6-f5a4-d9a0fce643c5@gmail.com>
Date: Mon, 1 May 2017 20:34:16 +0200
MIME-Version: 1.0
In-Reply-To: <190E3CFC-492F-4672-9385-9C3D8F57F26C@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoprt <rppt@linux.vnet.ibm.com>
Cc: mtk.manpages@gmail.com, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-man@vger.kernel.org

Hi Mike,

On 04/28/2017 11:45 AM, Mike Rapoprt wrote:
> 
> 
> On April 27, 2017 8:26:16 PM GMT+03:00, "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com> wrote:
>> Hi Mike,
>>
>> I've applied this, but have some questions/points I think 
>> further clarification.
>>
>> On 04/27/2017 04:14 PM, Mike Rapoport wrote:
>>> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
>>> ---
>>>  man2/userfaultfd.2 | 135
>> ++++++++++++++++++++++++++++++++++++++++++++++++++---
>>>  1 file changed, 128 insertions(+), 7 deletions(-)
>>>
>>> diff --git a/man2/userfaultfd.2 b/man2/userfaultfd.2
>>> index cfea5cb..44af3e4 100644
>>> --- a/man2/userfaultfd.2
>>> +++ b/man2/userfaultfd.2
>>> @@ -75,7 +75,7 @@ flag in
>>>  .PP
>>>  When the last file descriptor referring to a userfaultfd object is
>> closed,
>>>  all memory ranges that were registered with the object are
>> unregistered
>>> -and unread page-fault events are flushed.
>>> +and unread events are flushed.
>>>  .\"
>>>  .SS Usage
>>>  The userfaultfd mechanism is designed to allow a thread in a
>> multithreaded
>>> @@ -99,6 +99,20 @@ In such non-cooperative mode,
>>>  the process that monitors userfaultfd and handles page faults
>>>  needs to be aware of the changes in the virtual memory layout
>>>  of the faulting process to avoid memory corruption.
>>> +
>>> +Starting from Linux 4.11,
>>> +userfaultfd may notify the fault-handling threads about changes
>>> +in the virtual memory layout of the faulting process.
>>> +In addition, if the faulting process invokes
>>> +.BR fork (2)
>>> +system call,
>>> +the userfaultfd objects associated with the parent may be duplicated
>>> +into the child process and the userfaultfd monitor will be notified
>>> +about the file descriptor associated with the userfault objects
>>
>> What does "notified about the file descriptor" mean?
> 
> Well, seems that I've made this one really awkward :)
> When the monitored process forks, all the userfault objects
> associateda?? with it are duplicated into the child process. For each
> duplicated object, userfault generates event of type UFFD_EVENT_FORK
> and the uffdio_msg for this event contains the file descriptor that
> should be used to manipulate the duplicated userfault object.
> Hope this clarifies.

Yes, it's clearer now.

Mostly what was needed here was a forward reference that mentions
UFFD_EVENT_FORK explicitly. I added that, and also enhanced the
text on UFFD_EVENT_FORK a little.

Also, it's not just fork(2) for which UFFD_EVENT_FORK is generated,
right? It can also be a clone(2) cal that does not specify
CLONE_VM, right?

Could you review my changes in commit 522ab2ff6fc9010432a
to make sure they are okay.

Cheers,

Michael

-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
