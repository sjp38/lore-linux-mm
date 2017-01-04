Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 680D26B0069
	for <linux-mm@kvack.org>; Wed,  4 Jan 2017 18:44:02 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id c20so369775641itb.5
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 15:44:02 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id j132si51078372ioj.234.2017.01.04.15.44.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jan 2017 15:44:01 -0800 (PST)
Subject: Re: [RFC PATCH v3] sparc64: Add support for Application Data
 Integrity (ADI)
References: <1483569999-13543-1-git-send-email-khalid.aziz@oracle.com>
 <6fcaab9f-40fb-fdfb-2c7e-bf21a862ab7c@linux.intel.com>
From: Khalid Aziz <khalid.aziz@oracle.com>
Message-ID: <c3e2f4c6-5a3d-a34b-0648-b4885bc8dd1e@oracle.com>
Date: Wed, 4 Jan 2017 16:43:36 -0700
MIME-Version: 1.0
In-Reply-To: <6fcaab9f-40fb-fdfb-2c7e-bf21a862ab7c@linux.intel.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, davem@davemloft.net, corbet@lwn.net, arnd@arndb.de, akpm@linux-foundation.org
Cc: hpa@zytor.com, viro@zeniv.linux.org.uk, nitin.m.gupta@oracle.com, chris.hyser@oracle.com, tushar.n.dave@oracle.com, sowmini.varadhan@oracle.com, mike.kravetz@oracle.com, adam.buchbinder@gmail.com, minchan@kernel.org, hughd@google.com, kirill.shutemov@linux.intel.com, keescook@chromium.org, allen.pais@oracle.com, aryabinin@virtuozzo.com, atish.patra@oracle.com, joe@perches.com, pmladek@suse.com, jslaby@suse.cz, cmetcalf@mellanox.com, paul.gortmaker@windriver.com, mhocko@suse.com, jmarchan@redhat.com, lstoakes@gmail.com, 0x7f454c46@gmail.com, vbabka@suse.cz, tglx@linutronix.de, mingo@redhat.com, dan.j.williams@intel.com, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net, vdavydov.dev@gmail.com, hannes@cmpxchg.org, namit@vmware.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org, Khalid Aziz <khalid@gonehiking.org>

On 01/04/2017 04:27 PM, Dave Hansen wrote:
> On 01/04/2017 02:46 PM, Khalid Aziz wrote:
>> This patch extends mprotect to enable ADI (TSTATE.mcde), enable/disable
>> MCD (Memory Corruption Detection) on selected memory ranges, enable
>> TTE.mcd in PTEs, return ADI parameters to userspace and save/restore ADI
>> version tags on page swap out/in.
>
> I'm a bit confused why we need all the mechanics with set_swp_pte_at().
> For pkeys, for instance, all of the PTEs under a given VMA share a pkey.
>  When swapping something in, we just get the pkey out of the VMA and
> populate the PTE.
>
> ADI doesn't seem to have a similar restriction.  The feature is turned
> on or off at a VMA granularity, but we do not (or can enforce that all
> pages under a given VMA must share a tag.
>
> But this leads to an interesting question: is the tag associated with
> the (populated?) pte, or the virtual address?  Can you have tags
> associated with non-present addresses?  What's the mechanism that clears
> the tags at munmap() or MADV_FREE time?

Hi Dave,

Tag is associated with virtual address and all pages in a singular VMA 
do not share the same tag. When a page is swapped out, we need to save 
the tag that was set on it so we can restore it when we bring the page 
back in. When MMU translates a vitrtual address into physical address, 
it expects to see the same tag set on the physical page as is set in the 
VA before it will allow access. Tags are cleared on a page by 
NG4clear_page() and NG4clear_user_page() when a page is allocated to a task.

>
> Is the tag storage a precious resource?  Can it be exhausted?

There is a metadata area in RAM that stores the tags and it has enough 
space to cover all the tags for the RAM size.

--
Khalid

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
