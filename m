Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id C7FD66B0038
	for <linux-mm@kvack.org>; Thu, 16 Apr 2015 08:01:08 -0400 (EDT)
Received: by qgeb100 with SMTP id b100so4198071qge.3
        for <linux-mm@kvack.org>; Thu, 16 Apr 2015 05:01:08 -0700 (PDT)
Received: from mail-qk0-x22f.google.com (mail-qk0-x22f.google.com. [2607:f8b0:400d:c09::22f])
        by mx.google.com with ESMTPS id hi9si8017774qcb.46.2015.04.16.05.01.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Apr 2015 05:01:08 -0700 (PDT)
Received: by qkx62 with SMTP id 62so127219438qkx.0
        for <linux-mm@kvack.org>; Thu, 16 Apr 2015 05:01:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALYGNiPM0KgRvu2EP+h0UT8ZzSeBpNOwR04-BX2vPFnn2xLN_w@mail.gmail.com>
References: <20150416032316.00b79732@yak.slack>
	<CALYGNiPM0KgRvu2EP+h0UT8ZzSeBpNOwR04-BX2vPFnn2xLN_w@mail.gmail.com>
Date: Thu, 16 Apr 2015 14:01:07 +0200
Message-ID: <CANq1E4SbenR0-N4oLBMUe_2iiduU1TReA1RRTMA9_+h_mGwNOw@mail.gmail.com>
Subject: Re: [PATCH] mm/shmem.c: Add new seal to memfd: F_SEAL_WRITE_NONCREATOR
From: David Herrmann <dh.herrmann@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Michael Tirado <mtirado418@gmail.com>, Hugh Dickins <hughd@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi

On Thu, Apr 16, 2015 at 10:14 AM, Konstantin Khlebnikov
<koct9i@gmail.com> wrote:
> On Thu, Apr 16, 2015 at 10:23 AM, Michael Tirado <mtirado418@gmail.com> wrote:
>> Hi everyone, I have 2 questions (see comments marked with "Question:")
>> that I am hoping to get some input on.  Any feedback in general you can offer
>> is greatly appreciated.  Most importantly, I would like to be sure that this
>> is a valid way to implement such a seal.  This is my first kernel modification
>> and I haven't been following the mailing list for very long (for the record
>> in case there is a dumb mistake in here)   I don't know any kernel devs and
>> figured this would be the most appropriate place to find some useful feedback.
>>
>> This seal is similar to F_SEAL_WRITE, but will allow the task that created the
>> memfd to continue writing and retain a single shared writable mapping. Needed for
>> one-way communication between processes, authenticated at the task level.
>> Currently the only way to accomplish this is by constantly creating, filling,
>> sealing write, then sending memfd.  Also, a different name suggestion is welcome.
>
> I guess that was in original design but was dropped for some reason.

No. This is not what sealing is about. Seals are a property of an
object, they're unrelated to the process accessing it. Sealing is not
an access-control method, but describes the state and capabilities of
a file.

The same functionality of F_SEAL_WRITE_NONCREATOR can be achieved by
opening /proc/self/fd/<num> with O_RDONLY. Just pass that read-only FD
to your peers but retain the writable one. But note that you must
verify your peers do not have the same uid as you do, otherwise they
can just gain a writable descriptor by opening /proc/self/fd/<num>
themselves.

Thanks
David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
