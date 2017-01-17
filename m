Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 15CBB6B0033
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 23:47:56 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 75so111647898pgf.3
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 20:47:56 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [184.105.139.130])
        by mx.google.com with ESMTP id g12si23699278pln.18.2017.01.16.20.47.55
        for <linux-mm@kvack.org>;
        Mon, 16 Jan 2017 20:47:55 -0800 (PST)
Date: Mon, 16 Jan 2017 23:47:49 -0500 (EST)
Message-Id: <20170116.234749.545252655332977761.davem@davemloft.net>
Subject: Re: [PATCH v4 0/4] Application Data Integrity feature introduced
 by SPARC M7
From: David Miller <davem@davemloft.net>
In-Reply-To: <11d20dac-2c0f-6e9a-7f98-3839c749adb6@linux.intel.com>
References: <621cfed0-3e56-13e6-689a-0637bce164fe@linux.intel.com>
	<f70cd704-f486-ed5c-7961-b71278fc8f9a@oracle.com>
	<11d20dac-2c0f-6e9a-7f98-3839c749adb6@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave.hansen@linux.intel.com
Cc: khalid.aziz@oracle.com, corbet@lwn.net, arnd@arndb.de, akpm@linux-foundation.org, hpa@zytor.com, viro@zeniv.linux.org.uk, nitin.m.gupta@oracle.com, chris.hyser@oracle.com, tushar.n.dave@oracle.com, sowmini.varadhan@oracle.com, mike.kravetz@oracle.com, adam.buchbinder@gmail.com, minchan@kernel.org, hughd@google.com, kirill.shutemov@linux.intel.com, keescook@chromium.org, allen.pais@oracle.com, aryabinin@virtuozzo.com, atish.patra@oracle.com, joe@perches.com, pmladek@suse.com, jslaby@suse.cz, cmetcalf@mellanox.com, paul.gortmaker@windriver.com, mhocko@suse.com, jmarchan@redhat.com, lstoakes@gmail.com, 0x7f454c46@gmail.com, vbabka@suse.cz, tglx@linutronix.de, mingo@redhat.com, dan.j.williams@intel.com, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net, vdavydov.dev@gmail.com, hannes@cmpxchg.org, namit@vmware.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org

From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Wed, 11 Jan 2017 10:13:54 -0800

> For memory shared by two different processes, do they have to agree on
> what the tags are, or can they differ?

Whoever allocates the memory (does the mmap()+mprotect() or whatever),
decides on the tag.  They set it, and this determines which virtual
address is valid to access that mapping.

It's like kmalloc() returns pointers with some weird bits set in the
upper bits of the address.  Behind the scenes kmalloc() sets the
TAG bits appropriately.

It doesn't, in that sense, matter where in the non-tagged virtual
address space the memory is mapped.  All that matters is that, for
a given page, the TAG bits in the virtual address used for loads
and stores to that mapping are set properly.

I think the fundamental thing being missed is that the TAG bits in the
virtual address are not interpreted by the TLB.  They are chopped off
before virtual address translation occurs.

The TAG bits of the virtual address serve only to indicate what ADI
value the load or store thinks is valid to use for access to that
piece of memory.

Or something like that... :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
