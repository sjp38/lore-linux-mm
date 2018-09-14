Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id E18BC8E0001
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 17:33:38 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id z18-v6so5214079pfe.19
        for <linux-mm@kvack.org>; Fri, 14 Sep 2018 14:33:38 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id j37-v6si8473840pgl.432.2018.09.14.14.33.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Sep 2018 14:33:37 -0700 (PDT)
Subject: Re: [RFC PATCH v3 12/24] x86/mm: Modify ptep_set_wrprotect and
 pmdp_set_wrprotect for _PAGE_DIRTY_SW
References: <1535660494.28258.36.camel@intel.com>
 <CAG48ez0yOuDhqxB779aO3Kss3gQ3cZTJL1VphDXQm+_M9jFPvQ@mail.gmail.com>
 <1535662366.28781.6.camel@intel.com>
 <CAG48ez0mkr95_TbLQnDGuGUd6G+eJVLZ-fEjDkwA6dSrm+9tLw@mail.gmail.com>
 <CAG48ez3S3+DzAyo_SnoUW1GO0Cpd_x0A83MOx2p_MkogoAatLQ@mail.gmail.com>
 <20180831095300.GF24124@hirez.programming.kicks-ass.net>
 <1535726032.32537.0.camel@intel.com>
 <f5a36e32-7c5f-91fe-9e98-fb44867fda11@linux.intel.com>
 <1535730524.501.13.camel@intel.com>
 <6d31bd30-6d5b-bbde-1e97-1d8255eff76d@linux.intel.com>
 <20180831162920.GQ24124@hirez.programming.kicks-ass.net>
 <1536957543.12990.9.camel@intel.com>
 <8d9ce0e9-8fc7-8c68-4aa9-9aed9ee949f2@linux.intel.com>
 <1536959337.12990.27.camel@intel.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <9366d924-cd67-1d2d-b78d-809bb46e7186@linux.intel.com>
Date: Fri, 14 Sep 2018 14:33:36 -0700
MIME-Version: 1.0
In-Reply-To: <1536959337.12990.27.camel@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Jann Horn <jannh@google.com>, the arch/x86 maintainers <x86@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, kernel list <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Florian Weimer <fweimer@redhat.com>, hjl.tools@gmail.com, Jonathan Corbet <corbet@lwn.net>, keescook@chromium.org, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, ravi.v.shankar@intel.com, vedvyas.shanbhogue@intel.com

On 09/14/2018 02:08 PM, Yu-cheng Yu wrote:
> On Fri, 2018-09-14 at 13:46 -0700, Dave Hansen wrote:
>> On 09/14/2018 01:39 PM, Yu-cheng Yu wrote:
>>>
>>> With the updated ptep_set_wrprotect() below, I did MADV_WILLNEED to a shadow
>>> stack of 8 MB, then 10,000 fork()'s, but could not prove it is more or less
>>> efficient than the other. A So can we say this is probably fine in terms of
>>> efficiency?

BTW, I wasn't particularly concerned about shadow stacks.  Plain old
memory is affected by this change too.  Right?

>> Well, the first fork() will do all the hard work.A A I don't think
>> subsequent fork()s will be affected.
> 
> Are you talking about a recent commit:
> 
> A  A  1b2de5d0 mm/cow: don't bother write protecting already write-protected pages
> 
> With that, subsequent fork()s will not do all the hard work.
> However, I have not done that for shadow stack PTEs (do we want to do that?).
> I think the additional benefit for shadow stack is small?

You're right.  mprotect() doesn't use this path.

But, that reminds me, can you take a quick look at change_pte_range()
and double-check that it's not affected by this issue?
