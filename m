Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id 080D06B0035
	for <linux-mm@kvack.org>; Tue, 30 Sep 2014 05:36:50 -0400 (EDT)
Received: by mail-ig0-f181.google.com with SMTP id r10so342565igi.8
        for <linux-mm@kvack.org>; Tue, 30 Sep 2014 02:36:50 -0700 (PDT)
Received: from mail-ie0-x22e.google.com (mail-ie0-x22e.google.com [2607:f8b0:4001:c03::22e])
        by mx.google.com with ESMTPS id lo3si14680404igb.41.2014.09.30.02.36.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 30 Sep 2014 02:36:50 -0700 (PDT)
Received: by mail-ie0-f174.google.com with SMTP id tr6so3390174ieb.33
        for <linux-mm@kvack.org>; Tue, 30 Sep 2014 02:36:49 -0700 (PDT)
Message-ID: <542A79AF.8060602@gmail.com>
Date: Tue, 30 Sep 2014 05:36:47 -0400
From: Daniel Micay <danielmicay@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3] mm: add mremap flag for preserving the old mapping
References: <1412052900-1722-1-git-send-email-danielmicay@gmail.com> <CALCETrX6D7X7zm3qCn8kaBtYHCQvdR06LAAwzBA=1GteHAaLKA@mail.gmail.com>
In-Reply-To: <CALCETrX6D7X7zm3qCn8kaBtYHCQvdR06LAAwzBA=1GteHAaLKA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, jasone@canonware.com

On 30/09/14 01:53 AM, Andy Lutomirski wrote:
> On Mon, Sep 29, 2014 at 9:55 PM, Daniel Micay <danielmicay@gmail.com> wrote:
>> This introduces the MREMAP_RETAIN flag for preserving the source mapping
>> when MREMAP_MAYMOVE moves the pages to a new destination. Accesses to
>> the source location will fault and cause fresh pages to be mapped in.
>>
>> For consistency, the old_len >= new_len case could decommit the pages
>> instead of unmapping. However, userspace can accomplish the same thing
>> via madvise and a coherent definition of the flag is possible without
>> the extra complexity.
> 
> IMO this needs very clear documentation of exactly what it does.

Agreed, and thanks for the review. I'll post a slightly modified version
of the patch soon (mostly more commit message changes).

> Does it preserve the contents of the source pages?  (If so, why?
> Aren't you wasting a bunch of time on page faults and possibly
> unnecessary COWs?)

The source will act as if it was just created. For an anonymous memory
mapping, it will fault on any accesses and bring in new zeroed pages.

In jemalloc, it replaces an enormous memset(dst, src, size) followed by
madvise(src, size, MADV_DONTNEED) with mremap. Using mremap also ends up
eliding page faults from writes at the destination.

TCMalloc has nearly the same page allocation design, although it tries
to throttle the purging so it won't always gain as much.

> Does it work on file mappings?  Can it extend file mappings while it moves them?

It works on file mappings. If a move occurs, there will be the usual
extended destination mapping but with the source mapping left intact.

It wouldn't be useful with existing allocators, but in theory a general
purpose allocator could expose an MMIO API in order to reuse the same
address space via MAP_FIXED/MREMAP_FIXED to reduce VM fragmentation.

> If you MREMAP_RETAIN a partially COWed private mapping, what happens?

The original mapping is zeroed in the following test, as it would be
without fork:

#define _GNU_SOURCE

#include <string.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <unistd.h>
#include <sys/wait.h>

int main(void) {
  size_t size = 1024 * 1024;
  char *orig = mmap(NULL, size, PROT_READ|PROT_WRITE,
                    MAP_PRIVATE|MAP_ANONYMOUS, -1, 0);
  memset(orig, 5, size);
  int pid = fork();
  if (pid == -1)
    return 1;
  if (pid == 0) {
    memset(orig, 5, 1024);
    char *new = mremap(orig, size, size * 128, MREMAP_MAYMOVE|4);
    if (new == orig) return 1;
    for (size_t i = 0; i < size; i++)
      if (new[i] != 5)
        return 1;
    for (size_t i = 0; i < size; i++)
      if (orig[i] != 0)
        return 1;
    return 0;
  }
  int status;
  if (wait(&status) < -1) return 1;
  if (WIFEXITED(status))
    return WEXITSTATUS(status);
  return 1;
}

Hopefully this is the case you're referring to. :)

> Does it work on special mappings?  If so, please prevent it from doing
> so.  mremapping x86's vdso is a thing, and duplicating x86's vdso
> should not become a thing, because x86_32 in particular will become
> extremely confused.

I'll add a check for arch_vma_name(vma) == NULL.

There's an existing check for VM_DONTEXPAND | VM_PFNMAP when expanding
allocations (the only case this flag impacts). Are there other kinds of
special mappings that you're referring to?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
