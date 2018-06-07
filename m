Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id CAAA86B0006
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 14:23:32 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e3-v6so4909959pfe.15
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 11:23:32 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id v11-v6si53921885plp.25.2018.06.07.11.23.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 11:23:31 -0700 (PDT)
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 1F9CB208AC
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 18:23:31 +0000 (UTC)
Received: by mail-wm0-f52.google.com with SMTP id v131-v6so21053114wma.1
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 11:23:31 -0700 (PDT)
MIME-Version: 1.0
References: <20180607143807.3611-1-yu-cheng.yu@intel.com> <20180607143807.3611-2-yu-cheng.yu@intel.com>
 <CALCETrX4ALKbphJiZs4MXWtRFvQYD905bNAMTogbOeLh0Pp6xw@mail.gmail.com> <1528393611.4636.70.camel@2b52.sc.intel.com>
In-Reply-To: <1528393611.4636.70.camel@2b52.sc.intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 7 Jun 2018 11:23:18 -0700
Message-ID: <CALCETrU0gXZOZ90vUSMV_csop2O4TpKW_8D17no-wp-X3nutxA@mail.gmail.com>
Subject: Re: [PATCH 01/10] x86/cet: User-mode shadow stack support
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>, Florian Weimer <fweimer@redhat.com>
Cc: Andrew Lutomirski <luto@kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. J. Lu" <hjl.tools@gmail.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, mike.kravetz@oracle.com

On Thu, Jun 7, 2018 at 10:50 AM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
>
> On Thu, 2018-06-07 at 09:37 -0700, Andy Lutomirski wrote:
> > On Thu, Jun 7, 2018 at 7:41 AM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
> > >
> > > This patch adds basic shadow stack enabling/disabling routines.
> > > A task's shadow stack is allocated from memory with VM_SHSTK
> > > flag set and read-only protection.  The shadow stack is
> > > allocated to a fixed size and that can be changed by the system
> > > admin.
> >
> > How do threads work?  Can a user program mremap() its shadow stack to
> > make it bigger?
>
> A pthread's shadow stack is allocated/freed by the kernel.  This patch
> has the supporting routines that handle both non-pthread and pthread.
>
> In [PATCH 04/10] "Handle thread shadow stack", we allocate pthread
> shadow stack in copy_thread_tls(), and free it in deactivate_mm().
>
> If clone of a pthread fails, shadow stack is freed in
> cet_disable_free_shstk() below (I will add more comments):
>
> If (Current thread existing)
>         Disable and free shadow stack
>
> If (Clone of a pthread fails)
>         Free the pthread shadow stack
>
> We block mremap, mprotect, madvise, and munmap on a vma that has
> VM_SHSTK (in separate patches).

Why?  mremap() seems like a sensible way to enlarge a shadow stack.
munmap() seems like a good way to get rid of one, and mmap() seems
like a nice way to create a new shadow stack if one were needed (for
green threads or similar).
