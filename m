Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6AD368E0002
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 03:23:41 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id y2so7734439plr.8
        for <linux-mm@kvack.org>; Fri, 18 Jan 2019 00:23:41 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id r11si4143780pli.175.2019.01.18.00.23.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Jan 2019 00:23:40 -0800 (PST)
Date: Fri, 18 Jan 2019 17:23:34 +0900
From: Masami Hiramatsu <mhiramat@kernel.org>
Subject: Re: [PATCH 17/17] module: Prevent module removal racing with
 text_poke()
Message-Id: <20190118172334.d7b1bcd580c3f6c4ed388160@kernel.org>
In-Reply-To: <B48C6E93-AD57-4FF8-BBE8-887A5E965793@vmware.com>
References: <20190117003259.23141-1-rick.p.edgecombe@intel.com>
	<20190117003259.23141-18-rick.p.edgecombe@intel.com>
	<20190117165422.d33d1af83db8716e24960a3c@kernel.org>
	<B48C6E93-AD57-4FF8-BBE8-887A5E965793@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <namit@vmware.com>
Cc: Rick Edgecombe <rick.p.edgecombe@intel.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, the arch/x86 maintainers <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Damian Tometzki <linux_dti@icloud.com>, linux-integrity <linux-integrity@vger.kernel.org>, LSM List <linux-security-module@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>, Linux-MM <linux-mm@kvack.org>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "kristen@linux.intel.com" <kristen@linux.intel.com>, "deneen.t.dock@intel.com" <deneen.t.dock@intel.com>

On Thu, 17 Jan 2019 18:07:03 +0000
Nadav Amit <namit@vmware.com> wrote:

> > On Jan 16, 2019, at 11:54 PM, Masami Hiramatsu <mhiramat@kernel.org> wrote:
> > 
> > On Wed, 16 Jan 2019 16:32:59 -0800
> > Rick Edgecombe <rick.p.edgecombe@intel.com> wrote:
> > 
> >> From: Nadav Amit <namit@vmware.com>
> >> 
> >> It seems dangerous to allow code modifications to take place
> >> concurrently with module unloading. So take the text_mutex while the
> >> memory of the module is freed.
> > 
> > At that point, since the module itself is removed from module list,
> > it seems no actual harm. Or would you have any concern?
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

I agreed, but in that case, this is just a fool proof. I think we should
prevent this kind of bug by review, and should comment it on text_poke(),
instead of locking text_mutex.

What I thought was even if we take text_mutex here, such user can modify
the (released) module code right after we exit this section.

Maybe we'd better make text_poke() more smart?

> (*) I am not sure about kgdb, but it probably does not matter much

I think we don't need to care about kgdb. It is a tool which should be able
to shoot your feet and we can not prevent it. Only expert can avoid it. :)

Thank you,

-- 
Masami Hiramatsu <mhiramat@kernel.org>
