Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8D6B26B0279
	for <linux-mm@kvack.org>; Thu,  6 Jul 2017 19:30:15 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id u5so17346938pgq.14
        for <linux-mm@kvack.org>; Thu, 06 Jul 2017 16:30:15 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id x14si1086685plm.95.2017.07.06.16.30.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jul 2017 16:30:14 -0700 (PDT)
Subject: Re: [RFC v2 0/5] surface heterogeneous memory performance information
References: <20170706215233.11329-1-ross.zwisler@linux.intel.com>
 <20170706230803.GE2919@redhat.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <e85da2ef-88bd-18f9-8b92-b64875d98a8b@intel.com>
Date: Thu, 6 Jul 2017 16:30:08 -0700
MIME-Version: 1.0
In-Reply-To: <20170706230803.GE2919@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, "Anaczkowski, Lukasz" <lukasz.anaczkowski@intel.com>, "Box, David E" <david.e.box@intel.com>, "Kogut, Jaroslaw" <Jaroslaw.Kogut@intel.com>, "Lahtinen, Joonas" <joonas.lahtinen@intel.com>, "Moore, Robert" <robert.moore@intel.com>, "Nachimuthu, Murugasamy" <murugasamy.nachimuthu@intel.com>, "Odzioba, Lukasz" <lukasz.odzioba@intel.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, "Schmauss, Erik" <erik.schmauss@intel.com>, "Verma, Vishal L" <vishal.l.verma@intel.com>, "Zheng, Lv" <lv.zheng@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Len Brown <lenb@kernel.org>, Tim Chen <tim.c.chen@linux.intel.com>, devel@acpica.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org

On 07/06/2017 04:08 PM, Jerome Glisse wrote:
>> So, for applications that need to differentiate between memory ranges based
>> on their performance, what option would work best for you?  Is the local
>> (initiator,target) performance provided by patch 5 enough, or do you
>> require performance information for all possible (initiator,target)
>> pairings?
> 
> Am i right in assuming that HBM or any faster memory will be relatively small
> (1GB - 8GB maybe 16GB ?) and of fix amount (ie size will depend on the exact
> CPU model you have) ?

For HBM, that's certainly consistent with the Xeon Phi MCDRAM.

But, please remember that this patch set is for fast memory *and* slow
memory (vs. plain DRAM).

> If so i am wondering if we should not restrict NUMA placement policy for such
> node to vma only. Forbid any policy that would prefer those node globally at
> thread/process level. This would avoid wide thread policy to exhaust this
> smaller pool of memory.

You would like to take the NUMA APIs and bifurcate them?  Make some of
them able to work on this memory, and others not?  So, set_mempolicy()
would work if you passed it one of these "special" nodes with
MPOL_F_ADDR, but would fail otherwise?


> Drawback of doing so would be that existing applications would not benefit
> from it. So workload where is acceptable to exhaust such memory wouldn't
> benefit until their application are updated.

I think the guys running 40-year-old fortran binaries might not be so
keen on this restriction.  I bet there are a pretty substantial number
of folks out there that would love to get new hardware and just do:

	numactl --membind=fast-node ./old-binary

If I were working for a hardware company, I'd sure like to just be able
to sell somebody some fancy new hardware and have their existing
software "just work" with a minimal wrapper.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
