Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3E63F6B0297
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 01:11:35 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id i90so212807374ioo.13
        for <linux-mm@kvack.org>; Sun, 23 Apr 2017 22:11:35 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTPS id y10si8091711pfi.42.2017.04.23.22.11.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 23 Apr 2017 22:11:34 -0700 (PDT)
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id AD9ED2020F
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 05:11:32 +0000 (UTC)
Received: from mail-ua0-f171.google.com (mail-ua0-f171.google.com [209.85.217.171])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 0EA4120172
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 05:11:30 +0000 (UTC)
Received: by mail-ua0-f171.google.com with SMTP id f10so105680144uaa.2
        for <linux-mm@kvack.org>; Sun, 23 Apr 2017 22:11:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <030ea57b-5f6c-13d8-02f7-b245a754a87d@physik.fu-berlin.de>
References: <030ea57b-5f6c-13d8-02f7-b245a754a87d@physik.fu-berlin.de>
From: Andy Lutomirski <luto@kernel.org>
Date: Sun, 23 Apr 2017 22:11:08 -0700
Message-ID: <CALCETrUcB7STNjVw=WBZdFfz_H1DKcLnj3HHtnGaHGQ1UY8Zrw@mail.gmail.com>
Subject: Re: Question on the five-level page table support patches
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Michal Hocko <mhocko@suse.com>, linux-arch <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Sun, Apr 23, 2017 at 3:53 AM, John Paul Adrian Glaubitz
<glaubitz@physik.fu-berlin.de> wrote:
> Hi Kirill!
>
> I recently read the LWN article on your and your colleagues work to
> add five-level page table support for x86 to the Linux kernel [1]
> and I got your email address from the last patch of the series.
>
> Since this extends the address space beyond 48-bits, as you may know,
> it will cause potential headaches with Javascript engines which use
> tagged pointers. On SPARC, the virtual address space already extends
> to 52 bits and we are running into these very issues with Javascript
> engines on SPARC.
>
> Now, a possible way to mitigate this problem would be to pass the
> "hint" parameter to mmap() in order to tell the kernel not to allocate
> memory beyond the 48 bits address space. Unfortunately, on Linux this
> will only work when the area pointed to by "hint" is unallocated which
> means one cannot simply use a hardcoded "hint" to mitigate this problem.
>
> However, since this trick still works on NetBSD and used to work on
> Linux [3], I was wondering whether there are plans to bring back
> this behavior to mmap() in Linux.
>
> Currently, people are using ugly work-arounds [4] to address this
> problem which involve a manual iteration over memory blocks and
> basically implementing another allocator in the user space
> application.
>
> Thanks,
> Adrian
>
>> [1] https://lwn.net/Articles/717293/
>> [2] https://lwn.net/Articles/717300/
>> [3] https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=3D824449#22
>> [4] https://hg.mozilla.org/mozilla-central/rev/dfaafbaaa291
>

Can you explain what the issue is?  What used to work on Linux and
doesn't any more?  The man page is quite clear:

       MAP_FIXED
              Don't  interpret  addr  as  a hint: place the mapping at exac=
tly
              that address.  addr must be a multiple of the page size.  If =
the
              memory  region  specified  by addr and len overlaps pages of =
any
              existing mapping(s), then the overlapped part  of  the  exist=
ing
              mapping(s)  will  be discarded.  If the specified address can=
not
              be used, mmap() will fail.  Because requiring  a  fixed  addr=
ess
              for  a  mapping is less portable, the use of this option is d=
is=E2=80=90
              couraged.

and AFAIK Linux works exactly as documented.

FWIW, a patch to add a new MAP_ mode to tell mmap(2) to use the hinted
address if available and to *fail* if the hinted address is not
available would very likely be accepted and would IMO be much nicer
than the current behavior.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
