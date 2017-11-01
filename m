Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0BFCD6B0038
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 18:58:46 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id b79so3382897pfk.9
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 15:58:46 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id k8si1969814pgn.524.2017.11.01.15.58.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Nov 2017 15:58:45 -0700 (PDT)
Subject: Re: [PATCH 01/23] x86, kaiser: prepare assembly for entry/exit CR3
 switching
References: <20171031223146.6B47C861@viggo.jf.intel.com>
 <20171031223148.5334003A@viggo.jf.intel.com>
 <alpine.DEB.2.20.1711012155000.1942@nanos>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <1417af11-44fc-e14c-9cfa-5938a18605e1@linux.intel.com>
Date: Wed, 1 Nov 2017 15:58:43 -0700
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1711012155000.1942@nanos>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org, Borislav Petkov <bp@alien8.de>

On 11/01/2017 02:01 PM, Thomas Gleixner wrote:
> On Tue, 31 Oct 2017, Dave Hansen wrote:
>>  
>> +	pushq	%rdi
>> +	SWITCH_TO_KERNEL_CR3 scratch_reg=%rdi
>> +	popq	%rdi
> 
> Can you please have a macro variant which does:
> 
>     SWITCH_TO_KERNEL_CR3_PUSH reg=%rdi
> 
> So the pushq/popq is inside the macro. This has two reasons:
> 
>    1) If KAISER=n the pointless pushq/popq go away
> 
>    2) We need a boottime switch for that stuff, so we better have all
>       related code in the various macros in order to patch it in/out.

After Boris's comments, these push/pops are totally unnecessary.  We
just delay the CR3 until after we stashed off pt_regs and are allowed to
clobber things.

> Also, please wrap these macros in #ifdef KAISER right away and provide the
> stubs as well. It does not make sense to have them in patch 7 when patch 1
> introduces them.

Will do.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
