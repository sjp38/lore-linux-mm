Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3AAAE6B04D2
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 14:29:27 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id k14so110061qkl.11
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 11:29:27 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g6si11012qkc.238.2017.07.11.11.29.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jul 2017 11:29:26 -0700 (PDT)
Date: Tue, 11 Jul 2017 14:29:22 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM 12/15] mm/migrate: new memory migration helper for use with
 device memory v4
Message-ID: <20170711182922.GC5347@redhat.com>
References: <20170522165206.6284-1-jglisse@redhat.com>
 <20170522165206.6284-13-jglisse@redhat.com>
 <fa402b70fa9d418ebf58a26a454abd06@HQMAIL103.nvidia.com>
 <5f476e8c-8256-13a8-2228-a2b9e5650586@nvidia.com>
 <20170701005749.GA7232@redhat.com>
 <ff6cb2b9-b930-afad-1a1f-1c437eced3cf@nvidia.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="dDRMvlgZJXvWKvBx"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <ff6cb2b9-b930-afad-1a1f-1c437eced3cf@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Evgeny Baskakov <ebaskakov@nvidia.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>


--dDRMvlgZJXvWKvBx
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit

On Mon, Jul 10, 2017 at 04:44:38PM -0700, Evgeny Baskakov wrote:
> On 6/30/17 5:57 PM, Jerome Glisse wrote:
> 
> ...
> 
> Hi Jerome,
> 
> I am working on a sporadic data corruption seen in highly contented use
> cases. So far, I've been able to re-create a sporadic hang that happens when
> multiple threads compete to migrate the same page to and from device memory.
> The reproducer uses only the dummy driver from hmm-next.
> 
> Please find attached. This is how it hangs on my 12-core Intel i7-5930K SMT
> system:
> 

Can you test if attached patch helps ? I am having trouble reproducing this
from inside a vm.

My theory is that 2 concurrent CPU page fault happens. First one manage to
start the migration back to system memory but second one see the migration
special entry and call migration_entry_wait() which increase page refcount
and this happen before first one check page refcount are ok for migration.

For regular migration such scenario is ok as the migration bails out and
because page is CPU accessible there is no need to kick again the migration
for other thread that CPU fault to migrate.

I am looking into how i can change migration_entry_wait() not to refcount
pages. Let me know if the attached patch helps.

Thank you
Jerome

--dDRMvlgZJXvWKvBx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="0001-TEST-THEORY-ABOUT-MIGRATION-AND-DEVICE.patch"


--dDRMvlgZJXvWKvBx--
