Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4DD3A6B0038
	for <linux-mm@kvack.org>; Wed,  1 Feb 2017 12:18:38 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 75so494655692pgf.3
        for <linux-mm@kvack.org>; Wed, 01 Feb 2017 09:18:38 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [184.105.139.130])
        by mx.google.com with ESMTP id y6si14903592pgo.299.2017.02.01.09.18.36
        for <linux-mm@kvack.org>;
        Wed, 01 Feb 2017 09:18:37 -0800 (PST)
Date: Wed, 01 Feb 2017 12:18:32 -0500 (EST)
Message-Id: <20170201.121832.1810577893703014061.davem@davemloft.net>
Subject: Re: [PATCH v5 4/4] sparc64: Add support for ADI (Application Data
 Integrity)
From: David Miller <davem@davemloft.net>
In-Reply-To: <6c514e7e-338a-f1cd-140d-d4980ea6ac0f@oracle.com>
References: <0b6865aabc010ee3a7ea956a70447abbab53ea70.1485362562.git.khalid.aziz@oracle.com>
	<20170130.171531.1973857503703372714.davem@davemloft.net>
	<6c514e7e-338a-f1cd-140d-d4980ea6ac0f@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: khalid.aziz@oracle.com
Cc: corbet@lwn.net, viro@zeniv.linux.org.uk, nitin.m.gupta@oracle.com, mike.kravetz@oracle.com, akpm@linux-foundation.org, mingo@kernel.org, kirill.shutemov@linux.intel.com, adam.buchbinder@gmail.com, hughd@google.com, minchan@kernel.org, keescook@chromium.org, chris.hyser@oracle.com, atish.patra@oracle.com, cmetcalf@mellanox.com, atomlin@redhat.com, jslaby@suse.cz, joe@perches.com, paul.gortmaker@windriver.com, mhocko@suse.com, lstoakes@gmail.com, jack@suse.cz, dave.hansen@linux.intel.com, vbabka@suse.cz, dan.j.williams@intel.com, iamjoonsoo.kim@lge.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, khalid@gonehiking.org

From: Khalid Aziz <khalid.aziz@oracle.com>
Date: Tue, 31 Jan 2017 16:38:49 -0700

> Thanks for the feedback. This is very helpful. I checked and it indeed
> can cost 50+ cycles even on M7 processor for PSTATE accesses.

Consider how many bytes can be copied in 50+ cycles :-)

>> On etrap, you change ESTATE_PSTATE{1,2} to have the MCDE bit enabled.
>> Then the kernel always runs with ADI enabled.
> 
> Running the kernel with PSTATE.mcde=1 can possibly be problematic as
> we had discussed earlier in this thread where keeping PSTATE.mcde
> enabled might mean kernel having to keep track of which pages still
> have tags set on them or flush tags on every page on free. I will go
> through the code again to see if it PSTATE.mcde can be turned on in
> kernel all the time, which might be the case if we can ensure kernel
> accesses pages with TTE.mcd cleared.

If we can clear the tags properly on page release when the page was
used for ADI, it can work.

One way would be to track the state in the page struct somehow, and
in arch_alloc_page() clear the tags if necessary.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
