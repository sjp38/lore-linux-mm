Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 696BC6B0069
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 11:57:14 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 204so250748353pfx.1
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 08:57:14 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id a137si6317003pfa.221.2017.01.11.08.57.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jan 2017 08:57:13 -0800 (PST)
Subject: Re: [PATCH v4 0/4] Application Data Integrity feature introduced by
 SPARC M7
References: <cover.1483999591.git.khalid.aziz@oracle.com>
 <621cfed0-3e56-13e6-689a-0637bce164fe@linux.intel.com>
From: Khalid Aziz <khalid.aziz@oracle.com>
Message-ID: <f70cd704-f486-ed5c-7961-b71278fc8f9a@oracle.com>
Date: Wed, 11 Jan 2017 09:56:45 -0700
MIME-Version: 1.0
In-Reply-To: <621cfed0-3e56-13e6-689a-0637bce164fe@linux.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, davem@davemloft.net, corbet@lwn.net, arnd@arndb.de, akpm@linux-foundation.org
Cc: hpa@zytor.com, viro@zeniv.linux.org.uk, nitin.m.gupta@oracle.com, chris.hyser@oracle.com, tushar.n.dave@oracle.com, sowmini.varadhan@oracle.com, mike.kravetz@oracle.com, adam.buchbinder@gmail.com, minchan@kernel.org, hughd@google.com, kirill.shutemov@linux.intel.com, keescook@chromium.org, allen.pais@oracle.com, aryabinin@virtuozzo.com, atish.patra@oracle.com, joe@perches.com, pmladek@suse.com, jslaby@suse.cz, cmetcalf@mellanox.com, paul.gortmaker@windriver.com, mhocko@suse.com, jmarchan@redhat.com, lstoakes@gmail.com, 0x7f454c46@gmail.com, vbabka@suse.cz, tglx@linutronix.de, mingo@redhat.com, dan.j.williams@intel.com, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net, vdavydov.dev@gmail.com, hannes@cmpxchg.org, namit@vmware.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org

On 01/11/2017 09:33 AM, Dave Hansen wrote:
> On 01/11/2017 08:12 AM, Khalid Aziz wrote:
>> A userspace task enables ADI through mprotect(). This patch series adds
>> a page protection bit PROT_ADI and a corresponding VMA flag
>> VM_SPARC_ADI. VM_SPARC_ADI is used to trigger setting TTE.mcd bit in the
>> sparc pte that enables ADI checking on the corresponding page.
>
> Is there a cost in the hardware associated with doing this "ADI
> checking"?  For instance, instead of having this new mprotect()
> interface, why not just always set TTE.mcd on all PTEs?

There is no performance penalty in the MMU to check tags, but if 
PSTATE.mcd bit is set and TTE.mcde is set, the tag in VA must match what 
was set on the physical page for all memory accesses. Potential for side 
effects is too high in such case and would require kernel to either 
track tags for every page as they are re-allocated or migrated, or scrub 
pages constantly to ensure we do not get spurious tag mismatches. Unless 
there is a very strong reason to blindly set TTE.mcd on every PTE, I 
think the risk of instability is too high without lot of extra code.

>
> Also, should this be a privileged interface in some way?  The hardware
> is storing these tags *somewhere* and that storage is consuming
> resources *somewhere*.  What stops a crafty attacker from mmap()'ing a
> 128TB chunk of the zero pages and storing ADI tags for all of it?
> That'll be 128TB/64*4bits = 1TB worth of 4-bit tags.  Page tables, for
> instance, consume a comparable amount of storage, but the OS *knows*
> about those and can factor them into OOM decisions.

Hardware resources used to store tags are managed entirely by MMU and 
invisible to the kernel. Tags are stored in spare bits in memory. The 
only tag resource consumption visible to OS will be the space it 
allocates to store tags as pages are swapped in/out or migrated. If we 
choose to implement subpage granularity for tags in future, resource 
consumption will be a concern. You are right, each n pages of tagged 
memory requires n/128 pages to store tags. Since each tag is just 4 
bits, there are good possibilities to compress this data but that is for 
future.

Thanks,
Khalid

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
