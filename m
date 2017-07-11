Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id C587C6810BE
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 15:33:14 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id f49so449033wrf.5
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 12:33:14 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id d42si126822wrd.85.2017.07.11.12.33.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jul 2017 12:33:13 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6BJSiKH048067
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 15:33:11 -0400
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com [32.97.110.150])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2bn0mvad1j-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 15:33:11 -0400
Received: from localhost
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Tue, 11 Jul 2017 13:33:10 -0600
Date: Tue, 11 Jul 2017 12:32:57 -0700
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [RFC v5 00/38] powerpc: Memory Protection Keys
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <1499289735-14220-1-git-send-email-linuxram@us.ibm.com>
 <20170711145246.GA11917@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170711145246.GA11917@dhcp22.suse.cz>
Message-Id: <20170711193257.GB5525@ram.oc3035372033.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com

On Tue, Jul 11, 2017 at 04:52:46PM +0200, Michal Hocko wrote:
> On Wed 05-07-17 14:21:37, Ram Pai wrote:
> > Memory protection keys enable applications to protect its
> > address space from inadvertent access or corruption from
> > itself.
> > 
> > The overall idea:
> > 
> >  A process allocates a   key  and associates it with
> >  an  address  range  within    its   address   space.
> >  The process  then  can  dynamically  set read/write 
> >  permissions on  the   key   without  involving  the 
> >  kernel. Any  code that  violates   the  permissions
> >  of  the address space; as defined by its associated
> >  key, will receive a segmentation fault.
> > 
> > This patch series enables the feature on PPC64 HPTE
> > platform.
> > 
> > ISA3.0 section 5.7.13 describes the detailed specifications.
> 
> Could you describe the highlevel design of this feature in the cover
> letter.

Yes it can be hard to understand without the big picture.  I will
provide the high level design and the rationale behind the patch split
towards the end.  Also I will have it in the cover letter for my next
revision of the patchset.


> I have tried to get some idea from the patchset but it was
> really far from trivial. Patches are not very well split up (many
> helpers are added without their users etc..). 

I see your point. Earlier, I had the patches split such a way that the
users of the helpers were in the same patch as that of the helper.
But then comments from others lead to the current split.

> 
> > 
> > Testing:
> > 	This patch series has passed all the protection key
> > 	tests available in  the selftests directory.
> > 	The tests are updated to work on both x86 and powerpc.
> > 
> > version v5:
> > 	(1) reverted back to the old design -- store the 
> > 	    key in the pte, instead of bypassing it.
> > 	    The v4 design slowed down the hash page path.
> 
> This surprised me a lot but I couldn't find the respective code. Why do
> you need to store anything in the pte? My understanding of PKEYs is that
> the setup and teardown should be very cheap and so no page tables have
> to updated. Or do I just misunderstand what you wrote here?

Ideally the MMU looks at the PTE for keys, in order to enforce
protection. This is the case with x86 and is the case with power9 Radix
page table. Hence the keys have to be programmed into the PTE.

However with HPT on power, these keys do not necessarily have to be
programmed into the PTE. We could bypass the Linux Page Table Entry(PTE)
and instead just program them into the Hash Page Table(HPTE), since
the MMU does not refer the PTE but refers the HPTE. The last version
of the page attempted to do that.   It worked as follows:

a) when a address range is requested to be associated with a key; by the
   application through key_mprotect() system call, the kernel
   stores that key in the vmas corresponding to that address
   range.

b) Whenever there is a hash page fault for that address, the fault
   handler reads the key from the VMA and programs the key into the
   HPTE. __hash_page() is the function that does that.

c) Once the hpte is programmed, the MMU can sense key violations and
   generate key-faults.

The problem is with step (b).  This step is really a very critical
path which is performance sensitive. We dont want to add any delays.
However if we want to access the key from the vma, we will have to
hold the vma semaphore, and that is a big NO-NO. As a result, this
design had to be dropped.



I reverted back to the old design i.e the design in v4 version. In this
version we do the following:

a) when a address range is requested to be associated with a key; by the
   application through key_mprotect() system call, the kernel
   stores that key in the vmas corresponding to that address
   range. Also the kernel programs the key into Linux PTE coresponding to all the
   pages associated with the address range.

b) Whenever there is a hash page fault for that address, the fault
   handler reads the key from the Linux PTE and programs the key into 
   the HPTE.

c) Once the HPTE is programmed, the MMU can sense key violations and
   generate key-faults.


Since step (b) in this case has easy access to the Linux PTE, and hence
to the key, it is fast to access it and program the HPTE. Thus we avoid
taking any performance hit on this critical path.

Hope this explains the rationale,


As promised here is the high level design:

(1) When a application associates a key with a address range,
    program the key in the Linux PTE.
    
(2) Program the key into HPTE, when a HPTE is allocated to back
    the Linux PTE.
    
(3) And finally when the MMU detects a key violation due to invalid
    user access, invoke the registered signal handler and provide it
    with the key number that got violated and the state of the key 
    register (AMR) at the time it faulted.


In order to accomplish (1) we need to free up 5 bits in the Linux PTE to
store the key. This is accomplished by patches 

powerpc: Free up four 64K PTE bits in 4K backed HPTE
powerpc: Free up four 64K PTE bits in 64K backed HPTE pages



