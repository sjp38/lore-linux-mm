Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 30D1A6B0269
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 12:19:13 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id 191-v6so2469808pgb.23
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 09:19:13 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id j134-v6si2015457pgc.134.2018.10.03.09.19.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Oct 2018 09:19:11 -0700 (PDT)
Received: from mail-wm1-f42.google.com (mail-wm1-f42.google.com [209.85.128.42])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 47A18214AB
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 16:19:11 +0000 (UTC)
Received: by mail-wm1-f42.google.com with SMTP id s12-v6so6318543wmc.0
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 09:19:11 -0700 (PDT)
MIME-Version: 1.0
References: <20180921150351.20898-1-yu-cheng.yu@intel.com> <20180921150351.20898-25-yu-cheng.yu@intel.com>
 <20181003045611.GB22724@asgard.redhat.com> <CALCETrU-Ny-uC1NqRedQwNKe2MMhsFEqZ08TtHJwbLfCACMmLw@mail.gmail.com>
 <5ddb0ad33298d1858e530fce9c9ea2788b2fac81.camel@intel.com>
In-Reply-To: <5ddb0ad33298d1858e530fce9c9ea2788b2fac81.camel@intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Wed, 3 Oct 2018 09:18:57 -0700
Message-ID: <CALCETrVNp4Emx6z-+boE6_rhxi75pyA7O0Ay9sDDikX-VUWa0Q@mail.gmail.com>
Subject: Re: [RFC PATCH v4 24/27] mm/mmap: Create a guard area between VMAs
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: Eugene Syromiatnikov <esyr@redhat.com>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H. J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>

On Wed, Oct 3, 2018 at 9:06 AM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
>
> On Tue, 2018-10-02 at 22:36 -0700, Andy Lutomirski wrote:
> > On Tue, Oct 2, 2018 at 9:55 PM Eugene Syromiatnikov <esyr@redhat.com> wrote:
> > >
> > > On Fri, Sep 21, 2018 at 08:03:48AM -0700, Yu-cheng Yu wrote:
> > > > Create a guard area between VMAs, to detect memory corruption.
> > >
> > > Do I understand correctly that with this patch a user space program
> > > no longer be able to place two mappings back to back? If it is so,
> > > it will likely break a lot of things; for example, it's a common ring
> > > buffer implementations technique, to map buffer memory twice back
> > > to back in order to avoid special handling of items wrapping its end.
> >
> > I haven't checked what the patch actually does, but it shouldn't have
> > any affect on MAP_FIXED or the new no-replace MAP_FIXED variant.
> >
> > --Andy
>
> I did some mmap tests with/without MAP_FIXED, and it works as intended.
> In addition to the ring buffer, are there other test cases?
>

Various ELF loaders, perhaps?  Do they use MAP_FIXED or do they just
use address hints?
