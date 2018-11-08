Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6EA0C6B067E
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 18:53:01 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id w8-v6so34683wrt.22
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 15:53:01 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTPS id w132-v6si4698169wme.155.2018.11.08.15.52.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Nov 2018 15:52:59 -0800 (PST)
Date: Fri, 9 Nov 2018 00:52:44 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v5 04/27] x86/fpu/xstate: Add XSAVES system states for
 shadow stack
Message-ID: <20181108235244.GK7543@zn.tnic>
References: <20181011151523.27101-1-yu-cheng.yu@intel.com>
 <20181011151523.27101-5-yu-cheng.yu@intel.com>
 <20181108184038.GJ7543@zn.tnic>
 <bb049aa9578bae7cfc6bd7c05b540f033f6685cc.camel@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <bb049aa9578bae7cfc6bd7c05b540f033f6685cc.camel@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Thu, Nov 08, 2018 at 12:40:02PM -0800, Yu-cheng Yu wrote:
> In fpu_init_system_xstate(), we test and clear features that are not enabled.
> There we depend on the order of these elements.  This is the tenth "unknown
> xstate feature".

Aha, those are *reserved* bits - not unused, in XCR0.

Do an s/unused/reserved/g pls.

Now let's see, you have 0 for the 10th bit which happens to be

#define X86_FEATURE_FPU                 ( 0*32+ 0) /* Onboard FPU */

too. And if we look at the code:

        for (i = 0; i < ARRAY_SIZE(xsave_cpuid_features); i++) {
                if (!boot_cpu_has(xsave_cpuid_features[i]))
                        xfeatures_mask_all &= ~BIT_ULL(i);

guess what happens if i == 10.

I know, the subsequent & SUPPORTED_XFEATURES_MASK saves you from the
#GP but that's still not good enough. The loop should not even call
boot_cpu_has() for reserved feature bits.

Thx.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
