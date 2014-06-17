Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f171.google.com (mail-ie0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id 4B5B76B0031
	for <linux-mm@kvack.org>; Tue, 17 Jun 2014 06:01:56 -0400 (EDT)
Received: by mail-ie0-f171.google.com with SMTP id x19so6120307ier.2
        for <linux-mm@kvack.org>; Tue, 17 Jun 2014 03:01:56 -0700 (PDT)
Received: from mail-ig0-x231.google.com (mail-ig0-x231.google.com [2607:f8b0:4001:c05::231])
        by mx.google.com with ESMTPS id j1si15348900igv.36.2014.06.17.03.01.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 17 Jun 2014 03:01:55 -0700 (PDT)
Received: by mail-ig0-f177.google.com with SMTP id c1so827627igq.16
        for <linux-mm@kvack.org>; Tue, 17 Jun 2014 03:01:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <53A01049.6020502@redhat.com>
References: <1402655819-14325-1-git-send-email-dh.herrmann@gmail.com>
	<CALCETrVoE+JO2rLsBUHAOJdvescEEjxikj8iQ339Nxfopfc7pw@mail.gmail.com>
	<CANq1E4SaWLD=hNEc-CDJbNnrGfXE_PkxZFBhpW4tbK7wor7xPA@mail.gmail.com>
	<CALCETrU8N9EbnJ3=oQ1WQCG9Vunn3nR9Ba=J48wJm0SuH0YB4A@mail.gmail.com>
	<CANq1E4QQUKHabheq18AzkVZk3WDtAeC-6W66tVNB+EKgYOx1Vg@mail.gmail.com>
	<53A01049.6020502@redhat.com>
Date: Tue, 17 Jun 2014 12:01:55 +0200
Message-ID: <CANq1E4T3KJZ++=KF2OZ_dd+NvPqg+=4Pw6O7Po3-ZxaaMHPukw@mail.gmail.com>
Subject: Re: [PATCH v3 0/7] File Sealing & memfd_create()
From: David Herrmann <dh.herrmann@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>
Cc: Andy Lutomirski <luto@amacapital.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Michael Kerrisk <mtk.manpages@gmail.com>, Ryan Lortie <desrt@desrt.ca>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Greg Kroah-Hartman <greg@kroah.com>, John Stultz <john.stultz@linaro.org>, Lennart Poettering <lennart@poettering.net>, Daniel Mack <zonque@gmail.com>, Kay Sievers <kay@vrfy.org>, Hugh Dickins <hughd@google.com>, Tony Battersby <tonyb@cybernetics.com>

Hi

On Tue, Jun 17, 2014 at 11:54 AM, Florian Weimer <fweimer@redhat.com> wrote:
> On 06/13/2014 05:33 PM, David Herrmann wrote:
>>
>> On Fri, Jun 13, 2014 at 5:17 PM, Andy Lutomirski <luto@amacapital.net>
>> wrote:
>>>
>>> Isn't the point of SEAL_SHRINK to allow servers to mmap and read
>>> safely without worrying about SIGBUS?
>>
>>
>> No, I don't think so.
>> The point of SEAL_SHRINK is to prevent a file from shrinking. SIGBUS
>> is an effect, not a cause. It's only a coincidence that "OOM during
>> reads" and "reading beyond file-boundaries" has the same effect:
>> SIGBUS.
>> We only protect against reading beyond file-boundaries due to
>> shrinking. Therefore, OOM-SIGBUS is unrelated to SEAL_SHRINK.
>>
>> Anyone dealing with mmap() _has_ to use mlock() to protect against
>> OOM-SIGBUS. Making SEAL_SHRINK protect against OOM-SIGBUS would be
>> redundant, because you can achieve the same with SEAL_SHRINK+mlock().
>
>
> I don't think this is what potential users expect because mlock requires
> capabilities which are not available to them.
>
> A couple of weeks ago, sealing was to be applied to anonymous shared memory.
> Has this changed?  Why should *reading* it trigger OOM?

The file might have holes, therefore, you'd have to allocate backing
pages. This might hit a soft-limit and fail. To avoid this, use
fallocate() to allocate pages prior to mmap() or mlock() to make the
kernel lock them in memory.

Thanks
David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
