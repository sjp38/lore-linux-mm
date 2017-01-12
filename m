Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5A0A46B0033
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 19:22:37 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id f144so11380365pfa.3
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 16:22:37 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id x128si7315275pfd.87.2017.01.11.16.22.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jan 2017 16:22:36 -0800 (PST)
Subject: Re: [PATCH v4 0/4] Application Data Integrity feature introduced by
 SPARC M7
References: <cover.1483999591.git.khalid.aziz@oracle.com>
 <621cfed0-3e56-13e6-689a-0637bce164fe@linux.intel.com>
 <f70cd704-f486-ed5c-7961-b71278fc8f9a@oracle.com>
 <11d20dac-2c0f-6e9a-7f98-3839c749adb6@linux.intel.com>
 <4978715f-e5e8-824e-3804-597eaa0beb95@oracle.com>
 <558ad70b-4b19-3a78-038a-b12dc7af8585@linux.intel.com>
From: Khalid Aziz <khalid.aziz@oracle.com>
Message-ID: <5d28f71e-1ad2-b2f9-1174-ea4eb6399d23@oracle.com>
Date: Wed, 11 Jan 2017 17:22:06 -0700
MIME-Version: 1.0
In-Reply-To: <558ad70b-4b19-3a78-038a-b12dc7af8585@linux.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, davem@davemloft.net, corbet@lwn.net, arnd@arndb.de, akpm@linux-foundation.org
Cc: hpa@zytor.com, viro@zeniv.linux.org.uk, nitin.m.gupta@oracle.com, chris.hyser@oracle.com, tushar.n.dave@oracle.com, sowmini.varadhan@oracle.com, mike.kravetz@oracle.com, adam.buchbinder@gmail.com, minchan@kernel.org, hughd@google.com, kirill.shutemov@linux.intel.com, keescook@chromium.org, allen.pais@oracle.com, aryabinin@virtuozzo.com, atish.patra@oracle.com, joe@perches.com, pmladek@suse.com, jslaby@suse.cz, cmetcalf@mellanox.com, paul.gortmaker@windriver.com, mhocko@suse.com, jmarchan@redhat.com, lstoakes@gmail.com, 0x7f454c46@gmail.com, vbabka@suse.cz, tglx@linutronix.de, mingo@redhat.com, dan.j.williams@intel.com, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net, vdavydov.dev@gmail.com, hannes@cmpxchg.org, namit@vmware.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org

On 01/11/2017 12:11 PM, Dave Hansen wrote:
> On 01/11/2017 10:50 AM, Khalid Aziz wrote:
>> On 01/11/2017 11:13 AM, Dave Hansen wrote:
>>> On 01/11/2017 08:56 AM, Khalid Aziz wrote:
>>> For memory shared by two different processes, do they have to agree on
>>> what the tags are, or can they differ?
>>
>> The two processes have to agree on the tag. This is part of the security
>> design to prevent other processes from accessing pages belonging to
>> another process unless they know the tag set on those pages.
>
> So what do you do with static data, say from a shared executable?  You
> need to ensure that two different processes from two different privilege
> domains can't set different tags on the same physical memory.  That
> would seem to mean that you must not allow tags to be set of memory
> unless you have write access to it.  Or, you have to ensure that any
> file that you might want to use this feature on is entirely unreadable
> (well, un-mmap()-able really) by anybody that you are not coordinating with.

All of the tag coordination can happen in userspace. Once a process sets 
a tag on a physical page mapped in its address space, another process 
that has mapped the same physical page in its address space can only set 
the tag to exact same value. Attempts to set a different tag are caught 
by memory controller and result in MCD trap and kernel sends SIGSEGV to 
the process trying to set a different tag.

>
> If you want to use it on copy-on-write'able data, you've got to ensure
> that you've got entirely private copies.  I'm not sure we even have an
> interface to guarantee that.  How could this work after a fork() on
> un-COW'd, but COW'able data?

On COW, kernel maps the the source and destination pages with 
kmap_atomic() and copies the data over to the new page and the new page 
wouldn't be ADI protected unless the child process chooses to do so. 
This wouldn't change with ADI as far as private copies are concerned. 
Please do correct me if I get something wrong here. Quick tests with COW 
data show everything working as expected but your asking about COW has 
raised a few questions in my own mind. I am researching through docs and 
running experiments to validate my thinking and I will give you more 
definite information on whether COW would mess ADI up.

Thanks,
Khalid

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