The above two patches modify the way the HPTE slots are stored
in the PTE different various configurations. The details are abstracted
out into two helper functions introduced by the following two
patches.

powerpc: introduce pte_set_hash_slot() helper
powerpc: introduce pte_get_hash_gslot() helper


Now we go and modify all the code that can benefit by the
above abstraction. The following 5 patches handle that.

 powerpc: use helper functions in __hash_page_64K() for 64K PTE
 powerpc: use helper functions in __hash_page_huge() for 64K PTE
 powerpc: use helper functions in __hash_page_4K() for 64K PTE
 powerpc: use helper functions in __hash_page_4K() for 4K PTE
 powerpc: use helper functions in flush_hash_page()


Since we have modified the PTE format, it has to be correctly reflected
in the dump report provided through debugfs. the following patch does
it.
 powerpc: capture the PTE format changes in the dump pte report


Till now we have done nothing much other then prepared ourselves to
accomadate memory key bits in the PTE. The next set of patches do
the actual work.

The VMA stores the key value.  The x86 implementation needed
just 4bits in the VMA flags, since they support only 16keys.  But
PowerPC supports 32 keys, so we need one more bit. The following patch
does that.
 mm: introduce an additional vma bit for powerpc pkey


Also x86 does not allow one to create a key with execute-denied permission.
PowerPC can handle that. So we add the ability to
support such a feature if the arch can handle it. The following two
patch help towards that.
 mm: ability to disable execute permission on a key at creation
 x86: disallow pkey creation with PKEY_DISABLE_EXECUTE


We than introduce the ability to house-keep the protection keys. There
are 32 keys. We need to track; which keys are available, which keys are
allocated and which keys are reserved. All that is handled in the
following patch

powerpc: initial plumbing for key management


Before we introduce the pkey_alloc() and pkey_free() system calls, we 
need to implement infrastructure that can allocate and free the keys,
and can program the hardware registers correspondingly.
So the following patches enable that.

 powerpc: helper function to read,write AMR,IAMR,UAMOR registers
 powerpc: implementation for arch_set_user_pkey_access()
 powerpc: sys_pkey_alloc() and sys_pkey_free() system calls


The key state has to be stored and restored across context switches, since
each task has its own key state. the next patch helps towards that.

 powerpc: store and restore the pkey state across context switches


x86 implementation introduced the concept of execute-only key where a
key can be set aside with execute-only permissions and the kernel can
use the key to associate with address-spaces that are execute only. We
facilitate that requirement through the next patch

 powerpc: introduce execute-only pkey



At this point we are ready to support the key_mprotect() system call.
the following four patches accomplish that. These patches togather
handle programming the key into the pte bits. All the hard work
done to release some pte bits; in the initially patches,
are finally bearing fruits here.

  powerpc: ability to associate pkey to a vma
  powerpc: implementation for arch_override_mprotect_pkey()
  powerpc: map vma key-protection bits to pte key bits.
  powerpc: sys_pkey_mprotect() system call


Given that the PTE holds the key bits, we can copy them
bit into the HPTE, because that is where they should land eventually
for any key-faults to trigger. The following patch accomplishes that.

   powerpc: Program HPTE key protection bits


Side stepping a bit. We also need the ability for the kernel to validate
key violation when accessing user pages. things like copy_*_user().
So the following patches help towards that.

 powerpc: check key protection for user page access
 powerpc: helper to validate key-access permissions of a pte


Ok. back to the main theme. The key is programmed into the HPTE. 
the MMU is able to detect key violations and generate key faults. But
then the kernel has to be cognizant of the key faults or else it will
drop them. So the next few patches help towards that.

 powerpc: Handle exceptions caused by pkey violation
 powerpc: implementation for arch_vma_access_permitted()
 powerpc: Macro the mask used for checking DSI exception


Everything is in place now, just the final peice of informing user space
on key violation is missing. So the next set of patches accomplish that.

  powerpc: capture AMR register content on pkey violation
  powerpc: introduce get_pte_pkey() helper
  powerpc: capture the violated protection key on fault
  powerpc: Deliver SEGV signal on pkey violation


One missing piece. We need the ability to tell -- which key is associated
with each VMA my looking at the smaps. the following patch helps towards it.
  procfs: display the protection-key number associated with a vma


Well everything accomplished...but how do we know if everything is in place
and works as expected? The next set of patches modify the selftest, by first
moving them into arch-independent directory and then abstracting out
the arch-depended pieces, and finally adding some additional tests
to make it even more robust.

 selftest: Move protecton key selftest to arch neutral directory
 selftest: PowerPC specific test updates to memory protection keys


Nothing is complete without Documentation. and that is what the final
two patches accomplish. Again they move the documentation into
arch independent directory and explains the differences between
x86 and powerpc.

  Documentation: Move protecton key documentation to arch neutral directory
  Documentation: PowerPC specific updates to memory protection keys


Hope the above explanation helps.

NOTE: key support for power9 radix is not supported yet, but the above
design will make it easy to support it as and when the hardware is ready
to handle it.

Thanks for your valuable comments.
RP

> -- 
> Michal Hocko
> SUSE Labs

-- 
Ram Pai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
