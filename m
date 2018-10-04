Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3EFDE6B026B
	for <linux-mm@kvack.org>; Thu,  4 Oct 2018 12:08:09 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id y199-v6so7343609wmc.6
        for <linux-mm@kvack.org>; Thu, 04 Oct 2018 09:08:09 -0700 (PDT)
Received: from albireo.enyo.de (albireo.enyo.de. [5.158.152.32])
        by mx.google.com with ESMTPS id m66-v6si4192632wmm.192.2018.10.04.09.08.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 04 Oct 2018 09:08:07 -0700 (PDT)
From: Florian Weimer <fw@deneb.enyo.de>
Subject: Re: [RFC PATCH v4 6/9] x86/cet/ibt: Add arch_prctl functions for IBT
References: <20180921150553.21016-1-yu-cheng.yu@intel.com>
	<20180921150553.21016-7-yu-cheng.yu@intel.com>
	<20181004132811.GJ32759@asgard.redhat.com>
	<3350f7b42b32f3f7a1963a9c9c526210c24f7b05.camel@intel.com>
Date: Thu, 04 Oct 2018 18:07:47 +0200
In-Reply-To: <3350f7b42b32f3f7a1963a9c9c526210c24f7b05.camel@intel.com>
	(Yu-cheng Yu's message of "Thu, 04 Oct 2018 08:37:16 -0700")
Message-ID: <87murtn19o.fsf@mid.deneb.enyo.de>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: Eugene Syromiatnikov <esyr@redhat.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>, libc-alpha@sourceware.org, carlos@redhat.com

* Yu-cheng Yu:

> On Thu, 2018-10-04 at 15:28 +0200, Eugene Syromiatnikov wrote:
>> On Fri, Sep 21, 2018 at 08:05:50AM -0700, Yu-cheng Yu wrote:
>> > Update ARCH_CET_STATUS and ARCH_CET_DISABLE to include Indirect
>> > Branch Tracking features.
>> > 
>> > Introduce:
>> > 
>> > arch_prctl(ARCH_CET_LEGACY_BITMAP, unsigned long *addr)
>> >     Enable the Indirect Branch Tracking legacy code bitmap.
>> > 
>> >     The parameter 'addr' is a pointer to a user buffer.
>> >     On returning to the caller, the kernel fills the following:
>> > 
>> >     *addr = IBT bitmap base address
>> >     *(addr + 1) = IBT bitmap size
>> 
>> Again, some structure with a size field would be better from
>> UAPI/extensibility standpoint.
>> 
>> One additional point: "size" in the structure from kernel should have
>> structure size expected by kernel, and at least providing there "0" from
>> user space shouldn't lead to failure (in fact, it is possible to provide
>> structure size back to userspace even if buffer is too small, along
>> with error).
>
> This has been in GLIBC v2.28.  We cannot change it anymore.

In theory, you could, if you change the ARCH_CET_LEGACY_BITMAP
constant, so that glibc will not use the different arch_prctl
operation.  We could backport the change into the glibc 2.28 dynamic
linker, so that existing binaries will start using CET again.  Then
only statically linked binaries will be impacted.

It's definitely not ideal, but it's doable if the interface is
terminally broken or otherwise unacceptable.  But to me it looks like
this threshold isn't reached here.
