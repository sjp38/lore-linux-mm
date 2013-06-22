Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 6D7BB6B0031
	for <linux-mm@kvack.org>; Sat, 22 Jun 2013 01:12:51 -0400 (EDT)
Received: by mail-oa0-f42.google.com with SMTP id j6so649367oag.29
        for <linux-mm@kvack.org>; Fri, 21 Jun 2013 22:12:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAMbhsRQU=xrcum+ZUbG3S+JfFUJK_qm_VB96Vz=PpL=vQYhUvg@mail.gmail.com>
References: <CAMbhsRQU=xrcum+ZUbG3S+JfFUJK_qm_VB96Vz=PpL=vQYhUvg@mail.gmail.com>
Date: Sat, 22 Jun 2013 14:12:50 +0900
Message-ID: <CAH9JG2Uif-d-osTsCT-EqKw+ZWJ1S-rFJA-nQ9nkqTH7sbcSsQ@mail.gmail.com>
Subject: Re: RFC: named anonymous vmas
From: Kyungmin Park <kmpark@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Colin Cross <ccross@google.com>
Cc: lkml <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Android Kernel Team <kernel-team@android.com>, John Stultz <john.stultz@linaro.org>, Hyunhee Kim <hyunhee.kim@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Tomasz Stanislawski <t.stanislaws@samsung.com>

On Sat, Jun 22, 2013 at 8:42 AM, Colin Cross <ccross@google.com> wrote:
> One of the features of ashmem (drivers/staging/android/ashmem.c) that
> hasn't gotten much discussion about moving out of staging is named
> anonymous memory.
>
> In Android, ashmem is used for three different features, and most
> users of it only care about one feature at a time.  One is volatile
> ranges, which John Stultz has been implementing.  The second is
> anonymous shareable memory without having a world-writable tmpfs that
> untrusted apps could fill with files.  The third and most heavily used
> feature within the Android codebase is named anonymous memory, where a
> region of anonymous memory can have a name associated with it that
> will show up in /proc/pid/maps.  The Dalvik VM likes to use this

Good to know it. I didn't know ashmem provides these features.
we are also discussing these requirement internally. and study how to
show who request these anon memory and which callback is used for it.

> feature extensively, even for memory that will never be shared and
> could easily be allocated using an anonymous mmap, and even malloc has
> used it in the past.  It provides an easy way to collate memory used
> for different purposes across multiple processes, which Android uses
> for its "dumpsys meminfo" and "librank" tools to determine how much
> memory is used for java heaps, JIT caches, native mallocs, etc.
Same requirement for app developers. they want to know what's the
meaning these anon memory is allocated and how to find out these anon
memory is allocated at their codes.
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
Do you want to create new syscall? can it use current madvise and only
allow this feature at linux only?
As you know it's just hint and it doesn't break existing memory behaviors.
>
> Any comments as I start implementing it?  Is there any reason to allow
> naming a file-backed mapping and showing it alongside the file name in
> /proc/pid/maps?
>

Thank you,
Kyungmin Park

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
