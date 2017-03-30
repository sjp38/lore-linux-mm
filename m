Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id C54786B03C0
	for <linux-mm@kvack.org>; Thu, 30 Mar 2017 13:27:52 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id n37so18478720qtb.7
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 10:27:52 -0700 (PDT)
Received: from mail-qk0-f174.google.com (mail-qk0-f174.google.com. [209.85.220.174])
        by mx.google.com with ESMTPS id x33si2347453qta.126.2017.03.30.10.27.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Mar 2017 10:27:51 -0700 (PDT)
Received: by mail-qk0-f174.google.com with SMTP id d10so46401474qke.1
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 10:27:51 -0700 (PDT)
Subject: Re: sudo x86info -a => kernel BUG at mm/usercopy.c:78!
References: <d928849c-e7c3-6b81-e551-a39fa976f341@nokia.com>
 <CAGXu5jKo4gw=RHCmcY3v+GTiUUgteLbmvHDghd-Lrm7RprL8=Q@mail.gmail.com>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <3890813c-c891-89a5-c16f-66240a794319@redhat.com>
Date: Thu, 30 Mar 2017 10:27:47 -0700
MIME-Version: 1.0
In-Reply-To: <CAGXu5jKo4gw=RHCmcY3v+GTiUUgteLbmvHDghd-Lrm7RprL8=Q@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>, Tommi Rantala <tommi.t.rantala@nokia.com>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Mark Rutland <mark.rutland@arm.com>, Eric Biggers <ebiggers@google.com>, Dave Jones <davej@codemonkey.org.uk>

On 03/30/2017 09:45 AM, Kees Cook wrote:
> On Wed, Mar 29, 2017 at 11:44 PM, Tommi Rantala
> <tommi.t.rantala@nokia.com> wrote:
>> Hi,
>>
>> Running:
>>
>>   $ sudo x86info -a
>>
>> On this HP ZBook 15 G3 laptop kills the x86info process with segfault and
>> produces the following kernel BUG.
>>
>>   $ git describe
>>   v4.11-rc4-40-gfe82203
>>
>> It is also reproducible with the fedora kernel: 4.9.14-200.fc25.x86_64
>>
>> Full dmesg output here: https://pastebin.com/raw/Kur2mpZq
>>
>> [   51.418954] usercopy: kernel memory exposure attempt detected from
>> ffff880000090000 (dma-kmalloc-256) (4096 bytes)
> 
> This seems like a real exposure: the copy is attempting to read 4096
> bytes from a 256 byte object.
> 
>> [...]
>> [   51.419063] Call Trace:
>> [   51.419066]  read_mem+0x70/0x120
>> [   51.419069]  __vfs_read+0x28/0x130
>> [   51.419072]  ? security_file_permission+0x9b/0xb0
>> [   51.419075]  ? rw_verify_area+0x4e/0xb0
>> [   51.419077]  vfs_read+0x96/0x130
>> [   51.419079]  SyS_read+0x46/0xb0
>> [   51.419082]  ? SyS_lseek+0x87/0xb0
>> [   51.419085]  entry_SYSCALL_64_fastpath+0x1a/0xa9
> 
> I can't reproduce this myself, so I assume it's some specific /proc or
> /sys file that I don't have. Are you able to get a strace of x86info
> as it runs to see which file it is attempting to read here?
> 
> Thanks!
> 
> -Kees
> 

I can't see this on any of my Fedora systems. It looks like this
is trying to read /dev/mem so I suspect your BIOS is putting out
unexpected values. If you turn off hardened usercopy does x86info
give you reasonable values? I'd also echo getting an strace.

Thanks,
Laura

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
