Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id B7CD0440941
	for <linux-mm@kvack.org>; Fri, 14 Jul 2017 20:56:00 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id l55so44658998qtl.7
        for <linux-mm@kvack.org>; Fri, 14 Jul 2017 17:56:00 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v8si9426860qtc.58.2017.07.14.17.55.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jul 2017 17:55:59 -0700 (PDT)
Date: Fri, 14 Jul 2017 20:55:55 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM 12/15] mm/migrate: new memory migration helper for use with
 device memory v4
Message-ID: <20170715005554.GA12694@redhat.com>
References: <fa402b70fa9d418ebf58a26a454abd06@HQMAIL103.nvidia.com>
 <5f476e8c-8256-13a8-2228-a2b9e5650586@nvidia.com>
 <20170701005749.GA7232@redhat.com>
 <ff6cb2b9-b930-afad-1a1f-1c437eced3cf@nvidia.com>
 <20170711182922.GC5347@redhat.com>
 <7a4478cb-7eb6-2546-e707-1b0f18e3acd4@nvidia.com>
 <20170711184919.GD5347@redhat.com>
 <84d83148-41a3-d0e8-be80-56187a8e8ccc@nvidia.com>
 <20170713201620.GB1979@redhat.com>
 <ca12b033-8ec5-84b0-c2aa-ea829e1194fa@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <ca12b033-8ec5-84b0-c2aa-ea829e1194fa@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Evgeny Baskakov <ebaskakov@nvidia.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

On Fri, Jul 14, 2017 at 12:43:51PM -0700, Evgeny Baskakov wrote:
> On 7/13/17 1:16 PM, Jerome Glisse wrote:
> Hi Jerome,
> 
> I have hit another kind of hang. Briefly, if a not yet allocated page faults
> on CPU during migration to device memory, any subsequent migration will fail
> for such page. Such a situation can trigger if a CPU page fault happens just
> immediately after migrate_vma() starts unmapping pages to migrate.
> 
> Please find attached a reproducer based on the sample driver. In the
> hmm_test() function, an HMM_DMIRROR_MIGRATE request is triggered from a
> separate thread for not yet allocated pages (coming from malloc). In the
> same time, a HMM_DMIRROR_READ request is made for the same pages. This
> results in a sporadic app-side hang, because random number of pages never
> migrate to device memory.
> 
> Note that if the pages are touched (initialized with data) prior to that,
> everything works as expected: all HMM_DMIRROR_READ and HMM_DMIRROR_MIGRATE
> requests eventually succeed. See comments in the hmm_test() function.
> 

So pushed an updated hmm-next branch this should fix all issues you had.
Thought i am not sure about the test in this mail, all i see is that it
continously spit error messages but it does not hang (i let it run 20min
or so). Dunno if that is what expected. Let me know if this is still an
issue and if so what should be the expected output of this test program.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
