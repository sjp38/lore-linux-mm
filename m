Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 417096B026D
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 18:24:06 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id g6so3745145pgn.11
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 15:24:06 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id y72si637911plh.13.2017.11.01.15.24.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Nov 2017 15:24:05 -0700 (PDT)
Subject: Re: [PATCH 04/23] x86, tlb: make CR4-based TLB flushes more robust
References: <20171031223146.6B47C861@viggo.jf.intel.com>
 <20171031223154.67F15B2A@viggo.jf.intel.com>
 <alpine.DEB.2.20.1711012222330.1942@nanos>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <d7db2bfd-e251-606f-a42f-55c9ef1aca55@linux.intel.com>
Date: Wed, 1 Nov 2017 15:24:03 -0700
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1711012222330.1942@nanos>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org

On 11/01/2017 02:25 PM, Thomas Gleixner wrote:
>>  	cr4 = this_cpu_read(cpu_tlbstate.cr4);
>> -	/* clear PGE */
>> -	native_write_cr4(cr4 & ~X86_CR4_PGE);
>> -	/* write old PGE again and flush TLBs */
>> +	/*
>> +	 * This function is only called on systems that support X86_CR4_PGE
>> +	 * and where always set X86_CR4_PGE.  Warn if we are called without
>> +	 * PGE set.
>> +	 */
>> +	WARN_ON_ONCE(!(cr4 & X86_CR4_PGE));
> Because if CR4_PGE is not set, this warning triggers. So this defeats the
> toggle mode you are implementing.

The warning is there because there is probably plenty of *other* stuff
that breaks if we have X86_FEATURE_PGE=1, but CR4.PGE=0.

The point of this was to make this function do the right thing no matter
what, but warn if it gets called in an unexpected way.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
