Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3D17F6B067C
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 18:35:07 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id m1-v6so20657plb.13
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 15:35:07 -0800 (PST)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id q33-v6si4932924pgk.2.2018.11.08.15.35.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Nov 2018 15:35:05 -0800 (PST)
Subject: Re: [PATCH v5 04/27] x86/fpu/xstate: Add XSAVES system states for
 shadow stack
References: <20181011151523.27101-1-yu-cheng.yu@intel.com>
 <20181011151523.27101-5-yu-cheng.yu@intel.com>
 <CALCETrVAe8R=crVHoD5QmbN-gAW+V-Rwkwe4kQP7V7zQm9TM=Q@mail.gmail.com>
 <4295b8f786c10c469870a6d9725749ce75dcdaa2.camel@intel.com>
 <CALCETrUKzXYzRrWRdi8Z7AdAF0uZW5Gs7J4s=55dszoyzc29rw@mail.gmail.com>
 <043a17ef-dc9f-56d2-5fba-1a58b7b0fd4d@intel.com>
 <20181108220054.GP3074@bombadil.infradead.org>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <ead230ab-a904-50d6-c4cf-46d5804f6151@intel.com>
Date: Thu, 8 Nov 2018 15:35:02 -0800
MIME-Version: 1.0
In-Reply-To: <20181108220054.GP3074@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andy Lutomirski <luto@amacapital.net>, Yu-cheng Yu <yu-cheng.yu@intel.com>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, LKML <linux-kernel@vger.kernel.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, "H. J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>

On 11/8/18 2:00 PM, Matthew Wilcox wrote:
> struct a {
> 	char c;
> 	struct b b;
> };
> 
> we want struct b to start at offset 8, but with __packed, it will start
> at offset 1.

You're talking about how we want the struct laid out in memory if we
have control over the layout.  I'm talking about what happens if
something *else* tells us the layout, like a hardware specification
which is what is in play with the XSAVE instruction dictated layout
that's in question here.

What I'm concerned about is a structure like this:

struct foo {
        u32 i1;
        u64 i2;
};

If we leave that to natural alignment, we end up with a 16-byte
structure laid out like this:

	0-3	i1
	3-8	alignment gap
	8-15	i2

Which isn't what we want.  We want a 12-byte structure, laid out like this:

	0-3	i1
	4-11	i2

Which we get with:


struct foo {
        u32 i1;
        u64 i2;
} __packed;

Now, looking at Yu-cheng's specific example, it doesn't matter.  We've
got 64-bit types and natural 64-bit alignment.  Without __packed, we
need to look out for natural alignment screwing us up.  With __packed,
it just does what it *looks* like it does.
