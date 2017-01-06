Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 273446B0038
	for <linux-mm@kvack.org>; Fri,  6 Jan 2017 10:33:16 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id p127so576688005iop.5
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 07:33:16 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id v65si56075553iod.94.2017.01.06.07.33.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jan 2017 07:33:15 -0800 (PST)
Subject: Re: [RFC PATCH v3] sparc64: Add support for Application Data
 Integrity (ADI)
References: <d234fb8b-965f-d966-46fe-965478fdf7cb@linux.intel.com>
 <8612e7db-97c5-f757-0aae-24c3acedbc29@oracle.com>
 <2c0502d0-20ef-44ac-db5b-7f651a70b978@linux.intel.com>
 <ba9c4de2-cec1-1c88-82c9-24a524eb7948@oracle.com>
 <db31d324-a1ae-7450-0e54-ad98da205773@linux.intel.com>
 <5a0270ea-b29a-0751-a27f-2412a8588561@oracle.com>
 <7532a1d6-6562-b10b-dacd-931cb2a9e536@linux.intel.com>
 <92d55a69-b400-8461-53a1-d505de089700@oracle.com>
 <75c31c99-cff7-72dc-f593-012fe5acd405@linux.intel.com>
 <7fbc4ca1-22ef-8ef5-5c1b-dd075852e512@oracle.com>
 <20170106091934.GF5556@dhcp22.suse.cz>
From: Khalid Aziz <khalid.aziz@oracle.com>
Message-ID: <ac86aa55-964d-56a1-1381-c208de78b24e@oracle.com>
Date: Fri, 6 Jan 2017 08:32:43 -0700
MIME-Version: 1.0
In-Reply-To: <20170106091934.GF5556@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Rob Gardner <rob.gardner@oracle.com>, davem@davemloft.net, corbet@lwn.net, arnd@arndb.de, akpm@linux-foundation.org, hpa@zytor.com, viro@zeniv.linux.org.uk, nitin.m.gupta@oracle.com, chris.hyser@oracle.com, tushar.n.dave@oracle.com, sowmini.varadhan@oracle.com, mike.kravetz@oracle.com, adam.buchbinder@gmail.com, minchan@kernel.org, hughd@google.com, kirill.shutemov@linux.intel.com, keescook@chromium.org, allen.pais@oracle.com, aryabinin@virtuozzo.com, atish.patra@oracle.com, joe@perches.com, pmladek@suse.com, jslaby@suse.cz, cmetcalf@mellanox.com, paul.gortmaker@windriver.com, jmarchan@redhat.com, lstoakes@gmail.com, 0x7f454c46@gmail.com, vbabka@suse.cz, tglx@linutronix.de, mingo@redhat.com, dan.j.williams@intel.com, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net, vdavydov.dev@gmail.com, hannes@cmpxchg.org, namit@vmware.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org, Khalid Aziz <khalid@gonehiking.org>

On 01/06/2017 02:19 AM, Michal Hocko wrote:
> On Thu 05-01-17 13:30:10, Khalid Aziz wrote:
> [...]
>> It is very tempting to restrict tags to PAGE_SIZE granularity since it makes
>> code noticeably simpler and that is indeed going to be the majority of
>> cases. Sooner or later somebody would want to use multiple tags per page
>> though.
>
> I didn't get to read the patch throughly yet but I am really confused by
> this statement. The api is mprotect based which makes it ineherently
> PAGE_SIZE granular. How do you want to achieve cache line granularity
> with this API?
>
> And I would really vote for simplicity first... Subpage granularity
> sounds way too tricky...
>

Hi Michal,

ADI can be enabled for subsets of a task's address space. It takes three 
steps to enable ADI completely:

1. Enable the task to use ADI by setting PSTATE.mcde bit. This is the 
master switch for ADI. mprotect() does this in my patch. Granularity for 
this operation is entire address space for the task.

2. Set TTE.mcd bit for each page translation for the pages one wants ADI 
enabled on. mprotect() does this as well in my patch. Granularity for 
this operation is per page.

3. Set version tag for the addresses task wants to enable ADI on using 
"stxa" instruction. This is done entirely in userspace with no 
assistance or intervention needed from the kernel. Granularity for this 
operation is cache line size which is 64 bytes on Sparc M7.

I agree with you on simplicity first. Subpage granularity is complex, 
but the architecture allows for subpage granularity. Maybe the right 
approach is to support this at page granularity first for swappable 
pages and then expand to subpage granularity in a subsequent patch? 
Pages locked in memory can already use subpage granularity with my patch.

Thanks,
Khalid

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
