From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [RFC PATCH 00/13] Introduce first class virtual address spaces
Date: Wed, 15 Mar 2017 13:06:50 -0700
Message-ID: <CALCETrXfGgxaLivhci0VL=wUaWAnBiUXC47P7TUaEuOYV_-X_g__29923.052507411$1489608441$gmane$org@mail.gmail.com>
References: <CALCETrX5gv+zdhOYro4-u3wGWjVCab28DFHPSm5=BVG_hKxy3A@mail.gmail.com>
 <20170315194447.scsf3fiwvf7z5gzc@arch-dev>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by blaine.gmane.org with esmtp (Exim 4.84_2)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1coFCN-0006kA-T2
	for glkm-linux-mm-2@m.gmane.org; Wed, 15 Mar 2017 21:07:08 +0100
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 371996B038A
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 16:07:13 -0400 (EDT)
Received: by mail-ua0-f197.google.com with SMTP id 62so7028894uas.1
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 13:07:13 -0700 (PDT)
Received: from mail-vk0-x22c.google.com (mail-vk0-x22c.google.com. [2607:f8b0:400c:c05::22c])
        by mx.google.com with ESMTPS id k23si931722uaa.75.2017.03.15.13.07.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Mar 2017 13:07:12 -0700 (PDT)
Received: by mail-vk0-x22c.google.com with SMTP id d188so13785668vka.0
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 13:07:11 -0700 (PDT)
In-Reply-To: <20170315194447.scsf3fiwvf7z5gzc@arch-dev>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, Andy Lutomirski <luto@kernel.org>, Till Smejkal <till.smejkal@googlemail.com>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Steven Miao <realmz6@gmail.com>, Richard Kuo <rkuo@codeaurora.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, James Hogan <james.hogan@imgtec.com>, Ralf Baechle <ralf@linux-mips.org>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de>

On Wed, Mar 15, 2017 at 12:44 PM, Till Smejkal
<till.smejkal@googlemail.com> wrote:
> On Wed, 15 Mar 2017, Andy Lutomirski wrote:
>> > One advantage of VAS segments is that they can be globally queried by user programs
>> > which means that VAS segments can be shared by applications that not necessarily have
>> > to be related. If I am not mistaken, MAP_SHARED of pure in memory data will only work
>> > if the tasks that share the memory region are related (aka. have a common parent that
>> > initialized the shared mapping). Otherwise, the shared mapping have to be backed by a
>> > file.
>>
>> What's wrong with memfd_create()?
>>
>> > VAS segments on the other side allow sharing of pure in memory data by
>> > arbitrary related tasks without the need of a file. This becomes especially
>> > interesting if one combines VAS segments with non-volatile memory since one can keep
>> > data structures in the NVM and still be able to share them between multiple tasks.
>>
>> What's wrong with regular mmap?
>
> I never wanted to say that there is something wrong with regular mmap. We just
> figured that with VAS segments you could remove the need to mmap your shared data but
> instead can keep everything purely in memory.

memfd does that.

>
> Unfortunately, I am not at full speed with memfds. Is my understanding correct that
> if the last user of such a file descriptor closes it, the corresponding memory is
> freed? Accordingly, memfd cannot be used to keep data in memory while no program is
> currently using it, can it?

No, stop right here.  If you want to have a bunch of memory that
outlives the program that allocates it, use a filesystem (tmpfs,
hugetlbfs, ext4, whatever).  Don't create new persistent kernel
things.

> VAS segments on the other side would provide a functionality to
> achieve the same without the need of any mounted filesystem. However, I agree, that
> this is just a small advantage compared to what can already be achieved with the
> existing functionality provided by the Linux kernel.

I see this "small advantage" as "resource leak and security problem".

>> This sounds complicated and fragile.  What happens if a heuristically
>> shared region coincides with a region in the "first class address
>> space" being selected?
>
> If such a conflict happens, the task cannot use the first class address space and the
> corresponding system call will return an error. However, with the current available
> virtual address space size that programs can use, such conflicts are probably rare.

A bug that hits 1% of the time is often worse than one that hits 100%
of the time because debugging it is miserable.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
