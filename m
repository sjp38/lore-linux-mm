Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id A4AFC6B003A
	for <linux-mm@kvack.org>; Tue, 17 Jun 2014 12:51:19 -0400 (EDT)
Received: by mail-ig0-f178.google.com with SMTP id hn18so4415790igb.17
        for <linux-mm@kvack.org>; Tue, 17 Jun 2014 09:51:19 -0700 (PDT)
Received: from mail-ie0-x22c.google.com (mail-ie0-x22c.google.com [2607:f8b0:4001:c03::22c])
        by mx.google.com with ESMTPS id b11si11617402icj.83.2014.06.17.09.51.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 17 Jun 2014 09:51:19 -0700 (PDT)
Received: by mail-ie0-f172.google.com with SMTP id lx4so6588082iec.3
        for <linux-mm@kvack.org>; Tue, 17 Jun 2014 09:51:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALCETrVerC155vzO-1Js1W8cRTYat0-+OGOxW+kSynJor6rJag@mail.gmail.com>
References: <1402655819-14325-1-git-send-email-dh.herrmann@gmail.com>
	<CALCETrVoE+JO2rLsBUHAOJdvescEEjxikj8iQ339Nxfopfc7pw@mail.gmail.com>
	<CANq1E4SaWLD=hNEc-CDJbNnrGfXE_PkxZFBhpW4tbK7wor7xPA@mail.gmail.com>
	<CALCETrU8N9EbnJ3=oQ1WQCG9Vunn3nR9Ba=J48wJm0SuH0YB4A@mail.gmail.com>
	<CANq1E4QQUKHabheq18AzkVZk3WDtAeC-6W66tVNB+EKgYOx1Vg@mail.gmail.com>
	<53A01049.6020502@redhat.com>
	<CANq1E4T3KJZ++=KF2OZ_dd+NvPqg+=4Pw6O7Po3-ZxaaMHPukw@mail.gmail.com>
	<CALCETrVpZ0vFM4usHK+tQhk234Y2jWzB1522kGcGvdQQFAqsZQ@mail.gmail.com>
	<CANq1E4QdGz6cRm2Y-vMQHV1O=VK74XNP8qCAmiAskVaVKpJuxg@mail.gmail.com>
	<CALCETrVerC155vzO-1Js1W8cRTYat0-+OGOxW+kSynJor6rJag@mail.gmail.com>
Date: Tue, 17 Jun 2014 18:51:18 +0200
Message-ID: <CANq1E4RqLLk8_Fn=e-c2g29_uiD-R59u=WKF9Tka33L5G9VA9Q@mail.gmail.com>
Subject: Re: [PATCH v3 0/7] File Sealing & memfd_create()
From: David Herrmann <dh.herrmann@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Greg KH <greg@kroah.com>, Florian Weimer <fweimer@redhat.com>, Hugh Dickins <hughd@google.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Lennart Poettering <lennart@poettering.net>, Andrew Morton <akpm@linux-foundation.org>, Linux API <linux-api@vger.kernel.org>, Michael Kerrisk <mtk.manpages@gmail.com>, Kay Sievers <kay@vrfy.org>, John Stultz <john.stultz@linaro.org>, Linus Torvalds <torvalds@linux-foundation.org>, Daniel Mack <zonque@gmail.com>, Ryan Lortie <desrt@desrt.ca>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Tony Battersby <tonyb@cybernetics.com>

Hi

On Tue, Jun 17, 2014 at 6:41 PM, Andy Lutomirski <luto@amacapital.net> wrote:
> On Tue, Jun 17, 2014 at 9:36 AM, David Herrmann <dh.herrmann@gmail.com> wrote:
>> Hi
>>
>> On Tue, Jun 17, 2014 at 6:20 PM, Andy Lutomirski <luto@amacapital.net> wrote:
>>> Can you summarize why holes can't be reliably backed by the zero page?
>>
>> To answer this, I will quote Hugh from "PATCH v2 1/3":
>>
>>> We do already use the ZERO_PAGE instead of allocating when it's a
>>> simple read; and on the face of it, we could extend that to mmap
>>> once the file is sealed.  But I am rather afraid to do so - for
>>> many years there was an mmap /dev/zero case which did that, but
>>> it was an easily forgotten case which caught us out at least
>>> once, so I'm reluctant to reintroduce it now for sealing.
>>>
>>> Anyway, I don't expect you to resolve the issue of sealed holes:
>>> that's very much my territory, to give you support on.
>>
>> Holes can be avoided with a simple fallocate(). I don't understand why
>> I should make SEAL_WRITE do the fallocate for the caller. During the
>> discussion of memfd_create() I was told to drop the "size" parameter,
>> because it is redundant. I don't see how this implicit fallocate()
>> does not fall into the same category?
>>
>
> I'm really confused now.
>
> If I SEAL_WRITE a file, and then I mmap it PROT_READ, and then I read
> it, is that a "simple read"?  If so, doesn't that mean that there's no
> problem?

I assumed Hugh was talking about read(). So no, this is not about
memory-reads on mmap()ed regions.

Looking at shmem_file_read_iter() I can see a ZERO_PAGE(0) call in
case shmem_getpage_gfp(SGP_READ) tells us there's a hole. I cannot see
anything like that in the mmap_region() and shmem_fault() paths.

Thanks
David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
