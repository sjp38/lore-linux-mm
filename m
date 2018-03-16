Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id F3D486B0025
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 17:26:33 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id l32so7586967qtd.2
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 14:26:33 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id x67si3565809qka.399.2018.03.16.14.26.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 14:26:33 -0700 (PDT)
Date: Fri, 16 Mar 2018 17:26:30 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 03/14] mm/hmm: HMM should have a callback before MM is
 destroyed v2
Message-ID: <20180316212630.GC4861@redhat.com>
References: <20180316191414.3223-1-jglisse@redhat.com>
 <20180316191414.3223-4-jglisse@redhat.com>
 <20180316141221.f2b622630de3f1da51a5c105@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180316141221.f2b622630de3f1da51a5c105@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ralph Campbell <rcampbell@nvidia.com>, stable@vger.kernel.org, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, John Hubbard <jhubbard@nvidia.com>

On Fri, Mar 16, 2018 at 02:12:21PM -0700, Andrew Morton wrote:
> On Fri, 16 Mar 2018 15:14:08 -0400 jglisse@redhat.com wrote:
> 
> > The hmm_mirror_register() function registers a callback for when
> > the CPU pagetable is modified. Normally, the device driver will
> > call hmm_mirror_unregister() when the process using the device is
> > finished. However, if the process exits uncleanly, the struct_mm
> > can be destroyed with no warning to the device driver.
> 
> Again, what are the user-visible effects of the bug?  Such info is
> needed when others review our request for a -stable backport.  And the
> many people who review -stable patches for integration into their own
> kernel trees will want to understand the benefit of the patch to their
> users.

I have not had any issues in any of my own testing but nouveau driver
is not as advance as the NVidia closed driver in respect to HMM inte-
gration yet.

If any issues they will happen between exit_mm() and exit_files() in
do_exit() (kernel/exit.c) exit_mm() tear down the mm struct but without
this callback the device driver might still be handling page fault and
thus might potentialy tries to handle them against a dead mm_struct.

So i am not sure what are the symptoms. To be fair there is no public
driver using that part of HMM beside nouveau rfc patches. So at this
point the impact on anybody is non existent. If anyone want to back-
port nouveau HMM support once it make it upstream it will probably
have to backport more things along the way. This is why i am not that
aggressive on ccing stable so far.

Cheers,
Jerome
