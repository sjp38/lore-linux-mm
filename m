Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 104746B0279
	for <linux-mm@kvack.org>; Wed,  7 Jun 2017 10:49:17 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id b19so2624964qkj.10
        for <linux-mm@kvack.org>; Wed, 07 Jun 2017 07:49:17 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y10si2226261qth.35.2017.06.07.07.49.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Jun 2017 07:49:16 -0700 (PDT)
Date: Wed, 7 Jun 2017 10:49:12 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH] x86/mm/hotplug: fix BUG_ON() after hotremove
Message-ID: <20170607144912.GA6639@redhat.com>
References: <20170606173512.7378-1-jglisse@redhat.com>
 <20170607104715.5niuwk42fhahbftk@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170607104715.5niuwk42fhahbftk@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Logan Gunthorpe <logang@deltatee.com>

On Wed, Jun 07, 2017 at 01:47:15PM +0300, Kirill A. Shutemov wrote:
> On Tue, Jun 06, 2017 at 01:35:12PM -0400, Jerome Glisse wrote:
> > With commit af2cf278ef4f we no longer free pud so that we
> > do not have synchronize all pgd on hotremove/vfree. But the
> > new 5 level page table code re-added that code f2a6a705 and
> > thus we now trigger a BUG_ON() l128 in sync_global_pgds()
> > 
> > This patch remove free_pud() like in af2cf278ef4f
> 
> Good catch. Thanks!
> 
> But I think we only need to skip free_pud_table() for 4-level paging.
> If we don't we would leave 513 page tables around instead of one in
> 5-level paging case.
> 
> I don't think it's acceptable.
> 
> And please use patch subject lines along with commit hashes to simplify
> reading commit message.
> 

I sent a v2 that disable free_pud in 4 level page table config.
Note that your patchset that allow switching between 4 and 5 at
boot time will need to update that code. As this patch is a fix
and your boot time switching is an RFC i assume the fix will go
in first.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
