Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 8251A6B0031
	for <linux-mm@kvack.org>; Fri, 21 Jun 2013 19:42:42 -0400 (EDT)
Received: by mail-vb0-f46.google.com with SMTP id 10so6380520vbe.5
        for <linux-mm@kvack.org>; Fri, 21 Jun 2013 16:42:41 -0700 (PDT)
MIME-Version: 1.0
Date: Fri, 21 Jun 2013 16:42:41 -0700
Message-ID: <CAMbhsRQU=xrcum+ZUbG3S+JfFUJK_qm_VB96Vz=PpL=vQYhUvg@mail.gmail.com>
Subject: RFC: named anonymous vmas
From: Colin Cross <ccross@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lkml <linux-kernel@vger.kernel.org>
Cc: Linux-MM <linux-mm@kvack.org>, Android Kernel Team <kernel-team@android.com>, John Stultz <john.stultz@linaro.org>

One of the features of ashmem (drivers/staging/android/ashmem.c) that
hasn't gotten much discussion about moving out of staging is named
anonymous memory.

In Android, ashmem is used for three different features, and most
users of it only care about one feature at a time.  One is volatile
ranges, which John Stultz has been implementing.  The second is
anonymous shareable memory without having a world-writable tmpfs that
untrusted apps could fill with files.  The third and most heavily used
feature within the Android codebase is named anonymous memory, where a
region of anonymous memory can have a name associated with it that
will show up in /proc/pid/maps.  The Dalvik VM likes to use this
feature extensively, even for memory that will never be shared and
could easily be allocated using an anonymous mmap, and even malloc has
used it in the past.  It provides an easy way to collate memory used
for different purposes across multiple processes, which Android uses
for its "dumpsys meminfo" and "librank" tools to determine how much
memory is used for java heaps, JIT caches, native mallocs, etc.

I'd like to add this feature for anonymous mmap memory.  I propose
adding an madvise2(unsigned long start, size_t len_in, int behavior,
void *ptr, size_t size) syscall and a new MADV_NAME behavior, which
treats ptr as a string of length size.  The string would be copied
somewhere reusable in the kernel, or reused if it already exists, and
the kernel address of the string would get stashed in a new field in
struct vm_area_struct.  Adjacent vmas would only get merged if the
name pointer matched, and naming part of a mapping would split the
mapping.  show_map_vma would print the name only if none of the other
existing names rules match.

Any comments as I start implementing it?  Is there any reason to allow
naming a file-backed mapping and showing it alongside the file name in
/proc/pid/maps?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
