Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 2F15E6B0031
	for <linux-mm@kvack.org>; Sat, 13 Jul 2013 20:27:10 -0400 (EDT)
Received: by mail-ie0-f172.google.com with SMTP id 16so23943371iea.3
        for <linux-mm@kvack.org>; Sat, 13 Jul 2013 17:27:09 -0700 (PDT)
Message-ID: <51E1F056.3000108@gmail.com>
Date: Sun, 14 Jul 2013 08:27:02 +0800
From: Sam Ben <sam.bennn@gmail.com>
MIME-Version: 1.0
Subject: Re: RFC: named anonymous vmas
References: <CAMbhsRQU=xrcum+ZUbG3S+JfFUJK_qm_VB96Vz=PpL=vQYhUvg@mail.gmail.com>
In-Reply-To: <CAMbhsRQU=xrcum+ZUbG3S+JfFUJK_qm_VB96Vz=PpL=vQYhUvg@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Colin Cross <ccross@google.com>
Cc: lkml <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Android Kernel Team <kernel-team@android.com>, John Stultz <john.stultz@linaro.org>

Hi Colin,
On 06/22/2013 07:42 AM, Colin Cross wrote:
> One of the features of ashmem (drivers/staging/android/ashmem.c) that
> hasn't gotten much discussion about moving out of staging is named
> anonymous memory.
>
> In Android, ashmem is used for three different features, and most
> users of it only care about one feature at a time.  One is volatile
> ranges, which John Stultz has been implementing.  The second is
> anonymous shareable memory without having a world-writable tmpfs that
> untrusted apps could fill with files.  The third and most heavily used

How to understand "anonymous shareable memory without having a 
world-writable tmpfs that untrusted apps could fill with files"?

> feature within the Android codebase is named anonymous memory, where a
> region of anonymous memory can have a name associated with it that
> will show up in /proc/pid/maps.  The Dalvik VM likes to use this
> feature extensively, even for memory that will never be shared and
> could easily be allocated using an anonymous mmap, and even malloc has
> used it in the past.  It provides an easy way to collate memory used
> for different purposes across multiple processes, which Android uses
> for its "dumpsys meminfo" and "librank" tools to determine how much
> memory is used for java heaps, JIT caches, native mallocs, etc.
>
> I'd like to add this feature for anonymous mmap memory.  I propose
> adding an madvise2(unsigned long start, size_t len_in, int behavior,
> void *ptr, size_t size) syscall and a new MADV_NAME behavior, which
> treats ptr as a string of length size.  The string would be copied
> somewhere reusable in the kernel, or reused if it already exists, and
> the kernel address of the string would get stashed in a new field in
> struct vm_area_struct.  Adjacent vmas would only get merged if the
> name pointer matched, and naming part of a mapping would split the
> mapping.  show_map_vma would print the name only if none of the other
> existing names rules match.
>
> Any comments as I start implementing it?  Is there any reason to allow
> naming a file-backed mapping and showing it alongside the file name in
> /proc/pid/maps?
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
