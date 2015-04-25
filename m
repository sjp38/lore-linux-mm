Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id E80CF6B0032
	for <linux-mm@kvack.org>; Sat, 25 Apr 2015 09:53:21 -0400 (EDT)
Received: by wiax7 with SMTP id x7so53102252wia.0
        for <linux-mm@kvack.org>; Sat, 25 Apr 2015 06:53:21 -0700 (PDT)
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com. [209.85.212.179])
        by mx.google.com with ESMTPS id d1si24558025wjy.134.2015.04.25.06.53.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 25 Apr 2015 06:53:20 -0700 (PDT)
Received: by widdi4 with SMTP id di4so51934668wid.0
        for <linux-mm@kvack.org>; Sat, 25 Apr 2015 06:53:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1504241437070.2456@chino.kir.corp.google.com>
References: <1429909549-11726-1-git-send-email-anisse@astier.eu>
 <1429909549-11726-3-git-send-email-anisse@astier.eu> <alpine.DEB.2.10.1504241437070.2456@chino.kir.corp.google.com>
From: Anisse Astier <anisse@astier.eu>
Date: Sat, 25 Apr 2015 15:52:59 +0200
Message-ID: <CALUN=q+-yUtZCyVbxcSLq2J_RyR4bOYrVbm2NfTX4FdVkEXtCg@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm/page_alloc.c: add config option to sanitize freed pages
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Alan Cox <gnomes@lxorguk.ukuu.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Kees Cook <keescook@chromium.org>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Fri, Apr 24, 2015 at 11:38 PM, David Rientjes <rientjes@google.com> wrote:
> On Fri, 24 Apr 2015, Anisse Astier wrote:
>
>> diff --git a/mm/Kconfig b/mm/Kconfig
>> index 390214d..cb2df5f 100644
>> --- a/mm/Kconfig
>> +++ b/mm/Kconfig
>> @@ -635,3 +635,15 @@ config MAX_STACK_SIZE_MB
>>         changed to a smaller value in which case that is used.
>>
>>         A sane initial value is 80 MB.
>> +
>> +config SANITIZE_FREED_PAGES
>> +     bool "Sanitize memory pages after free"
>> +     default n
>> +     help
>> +       This option is used to make sure all pages freed are zeroed. This is
>> +       quite low-level and doesn't handle your slab buffers.
>> +       It has various applications, from preventing some info leaks to
>> +       helping kernel same-page merging in virtualised environments.
>> +       Depending on your workload, it will reduce performance of about 3%.
>> +
>> +       If unsure, say N.
>
> Objection to allowing this without first enabling some other DEBUG config
> option, it should never be a standalone option, but also to pretending to

I'm not sure I understand the rationale here. Is it to protect the
innocent ? The performance warning and "N" recommendation ought to be
enough.
I'm not sure depending on DEBUG will help anyone; it will just hinder
those who want to use this on a hardened system (where you might not
want to have DEBUG enabled).

> have any insight into what the performance degredation of it will be.  On

I fully agree I shouldn't have let the 3% ballpark estimate slip, I'll
remove it.

> my systems, this would be _massive_.

I'm interested in what you mean by "massive". Have you conducted
experiments on the impact or is just your gut feeling ? Anyway, I'd be
curious to see numbers showing what it looks like on big hardware.

Anisse

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
