Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id D27F16B0006
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 18:27:21 -0500 (EST)
Received: by mail-yb1-f200.google.com with SMTP id i13-v6so13950909ybe.14
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 15:27:21 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z5-v6sor2120571ywf.12.2018.11.14.15.27.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 14 Nov 2018 15:27:20 -0800 (PST)
Received: from mail-yw1-f42.google.com (mail-yw1-f42.google.com. [209.85.161.42])
        by smtp.gmail.com with ESMTPSA id 207-v6sm7102412ywo.87.2018.11.14.15.27.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Nov 2018 15:27:19 -0800 (PST)
Received: by mail-yw1-f42.google.com with SMTP id h21-v6so8020703ywa.3
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 15:27:18 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <FFE931C2-DE41-4AD8-866B-FD37C1493590@oracle.com>
References: <1542156686-12253-1-git-send-email-isaacm@codeaurora.org> <FFE931C2-DE41-4AD8-866B-FD37C1493590@oracle.com>
From: Kees Cook <keescook@chromium.org>
Date: Wed, 14 Nov 2018 17:27:17 -0600
Message-ID: <CAGXu5j+pSP7+ScCc4PrM+PCRSO=3-1=OLdo8WBcgJpk7vjM1vw@mail.gmail.com>
Subject: Re: [PATCH] mm/usercopy: Use memory range to be accessed for
 wraparound check
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: William Kucharski <william.kucharski@oracle.com>
Cc: "Isaac J. Manjarres" <isaacm@codeaurora.org>, Chris von Recklinghausen <crecklin@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Sodagudi Prasad <psodagud@codeaurora.org>, tsoni@codeaurora.org, "# 3.4.x" <stable@vger.kernel.org>

On Wed, Nov 14, 2018 at 4:35 AM, William Kucharski
<william.kucharski@oracle.com> wrote:
>
>
>> On Nov 13, 2018, at 5:51 PM, Isaac J. Manjarres <isaacm@codeaurora.org> wrote:
>>
>> diff --git a/mm/usercopy.c b/mm/usercopy.c
>> index 852eb4e..0293645 100644
>> --- a/mm/usercopy.c
>> +++ b/mm/usercopy.c
>> @@ -151,7 +151,7 @@ static inline void check_bogus_address(const unsigned long ptr, unsigned long n,
>>                                      bool to_user)
>> {
>>       /* Reject if object wraps past end of memory. */
>> -     if (ptr + n < ptr)
>> +     if (ptr + (n - 1) < ptr)
>>               usercopy_abort("wrapped address", NULL, to_user, 0, ptr + n);
>
> I'm being paranoid, but is it possible this routine could ever be passed "n" set to zero?

It's a single-use inline, and zero is tested just before getting called:

        /* Skip all tests if size is zero. */
        if (!n)
                return;

        /* Check for invalid addresses. */
        check_bogus_address((const unsigned long)ptr, n, to_user);


>
> If so, it will erroneously abort indicating a wrapped address as (n - 1) wraps to ULONG_MAX.
>
> Easily fixed via:
>
>         if ((n != 0) && (ptr + (n - 1) < ptr))

Agreed. Thanks for noticing this!

-Kees

-- 
Kees Cook
