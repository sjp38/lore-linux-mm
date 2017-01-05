Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id D5B3C6B0069
	for <linux-mm@kvack.org>; Thu,  5 Jan 2017 14:22:41 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id a190so1411145611pgc.0
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 11:22:41 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id p61si76940988plb.159.2017.01.05.11.22.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Jan 2017 11:22:41 -0800 (PST)
From: Dave Hansen <dave.hansen@linux.intel.com>
Subject: Re: [RFC PATCH v3] sparc64: Add support for Application Data
 Integrity (ADI)
References: <1483569999-13543-1-git-send-email-khalid.aziz@oracle.com>
 <6fcaab9f-40fb-fdfb-2c7e-bf21a862ab7c@linux.intel.com>
 <ae0b7d0b-54fa-fa93-3b50-d14ace1b16f5@oracle.com>
 <d234fb8b-965f-d966-46fe-965478fdf7cb@linux.intel.com>
 <8612e7db-97c5-f757-0aae-24c3acedbc29@oracle.com>
 <2c0502d0-20ef-44ac-db5b-7f651a70b978@linux.intel.com>
 <ba9c4de2-cec1-1c88-82c9-24a524eb7948@oracle.com>
 <db31d324-a1ae-7450-0e54-ad98da205773@linux.intel.com>
 <5a0270ea-b29a-0751-a27f-2412a8588561@oracle.com>
 <7532a1d6-6562-b10b-dacd-931cb2a9e536@linux.intel.com>
 <92d55a69-b400-8461-53a1-d505de089700@oracle.com>
Message-ID: <75c31c99-cff7-72dc-f593-012fe5acd405@linux.intel.com>
Date: Thu, 5 Jan 2017 11:22:33 -0800
MIME-Version: 1.0
In-Reply-To: <92d55a69-b400-8461-53a1-d505de089700@oracle.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Khalid Aziz <khalid.aziz@oracle.com>, Rob Gardner <rob.gardner@oracle.com>, davem@davemloft.net, corbet@lwn.net, arnd@arndb.de, akpm@linux-foundation.org
Cc: hpa@zytor.com, viro@zeniv.linux.org.uk, nitin.m.gupta@oracle.com, chris.hyser@oracle.com, tushar.n.dave@oracle.com, sowmini.varadhan@oracle.com, mike.kravetz@oracle.com, adam.buchbinder@gmail.com, minchan@kernel.org, hughd@google.com, kirill.shutemov@linux.intel.com, keescook@chromium.org, allen.pais@oracle.com, aryabinin@virtuozzo.com, atish.patra@oracle.com, joe@perches.com, pmladek@suse.com, jslaby@suse.cz, cmetcalf@mellanox.com, paul.gortmaker@windriver.com, mhocko@suse.com, jmarchan@redhat.com, lstoakes@gmail.com, 0x7f454c46@gmail.com, vbabka@suse.cz, tglx@linutronix.de, mingo@redhat.com, dan.j.williams@intel.com, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net, vdavydov.dev@gmail.com, hannes@cmpxchg.org, namit@vmware.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org, Khalid Aziz <khalid@gonehiking.org>

On 01/04/2017 04:26 PM, Khalid Aziz wrote:
...
> No, we do not have space to stuff PAGE_SIZE/64 version tags in swap pte.
> There is enough space for just one tag per page. DaveM had suggested
> doing this since the usual case is for a task to set one tag per page
> even though MMU does not require it. I have implemented this as first
> pass to start a discussion and get feedback on whether rest of the
> swapping implementation and other changes look right, hence the patch is
> "RFC". If this all looks good, I can expand swapping support in a
> subsequent patch or iteration of this patch to allocate space in
> mm_context_t possibly to store per cacheline tags. I am open to any
> other ideas on storing this larger number of version tags.

FWIW, This is the kind of thing that would be really useful to point out
to reviewers instead of requiring them to ferret it out of the code.  It
has huge implications for how applications use this feature.

As for where to store the tags...  It's potentially a *lot* of data, so
I think it'll be a pain any way you do it.

If you, instead, can live with doing things on a PAGE_SIZE granularity
like pkeys does, you could just store it in the VMA and have the kernel
tag the data at the same time it zeroes the pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
