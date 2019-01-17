Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id D12088E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 18:58:49 -0500 (EST)
Received: by mail-yb1-f200.google.com with SMTP id y6so4937543ybb.11
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 15:58:49 -0800 (PST)
Received: from mail.zytor.com (terminus.zytor.com. [198.137.202.136])
        by mx.google.com with ESMTPS id j124si2117634ywf.336.2019.01.17.15.58.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 17 Jan 2019 15:58:46 -0800 (PST)
Subject: Re: [PATCH 17/17] module: Prevent module removal racing with
 text_poke()
References: <20190117003259.23141-1-rick.p.edgecombe@intel.com>
 <20190117003259.23141-18-rick.p.edgecombe@intel.com>
 <20190117165422.d33d1af83db8716e24960a3c@kernel.org>
From: "H. Peter Anvin" <hpa@zytor.com>
Message-ID: <e865e051-be79-adce-7275-72abf2173bdb@zytor.com>
Date: Thu, 17 Jan 2019 15:58:31 -0800
MIME-Version: 1.0
In-Reply-To: <20190117165422.d33d1af83db8716e24960a3c@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Masami Hiramatsu <mhiramat@kernel.org>, Rick Edgecombe <rick.p.edgecombe@intel.com>
Cc: Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, Nadav Amit <nadav.amit@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, linux_dti@icloud.com, linux-integrity@vger.kernel.org, linux-security-module@vger.kernel.org, akpm@linux-foundation.org, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, will.deacon@arm.com, ard.biesheuvel@linaro.org, kristen@linux.intel.com, deneen.t.dock@intel.com, Nadav Amit <namit@vmware.com>

On 1/16/19 11:54 PM, Masami Hiramatsu wrote:
> On Wed, 16 Jan 2019 16:32:59 -0800
> Rick Edgecombe <rick.p.edgecombe@intel.com> wrote:
> 
>> From: Nadav Amit <namit@vmware.com>
>>
>> It seems dangerous to allow code modifications to take place
>> concurrently with module unloading. So take the text_mutex while the
>> memory of the module is freed.
> 
> At that point, since the module itself is removed from module list,
> it seems no actual harm. Or would you have any concern?
> 

The issue isn't the module list, but rather when it is safe to free the
contents, so we don't clobber anything. We absolutely need to enforce
that we can't text_poke() something that might have already been freed.

That being said, we *also* really would prefer to enforce that we can't
text_poke() memory that doesn't actually contain code; as far as I can
tell we don't currently do that check.

This, again, is a good use for a separate mm context. We can enforce
that that context will only ever contain valid page mappings for actual
code pages.

(Note: in my proposed algorithm, with a separate mm, replace INVLPG with
switching CR3 if we have to do a rollback or roll forward in the
breakpoint handler.)

	-hpa
