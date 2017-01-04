Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 303436B0069
	for <linux-mm@kvack.org>; Wed,  4 Jan 2017 18:27:37 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id b1so1440419281pgc.5
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 15:27:37 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id i9si53970429pgn.3.2017.01.04.15.27.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jan 2017 15:27:36 -0800 (PST)
Subject: Re: [RFC PATCH v3] sparc64: Add support for Application Data
 Integrity (ADI)
References: <1483569999-13543-1-git-send-email-khalid.aziz@oracle.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <6fcaab9f-40fb-fdfb-2c7e-bf21a862ab7c@linux.intel.com>
Date: Wed, 4 Jan 2017 15:27:35 -0800
MIME-Version: 1.0
In-Reply-To: <1483569999-13543-1-git-send-email-khalid.aziz@oracle.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Khalid Aziz <khalid.aziz@oracle.com>, davem@davemloft.net, corbet@lwn.net, arnd@arndb.de, akpm@linux-foundation.org
Cc: hpa@zytor.com, viro@zeniv.linux.org.uk, nitin.m.gupta@oracle.com, chris.hyser@oracle.com, tushar.n.dave@oracle.com, sowmini.varadhan@oracle.com, mike.kravetz@oracle.com, adam.buchbinder@gmail.com, minchan@kernel.org, hughd@google.com, kirill.shutemov@linux.intel.com, keescook@chromium.org, allen.pais@oracle.com, aryabinin@virtuozzo.com, atish.patra@oracle.com, joe@perches.com, pmladek@suse.com, jslaby@suse.cz, cmetcalf@mellanox.com, paul.gortmaker@windriver.com, mhocko@suse.com, jmarchan@redhat.com, lstoakes@gmail.com, 0x7f454c46@gmail.com, vbabka@suse.cz, tglx@linutronix.de, mingo@redhat.com, dan.j.williams@intel.com, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net, vdavydov.dev@gmail.com, hannes@cmpxchg.org, namit@vmware.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org, Khalid Aziz <khalid@gonehiking.org>

On 01/04/2017 02:46 PM, Khalid Aziz wrote:
> This patch extends mprotect to enable ADI (TSTATE.mcde), enable/disable
> MCD (Memory Corruption Detection) on selected memory ranges, enable
> TTE.mcd in PTEs, return ADI parameters to userspace and save/restore ADI
> version tags on page swap out/in. 

I'm a bit confused why we need all the mechanics with set_swp_pte_at().
For pkeys, for instance, all of the PTEs under a given VMA share a pkey.
 When swapping something in, we just get the pkey out of the VMA and
populate the PTE.

ADI doesn't seem to have a similar restriction.  The feature is turned
on or off at a VMA granularity, but we do not (or can enforce that all
pages under a given VMA must share a tag.

But this leads to an interesting question: is the tag associated with
the (populated?) pte, or the virtual address?  Can you have tags
associated with non-present addresses?  What's the mechanism that clears
the tags at munmap() or MADV_FREE time?

Is the tag storage a precious resource?  Can it be exhausted?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
