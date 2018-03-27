Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9EBBA6B0003
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 23:48:30 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e10so12278658pff.3
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 20:48:30 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id w128si233933pgb.460.2018.03.26.20.48.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 26 Mar 2018 20:48:27 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH v4] mm, pkey: treat pkey-0 special
In-Reply-To: <20180316193152.GG1060@ram.oc3035372033.ibm.com>
References: <1521196416-18157-1-git-send-email-linuxram@us.ibm.com> <CAKTCnzmSCT+VecdSRpyY2Rb_AW2ngCi3UTZfLE3VOLNSQn6vsA@mail.gmail.com> <20180316193152.GG1060@ram.oc3035372033.ibm.com>
Date: Tue, 27 Mar 2018 14:48:21 +1100
Message-ID: <87o9jaji0q.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, Balbir Singh <bsingharora@gmail.com>
Cc: Ingo Molnar <mingo@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "open list:LINUX FOR POWERPC (32-BIT AND 64-BIT)" <linuxppc-dev@lists.ozlabs.org>, linux-mm <linux-mm@kvack.org>, "maintainer:X86 ARCHITECTURE (32-BIT AND 64-BIT)" <x86@kernel.org>, linux-arch <linux-arch@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dave Hansen <dave.hansen@intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Aneesh Kumar KV <aneesh.kumar@linux.vnet.ibm.com>, Haren Myneni/Beaverton/IBM <hbabu@us.ibm.com>, Michal Hocko <mhocko@kernel.org>, Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Jonathan Corbet <corbet@lwn.net>, Arnd Bergmann <arnd@arndb.de>, fweimer@redhat.com, msuchanek@suse.com, Thomas Gleixner <tglx@linutronix.de>, Ulrich.Weigand@de.ibm.com, Ram Pai <ram.n.pai@gmail.com>

Ram Pai <linuxram@us.ibm.com> writes:

> On Fri, Mar 16, 2018 at 10:02:22PM +1100, Balbir Singh wrote:
>> On Fri, Mar 16, 2018 at 9:33 PM, Ram Pai <linuxram@us.ibm.com> wrote:
>> > Applications need the ability to associate an address-range with some
>> > key and latter revert to its initial default key. Pkey-0 comes close to
>> > providing this function but falls short, because the current
>> > implementation disallows applications to explicitly associate pkey-0 to
>> > the address range.
>> >
>> > Clarify the semantics of pkey-0 and provide the corresponding
>> > implementation.
>> >
>> > Pkey-0 is special with the following semantics.
>> > (a) it is implicitly allocated and can never be freed. It always exists.
>> > (b) it is the default key assigned to any address-range.
>> > (c) it can be explicitly associated with any address-range.
>> >
>> > Tested on powerpc only. Could not test on x86.
>> 
>> Ram,
>> 
>> I was wondering if we should check the AMOR values on the ppc side to make sure
>> that pkey0 is indeed available for use as default. I am still of the
>> opinion that we
>
> AMOR cannot be read/written by the OS in priviledge-non-hypervisor-mode.
> We could try testing if key-0 is available to the OS by temproarily
> changing the bits key-0 bits of AMR or IAMR register. But will be
> dangeorous to do, for you might disable read,execute of all the pages,
> since all pages are asscoiated with key-0 bydefault.

No we should do what firmware tells us. If it says key 0 is available we
use it, otherwise we don't.

Now if you notice the way the firmware API (device tree property) is
defined, it tells us how many keys are available, counting from 0.

So for pkey 0 to be reserved there must be 0 keys available.

End of story.

cheers
