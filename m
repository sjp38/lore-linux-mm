Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 182FE6B0033
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 11:51:09 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id l7so18284665qtd.2
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 08:51:09 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id z21si9768209pgi.50.2017.01.12.08.51.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jan 2017 08:51:08 -0800 (PST)
Subject: Re: [PATCH v4 0/4] Application Data Integrity feature introduced by
 SPARC M7
References: <cover.1483999591.git.khalid.aziz@oracle.com>
 <621cfed0-3e56-13e6-689a-0637bce164fe@linux.intel.com>
 <f70cd704-f486-ed5c-7961-b71278fc8f9a@oracle.com>
 <11d20dac-2c0f-6e9a-7f98-3839c749adb6@linux.intel.com>
 <4978715f-e5e8-824e-3804-597eaa0beb95@oracle.com>
 <558ad70b-4b19-3a78-038a-b12dc7af8585@linux.intel.com>
 <5d28f71e-1ad2-b2f9-1174-ea4eb6399d23@oracle.com>
 <a7ab2796-d777-df7b-2372-2d76f2906ead@linux.intel.com>
From: Khalid Aziz <khalid.aziz@oracle.com>
Message-ID: <b480fdcc-e08a-eea7-9bac-12bc236422c6@oracle.com>
Date: Thu, 12 Jan 2017 09:50:35 -0700
MIME-Version: 1.0
In-Reply-To: <a7ab2796-d777-df7b-2372-2d76f2906ead@linux.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, davem@davemloft.net, corbet@lwn.net, arnd@arndb.de, akpm@linux-foundation.org
Cc: hpa@zytor.com, viro@zeniv.linux.org.uk, nitin.m.gupta@oracle.com, chris.hyser@oracle.com, tushar.n.dave@oracle.com, sowmini.varadhan@oracle.com, mike.kravetz@oracle.com, adam.buchbinder@gmail.com, minchan@kernel.org, hughd@google.com, kirill.shutemov@linux.intel.com, keescook@chromium.org, allen.pais@oracle.com, aryabinin@virtuozzo.com, atish.patra@oracle.com, joe@perches.com, pmladek@suse.com, jslaby@suse.cz, cmetcalf@mellanox.com, paul.gortmaker@windriver.com, mhocko@suse.com, jmarchan@redhat.com, lstoakes@gmail.com, 0x7f454c46@gmail.com, vbabka@suse.cz, tglx@linutronix.de, mingo@redhat.com, dan.j.williams@intel.com, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net, vdavydov.dev@gmail.com, hannes@cmpxchg.org, namit@vmware.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org

On 01/11/2017 05:49 PM, Dave Hansen wrote:
> On 01/11/2017 04:22 PM, Khalid Aziz wrote:
> ...
>> All of the tag coordination can happen in userspace. Once a process sets
>> a tag on a physical page mapped in its address space, another process
>> that has mapped the same physical page in its address space can only set
>> the tag to exact same value. Attempts to set a different tag are caught
>> by memory controller and result in MCD trap and kernel sends SIGSEGV to
>> the process trying to set a different tag.
>
> Again, I don't think these semantics will work for anything other than
> explicitly shared memory.  This behavior ensures that it is *entirely*
> unsafe to use ADI on any data that any process you do not control might
> be able to mmap().  That's a *HUGE* caveat for the feature and can't
> imagine ever seeing this get merged without addressing it.
>
> I think it's fairly simple to address, though a bit expensive.  First,
> you can't allow the VMA bit to get set on non-writable mappings.
> Second, you'll have to force COW to occur on read-only pages in writable
> mappings before the PTE bit can get set.  I think you can probably even
> do this in the faults that presumably occur when you try to set ADI tags
> on memory mapped with non-ADI PTEs.

Hi Dave,

You have brought up an interesting scenario with COW pages. I had 
started out with the following policies regarding ADI that made sense:

1. New data pages do not get full ADI protection by default, i.e. 
TTE.mcd is not set and tags are not set on the new pages. A task that 
creates a new data page must make decision to protect these new pages or 
not.

2. Any shared page that has ADI protection enabled on it, must stay ADI 
protected across all processes sharing it.

COW creates an intersection of the two. It creates a new copy of the 
shared data. It is a new data page and hence the process creating it 
must be the one responsible for enabling ADI protection on it. It is 
also a copy of what was ADI protected data, so should it inherit the 
protection instead?

I misspoke earlier. I had misinterpreted the results of test I ran. 
Changing the tag on shared memory is allowed by memory controller. The 
requirement is every one sharing the page must switch to the new tag or 
else they get SIGSEGV.

I am inclined to suggest we copy the tags to the new data page on COW 
and that will continue to enforce ADI on the COW'd pages even though 
COW'd pages are new data pages. This is the logically consistent 
behavior. Does that make sense?

Thanks,
Khalid

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
