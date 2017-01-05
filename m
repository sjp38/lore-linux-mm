Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4FE116B0261
	for <linux-mm@kvack.org>; Thu,  5 Jan 2017 15:30:45 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id f73so556857174ioe.1
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 12:30:45 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id q3si97574itq.0.2017.01.05.12.30.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Jan 2017 12:30:44 -0800 (PST)
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
 <75c31c99-cff7-72dc-f593-012fe5acd405@linux.intel.com>
From: Khalid Aziz <khalid.aziz@oracle.com>
Message-ID: <7fbc4ca1-22ef-8ef5-5c1b-dd075852e512@oracle.com>
Date: Thu, 5 Jan 2017 13:30:10 -0700
MIME-Version: 1.0
In-Reply-To: <75c31c99-cff7-72dc-f593-012fe5acd405@linux.intel.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, Rob Gardner <rob.gardner@oracle.com>, davem@davemloft.net, corbet@lwn.net, arnd@arndb.de, akpm@linux-foundation.org
Cc: hpa@zytor.com, viro@zeniv.linux.org.uk, nitin.m.gupta@oracle.com, chris.hyser@oracle.com, tushar.n.dave@oracle.com, sowmini.varadhan@oracle.com, mike.kravetz@oracle.com, adam.buchbinder@gmail.com, minchan@kernel.org, hughd@google.com, kirill.shutemov@linux.intel.com, keescook@chromium.org, allen.pais@oracle.com, aryabinin@virtuozzo.com, atish.patra@oracle.com, joe@perches.com, pmladek@suse.com, jslaby@suse.cz, cmetcalf@mellanox.com, paul.gortmaker@windriver.com, mhocko@suse.com, jmarchan@redhat.com, lstoakes@gmail.com, 0x7f454c46@gmail.com, vbabka@suse.cz, tglx@linutronix.de, mingo@redhat.com, dan.j.williams@intel.com, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net, vdavydov.dev@gmail.com, hannes@cmpxchg.org, namit@vmware.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org, Khalid Aziz <khalid@gonehiking.org>

On 01/05/2017 12:22 PM, Dave Hansen wrote:
> On 01/04/2017 04:26 PM, Khalid Aziz wrote:
> ...
>> No, we do not have space to stuff PAGE_SIZE/64 version tags in swap pte.
>> There is enough space for just one tag per page. DaveM had suggested
>> doing this since the usual case is for a task to set one tag per page
>> even though MMU does not require it. I have implemented this as first
>> pass to start a discussion and get feedback on whether rest of the
>> swapping implementation and other changes look right, hence the patch is
>> "RFC". If this all looks good, I can expand swapping support in a
>> subsequent patch or iteration of this patch to allocate space in
>> mm_context_t possibly to store per cacheline tags. I am open to any
>> other ideas on storing this larger number of version tags.
>
> FWIW, This is the kind of thing that would be really useful to point out
> to reviewers instead of requiring them to ferret it out of the code.  It
> has huge implications for how applications use this feature.

Hi Dave,

Thanks for taking the time to review this. I appreciate your patience. I 
will add more details.

>
> As for where to store the tags...  It's potentially a *lot* of data, so
> I think it'll be a pain any way you do it.
>
> If you, instead, can live with doing things on a PAGE_SIZE granularity
> like pkeys does, you could just store it in the VMA and have the kernel
> tag the data at the same time it zeroes the pages.

It is very tempting to restrict tags to PAGE_SIZE granularity since it 
makes code noticeably simpler and that is indeed going to be the 
majority of cases. Sooner or later somebody would want to use multiple 
tags per page though. There can be 128 4-bit tags per 8K page which 
requires 64 bytes of tag storage for each page. This can add up. What I 
am considering doing is store the tag in swp pte if I find only one tag 
on the page. A VMA can cover multiple pages and we have unused bits in 
swp pte. It makes more sense to store the tags in swp pte. If I find 
more than one tag on the page, I can allocate memory, attach it to a 
data structure in mm_context_t and store the tags there. I will need to 
use an rb tree or some other way to keep the data sorted to make it 
quick to retrieve the tags for one of the millions of pages a task might 
have. As I said, it gets complex trying to store tags per cacheline as 
opposed to per page :)

--
Khalid

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
