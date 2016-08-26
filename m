Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 215336B02A0
	for <linux-mm@kvack.org>; Fri, 26 Aug 2016 17:32:31 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id u81so4445798wmu.3
        for <linux-mm@kvack.org>; Fri, 26 Aug 2016 14:32:31 -0700 (PDT)
Received: from mail-lf0-x241.google.com (mail-lf0-x241.google.com. [2a00:1450:4010:c07::241])
        by mx.google.com with ESMTPS id m18si10137961lfe.130.2016.08.26.14.32.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Aug 2016 14:32:29 -0700 (PDT)
Received: by mail-lf0-x241.google.com with SMTP id f93so4359940lfi.0
        for <linux-mm@kvack.org>; Fri, 26 Aug 2016 14:32:29 -0700 (PDT)
Date: Sat, 27 Aug 2016 00:32:27 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v1] mm, sysctl: Add sysctl for controlling VM_MAYEXEC
 taint
Message-ID: <20160826213227.GA11393@node.shutemov.name>
References: <1472229004-9658-1-git-send-email-robert.foss@collabora.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1472229004-9658-1-git-send-email-robert.foss@collabora.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: robert.foss@collabora.com
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, vbabka@suse.cz, mhocko@suse.com, mingo@kernel.org, dave.hansen@linux.intel.com, hannes@cmpxchg.org, dan.j.williams@intel.com, iamjoonsoo.kim@lge.com, acme@redhat.com, keescook@chromium.org, mgorman@techsingularity.net, atomlin@redhat.com, hughd@google.com, dyoung@redhat.com, viro@zeniv.linux.org.uk, dcashman@google.com, w@1wt.eu, idryomov@gmail.com, yang.shi@linaro.org, wad@chromium.org, vkuznets@redhat.com, vdavydov@virtuozzo.com, vitalywool@gmail.com, oleg@redhat.com, gang.chen.5i5j@gmail.com, koct9i@gmail.com, aarcange@redhat.com, aryabinin@virtuozzo.com, kuleshovmail@gmail.com, minchan@kernel.org, mguzik@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, krasin@google.com, Roland McGrath <mcgrathr@chromium.org>, Mandeep Singh Baines <msb@chromium.org>, Ben Zhang <benzh@chromium.org>, Filipe Brandenburger <filbranden@chromium.org>

On Fri, Aug 26, 2016 at 12:30:04PM -0400, robert.foss@collabora.com wrote:
> From: Will Drewry <wad@chromium.org>
> 
> This patch proposes a sysctl knob that allows a privileged user to
> disable ~VM_MAYEXEC tainting when mapping in a vma from a MNT_NOEXEC
> mountpoint.  It does not alter the normal behavior resulting from
> attempting to directly mmap(PROT_EXEC) a vma (-EPERM) nor the behavior
> of any other subsystems checking MNT_NOEXEC.

Wouldn't it be equal to remounting all filesystems without noexec from
attacker POV? It's hardly a fence to make additional mprotect(PROT_EXEC)
call, before starting executing code from such filesystems.

If administrator of the system wants this, he can just mount filesystem
without noexec, no new kernel code required. And it's more fine-grained
than this.

So, no, I don't think we should add knob like this. Unless I miss
something.

NAK.

> It is motivated by a common /dev/shm, /tmp usecase. There are few
> facilities for creating a shared memory segment that can be remapped in
> the same process address space with different permissions.

What about using memfd_create(2) for such cases? You'll get a file
descriptor from in-kernel tmpfs (shm_mnt) which is not exposed to
userspace for remount as noexec.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
