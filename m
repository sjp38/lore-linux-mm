Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 14D566B5652
	for <linux-mm@kvack.org>; Fri, 31 Aug 2018 05:53:24 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id v1-v6so3162402wmh.4
        for <linux-mm@kvack.org>; Fri, 31 Aug 2018 02:53:24 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id i1-v6si8715595wrq.11.2018.08.31.02.53.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 31 Aug 2018 02:53:22 -0700 (PDT)
Date: Fri, 31 Aug 2018 11:53:00 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC PATCH v3 12/24] x86/mm: Modify ptep_set_wrprotect and
 pmdp_set_wrprotect for _PAGE_DIRTY_SW
Message-ID: <20180831095300.GF24124@hirez.programming.kicks-ass.net>
References: <ce051b5b-feef-376f-e085-11f65a5f2215@linux.intel.com>
 <1535649960.26689.15.camel@intel.com>
 <33d45a12-513c-eba2-a2de-3d6b630e928e@linux.intel.com>
 <1535651666.27823.6.camel@intel.com>
 <CAG48ez3ixWROuQc6WZze6qPL6q0e_gCnMU4XF11JUWziePsBJg@mail.gmail.com>
 <1535660494.28258.36.camel@intel.com>
 <CAG48ez0yOuDhqxB779aO3Kss3gQ3cZTJL1VphDXQm+_M9jFPvQ@mail.gmail.com>
 <1535662366.28781.6.camel@intel.com>
 <CAG48ez0mkr95_TbLQnDGuGUd6G+eJVLZ-fEjDkwA6dSrm+9tLw@mail.gmail.com>
 <CAG48ez3S3+DzAyo_SnoUW1GO0Cpd_x0A83MOx2p_MkogoAatLQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAG48ez3S3+DzAyo_SnoUW1GO0Cpd_x0A83MOx2p_MkogoAatLQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jannh@google.com>
Cc: yu-cheng.yu@intel.com, Dave Hansen <dave.hansen@linux.intel.com>, the arch/x86 maintainers <x86@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, kernel list <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Florian Weimer <fweimer@redhat.com>, hjl.tools@gmail.com, Jonathan Corbet <corbet@lwn.net>, keescook@chromiun.org, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, ravi.v.shankar@intel.com, vedvyas.shanbhogue@intel.com

On Thu, Aug 30, 2018 at 11:47:16PM +0200, Jann Horn wrote:
>         do {
>                 pte = pte_wrprotect(pte);
>                 /* note: relies on _PAGE_DIRTY_HW < _PAGE_DIRTY_SW */
>                 /* dirty direct bit-twiddling; you can probably write
> this in a nicer way */
>                 pte.pte |= (pte.pte & _PAGE_DIRTY_HW) >>
> _PAGE_BIT_DIRTY_HW << _PAGE_BIT_DIRTY_SW;
>                 pte.pte &= ~_PAGE_DIRTY_HW;
>                 pte = cmpxchg(ptep, pte, new_pte);
>         } while (pte != new_pte);

Please use the form:

	pte_t new_pte, pte = READ_ONCE(*ptep);
	do {
		new_pte = /* ... */;
	} while (!try_cmpxchg(ptep, &pte, new_pte);

Also, this will fail to build on i386-PAE, but I suspect this code will
be under some CONFIG option specific to x86_64 anyway.
