Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6E55C8E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 18:45:09 -0500 (EST)
Received: by mail-io1-f71.google.com with SMTP id q16so8781523ios.1
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 15:45:09 -0800 (PST)
Received: from mail.zytor.com (terminus.zytor.com. [198.137.202.136])
        by mx.google.com with ESMTPS id d11si1711408itc.14.2019.01.17.15.45.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 17 Jan 2019 15:45:08 -0800 (PST)
Subject: Re: [PATCH 17/17] module: Prevent module removal racing with
 text_poke()
References: <20190117003259.23141-1-rick.p.edgecombe@intel.com>
 <20190117003259.23141-18-rick.p.edgecombe@intel.com>
 <20190117165422.d33d1af83db8716e24960a3c@kernel.org>
 <B48C6E93-AD57-4FF8-BBE8-887A5E965793@vmware.com>
From: "H. Peter Anvin" <hpa@zytor.com>
Message-ID: <ab04ceec-0708-06df-a399-cb53fce41a37@zytor.com>
Date: Thu, 17 Jan 2019 15:44:48 -0800
MIME-Version: 1.0
In-Reply-To: <B48C6E93-AD57-4FF8-BBE8-887A5E965793@vmware.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <namit@vmware.com>, Masami Hiramatsu <mhiramat@kernel.org>
Cc: Rick Edgecombe <rick.p.edgecombe@intel.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Damian Tometzki <linux_dti@icloud.com>, linux-integrity <linux-integrity@vger.kernel.org>, LSM List <linux-security-module@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>, Linux-MM <linux-mm@kvack.org>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "kristen@linux.intel.com" <kristen@linux.intel.com>, "deneen.t.dock@intel.com" <deneen.t.dock@intel.com>

On 1/17/19 10:07 AM, Nadav Amit wrote:
>> On Jan 16, 2019, at 11:54 PM, Masami Hiramatsu <mhiramat@kernel.org> wrote:
>>
>> On Wed, 16 Jan 2019 16:32:59 -0800
>> Rick Edgecombe <rick.p.edgecombe@intel.com> wrote:
>>
>>> From: Nadav Amit <namit@vmware.com>
>>>
>>> It seems dangerous to allow code modifications to take place
>>> concurrently with module unloading. So take the text_mutex while the
>>> memory of the module is freed.
>>
>> At that point, since the module itself is removed from module list,
>> it seems no actual harm. Or would you have any concern?
> 
> So it appears that you are right and all the users of text_poke() and
> text_poke_bp() do install module notifiers, and remove the module from their
> internal data structure when they are done (*). As long as they prevent
> text_poke*() to be called concurrently (e.g., using jump_label_lock()),
> everything is fine.
> 
> Having said that, the question is whether you “trust” text_poke*() users to
> do so. text_poke() description does not day explicitly that you need to
> prevent modules from being removed.
> 
> What do you say?
> 

Please make it explicit.

	-hpa
