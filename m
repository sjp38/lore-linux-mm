Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f171.google.com (mail-ve0-f171.google.com [209.85.128.171])
	by kanga.kvack.org (Postfix) with ESMTP id 412AB6B0036
	for <linux-mm@kvack.org>; Thu, 15 May 2014 15:59:25 -0400 (EDT)
Received: by mail-ve0-f171.google.com with SMTP id oz11so1946763veb.16
        for <linux-mm@kvack.org>; Thu, 15 May 2014 12:59:25 -0700 (PDT)
Received: from mail-vc0-f172.google.com (mail-vc0-f172.google.com [209.85.220.172])
        by mx.google.com with ESMTPS id rl1si1117385vcb.74.2014.05.15.12.59.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 15 May 2014 12:59:24 -0700 (PDT)
Received: by mail-vc0-f172.google.com with SMTP id hr9so5109655vcb.3
        for <linux-mm@kvack.org>; Thu, 15 May 2014 12:59:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140515195320.GR28328@moon>
References: <20140514132312.573e5d3cf99276c3f0b82980@linux-foundation.org>
 <5373D509.7090207@oracle.com> <20140514140305.7683c1c2f1e4fb0a63085a2a@linux-foundation.org>
 <5373DBE4.6030907@oracle.com> <20140514143124.52c598a2ba8e2539ee76558c@linux-foundation.org>
 <CALCETrXQOPBOBOgE_snjdmJM7zi34Ei8-MUA-U-YVrwubz4sOQ@mail.gmail.com>
 <20140514221140.GF28328@moon> <CALCETrUc2CpTEeo=NjLGxXQWHn-HG3uYUo-L3aOU-yVjVx3PGg@mail.gmail.com>
 <20140515084558.GI28328@moon> <CALCETrWwWXEoNparvhx4yJB8YmiUBZCuR6yQxJOTjYKuA8AdqQ@mail.gmail.com>
 <20140515195320.GR28328@moon>
From: Andy Lutomirski <luto@amacapital.net>
Date: Thu, 15 May 2014 12:59:04 -0700
Message-ID: <CALCETrWbf8XYvBh=zdyOBqVqRd7s8SVbbDX=O2X+zAZn83r-bw@mail.gmail.com>
Subject: Re: mm: NULL ptr deref handling mmaping of special mappings
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Jones <davej@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Pavel Emelyanov <xemul@parallels.com>

On Thu, May 15, 2014 at 12:53 PM, Cyrill Gorcunov <gorcunov@gmail.com> wrote:
> On Thu, May 15, 2014 at 12:46:34PM -0700, Andy Lutomirski wrote:
>> On Thu, May 15, 2014 at 1:45 AM, Cyrill Gorcunov <gorcunov@gmail.com> wrote:
>> > On Wed, May 14, 2014 at 03:23:27PM -0700, Andy Lutomirski wrote:
>> >> I can summarize:
>> >>
>> >> On 3.14 and before, the vdso is just a bunch of ELF headers and
>> >> executable data.  When executed by 64-bit binaries, it reads from the
>> >> fixmap to do its thing.  That is, it reads from kernel addresses that
>> >> don't have vmas.  When executed by 32-bit binaries, it doesn't read
>> >> anything, since there was no 32-bit timing code.
>> >>
>> >> On 3.15, the x86_64 vdso is unchanged.  The 32-bit vdso is preceded by
>> >> a separate vma containing two pages worth of time-varying read-only
>> >> data.  The vdso reads those pages using PIC references.
>> >
>> > Andy, could you please point me where is the code which creates a second vma?
>> > latest 3.15 master branch
>>
>> Search for _install_special_mapping in arch/x86/vdso.  It's in a
>> different place in 3.15-rc and -next.
>
> As far as I see _install_special_mapping allocates one vma from cache and
>
>         vma->vm_start = addr;
>         vma->vm_end = addr + len;
>
> so where is the second one?

Look at its callers in vdso32-setup.c and/or vma.c, depending on version.

>
>>
>> >
>> > [root@fc ~]# cat /proc/self/maps
>> > ...
>> > 7fff57b6e000-7fff57b8f000 rw-p 00000000 00:00 0                          [stack]
>> > 7fff57bff000-7fff57c00000 r-xp 00000000 00:00 0                          [vdso]
>> > ffffffffff600000-ffffffffff601000 r-xp 00000000 00:00 0                  [vsyscall]
>> > [root@fc ~]#
>> >
>>
>> What version and bitness is this?
>
> x86-64, 3.15-rc5

Aha.  Give tip/x86/vdso or -next a try or boot a 32-bit 3.15-rc kernel
and you'll see it.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
