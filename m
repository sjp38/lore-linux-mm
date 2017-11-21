Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 159876B0038
	for <linux-mm@kvack.org>; Tue, 21 Nov 2017 17:09:08 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 26so12734614pfs.22
        for <linux-mm@kvack.org>; Tue, 21 Nov 2017 14:09:08 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id y8si12204806pli.714.2017.11.21.14.09.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Nov 2017 14:09:06 -0800 (PST)
Subject: Re: [PATCH 09/30] x86, kaiser: only populate shadow page tables for
 userspace
References: <20171110193058.BECA7D88@viggo.jf.intel.com>
 <20171110193113.E35BC3BF@viggo.jf.intel.com>
 <alpine.DEB.2.20.1711202057581.2348@nanos>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <7e458284-b334-bb70-a374-c65cc4ef9f02@linux.intel.com>
Date: Tue, 21 Nov 2017 14:09:03 -0800
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1711202057581.2348@nanos>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org

On 11/20/2017 12:12 PM, Thomas Gleixner wrote:
>> +			 */
>> +			native_get_shadow_pgd(pgdp)->pgd = pgd.pgd;
>> +			/*
>> +			 * For the copy of the pgd that the kernel
>> +			 * uses, make it unusable to userspace.  This
>> +			 * ensures if we get out to userspace with the
>> +			 * wrong CR3 value, userspace will crash
>> +			 * instead of running.
>> +			 */
>> +			pgd.pgd |= _PAGE_NX;
>> +		}
>> +	} else if (!pgd.pgd) {
>> +		/*
>> +		 * We are clearing the PGD and can not check  _PAGE_USER
>> +		 * in the zero'd PGD.
> 
> Just the argument cannot be checked because it's clearing the entry. The
> pgd entry itself is not yet modified, so it could be checked.

So, I guess we could enforce that only PGDs with _PAGE_USER set can ever
be cleared.  That has a nice symmetry to it because we set the shadow
when we see _PAGE_USER and we would then clear the shadow when we see
_PAGE_USER.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
