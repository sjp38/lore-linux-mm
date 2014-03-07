Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f177.google.com (mail-ea0-f177.google.com [209.85.215.177])
	by kanga.kvack.org (Postfix) with ESMTP id 0B75D6B0031
	for <linux-mm@kvack.org>; Fri,  7 Mar 2014 18:03:07 -0500 (EST)
Received: by mail-ea0-f177.google.com with SMTP id h10so2606154eak.36
        for <linux-mm@kvack.org>; Fri, 07 Mar 2014 15:03:07 -0800 (PST)
Received: from mail-ee0-f45.google.com (mail-ee0-f45.google.com [74.125.83.45])
        by mx.google.com with ESMTPS id t3si19356702eeg.64.2014.03.07.15.03.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 07 Mar 2014 15:03:06 -0800 (PST)
Received: by mail-ee0-f45.google.com with SMTP id d17so2000016eek.32
        for <linux-mm@kvack.org>; Fri, 07 Mar 2014 15:03:06 -0800 (PST)
MIME-Version: 1.0
Date: Sat, 8 Mar 2014 00:03:05 +0100
Message-ID: <CAM9z9z-ngrFwc-KvdUqWsY=b8jzuzzKDYbG+nd10h_y=NApOVA@mail.gmail.com>
Subject: hugetlb_cow and tlb invalidation on x86
From: Anthony I <foobar@altatus.com>
Content-Type: multipart/alternative; boundary=001a11c3f68cb3bb3704f40c413a
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

--001a11c3f68cb3bb3704f40c413a
Content-Type: text/plain; charset=ISO-8859-1

Hi all,

Currently huge_ptep_clear_flush on x86 is a nop. How is dtlb invalidation
handled, for the copy-on-write cases on huge pages ?

I have actually verified that dtlb consistency is maintained with an
example code, under the following scenario:

- parent allocates a 2M hugepage (via mmap/MAP_HUGETLB), fills page with
some random data
- forks a child process
- clones a thread
(all parent, child and thread run on separate cores, pinned).

The child process as well as the thread, read the contents of the hugepage
(thus there is a dtlb entry at the core that the thread runs)

At a later point, parent writes into the page, thus inducing a CoW fault.
Since this is a hugepage, there is no tlb page flushing taking place (no
tlb-flushing IPIs). My assumption is that the thread would be now reading
from the physical page that belongs to the child after CoW, since the
parent pgtable pte is now pointing to a newly allocated page, but the core
executing the thread has not received any tlb invalidation interrupts (thus
it would be following the "old" tlb entry). Oddly enough, this does not
hold true (the thread can see the updated page).

Going through the intel devel manuals, I do not see how this would happen.
It does not seem that large pages are treated differently from 4K pages as
far as tlb invalidation goes.

Any ideas ? Does the kernel somehow manage this in a different way, or is
it an x86 thing that is non-obvious ?

Regards,
Anthony

--001a11c3f68cb3bb3704f40c413a
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hi all,<br><br>Currently huge_ptep_clear_flush on x86 is a=
 nop. How is dtlb invalidation handled, for the copy-on-write cases on huge=
 pages ?<br><br>I have actually verified that dtlb consistency is maintaine=
d with an example code, under the following scenario:<br>

<br>- parent allocates a 2M hugepage (via mmap/MAP_HUGETLB), fills page wit=
h some random data<br>- forks a child process<br>- clones a thread<br>(all =
parent, child and thread run on separate cores, pinned).<br><br>The child p=
rocess as well as the thread, read the contents of the hugepage (thus there=
 is a dtlb entry at the core that the thread runs)<br>

<br>At a later point, parent writes into the page, thus inducing a CoW faul=
t. Since this is a hugepage, there is no tlb page flushing taking place (no=
 tlb-flushing IPIs). My assumption is that the thread would be now reading =
from the physical page that belongs to the child after CoW, since the paren=
t pgtable pte is now pointing to a newly allocated page, but the core execu=
ting the thread has not received any tlb invalidation interrupts (thus it w=
ould be following the &quot;old&quot; tlb entry). Oddly enough, this does n=
ot hold true (the thread can see the updated page).<br>

<br>Going through the intel devel manuals, I do not see how this would happ=
en. It does not seem that large pages are treated differently from 4K pages=
 as far as tlb invalidation goes.<br><br>Any ideas ? Does the kernel someho=
w manage this in a different way, or is it an x86 thing that is non-obvious=
 ?<br>
<br>Regards,<br>Anthony<br></div>

--001a11c3f68cb3bb3704f40c413a--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
