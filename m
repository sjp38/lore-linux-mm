Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 57602440856
	for <linux-mm@kvack.org>; Wed, 12 Jul 2017 03:23:43 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id g46so3440287wrd.3
        for <linux-mm@kvack.org>; Wed, 12 Jul 2017 00:23:43 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 189si1472252wmy.138.2017.07.12.00.23.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 12 Jul 2017 00:23:42 -0700 (PDT)
Date: Wed, 12 Jul 2017 09:23:37 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC v5 00/38] powerpc: Memory Protection Keys
Message-ID: <20170712072337.GB28912@dhcp22.suse.cz>
References: <1499289735-14220-1-git-send-email-linuxram@us.ibm.com>
 <20170711145246.GA11917@dhcp22.suse.cz>
 <20170711193257.GB5525@ram.oc3035372033.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170711193257.GB5525@ram.oc3035372033.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com

On Tue 11-07-17 12:32:57, Ram Pai wrote:
> On Tue, Jul 11, 2017 at 04:52:46PM +0200, Michal Hocko wrote:
> > On Wed 05-07-17 14:21:37, Ram Pai wrote:
> > > Memory protection keys enable applications to protect its
> > > address space from inadvertent access or corruption from
> > > itself.
> > > 
> > > The overall idea:
> > > 
> > >  A process allocates a   key  and associates it with
> > >  an  address  range  within    its   address   space.
> > >  The process  then  can  dynamically  set read/write 
> > >  permissions on  the   key   without  involving  the 
> > >  kernel. Any  code that  violates   the  permissions
> > >  of  the address space; as defined by its associated
> > >  key, will receive a segmentation fault.
> > > 
> > > This patch series enables the feature on PPC64 HPTE
> > > platform.
> > > 
> > > ISA3.0 section 5.7.13 describes the detailed specifications.
> > 
> > Could you describe the highlevel design of this feature in the cover
> > letter.
> 
> Yes it can be hard to understand without the big picture.  I will
> provide the high level design and the rationale behind the patch split
> towards the end.  Also I will have it in the cover letter for my next
> revision of the patchset.

Thanks!
 
> > I have tried to get some idea from the patchset but it was
> > really far from trivial. Patches are not very well split up (many
> > helpers are added without their users etc..). 
> 
> I see your point. Earlier, I had the patches split such a way that the
> users of the helpers were in the same patch as that of the helper.
> But then comments from others lead to the current split.

It is not my call here, obviously. I cannot review arch specific parts
due to lack of familiarity but it is a general good practice to include
helpers along with their users to make the usage clear. Also, as much as
I like small patches because they are easier to review, having very many
of them can lead to a harder review in the end because you easily lose
a higher level overview.

> > > Testing:
> > > 	This patch series has passed all the protection key
> > > 	tests available in  the selftests directory.
> > > 	The tests are updated to work on both x86 and powerpc.
> > > 
> > > version v5:
> > > 	(1) reverted back to the old design -- store the 
> > > 	    key in the pte, instead of bypassing it.
> > > 	    The v4 design slowed down the hash page path.
> > 
> > This surprised me a lot but I couldn't find the respective code. Why do
> > you need to store anything in the pte? My understanding of PKEYs is that
> > the setup and teardown should be very cheap and so no page tables have
> > to updated. Or do I just misunderstand what you wrote here?
> 
> Ideally the MMU looks at the PTE for keys, in order to enforce
> protection. This is the case with x86 and is the case with power9 Radix
> page table. Hence the keys have to be programmed into the PTE.

But x86 doesn't update ptes for PKEYs, that would be just too expensive.
You could use standard mprotect to do the same...
 
> However with HPT on power, these keys do not necessarily have to be
> programmed into the PTE. We could bypass the Linux Page Table Entry(PTE)
> and instead just program them into the Hash Page Table(HPTE), since
> the MMU does not refer the PTE but refers the HPTE. The last version
> of the page attempted to do that.   It worked as follows:
> 
> a) when a address range is requested to be associated with a key; by the
>    application through key_mprotect() system call, the kernel
>    stores that key in the vmas corresponding to that address
>    range.
> 
> b) Whenever there is a hash page fault for that address, the fault
>    handler reads the key from the VMA and programs the key into the
>    HPTE. __hash_page() is the function that does that.

What causes the fault here?

> c) Once the hpte is programmed, the MMU can sense key violations and
>    generate key-faults.
> 
> The problem is with step (b).  This step is really a very critical
> path which is performance sensitive. We dont want to add any delays.
> However if we want to access the key from the vma, we will have to
> hold the vma semaphore, and that is a big NO-NO. As a result, this
> design had to be dropped.
> 
> 
> 
> I reverted back to the old design i.e the design in v4 version. In this
> version we do the following:
> 
> a) when a address range is requested to be associated with a key; by the
>    application through key_mprotect() system call, the kernel
>    stores that key in the vmas corresponding to that address
>    range. Also the kernel programs the key into Linux PTE coresponding to all the
>    pages associated with the address range.

OK, so how is this any different from the regular mprotect then?

> b) Whenever there is a hash page fault for that address, the fault
>    handler reads the key from the Linux PTE and programs the key into 
>    the HPTE.
> 
> c) Once the HPTE is programmed, the MMU can sense key violations and
>    generate key-faults.
> 
> 
> Since step (b) in this case has easy access to the Linux PTE, and hence
> to the key, it is fast to access it and program the HPTE. Thus we avoid
> taking any performance hit on this critical path.
> 
> Hope this explains the rationale,
> 
> 
> As promised here is the high level design:

I will read through that later
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
