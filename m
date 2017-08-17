Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id DCF676B02F3
	for <linux-mm@kvack.org>; Thu, 17 Aug 2017 19:42:46 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 5so16077498wrz.14
        for <linux-mm@kvack.org>; Thu, 17 Aug 2017 16:42:46 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id k19si842633wre.0.2017.08.17.16.42.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Aug 2017 16:42:45 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v7HNd4MR124876
	for <linux-mm@kvack.org>; Thu, 17 Aug 2017 19:42:44 -0400
Received: from e15.ny.us.ibm.com (e15.ny.us.ibm.com [129.33.205.205])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2cdhun0tnt-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 17 Aug 2017 19:42:44 -0400
Received: from localhost
	by e15.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Thu, 17 Aug 2017 19:42:43 -0400
Date: Thu, 17 Aug 2017 16:42:31 -0700
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [RFC v6 21/62] powerpc: introduce execute-only pkey
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com>
 <1500177424-13695-22-git-send-email-linuxram@us.ibm.com>
 <87shhgdx5i.fsf@linux.vnet.ibm.com>
 <87d18fu6o1.fsf@concordia.ellerman.id.au>
 <87d18fw9it.fsf@linux.vnet.ibm.com>
 <871sous3xd.fsf@concordia.ellerman.id.au>
 <20170817233555.GC5427@ram.oc3035372033.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170817233555.GC5427@ram.oc3035372033.ibm.com>
Message-Id: <20170817234231.GA5445@ram.oc3035372033.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com>, linux-arch@vger.kernel.org, corbet@lwn.net, arnd@arndb.de, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, mhocko@kernel.org, linux-mm@kvack.org, dave.hansen@intel.com, mingo@redhat.com, paulus@samba.org, aneesh.kumar@linux.vnet.ibm.com, linux-kselftest@vger.kernel.org, akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org, khandual@linux.vnet.ibm.com

On Thu, Aug 17, 2017 at 04:35:55PM -0700, Ram Pai wrote:
> On Wed, Aug 02, 2017 at 07:40:46PM +1000, Michael Ellerman wrote:
> > Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com> writes:
> > 
> > > Michael Ellerman <mpe@ellerman.id.au> writes:
> > >
> > >> Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com> writes:
> > >>> Ram Pai <linuxram@us.ibm.com> writes:
> > >> ...
> > >>>> +
> > >>>> +	/* We got one, store it and use it from here on out */
> > >>>> +	if (need_to_set_mm_pkey)
> > >>>> +		mm->context.execute_only_pkey = execute_only_pkey;
> > >>>> +	return execute_only_pkey;
> > >>>> +}
> > >>>
> > >>> If you follow the code flow in __execute_only_pkey, the AMR and UAMOR
> > >>> are read 3 times in total, and AMR is written twice. IAMR is read and
> > >>> written twice. Since they are SPRs and access to them is slow (or isn't
> > >>> it?),
> > >>
> > >> SPRs read/writes are slow, but they're not *that* slow in comparison to
> > >> a system call (which I think is where this code is being called?).
> > >
> > > Yes, this code runs on mprotect and mmap syscalls if the memory is
> > > requested to have execute but not read nor write permissions.
> > 
> > Yep. That's not in the fast path for key usage, ie. the fast path is
> > userspace changing the AMR itself, and the overhead of a syscall is
> > already hundreds of cycles.
> > 
> > >> So we should try to avoid too many SPR read/writes, but at the same time
> > >> we can accept more than the minimum if it makes the code much easier to
> > >> follow.
> > >
> > > Ok. Ram had asked me to suggest a way to optimize the SPR reads and
> > > writes and I came up with the patch below. Do you think it's worth it?
> > 
> > At a glance no I don't think it is. Sorry you spent that much time on it.
> > 
> > I think we can probably reduce the number of SPR accesses without
> > needing to go to that level of complexity.
> > 
> > But don't throw the patch away, I may eat my words once I have the full
> > series applied and am looking at it hard - at the moment I'm just
> > reviewing the patches piecemeal as I get time.
> 

Thiago's patch does save some cycles. I dont feel like throwing his
work. I agree, It should be considered after applying all the patches. 
 
RP

-- 
Ram Pai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
