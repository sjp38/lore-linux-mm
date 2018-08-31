Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id AEAFC6B5771
	for <linux-mm@kvack.org>; Fri, 31 Aug 2018 10:38:10 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id e8-v6so6168704plt.4
        for <linux-mm@kvack.org>; Fri, 31 Aug 2018 07:38:10 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id 16-v6si10104807pgy.641.2018.08.31.07.38.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Aug 2018 07:38:09 -0700 (PDT)
Message-ID: <1535726032.32537.0.camel@intel.com>
Subject: Re: [RFC PATCH v3 12/24] x86/mm: Modify ptep_set_wrprotect and
 pmdp_set_wrprotect for _PAGE_DIRTY_SW
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Fri, 31 Aug 2018 07:33:52 -0700
In-Reply-To: <20180831095300.GF24124@hirez.programming.kicks-ass.net>
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
	 <20180831095300.GF24124@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Jann Horn <jannh@google.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, the arch/x86 maintainers <x86@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, kernel list <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Florian Weimer <fweimer@redhat.com>, hjl.tools@gmail.com, Jonathan Corbet <corbet@lwn.net>, keescook@chromiun.org, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, ravi.v.shankar@intel.com, vedvyas.shanbhogue@intel.com

On Fri, 2018-08-31 at 11:53 +0200, Peter Zijlstra wrote:
> On Thu, Aug 30, 2018 at 11:47:16PM +0200, Jann Horn wrote:
> > 
> > A A A A A A A A do {
> > A A A A A A A A A A A A A A A A pte = pte_wrprotect(pte);
> > A A A A A A A A A A A A A A A A /* note: relies on _PAGE_DIRTY_HW < _PAGE_DIRTY_SW
> > */
> > A A A A A A A A A A A A A A A A /* dirty direct bit-twiddling; you can probably
> > write
> > this in a nicer way */
> > A A A A A A A A A A A A A A A A pte.pte |= (pte.pte & _PAGE_DIRTY_HW) >>
> > _PAGE_BIT_DIRTY_HW << _PAGE_BIT_DIRTY_SW;
> > A A A A A A A A A A A A A A A A pte.pte &= ~_PAGE_DIRTY_HW;
> > A A A A A A A A A A A A A A A A pte = cmpxchg(ptep, pte, new_pte);
> > A A A A A A A A } while (pte != new_pte);
> Please use the form:
> 
> 	pte_t new_pte, pte = READ_ONCE(*ptep);
> 	do {
> 		new_pte = /* ... */;
> 	} while (!try_cmpxchg(ptep, &pte, new_pte);
> 
> Also, this will fail to build on i386-PAE, but I suspect this code
> will
> be under some CONFIG option specific to x86_64 anyway.

Thanks! A I will work on it.

Yu-cheng
