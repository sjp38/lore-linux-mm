Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id A57E86B0038
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 09:49:09 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 204so130372197pfx.1
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 06:49:09 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id c19si12909344pgk.317.2017.01.13.06.49.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jan 2017 06:49:08 -0800 (PST)
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
 <b480fdcc-e08a-eea7-9bac-12bc236422c6@oracle.com>
 <b0a6341d-fb85-9f50-4803-304f3e28b4ab@linux.intel.com>
 <ae1662fa-4e51-d92d-7f19-403c92406194@oracle.com>
 <ee959bf4-73db-f9bb-c697-20b47dd8d55f@oracle.com>
From: Khalid Aziz <khalid.aziz@oracle.com>
Message-ID: <9aa6d94d-0a80-7397-5cd2-c04a39cbaf82@oracle.com>
Date: Fri, 13 Jan 2017 07:48:42 -0700
MIME-Version: 1.0
In-Reply-To: <ee959bf4-73db-f9bb-c697-20b47dd8d55f@oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rob Gardner <rob.gardner@oracle.com>, Dave Hansen <dave.hansen@linux.intel.com>, davem@davemloft.net, corbet@lwn.net, arnd@arndb.de, akpm@linux-foundation.org
Cc: hpa@zytor.com, viro@zeniv.linux.org.uk, nitin.m.gupta@oracle.com, chris.hyser@oracle.com, tushar.n.dave@oracle.com, sowmini.varadhan@oracle.com, mike.kravetz@oracle.com, adam.buchbinder@gmail.com, minchan@kernel.org, hughd@google.com, kirill.shutemov@linux.intel.com, keescook@chromium.org, allen.pais@oracle.com, aryabinin@virtuozzo.com, atish.patra@oracle.com, joe@perches.com, pmladek@suse.com, jslaby@suse.cz, cmetcalf@mellanox.com, paul.gortmaker@windriver.com, mhocko@suse.com, jmarchan@redhat.com, lstoakes@gmail.com, 0x7f454c46@gmail.com, vbabka@suse.cz, tglx@linutronix.de, mingo@redhat.com, dan.j.williams@intel.com, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net, vdavydov.dev@gmail.com, hannes@cmpxchg.org, namit@vmware.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org

On 01/12/2017 06:31 PM, Rob Gardner wrote:
> On 01/12/2017 05:22 PM, Khalid Aziz wrote:
>> On 01/12/2017 10:53 AM, Dave Hansen wrote:
>>> On 01/12/2017 08:50 AM, Khalid Aziz wrote:
>>>> 2. Any shared page that has ADI protection enabled on it, must stay ADI
>>>> protected across all processes sharing it.
>>>
>>> Is that true?
>>>
>>> What happens if a page with ADI tags set is accessed via a PTE without
>>> the ADI enablement bit set?
>>
>> ADI protection applies across all processes in terms of all of them
>> must use the same tag to access the shared memory, but if a process
>> accesses a shared page with TTE.mcde bit cleared, access will be granted.
>>
>>>
>>>> COW creates an intersection of the two. It creates a new copy of the
>>>> shared data. It is a new data page and hence the process creating it
>>>> must be the one responsible for enabling ADI protection on it.
>>>
>>> Do you mean that the application must be responsible?  Or the kernel
>>> running in the context of the new process must be responsible?
>>>
>>>> It is also a copy of what was ADI protected data, so should it
>>>> inherit the protection instead?
>>>
>>> I think the COW'd copy must inherit the VMA bit, the PTE bits, and the
>>> tags on the cachelines.
>>>
>>>> I misspoke earlier. I had misinterpreted the results of test I ran.
>>>> Changing the tag on shared memory is allowed by memory controller. The
>>>> requirement is every one sharing the page must switch to the new tag or
>>>> else they get SIGSEGV.
>>>
>>> I asked this in the last mail, but I guess I'll ask it again. Please
>>> answer this directly.
>>>
>>> If we require that everyone coordinate their tags on the backing
>>> physical memory, and we allow a lower-privileged program to access the
>>> same data as a more-privileged one, then the lower-privilege app can
>>> cause arbitrary crashes in the privileged application.
>>>
>>> For instance, say sudo mmap()'s /etc/passwd and uses ADI tags to protect
>>> the mapping.  Couldn't any other app in the system prevent sudo from
>>> working?
>>>
>>> How can we *EVER* allow tags to be set on non-writable mappings?
>
> I don't think you can write a tag to memory if you don't have write
> access in the TTE. Writing a tag requires a store instruction, and if
> the machine is at all sane, this will fault if you don't have write access.
>

But could you have mmap'd the file writable, set the tags and then 
changed the protection on memory to read-only? That would be the logical 
way to ADI protect a memory being used to mmap a file. Right?

--
Khalid

> Rob
>
>
>
>>
>> I understand your quetion better now. That is a very valid concern.
>> Using ADI tags to prevent an unauthorized process from just reading
>> data in memory, say an in-memory copy of database, is one of the use
>> cases for ADI. This means there is a reasonable case to allow enabling
>> ADI and setting tags even on non-writable mappings. On the other hand,
>> if an unauthorized process manages to map the right memory pages in
>> its address space, it can read them any way by not setting TTE.mcd.
>>
>> Userspace app can set tag on any memory it has mapped in without
>> requiring assistance from kernel. Can this problem be solved by not
>> allowing setting TTE.mcd on non-writable mappings? Doesn't the same
>> problem occur on writable mappings? If a privileged process mmap()'s a
>> writable file with MAP_SHARED, enables ADI and sets tag on the mmap'd
>> memory region, then another lower privilege process mmap's the same
>> file writable (assuming file permissions allow it to), enables ADI and
>> sets a different tag on it, the privileged process would get SIGSEGV
>> when it tries to access the mmap'd file. Right?
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe sparclinux" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
