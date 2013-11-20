Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f47.google.com (mail-yh0-f47.google.com [209.85.213.47])
	by kanga.kvack.org (Postfix) with ESMTP id 2E0E36B0031
	for <linux-mm@kvack.org>; Wed, 20 Nov 2013 17:19:19 -0500 (EST)
Received: by mail-yh0-f47.google.com with SMTP id 29so2706146yhl.20
        for <linux-mm@kvack.org>; Wed, 20 Nov 2013 14:19:18 -0800 (PST)
Received: from mail-oa0-x236.google.com (mail-oa0-x236.google.com [2607:f8b0:4003:c02::236])
        by mx.google.com with ESMTPS id u24si5674068yhg.256.2013.11.20.14.19.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 20 Nov 2013 14:19:18 -0800 (PST)
Received: by mail-oa0-f54.google.com with SMTP id h16so5350443oag.13
        for <linux-mm@kvack.org>; Wed, 20 Nov 2013 14:19:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20131120141534.06ea091ca53b1dec60ace63d@linux-foundation.org>
References: <alpine.DEB.2.02.1311121811310.29891@chino.kir.corp.google.com>
	<20131120141534.06ea091ca53b1dec60ace63d@linux-foundation.org>
Date: Wed, 20 Nov 2013 14:19:17 -0800
Message-ID: <CAGXu5jLeRL7wgi+_TvCDQAOmKDBczpN=dZ=Mby-O46iRU9jCWA@mail.gmail.com>
Subject: Re: [patch -mm] mm, mempolicy: silence gcc warning
From: Kees Cook <keescook@chromium.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Fengguang Wu <fengguang.wu@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org

On Wed, Nov 20, 2013 at 2:15 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Tue, 12 Nov 2013 18:12:32 -0800 (PST) David Rientjes <rientjes@google.com> wrote:
>
>> Fengguang Wu reports that compiling mm/mempolicy.c results in a warning:
>>
>>       mm/mempolicy.c: In function 'mpol_to_str':
>>       mm/mempolicy.c:2878:2: error: format not a string literal and no format arguments
>>
>> Kees says this is because he is using -Wformat-security.
>>
>> Silence the warning.
>>
>> ...
>>
>> --- a/mm/mempolicy.c
>> +++ b/mm/mempolicy.c
>> @@ -2950,7 +2950,7 @@ void mpol_to_str(char *buffer, int maxlen, struct mempolicy *pol)
>>               return;
>>       }
>>
>> -     p += snprintf(p, maxlen, policy_modes[mode]);
>> +     p += snprintf(p, maxlen, "%s", policy_modes[mode]);
>>
>>       if (flags & MPOL_MODE_FLAGS) {
>>               p += snprintf(p, buffer + maxlen - p, "=");
>
> mutter.  There are no '%'s in policy_modes[].  Maybe we should only do
> this #ifdef CONFIG_KEES.

Yeah, I had offered to just whitelist this in my checker, since it's
the type of const char array that gcc doesn't realize is harmless as
an arg-less format string. Fengguang's reports are way faster than me,
though. :)

> mpol_to_str() would be simpler (and slower) if it was switched to use
> strncat().
>
> It worries me that the CONFIG_NUMA=n version of mpol_to_str() doesn't
> stick a '\0' into *buffer.  Hopefully it never gets called...

-Kees

-- 
Kees Cook
Chrome OS Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
