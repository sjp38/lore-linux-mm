Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 671BE6B0069
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 14:11:59 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id f144so269275691pfa.3
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 11:11:59 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id r66si4300193pfg.195.2017.01.11.11.11.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jan 2017 11:11:58 -0800 (PST)
Subject: Re: [PATCH v4 0/4] Application Data Integrity feature introduced by
 SPARC M7
References: <cover.1483999591.git.khalid.aziz@oracle.com>
 <621cfed0-3e56-13e6-689a-0637bce164fe@linux.intel.com>
 <f70cd704-f486-ed5c-7961-b71278fc8f9a@oracle.com>
 <11d20dac-2c0f-6e9a-7f98-3839c749adb6@linux.intel.com>
 <4978715f-e5e8-824e-3804-597eaa0beb95@oracle.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <558ad70b-4b19-3a78-038a-b12dc7af8585@linux.intel.com>
Date: Wed, 11 Jan 2017 11:11:55 -0800
MIME-Version: 1.0
In-Reply-To: <4978715f-e5e8-824e-3804-597eaa0beb95@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Khalid Aziz <khalid.aziz@oracle.com>, davem@davemloft.net, corbet@lwn.net, arnd@arndb.de, akpm@linux-foundation.org
Cc: hpa@zytor.com, viro@zeniv.linux.org.uk, nitin.m.gupta@oracle.com, chris.hyser@oracle.com, tushar.n.dave@oracle.com, sowmini.varadhan@oracle.com, mike.kravetz@oracle.com, adam.buchbinder@gmail.com, minchan@kernel.org, hughd@google.com, kirill.shutemov@linux.intel.com, keescook@chromium.org, allen.pais@oracle.com, aryabinin@virtuozzo.com, atish.patra@oracle.com, joe@perches.com, pmladek@suse.com, jslaby@suse.cz, cmetcalf@mellanox.com, paul.gortmaker@windriver.com, mhocko@suse.com, jmarchan@redhat.com, lstoakes@gmail.com, 0x7f454c46@gmail.com, vbabka@suse.cz, tglx@linutronix.de, mingo@redhat.com, dan.j.williams@intel.com, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net, vdavydov.dev@gmail.com, hannes@cmpxchg.org, namit@vmware.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org

On 01/11/2017 10:50 AM, Khalid Aziz wrote:
> On 01/11/2017 11:13 AM, Dave Hansen wrote:
>> On 01/11/2017 08:56 AM, Khalid Aziz wrote:
>> For memory shared by two different processes, do they have to agree on
>> what the tags are, or can they differ?
> 
> The two processes have to agree on the tag. This is part of the security
> design to prevent other processes from accessing pages belonging to
> another process unless they know the tag set on those pages.

So what do you do with static data, say from a shared executable?  You
need to ensure that two different processes from two different privilege
domains can't set different tags on the same physical memory.  That
would seem to mean that you must not allow tags to be set of memory
unless you have write access to it.  Or, you have to ensure that any
file that you might want to use this feature on is entirely unreadable
(well, un-mmap()-able really) by anybody that you are not coordinating with.

If you want to use it on copy-on-write'able data, you've got to ensure
that you've got entirely private copies.  I'm not sure we even have an
interface to guarantee that.  How could this work after a fork() on
un-COW'd, but COW'able data?

>>> Potential for side
>>> effects is too high in such case and would require kernel to either
>>> track tags for every page as they are re-allocated or migrated, or scrub
>>> pages constantly to ensure we do not get spurious tag mismatches. Unless
>>> there is a very strong reason to blindly set TTE.mcd on every PTE, I
>>> think the risk of instability is too high without lot of extra code.
>>
>> Ahh, ok.  That makes sense.  Clearing the tags is expensive.  We must
>> either clear tags or know the previous tags of the memory before we
>> access it.
>>
>> Are any of the tags special?  Do any of them mean "don't do any
>> checking", or similar?
> 
> Tag values of 0 and 15 can be considered special. Setting tag to 15 on
> memory range is disallowed. Accessing a memory location whose tag is
> cleared (means set to 0) with any tag value in the VA is allowed. Once a
> tag is set on a memory, and PSTATE.mcde and TTE.mcd are set, there isn't
> a tag that can be used to bypass version check by MMU.

Bummer.  If the hardware had allowed a special VA tag to bypass checks,
then you wouldn't need to worry about clearing the tags, and you
wouldn't need the interface to control the PTE bit setting/clearing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
