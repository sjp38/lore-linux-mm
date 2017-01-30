Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id BE2A96B0260
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 17:15:36 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id y143so471380089pfb.6
        for <linux-mm@kvack.org>; Mon, 30 Jan 2017 14:15:36 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [184.105.139.130])
        by mx.google.com with ESMTP id e5si9520407pgd.111.2017.01.30.14.15.35
        for <linux-mm@kvack.org>;
        Mon, 30 Jan 2017 14:15:35 -0800 (PST)
Date: Mon, 30 Jan 2017 17:15:31 -0500 (EST)
Message-Id: <20170130.171531.1973857503703372714.davem@davemloft.net>
Subject: Re: [PATCH v5 4/4] sparc64: Add support for ADI (Application Data
 Integrity)
From: David Miller <davem@davemloft.net>
In-Reply-To: <0b6865aabc010ee3a7ea956a70447abbab53ea70.1485362562.git.khalid.aziz@oracle.com>
References: <cover.1485362562.git.khalid.aziz@oracle.com>
	<cover.1485362562.git.khalid.aziz@oracle.com>
	<0b6865aabc010ee3a7ea956a70447abbab53ea70.1485362562.git.khalid.aziz@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: khalid.aziz@oracle.com
Cc: corbet@lwn.net, viro@zeniv.linux.org.uk, nitin.m.gupta@oracle.com, mike.kravetz@oracle.com, akpm@linux-foundation.org, mingo@kernel.org, kirill.shutemov@linux.intel.com, adam.buchbinder@gmail.com, hughd@google.com, minchan@kernel.org, keescook@chromium.org, chris.hyser@oracle.com, atish.patra@oracle.com, cmetcalf@mellanox.com, atomlin@redhat.com, jslaby@suse.cz, joe@perches.com, paul.gortmaker@windriver.com, mhocko@suse.com, lstoakes@gmail.com, jack@suse.cz, dave.hansen@linux.intel.com, vbabka@suse.cz, dan.j.williams@intel.com, iamjoonsoo.kim@lge.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, khalid@gonehiking.org

From: Khalid Aziz <khalid.aziz@oracle.com>
Date: Wed, 25 Jan 2017 12:57:16 -0700

> +static inline void enable_adi(void)
> +{
 ...
> +	__asm__ __volatile__(
> +		"rdpr %%pstate, %%g1\n\t"
> +		"or %%g1, %0, %%g1\n\t"
> +		"wrpr %%g1, %%g0, %%pstate\n\t"
> +		".word 0x83438000\n\t"	/* rd %mcdper, %g1 */
> +		".word 0xaf900001\n\t"	/* wrpr  %g0, %g1, %pmcdper */
> +		:
> +		: "i" (PSTATE_MCDE)
> +		: "g1");
> +}

This is _crazy_ expensive.

This is 4 privileged register operations, every single one incurs a full
pipline flush and virtual cpu thread yield.

And we do this around _every_ single userspace access from the kernel
when the thread has ADI enabled.

I think if the kernel manages the ADI metadata properly, you can get rid
of all of this.

On etrap, you change ESTATE_PSTATE{1,2} to have the MCDE bit enabled.
Then the kernel always runs with ADI enabled.

Furthermore, since the %mcdper register should be set to whatever the
current task has asked for, you should be able to avoid touching it
as well assuming that traps do not change %mcdper's value.

Then you don't need to do anything special during userspace accesses
which seems to be the way this was designed to be used.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
