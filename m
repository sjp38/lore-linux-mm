Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f53.google.com (mail-yh0-f53.google.com [209.85.213.53])
	by kanga.kvack.org (Postfix) with ESMTP id 1D4846B0035
	for <linux-mm@kvack.org>; Sat, 23 Nov 2013 15:49:30 -0500 (EST)
Received: by mail-yh0-f53.google.com with SMTP id b20so1774546yha.26
        for <linux-mm@kvack.org>; Sat, 23 Nov 2013 12:49:29 -0800 (PST)
Received: from mail-ob0-x235.google.com (mail-ob0-x235.google.com [2607:f8b0:4003:c01::235])
        by mx.google.com with ESMTPS id b7si15065858yhm.135.2013.11.23.12.49.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 23 Nov 2013 12:49:29 -0800 (PST)
Received: by mail-ob0-f181.google.com with SMTP id uy5so2679793obc.26
        for <linux-mm@kvack.org>; Sat, 23 Nov 2013 12:49:28 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20131120141534.06ea091ca53b1dec60ace63d@linux-foundation.org>
References: <alpine.DEB.2.02.1311121811310.29891@chino.kir.corp.google.com> <20131120141534.06ea091ca53b1dec60ace63d@linux-foundation.org>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Sat, 23 Nov 2013 15:49:08 -0500
Message-ID: <CAHGf_=ooNHx=2HeUDGxrZFma-6YRvL42ViDMkSOqLOffk8MVsw@mail.gmail.com>
Subject: Re: [patch -mm] mm, mempolicy: silence gcc warning
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Kees Cook <keescook@chromium.org>, Rik van Riel <riel@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

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
>
> mpol_to_str() would be simpler (and slower) if it was switched to use
> strncat().

IMHO, you should queue this patch. mpol_to_str() is not fast path at all and
I don't want worry about false positive warning.

> It worries me that the CONFIG_NUMA=n version of mpol_to_str() doesn't
> stick a '\0' into *buffer.  Hopefully it never gets called...

Don't worry. It never happens. Currently, all of caller depend on CONFIG_NUMA.
However it would be nice if CONFIG_NUMA=n version of mpol_to_str() is
implemented
more carefully. I don't know who's mistake.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
