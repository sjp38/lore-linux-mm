Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id A88126B0253
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 19:49:08 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id f144so12850038pfa.3
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 16:49:08 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id f17si7374882pgj.23.2017.01.11.16.49.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jan 2017 16:49:07 -0800 (PST)
Subject: Re: [PATCH v4 0/4] Application Data Integrity feature introduced by
 SPARC M7
References: <cover.1483999591.git.khalid.aziz@oracle.com>
 <621cfed0-3e56-13e6-689a-0637bce164fe@linux.intel.com>
 <f70cd704-f486-ed5c-7961-b71278fc8f9a@oracle.com>
 <11d20dac-2c0f-6e9a-7f98-3839c749adb6@linux.intel.com>
 <4978715f-e5e8-824e-3804-597eaa0beb95@oracle.com>
 <558ad70b-4b19-3a78-038a-b12dc7af8585@linux.intel.com>
 <5d28f71e-1ad2-b2f9-1174-ea4eb6399d23@oracle.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <a7ab2796-d777-df7b-2372-2d76f2906ead@linux.intel.com>
Date: Wed, 11 Jan 2017 16:49:05 -0800
MIME-Version: 1.0
In-Reply-To: <5d28f71e-1ad2-b2f9-1174-ea4eb6399d23@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Khalid Aziz <khalid.aziz@oracle.com>, davem@davemloft.net, corbet@lwn.net, arnd@arndb.de, akpm@linux-foundation.org
Cc: hpa@zytor.com, viro@zeniv.linux.org.uk, nitin.m.gupta@oracle.com, chris.hyser@oracle.com, tushar.n.dave@oracle.com, sowmini.varadhan@oracle.com, mike.kravetz@oracle.com, adam.buchbinder@gmail.com, minchan@kernel.org, hughd@google.com, kirill.shutemov@linux.intel.com, keescook@chromium.org, allen.pais@oracle.com, aryabinin@virtuozzo.com, atish.patra@oracle.com, joe@perches.com, pmladek@suse.com, jslaby@suse.cz, cmetcalf@mellanox.com, paul.gortmaker@windriver.com, mhocko@suse.com, jmarchan@redhat.com, lstoakes@gmail.com, 0x7f454c46@gmail.com, vbabka@suse.cz, tglx@linutronix.de, mingo@redhat.com, dan.j.williams@intel.com, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net, vdavydov.dev@gmail.com, hannes@cmpxchg.org, namit@vmware.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org

On 01/11/2017 04:22 PM, Khalid Aziz wrote:
...
> All of the tag coordination can happen in userspace. Once a process sets
> a tag on a physical page mapped in its address space, another process
> that has mapped the same physical page in its address space can only set
> the tag to exact same value. Attempts to set a different tag are caught
> by memory controller and result in MCD trap and kernel sends SIGSEGV to
> the process trying to set a different tag.

Again, I don't think these semantics will work for anything other than
explicitly shared memory.  This behavior ensures that it is *entirely*
unsafe to use ADI on any data that any process you do not control might
be able to mmap().  That's a *HUGE* caveat for the feature and can't
imagine ever seeing this get merged without addressing it.

I think it's fairly simple to address, though a bit expensive.  First,
you can't allow the VMA bit to get set on non-writable mappings.
Second, you'll have to force COW to occur on read-only pages in writable
mappings before the PTE bit can get set.  I think you can probably even
do this in the faults that presumably occur when you try to set ADI tags
on memory mapped with non-ADI PTEs.

>> If you want to use it on copy-on-write'able data, you've got to ensure
>> that you've got entirely private copies.  I'm not sure we even have an
>> interface to guarantee that.  How could this work after a fork() on
>> un-COW'd, but COW'able data?
> 
> On COW, kernel maps the the source and destination pages with
> kmap_atomic() and copies the data over to the new page and the new page
> wouldn't be ADI protected unless the child process chooses to do so.

What do you mean by "ADI protection"?

I think of ADI _protection_ as coming from the PTE and/or VMA bits.
Those are copied at fork() from the old VMA to the new one.  Is there a
reason the child won't implicitly inherit these that I missed?

Whether the parent or the child does the COW fault is basically random.
Whether they get the ADI-tagged page, or the non-ADI-tagged copy is thus
effectively random.  Assuming that the new page has its tags cleared
(and thus is tagged not to be protected), whether your data continues to
be protected or not after a fork() is random.

That doesn't seem like workable behavior.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
