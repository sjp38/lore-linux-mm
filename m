Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 637CE6B0292
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 15:32:12 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id v191so1226156wmf.2
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 12:32:12 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id p1si3540493edh.187.2018.03.16.12.32.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 12:32:11 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2GJUKka004208
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 15:32:09 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2grk2fjdew-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 15:32:09 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Fri, 16 Mar 2018 19:32:05 -0000
Date: Fri, 16 Mar 2018 12:31:52 -0700
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [PATCH v4] mm, pkey: treat pkey-0 special
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <1521196416-18157-1-git-send-email-linuxram@us.ibm.com>
 <CAKTCnzmSCT+VecdSRpyY2Rb_AW2ngCi3UTZfLE3VOLNSQn6vsA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKTCnzmSCT+VecdSRpyY2Rb_AW2ngCi3UTZfLE3VOLNSQn6vsA@mail.gmail.com>
Message-Id: <20180316193152.GG1060@ram.oc3035372033.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>, Ingo Molnar <mingo@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "open list:LINUX FOR POWERPC (32-BIT AND 64-BIT)" <linuxppc-dev@lists.ozlabs.org>, linux-mm <linux-mm@kvack.org>, "maintainer:X86 ARCHITECTURE (32-BIT AND 64-BIT)" <x86@kernel.org>, linux-arch <linux-arch@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dave Hansen <dave.hansen@intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Aneesh Kumar KV <aneesh.kumar@linux.vnet.ibm.com>, Haren Myneni/Beaverton/IBM <hbabu@us.ibm.com>, Michal Hocko <mhocko@kernel.org>, Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Jonathan Corbet <corbet@lwn.net>, Arnd Bergmann <arnd@arndb.de>, fweimer@redhat.com, msuchanek@suse.com, Thomas Gleixner <tglx@linutronix.de>, Ulrich.Weigand@de.ibm.com, Ram Pai <ram.n.pai@gmail.com>

On Fri, Mar 16, 2018 at 10:02:22PM +1100, Balbir Singh wrote:
> On Fri, Mar 16, 2018 at 9:33 PM, Ram Pai <linuxram@us.ibm.com> wrote:
> > Applications need the ability to associate an address-range with some
> > key and latter revert to its initial default key. Pkey-0 comes close to
> > providing this function but falls short, because the current
> > implementation disallows applications to explicitly associate pkey-0 to
> > the address range.
> >
> > Clarify the semantics of pkey-0 and provide the corresponding
> > implementation.
> >
> > Pkey-0 is special with the following semantics.
> > (a) it is implicitly allocated and can never be freed. It always exists.
> > (b) it is the default key assigned to any address-range.
> > (c) it can be explicitly associated with any address-range.
> >
> > Tested on powerpc only. Could not test on x86.
> 
> 
> Ram,
> 
> I was wondering if we should check the AMOR values on the ppc side to make sure
> that pkey0 is indeed available for use as default. I am still of the
> opinion that we

AMOR cannot be read/written by the OS in priviledge-non-hypervisor-mode.
We could try testing if key-0 is available to the OS by temproarily
changing the bits key-0 bits of AMR or IAMR register. But will be
dangeorous to do, for you might disable read,execute of all the pages,
since all pages are asscoiated with key-0 bydefault.

May be we can play with UAMOR register and check if its key-0 can be
modified. That is a good indication that key-0 is available.
If it is not available, disable the pkey-subsystem, and operate
the legacy way; no pkeys.


> should consider non-0 default pkey in the long run. I'm OK with the patches for
> now, but really 0 is not special except for it being the default bit
> values present
> in the PTE.

it will be a pain. Any new pte that gets instantiated will now have to
explicitly initialize its key to this default-non-zero-key.  I hope
we or any architecture goes there ever.

-- 
Ram Pai
