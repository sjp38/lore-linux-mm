Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f169.google.com (mail-qc0-f169.google.com [209.85.216.169])
	by kanga.kvack.org (Postfix) with ESMTP id C44E96B0037
	for <linux-mm@kvack.org>; Tue, 28 Jan 2014 19:49:42 -0500 (EST)
Received: by mail-qc0-f169.google.com with SMTP id w7so1786722qcr.14
        for <linux-mm@kvack.org>; Tue, 28 Jan 2014 16:49:42 -0800 (PST)
Received: from mail-qa0-x234.google.com (mail-qa0-x234.google.com [2607:f8b0:400d:c00::234])
        by mx.google.com with ESMTPS id ew5si312493qab.103.2014.01.28.16.49.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Jan 2014 16:49:41 -0800 (PST)
Received: by mail-qa0-f52.google.com with SMTP id j15so1556581qaq.39
        for <linux-mm@kvack.org>; Tue, 28 Jan 2014 16:49:41 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <52E84941.4080704@zytor.com>
References: <52E709C0.1050006@linaro.org> <52E7298D.5020001@zytor.com>
 <52E80B85.8020302@linaro.org> <52E814FF.6060403@zytor.com>
 <52E819F0.6040806@linaro.org> <CAPXgP11Fv6TU+o2Eui5rVW0A37U7KjwC0DZYbQOJJ8rEAYOiJg@mail.gmail.com>
 <52E81BB3.6060306@linaro.org> <52E81CE2.3030304@zytor.com>
 <52E8271B.4030201@linaro.org> <CAPXgP13G14B3YFpaE+m_AtFfFR6NRVSi1JYAvLZSsfftSkgwBQ@mail.gmail.com>
 <52E83719.9060709@zytor.com> <CAPXgP116TBZx82=J_pKxgSqJsy4HY1nofMOkUtZELBYvcFhDcw@mail.gmail.com>
 <52E83AEB.4020809@zytor.com> <CAPXgP13u+0PCFsRDRFqSdopDuXyAvZCS2crOCDrPoT6m8Nq2Og@mail.gmail.com>
 <52E84941.4080704@zytor.com>
From: Kay Sievers <kay@vrfy.org>
Date: Wed, 29 Jan 2014 01:49:21 +0100
Message-ID: <CAPXgP12v3PPDJDJX1ZLNWAxiOUVbsexaBfnR9JOs01O2r+qfRg@mail.gmail.com>
Subject: Re: [RFC] shmgetfd idea
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: John Stultz <john.stultz@linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Greg KH <gregkh@linuxfoundation.org>, Android Kernel Team <kernel-team@android.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Takahiro Akashi <takahiro.akashi@linaro.org>, Minchan Kim <minchan@kernel.org>, Lennart Poettering <mzxreary@0pointer.de>

On Wed, Jan 29, 2014 at 1:20 AM, H. Peter Anvin <hpa@zytor.com> wrote:
> On 01/28/2014 04:14 PM, Kay Sievers wrote:
>>>
>>> If the "single owner" is determined by the file structure (e.g. via a
>>> fcntl as opposed to a ioctl), then presumably we would simply deny an
>>> attempt to open the inode and create a new file structure for it.
>>>
>>> On Linux, /proc/$PID/fd is an open as opposed to a dup (as much as I
>>> personally don't like those semantics, they are well set in stone at
>>> this point) so it satisfies your requirements.
>>
>> If that all could be made working, for the kdbus case we would be fine
>> with requiring *any* tmpfs mount, create a new memfd from there with
>> O_TMPFILE, and use new fcntl() definitios to protect/seal/unseal and
>> identify that fd.
>>
>> For the more restricted cases like Android that tmpfs mount could get
>> a mount option to not allow the creation of any non-unlinked file, I
>> guess.
>>
>
> Right, that would be the idea.

I like your idea. Sounds worth trying, if you think we can make the
protection/sealing work without too much ugly workarounds.

With the filesystem as a "domain" / the root for all the unlinked
shmem files, we could even mount a separate tmpfs for every logged-in
user, and put the quota on the user that way.

It will still not solve the /dev/shm/ or /tmp quota problem, but it
would at least not get bigger with every new shmem user we invent. :)

Kay

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
