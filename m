Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 3785E6B0031
	for <linux-mm@kvack.org>; Tue, 17 Jun 2014 08:13:55 -0400 (EDT)
Received: by mail-wg0-f48.google.com with SMTP id n12so6833527wgh.31
        for <linux-mm@kvack.org>; Tue, 17 Jun 2014 05:13:54 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id em6si12349475wib.48.2014.06.17.05.13.52
        for <linux-mm@kvack.org>;
        Tue, 17 Jun 2014 05:13:53 -0700 (PDT)
Message-ID: <53A030E9.7010701@redhat.com>
Date: Tue, 17 Jun 2014 14:13:29 +0200
From: Florian Weimer <fweimer@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 0/7] File Sealing & memfd_create()
References: <1402655819-14325-1-git-send-email-dh.herrmann@gmail.com>	<CALCETrVoE+JO2rLsBUHAOJdvescEEjxikj8iQ339Nxfopfc7pw@mail.gmail.com>	<CANq1E4SaWLD=hNEc-CDJbNnrGfXE_PkxZFBhpW4tbK7wor7xPA@mail.gmail.com>	<CALCETrU8N9EbnJ3=oQ1WQCG9Vunn3nR9Ba=J48wJm0SuH0YB4A@mail.gmail.com>	<CANq1E4QQUKHabheq18AzkVZk3WDtAeC-6W66tVNB+EKgYOx1Vg@mail.gmail.com>	<53A01049.6020502@redhat.com>	<CANq1E4T3KJZ++=KF2OZ_dd+NvPqg+=4Pw6O7Po3-ZxaaMHPukw@mail.gmail.com>	<53A012C8.7060109@redhat.com> <CANq1E4QinvVA-O=dX4N819jVK3xSihJcpz9juFj+A3qv0MXODg@mail.gmail.com>
In-Reply-To: <CANq1E4QinvVA-O=dX4N819jVK3xSihJcpz9juFj+A3qv0MXODg@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Herrmann <dh.herrmann@gmail.com>
Cc: Andy Lutomirski <luto@amacapital.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Michael Kerrisk <mtk.manpages@gmail.com>, Ryan Lortie <desrt@desrt.ca>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Greg Kroah-Hartman <greg@kroah.com>, John Stultz <john.stultz@linaro.org>, Lennart Poettering <lennart@poettering.net>, Daniel Mack <zonque@gmail.com>, Kay Sievers <kay@vrfy.org>, Hugh Dickins <hughd@google.com>, Tony Battersby <tonyb@cybernetics.com>

On 06/17/2014 12:10 PM, David Herrmann wrote:

>>> The file might have holes, therefore, you'd have to allocate backing
>>> pages. This might hit a soft-limit and fail. To avoid this, use
>>> fallocate() to allocate pages prior to mmap()
>>
>> This does not work because the consuming side does not know how the
>> descriptor was set up if sealing does not imply that.
>
> The consuming side has to very seals via F_GET_SEALS. After that, it
> shall do a simple fallocate() on the whole file if it wants to go sure
> that all pages are allocated. Why shouldn't that be possible? Please
> elaborate.

Hmm.  You permit general fallocate even for WRITE seals.  That's really 
unexpected.

The inode_newsize_ok check in shmem_fallocate can result in SIGXFSZ, 
which doesn't seem to be what's intended here.

Will the new pages attributed to the process calling fallocate, or to 
the process calling memfd_create?

-- 
Florian Weimer / Red Hat Product Security Team

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
