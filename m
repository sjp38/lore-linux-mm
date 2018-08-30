Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 584876B5336
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 16:25:51 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id r20-v6so5593764pgv.20
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 13:25:51 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id y19-v6si7021590plr.497.2018.08.30.13.25.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Aug 2018 13:25:50 -0700 (PDT)
Message-ID: <1535660494.28258.36.camel@intel.com>
Subject: Re: [RFC PATCH v3 12/24] x86/mm: Modify ptep_set_wrprotect and
 pmdp_set_wrprotect for _PAGE_DIRTY_SW
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Thu, 30 Aug 2018 13:21:34 -0700
In-Reply-To: <CAG48ez3ixWROuQc6WZze6qPL6q0e_gCnMU4XF11JUWziePsBJg@mail.gmail.com>
References: <20180830143904.3168-1-yu-cheng.yu@intel.com>
	 <20180830143904.3168-13-yu-cheng.yu@intel.com>
	 <CAG48ez0Rca0XsdXJZ07c+iGPyep0Gpxw+sxQuACP5gyPaBgDKA@mail.gmail.com>
	 <079a55f2-4654-4adf-a6ef-6e480b594a2f@linux.intel.com>
	 <CAG48ez2gHOD9hH4+0wek5vUOv9upj79XWoug2SXjdwfXWoQqxw@mail.gmail.com>
	 <ce051b5b-feef-376f-e085-11f65a5f2215@linux.intel.com>
	 <1535649960.26689.15.camel@intel.com>
	 <33d45a12-513c-eba2-a2de-3d6b630e928e@linux.intel.com>
	 <1535651666.27823.6.camel@intel.com>
	 <CAG48ez3ixWROuQc6WZze6qPL6q0e_gCnMU4XF11JUWziePsBJg@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jannh@google.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, the arch/x86 maintainers <x86@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, kernel list <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Florian Weimer <fweimer@redhat.com>, hjl.tools@gmail.com, Jonathan Corbet <corbet@lwn.net>, keescook@chromiun.org, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, ravi.v.shankar@intel.com, vedvyas.shanbhogue@intel.com

On Thu, 2018-08-30 at 19:59 +0200, Jann Horn wrote:
> On Thu, Aug 30, 2018 at 7:58 PM Yu-cheng Yu <yu-cheng.yu@intel.com>
> wrote:
> > 
> > 
> > On Thu, 2018-08-30 at 10:33 -0700, Dave Hansen wrote:
> > > 
> > > On 08/30/2018 10:26 AM, Yu-cheng Yu wrote:
> > > > 
> > > > 
> > > > We don't have the guard page now, but there is a shadow stack
> > > > token
> > > > there, which cannot be used as a return address.
> > > The overall concern is that we could overflow into a page that
> > > we
> > > did
> > > not intend.A A Either another actual shadow stack or something
> > > that a
> > > page
> > > that the attacker constructed, like the transient scenario Jann
> > > described.
> > > 
> > A task could go beyond the bottom of its shadow stack by doing
> > either
> > 'ret' or 'incssp'.A A If it is the 'ret' case, the token prevents
> > it.
> > A If it is the 'incssp' case, a guard page cannot prevent it
> > entirely,
> > right?
> I mean the other direction, on "call".

In the flow you described, if C writes to the overflow page before B
gets in with a 'call', the return address is still correct for B. A To
make an attack, C needs to write again before the TLB flush. A I agree
that is possible.

Assume we have a guard page, can someone in the short window do
recursive calls in B, move ssp to the end of the guard page, and
trigger the same again? A He can simply take the incssp route.
