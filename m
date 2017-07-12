Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3F190440874
	for <linux-mm@kvack.org>; Wed, 12 Jul 2017 18:54:17 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id q66so19081479qki.1
        for <linux-mm@kvack.org>; Wed, 12 Jul 2017 15:54:17 -0700 (PDT)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id x131si3560868qkb.217.2017.07.12.15.54.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 12 Jul 2017 15:54:16 -0700 (PDT)
Message-ID: <1499900032.2865.46.camel@kernel.crashing.org>
Subject: Re: [RFC v5 00/38] powerpc: Memory Protection Keys
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Thu, 13 Jul 2017 08:53:52 +1000
In-Reply-To: <20170712072337.GB28912@dhcp22.suse.cz>
References: <1499289735-14220-1-git-send-email-linuxram@us.ibm.com>
	 <20170711145246.GA11917@dhcp22.suse.cz>
	 <20170711193257.GB5525@ram.oc3035372033.ibm.com>
	 <20170712072337.GB28912@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Ram Pai <linuxram@us.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com

On Wed, 2017-07-12 at 09:23 +0200, Michal Hocko wrote:
> 
> > 
> > Ideally the MMU looks at the PTE for keys, in order to enforce
> > protection. This is the case with x86 and is the case with power9 Radix
> > page table. Hence the keys have to be programmed into the PTE.
> 
> But x86 doesn't update ptes for PKEYs, that would be just too expensive.
> You could use standard mprotect to do the same...

What do you mean ? x86 ends up in mprotect_fixup -> change_protection()
which will update the PTEs just the same as we do.

Changing the key for a page is a form mprotect. Changing the access
permissions for keys is different, for us it's a special register
(AMR).

I don't understand why you think we are doing any differently than x86
here.

> > However with HPT on power, these keys do not necessarily have to be
> > programmed into the PTE. We could bypass the Linux Page Table Entry(PTE)
> > and instead just program them into the Hash Page Table(HPTE), since
> > the MMU does not refer the PTE but refers the HPTE. The last version
> > of the page attempted to do that.   It worked as follows:
> > 
> > a) when a address range is requested to be associated with a key; by the
> >    application through key_mprotect() system call, the kernel
> >    stores that key in the vmas corresponding to that address
> >    range.
> > 
> > b) Whenever there is a hash page fault for that address, the fault
> >    handler reads the key from the VMA and programs the key into the
> >    HPTE. __hash_page() is the function that does that.
> 
> What causes the fault here?

The hardware. With the hash MMU, the HW walks a hash table which is
effectively a large in-memory TLB extension. When a page isn't found
there, a  "hash fault" is generated allowing Linux to populate that
hash table with the content of the corresponding PTE. 

> > c) Once the hpte is programmed, the MMU can sense key violations and
> >    generate key-faults.
> > 
> > The problem is with step (b).  This step is really a very critical
> > path which is performance sensitive. We dont want to add any delays.
> > However if we want to access the key from the vma, we will have to
> > hold the vma semaphore, and that is a big NO-NO. As a result, this
> > design had to be dropped.
> > 
> > 
> > 
> > I reverted back to the old design i.e the design in v4 version. In this
> > version we do the following:
> > 
> > a) when a address range is requested to be associated with a key; by the
> >    application through key_mprotect() system call, the kernel
> >    stores that key in the vmas corresponding to that address
> >    range. Also the kernel programs the key into Linux PTE coresponding to all the
> >    pages associated with the address range.
> 
> OK, so how is this any different from the regular mprotect then?

It takes the key argument. This is nothing new. This was done for x86
already, we are just re-using the infrastructure. Look at
do_mprotect_pkey() in mm/mprotect.c today. It's all the same code,
pkey_mprotect() is just mprotect with an added key argument.

> > b) Whenever there is a hash page fault for that address, the fault
> >    handler reads the key from the Linux PTE and programs the key into 
> >    the HPTE.
> > 
> > c) Once the HPTE is programmed, the MMU can sense key violations and
> >    generate key-faults.
> > 
> > 
> > Since step (b) in this case has easy access to the Linux PTE, and hence
> > to the key, it is fast to access it and program the HPTE. Thus we avoid
> > taking any performance hit on this critical path.
> > 
> > Hope this explains the rationale,
> > 
> > 
> > As promised here is the high level design:
> 
> I will read through that later
> [...]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
