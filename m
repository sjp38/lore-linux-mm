Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7E5B66B0031
	for <linux-mm@kvack.org>; Wed,  9 Apr 2014 11:51:02 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id kq14so2683164pab.38
        for <linux-mm@kvack.org>; Wed, 09 Apr 2014 08:51:02 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id ha5si665056pbc.215.2014.04.09.08.51.01
        for <linux-mm@kvack.org>;
        Wed, 09 Apr 2014 08:51:01 -0700 (PDT)
Message-ID: <53456B61.1040901@intel.com>
Date: Wed, 09 Apr 2014 08:46:41 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH V2 1/2] mm: move FAULT_AROUND_ORDER to arch/
References: <1396592835-24767-1-git-send-email-maddy@linux.vnet.ibm.com> <1396592835-24767-2-git-send-email-maddy@linux.vnet.ibm.com> <533EDB63.8090909@intel.com> <5344A312.80802@linux.vnet.ibm.com>
In-Reply-To: <5344A312.80802@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Madhavan Srinivasan <maddy@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, kirill.shutemov@linux.intel.com, rusty@rustcorp.com.au, akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, ak@linux.intel.com, peterz@infradead.org, mingo@kernel.org

On 04/08/2014 06:32 PM, Madhavan Srinivasan wrote:
>> > In mm/Kconfig, put
>> > 
>> > 	config FAULT_AROUND_ORDER
>> > 		int
>> > 		default 1234 if POWERPC
>> > 		default 4
>> > 
>> > The way you have it now, every single architecture that needs to enable
>> > this has to go put that in their Kconfig.  That's madness.  This way,
> I though about it and decided not to do this way because, in future,
> sub platforms of the architecture may decide to change the values. Also,
> adding an if line for each architecture with different sub platforms
> oring to it will look messy.

I'm not sure why I'm trying here any more.  You do seem quite content to
add as much cruft to ppc and every other architecture as possible.  If
your theoretical scenario pops up, you simply do this in ppc:

config ARCH_FAULT_AROUND_ORDER
	int
	default 999
	default 888 if OTHER_SILLY_POWERPC_SUBARCH

But *ONLY* in the architectures that care about doing that stuff.  You
leave every other architecture on the planet alone.  Then, in mm/Kconfig:

config FAULT_AROUND_ORDER
	int
	default ARCH_FAULT_AROUND_ORDER if ARCH_FAULT_AROUND_ORDER
	default 4

Your way still requires going and individually touching every single
architecture's Kconfig that wants to enable fault around.  That's not an
acceptable solution.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
