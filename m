Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id D679A440874
	for <linux-mm@kvack.org>; Thu, 13 Jul 2017 02:20:08 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id r123so2608772wmb.1
        for <linux-mm@kvack.org>; Wed, 12 Jul 2017 23:20:08 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 10si4317535wmt.41.2017.07.12.23.20.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 12 Jul 2017 23:20:07 -0700 (PDT)
Date: Thu, 13 Jul 2017 08:20:02 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC v5 00/38] powerpc: Memory Protection Keys
Message-ID: <20170713062002.GB14492@dhcp22.suse.cz>
References: <1499289735-14220-1-git-send-email-linuxram@us.ibm.com>
 <20170711145246.GA11917@dhcp22.suse.cz>
 <20170711193257.GB5525@ram.oc3035372033.ibm.com>
 <20170712072337.GB28912@dhcp22.suse.cz>
 <1499900032.2865.46.camel@kernel.crashing.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1499900032.2865.46.camel@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Ram Pai <linuxram@us.ibm.com>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com

On Thu 13-07-17 08:53:52, Benjamin Herrenschmidt wrote:
> On Wed, 2017-07-12 at 09:23 +0200, Michal Hocko wrote:
> > 
> > > 
> > > Ideally the MMU looks at the PTE for keys, in order to enforce
> > > protection. This is the case with x86 and is the case with power9 Radix
> > > page table. Hence the keys have to be programmed into the PTE.
> > 
> > But x86 doesn't update ptes for PKEYs, that would be just too expensive.
> > You could use standard mprotect to do the same...
> 
> What do you mean ? x86 ends up in mprotect_fixup -> change_protection()
> which will update the PTEs just the same as we do.
> 
> Changing the key for a page is a form mprotect. Changing the access
> permissions for keys is different, for us it's a special register
> (AMR).
> 
> I don't understand why you think we are doing any differently than x86
> here.

That was a misunderstanding on my side as explained in other reply.

> > > However with HPT on power, these keys do not necessarily have to be
> > > programmed into the PTE. We could bypass the Linux Page Table Entry(PTE)
> > > and instead just program them into the Hash Page Table(HPTE), since
> > > the MMU does not refer the PTE but refers the HPTE. The last version
> > > of the page attempted to do that.   It worked as follows:
> > > 
> > > a) when a address range is requested to be associated with a key; by the
> > >    application through key_mprotect() system call, the kernel
> > >    stores that key in the vmas corresponding to that address
> > >    range.
> > > 
> > > b) Whenever there is a hash page fault for that address, the fault
> > >    handler reads the key from the VMA and programs the key into the
> > >    HPTE. __hash_page() is the function that does that.
> > 
> > What causes the fault here?
> 
> The hardware. With the hash MMU, the HW walks a hash table which is
> effectively a large in-memory TLB extension. When a page isn't found
> there, a  "hash fault" is generated allowing Linux to populate that
> hash table with the content of the corresponding PTE. 

Thanks for the clarification
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
