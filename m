Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 50CA06B066C
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 16:48:58 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id f69-v6so13277766pfa.15
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 13:48:58 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id b23-v6si1996475pls.367.2018.11.08.13.48.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Nov 2018 13:48:57 -0800 (PST)
Subject: Re: [PATCH v5 04/27] x86/fpu/xstate: Add XSAVES system states for
 shadow stack
References: <20181011151523.27101-1-yu-cheng.yu@intel.com>
 <20181011151523.27101-5-yu-cheng.yu@intel.com>
 <CALCETrVAe8R=crVHoD5QmbN-gAW+V-Rwkwe4kQP7V7zQm9TM=Q@mail.gmail.com>
 <4295b8f786c10c469870a6d9725749ce75dcdaa2.camel@intel.com>
 <CALCETrUKzXYzRrWRdi8Z7AdAF0uZW5Gs7J4s=55dszoyzc29rw@mail.gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <043a17ef-dc9f-56d2-5fba-1a58b7b0fd4d@intel.com>
Date: Thu, 8 Nov 2018 13:48:54 -0800
MIME-Version: 1.0
In-Reply-To: <CALCETrUKzXYzRrWRdi8Z7AdAF0uZW5Gs7J4s=55dszoyzc29rw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, LKML <linux-kernel@vger.kernel.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, "H. J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>

On 11/8/18 1:22 PM, Andy Lutomirski wrote:
>> +struct cet_kernel_state {
>> +       u64 kernel_ssp; /* kernel shadow stack */
>> +       u64 pl1_ssp;    /* ring-1 shadow stack */
>> +       u64 pl2_ssp;    /* ring-2 shadow stack */
>> +} __packed;
>> +
> Why are these __packed?  It seems like it'll generate bad code for no
> obvious purpose.

It's a hardware-defined in-memory structure.  Granted, we'd need a
really wonky compiler to make that anything *other* than a nicely-packed
24-byte structure, but the __packed makes it explicit.

It is probably a really useful long-term thing to stop using __packed
and start using "__hw_defined" or something that #defines down to __packed.
