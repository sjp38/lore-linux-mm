Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0484E6B026C
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 17:50:37 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id c23so11053356pfl.1
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 14:50:36 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id o12si13952419pgv.237.2017.11.22.14.50.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 14:50:36 -0800 (PST)
Subject: Re: [PATCH 08/30] x86, kaiser: unmap kernel from userspace page
 tables (core patch)
References: <20171110193058.BECA7D88@viggo.jf.intel.com>
 <20171110193112.6A962D6A@viggo.jf.intel.com>
 <alpine.DEB.2.20.1711201518490.1734@nanos>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <e4a82789-4a2d-ec58-1d14-fc7a2f77d4d2@linux.intel.com>
Date: Wed, 22 Nov 2017 14:50:32 -0800
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1711201518490.1734@nanos>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, richard.fellner@student.tugraz.at, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org

On 11/20/2017 09:21 AM, Thomas Gleixner wrote:
>> +}
>> +
>>  static inline void native_set_p4d(p4d_t *p4dp, p4d_t p4d)
>>  {
>> +#if defined(CONFIG_KAISER) && !defined(CONFIG_X86_5LEVEL)
>> +	/*
>> +	 * set_pgd() does not get called when we are running
>> +	 * CONFIG_X86_5LEVEL=y.  So, just hack around it.  We
>> +	 * know here that we have a p4d but that it is really at
>> +	 * the top level of the page tables; it is really just a
>> +	 * pgd.
>> +	 */
>> +	/* Do we need to also populate the shadow p4d? */
>> +	if (is_userspace_pgd(p4dp))
>> +		native_get_shadow_p4d(p4dp)->pgd = p4d.pgd;
> native_get_shadow_p4d() is kinda confusing, as it suggest that we get the
> entry not the pointer to it. native_get_shadow_p4d_ptr() is what it
> actually wants to be, but a setter e.g. native_set_shadow...(), we also
> have set_pgd() would be more obvious I think.

How about "kernel_to_shadow_pgdp()"? ... and friends

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
