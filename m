Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8409983102
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 11:31:59 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id e7so100650908lfe.0
        for <linux-mm@kvack.org>; Mon, 29 Aug 2016 08:31:59 -0700 (PDT)
Received: from bhuna.collabora.co.uk (bhuna.collabora.co.uk. [46.235.227.227])
        by mx.google.com with ESMTPS id 16si12305288wmb.72.2016.08.29.08.31.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Aug 2016 08:31:58 -0700 (PDT)
Subject: Re: [PATCH v1] mm, sysctl: Add sysctl for controlling VM_MAYEXEC
 taint
References: <1472229004-9658-1-git-send-email-robert.foss@collabora.com>
 <20160826213227.GA11393@node.shutemov.name>
 <CAAFS_9HiuMt=Xy=YXmvw0+kqcXw=8qXTx2-2bXaqPc_rjtRZgw@mail.gmail.com>
From: Robert Foss <robert.foss@collabora.com>
Message-ID: <160c3fc3-6d75-18d3-8575-98bb41e0543a@collabora.com>
Date: Mon, 29 Aug 2016 11:31:50 -0400
MIME-Version: 1.0
In-Reply-To: <CAAFS_9HiuMt=Xy=YXmvw0+kqcXw=8qXTx2-2bXaqPc_rjtRZgw@mail.gmail.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Drewry <wad@chromium.org>, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, kirill.shutemov@linux.intel.com, vbabka@suse.cz, mhocko@suse.com, mingo@kernel.org, dave.hansen@linux.intel.com, hannes@cmpxchg.org, dan.j.williams@intel.com, iamjoonsoo.kim@lge.com, acme@redhat.com, Kees Cook <keescook@chromium.org>, mgorman@techsingularity.net, atomlin@redhat.com, Hugh Dickins <hughd@google.com>, dyoung@redhat.com, Al Viro <viro@zeniv.linux.org.uk>, Daniel Cashman <dcashman@google.com>, w@1wt.eu, idryomov@gmail.com, yang.shi@linaro.org, vkuznets@redhat.com, vdavydov@virtuozzo.com, vitalywool@gmail.com, oleg@redhat.com, gang.chen.5i5j@gmail.com, koct9i@gmail.com, aarcange@redhat.com, aryabinin@virtuozzo.com, kuleshovmail@gmail.com, minchan@kernel.org, mguzik@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ivan Krasin <krasin@google.com>, Roland McGrath <mcgrathr@chromium.org>, Mandeep Singh Baines <msb@chromium.org>, Ben Zhang <benzh@chromium.org>, Filipe Brandenburger <filbranden@chromium.org>



On 2016-08-29 11:25 AM, Will Drewry wrote:
>
>
> On Fri, Aug 26, 2016 at 4:32 PM, Kirill A. Shutemov
> <kirill@shutemov.name <mailto:kirill@shutemov.name>> wrote:
>
>     On Fri, Aug 26, 2016 at 12:30:04PM -0400, robert.foss@collabora.com
>     <mailto:robert.foss@collabora.com> wrote:
>     > From: Will Drewry <wad@chromium.org <mailto:wad@chromium.org>>
>     >
>     > This patch proposes a sysctl knob that allows a privileged user to
>     > disable ~VM_MAYEXEC tainting when mapping in a vma from a MNT_NOEXEC
>     > mountpoint.  It does not alter the normal behavior resulting from
>     > attempting to directly mmap(PROT_EXEC) a vma (-EPERM) nor the behavior
>     > of any other subsystems checking MNT_NOEXEC.
>
>     Wouldn't it be equal to remounting all filesystems without noexec from
>     attacker POV? It's hardly a fence to make additional mprotect(PROT_EXEC)
>     call, before starting executing code from such filesystems.
>
>     If administrator of the system wants this, he can just mount filesystem
>     without noexec, no new kernel code required. And it's more fine-grained
>     than this.
>
>     So, no, I don't think we should add knob like this. Unless I miss
>     something.
>
>
> I don't believe this patch is necessary anymore (though, thank you
> Robert for testing and re-sending!).
>
> The primary offenders wrt to needing to mmap/mprotect a file in /dev/shm
> was the older nvidia
> driver (binary only iirc) and the Chrome Native Client code.
>
> The reason why half-exec is an "ok" (half) mitigation is because it
> blocks simple gadgets and other paths for using loadable libraries or
> binaries (via glibc) as it disallows mmap(PROT_EXEC) even though it
> allows mprotect(PROT_EXEC).  This stops ld in its tracks since it does
> the obvious thing and uses mmap(PROT_EXEC).
>
> I think time has marched on and this patch is now something I can toss
> in the dustbin of history. Both Chrome's Native Client and an older
> nvidia driver relied on creating-then-unlinking a file in tmpfs, but
> there is now a better facility!
>
>
>     NAK.
>
>
> Agreed - this is old and software that predicated it should be gone.. I
> hope. :)

Splendid, patch dropped!
Thanks Will and Kirill!


Rob.

>
>
>
>     > It is motivated by a common /dev/shm, /tmp usecase. There are few
>     > facilities for creating a shared memory segment that can be remapped in
>     > the same process address space with different permissions.
>
>     What about using memfd_create(2) for such cases? You'll get a file
>     descriptor from in-kernel tmpfs (shm_mnt) which is not exposed to
>     userspace for remount as noexec.
>
>
> This is a relatively old patch ( https://lwn.net/Articles/455256/
> <https://lwn.net/Articles/455256/> ) which predated memfd_create().
>  memfd_create() is the right solution to this problem!
>
>
> Thanks again!
> will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
