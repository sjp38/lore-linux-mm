Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f50.google.com (mail-yh0-f50.google.com [209.85.213.50])
	by kanga.kvack.org (Postfix) with ESMTP id 07CBE6B0038
	for <linux-mm@kvack.org>; Fri, 20 Mar 2015 12:53:23 -0400 (EDT)
Received: by yhch68 with SMTP id h68so42417305yhc.1
        for <linux-mm@kvack.org>; Fri, 20 Mar 2015 09:53:22 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id 195si2402409ykf.4.2015.03.20.09.53.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 20 Mar 2015 09:53:22 -0700 (PDT)
Message-ID: <550C5078.8040402@oracle.com>
Date: Fri, 20 Mar 2015 10:53:12 -0600
From: David Ahern <david.ahern@oracle.com>
MIME-Version: 1.0
Subject: Re: 4.0.0-rc4: panic in free_block
References: <550C37C9.2060200@oracle.com> <CA+55aFxhNphSMrNvwqj0AQRzuqRdPG11J6DaazKWMb2U+H7wKg@mail.gmail.com>
In-Reply-To: <CA+55aFxhNphSMrNvwqj0AQRzuqRdPG11J6DaazKWMb2U+H7wKg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, sparclinux@vger.kernel.org

On 3/20/15 10:48 AM, Linus Torvalds wrote:
> [ Added Davem and the sparc mailing list, since it happens on sparc
> and that just makes me suspicious ]
>
> On Fri, Mar 20, 2015 at 8:07 AM, David Ahern <david.ahern@oracle.com> wrote:
>> I can easily reproduce the panic below doing a kernel build with make -j N,
>> N=128, 256, etc. This is a 1024 cpu system running 4.0.0-rc4.
>
> 3.19 is fine? Because I dont' think I've seen any reports like this
> for others, and what stands out is sparc (and to a lesser degree "1024
> cpus", which obviously gets a lot less testing)

I haven't tried 3.19 yet. Just backed up to 3.18 and it shows the same 
problem. And I can reproduce the 4.0 crash in a 128 cpu ldom (VM).

>
>> The top 3 frames are consistently:
>>      free_block+0x60
>>      cache_flusharray+0xac
>>      kmem_cache_free+0xfc
>>
>> After that one path has been from __mmdrop and the others are like below,
>> from remove_vma.
>>
>> Unable to handle kernel paging request at virtual address 0006100000000000
>
> One thing you *might* check is if the problem goes away if you select
> CONFIG_SLUB instead of CONFIG_SLAB. I'd really like to just get rid of
> SLAB. The whole "we have multiple different allocators" is a mess and
> causes test coverage issues.
>
> Apart from testing with CONFIG_SLUB, if 3.19 is ok and you seem to be
> able to "easily reproduce" this, the obvious thing to do is to try to
> bisect it.

I'll try SLUB. The ldom reboots 1000 times faster then resetting the h/w 
so a better chance of bisecting - if I can find a known good release.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
