Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id B60B36B57BA
	for <linux-mm@kvack.org>; Fri, 31 Aug 2018 11:53:02 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id x2-v6so7038867pgp.4
        for <linux-mm@kvack.org>; Fri, 31 Aug 2018 08:53:02 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id e11-v6si9910279plb.373.2018.08.31.08.53.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Aug 2018 08:53:01 -0700 (PDT)
Message-ID: <1535730524.501.13.camel@intel.com>
Subject: Re: [RFC PATCH v3 12/24] x86/mm: Modify ptep_set_wrprotect and
 pmdp_set_wrprotect for _PAGE_DIRTY_SW
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Fri, 31 Aug 2018 08:48:44 -0700
In-Reply-To: <f5a36e32-7c5f-91fe-9e98-fb44867fda11@linux.intel.com>
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
	 <1535726032.32537.0.camel@intel.com>
	 <f5a36e32-7c5f-91fe-9e98-fb44867fda11@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Jann Horn <jannh@google.com>
Cc: the arch/x86 maintainers <x86@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, kernel list <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Florian Weimer <fweimer@redhat.com>, hjl.tools@gmail.com, Jonathan Corbet <corbet@lwn.net>, keescook@chromiun.org, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, ravi.v.shankar@intel.com, vedvyas.shanbhogue@intel.com

On Fri, 2018-08-31 at 07:47 -0700, Dave Hansen wrote:
> On 08/31/2018 07:33 AM, Yu-cheng Yu wrote:
> > 
> > Please use the form:
> > 
> > 	pte_t new_pte, pte = READ_ONCE(*ptep);
> > 	do {
> > 		new_pte = /* ... */;
> > 	} while (!try_cmpxchg(ptep, &pte, new_pte);
> It's probably also worth doing some testing to see if you can detect
> the
> cost of the cmpxchg.A A It's definitely more than the old code.
> 
> A loop that does mprotect(PROT_READ) followed by
> mprotect(PROT_READ|PROT_WRITE) should do it.

I created the test,

https://github.com/yyu168/cet-smoke-test/blob/quick/quick/mprotect_ben
ch.c

then realized this won't work.

To trigger a race in ptep_set_wrprotect(), we need to fork from one of
three pthread siblings.

Or do we measure only how much this affects fork?
If there is no racing, the effect should be minimal.

Yu-cheng
