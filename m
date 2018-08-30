Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id BE5A46B529E
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 14:00:00 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id m21-v6so8132709oic.7
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 11:00:00 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u141-v6sor5741042oie.151.2018.08.30.10.59.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 30 Aug 2018 10:59:59 -0700 (PDT)
MIME-Version: 1.0
References: <20180830143904.3168-1-yu-cheng.yu@intel.com> <20180830143904.3168-13-yu-cheng.yu@intel.com>
 <CAG48ez0Rca0XsdXJZ07c+iGPyep0Gpxw+sxQuACP5gyPaBgDKA@mail.gmail.com>
 <079a55f2-4654-4adf-a6ef-6e480b594a2f@linux.intel.com> <CAG48ez2gHOD9hH4+0wek5vUOv9upj79XWoug2SXjdwfXWoQqxw@mail.gmail.com>
 <ce051b5b-feef-376f-e085-11f65a5f2215@linux.intel.com> <1535649960.26689.15.camel@intel.com>
 <33d45a12-513c-eba2-a2de-3d6b630e928e@linux.intel.com> <1535651666.27823.6.camel@intel.com>
In-Reply-To: <1535651666.27823.6.camel@intel.com>
From: Jann Horn <jannh@google.com>
Date: Thu, 30 Aug 2018 19:59:32 +0200
Message-ID: <CAG48ez3ixWROuQc6WZze6qPL6q0e_gCnMU4XF11JUWziePsBJg@mail.gmail.com>
Subject: Re: [RFC PATCH v3 12/24] x86/mm: Modify ptep_set_wrprotect and
 pmdp_set_wrprotect for _PAGE_DIRTY_SW
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yu-cheng.yu@intel.com
Cc: Dave Hansen <dave.hansen@linux.intel.com>, the arch/x86 maintainers <x86@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, kernel list <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Florian Weimer <fweimer@redhat.com>, hjl.tools@gmail.com, Jonathan Corbet <corbet@lwn.net>, keescook@chromiun.org, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, ravi.v.shankar@intel.com, vedvyas.shanbhogue@intel.com

On Thu, Aug 30, 2018 at 7:58 PM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
>
> On Thu, 2018-08-30 at 10:33 -0700, Dave Hansen wrote:
> > On 08/30/2018 10:26 AM, Yu-cheng Yu wrote:
> > >
> > > We don't have the guard page now, but there is a shadow stack
> > > token
> > > there, which cannot be used as a return address.
> > The overall concern is that we could overflow into a page that we
> > did
> > not intend.  Either another actual shadow stack or something that a
> > page
> > that the attacker constructed, like the transient scenario Jann
> > described.
> >
>
> A task could go beyond the bottom of its shadow stack by doing either
> 'ret' or 'incssp'.  If it is the 'ret' case, the token prevents it.
>  If it is the 'incssp' case, a guard page cannot prevent it entirely,
> right?

I mean the other direction, on "call".
