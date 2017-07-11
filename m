Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2B3C06B0516
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 14:49:24 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id z22so345485qka.4
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 11:49:24 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x7si62251qtx.301.2017.07.11.11.49.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jul 2017 11:49:23 -0700 (PDT)
Date: Tue, 11 Jul 2017 14:49:19 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM 12/15] mm/migrate: new memory migration helper for use with
 device memory v4
Message-ID: <20170711184919.GD5347@redhat.com>
References: <20170522165206.6284-1-jglisse@redhat.com>
 <20170522165206.6284-13-jglisse@redhat.com>
 <fa402b70fa9d418ebf58a26a454abd06@HQMAIL103.nvidia.com>
 <5f476e8c-8256-13a8-2228-a2b9e5650586@nvidia.com>
 <20170701005749.GA7232@redhat.com>
 <ff6cb2b9-b930-afad-1a1f-1c437eced3cf@nvidia.com>
 <20170711182922.GC5347@redhat.com>
 <7a4478cb-7eb6-2546-e707-1b0f18e3acd4@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <7a4478cb-7eb6-2546-e707-1b0f18e3acd4@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Evgeny Baskakov <ebaskakov@nvidia.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

On Tue, Jul 11, 2017 at 11:42:20AM -0700, Evgeny Baskakov wrote:
> On 7/11/17 11:29 AM, Jerome Glisse wrote:
> > Can you test if attached patch helps ? I am having trouble reproducing
> > this
> > from inside a vm.
> > 
> > My theory is that 2 concurrent CPU page fault happens. First one manage to
> > start the migration back to system memory but second one see the migration
> > special entry and call migration_entry_wait() which increase page refcount
> > and this happen before first one check page refcount are ok for migration.
> > 
> > For regular migration such scenario is ok as the migration bails out and
> > because page is CPU accessible there is no need to kick again the migration
> > for other thread that CPU fault to migrate.
> > 
> > I am looking into how i can change migration_entry_wait() not to refcount
> > pages. Let me know if the attached patch helps.
> > 
> > Thank you
> > Jerome
> 
> Hi Jerome,
> 
> Thanks for the update.
> 
> Unfortunately, the patch does not help. I just applied it and recompiled the
> kernel. Please find attached a new kernel log and an app log.
> 

What are the symptoms ? The program just stop making any progress and you
trigger a sysrequest to dump current states of each threads ? In this
log i don't see migration_entry_wait() anymore but it seems to be waiting
on page lock so there might be 2 issues here.

Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
