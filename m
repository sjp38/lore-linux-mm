Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id D471F6B0005
	for <linux-mm@kvack.org>; Wed,  2 May 2018 17:06:24 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id l9-v6so11724334qtp.23
        for <linux-mm@kvack.org>; Wed, 02 May 2018 14:06:24 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id g8-v6si6336552qvd.37.2018.05.02.14.06.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 May 2018 14:06:23 -0700 (PDT)
Subject: Re: [PATCH] pkeys: Introduce PKEY_ALLOC_SIGNALINHERIT and change
 signal semantics
References: <20180502132751.05B9F401F3041@oldenburg.str.redhat.com>
 <248faadb-e484-806f-1485-c34a72a9ca0b@intel.com>
 <822a28c9-5405-68c2-11bf-0c282887466d@redhat.com>
 <57459C6F-C8BA-4E2D-99BA-64F35C11FC05@amacapital.net>
 <6286ba0a-7e09-b4ec-e31f-bd091f5940ff@redhat.com>
 <CALCETrVrm6yGiv6_z7RqdeB-324RoeMmjpf1EHsrGOh+iKb7+A@mail.gmail.com>
From: Florian Weimer <fweimer@redhat.com>
Message-ID: <b2df1386-9df9-2db8-0a25-51bf5ff63592@redhat.com>
Date: Wed, 2 May 2018 23:06:20 +0200
MIME-Version: 1.0
In-Reply-To: <CALCETrVrm6yGiv6_z7RqdeB-324RoeMmjpf1EHsrGOh+iKb7+A@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Linux-MM <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, linux-x86_64@vger.kernel.org, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, linuxram@us.ibm.com

On 05/02/2018 10:41 PM, Andy Lutomirski wrote:

>> See above.  The signal handler will crash if it calls any non-local
>> function through the GOT because with the default access rights, it's
>> not readable in the signal handler.
> 
>> Any use of memory protection keys for basic infrastructure will run into
>> this problem, so I think the current kernel behavior is not very useful.
>>     It's also x86-specific.
> 
>>    From a security perspective, the atomic behavior is not very useful
>> because you generally want to modify PKRU *before* computing the details
>> of the memory access, so that you don't have a general a??poke anywhere
>> with this access righta?? primitive in the text segment.  (I called this
>> the a??suffix problema?? in another context.)
> 
> 
> Ugh, right.  It's been long enough that I forgot about the underlying
> issue.  A big part of the problem here is that pkey_alloc() should set the
> initial value of the key across all threads, but it *can't*.  There is
> literally no way to do it in a multithreaded program that uses RDPKRU and
> WRPKRU.

The kernel could do *something*, probably along the membarrier system 
call.  I mean, I could implement a reasonable close approximation in 
userspace, via the setxid mechanism in glibc (but I really don't want to).

> But I think the right fix, at least for your use case, is to have a per-mm
> init_pkru variable that starts as "deny all".  We'd add a new pkey_alloc()
> flag like PKEY_ALLOC_UPDATE_INITIAL_STATE that causes the specified mode to
> update init_pkru.  New threads and delivered signals would get the
> init_pkru state instead of the hardcoded default.

I implemented this for signal handlers:

   https://marc.info/?l=linux-api&m=151285420302698&w=2

This does not alter the thread inheritance behavior yet.  I would have 
to investigate how to implement that.

Feedback led to the current patch, though.  I'm not sure what has 
changed since then.

If I recall correctly, the POWER maintainer did express a strong desire 
back then for (what is, I believe) their current semantics, which my 
PKEY_ALLOC_SIGNALINHERIT patch implements for x86, too.

Thanks,
Florian
