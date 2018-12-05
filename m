Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 90E256B753D
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 11:29:03 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id 89so15220774ple.19
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 08:29:03 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n34si21249205pld.381.2018.12.05.08.29.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Dec 2018 08:29:01 -0800 (PST)
Date: Wed, 5 Dec 2018 17:28:57 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 2/3] mm/mmu_notifier: use structure for
 invalidate_range_start/end calls
Message-ID: <20181205162857.GF30615@quack2.suse.cz>
References: <20181203201817.10759-1-jglisse@redhat.com>
 <20181203201817.10759-3-jglisse@redhat.com>
 <20181205110416.GE22304@quack2.suse.cz>
 <20181205155357.GA3536@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20181205155357.GA3536@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <zwisler@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Michal Hocko <mhocko@kernel.org>, Christian Koenig <christian.koenig@amd.com>, Felix Kuehling <felix.kuehling@amd.com>, Ralph Campbell <rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, kvm@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org, linux-fsdevel@vger.kernel.org

On Wed 05-12-18 10:53:57, Jerome Glisse wrote:
> On Wed, Dec 05, 2018 at 12:04:16PM +0100, Jan Kara wrote:
> > Hi Jerome!
> > 
> > On Mon 03-12-18 15:18:16, jglisse@redhat.com wrote:
> > > From: J�r�me Glisse <jglisse@redhat.com>
> > > 
> > > To avoid having to change many call sites everytime we want to add a
> > > parameter use a structure to group all parameters for the mmu_notifier
> > > invalidate_range_start/end cakks. No functional changes with this
> > > patch.
> > 
> > Two suggestions for the patch below:
> > 
> > > @@ -772,7 +775,8 @@ static void dax_entry_mkclean(struct address_space *mapping, pgoff_t index,
> > >  		 * call mmu_notifier_invalidate_range_start() on our behalf
> > >  		 * before taking any lock.
> > >  		 */
> > > -		if (follow_pte_pmd(vma->vm_mm, address, &start, &end, &ptep, &pmdp, &ptl))
> > > +		if (follow_pte_pmd(vma->vm_mm, address, &range,
> > > +				   &ptep, &pmdp, &ptl))
> > >  			continue;
> > 
> > The change of follow_pte_pmd() arguments looks unexpected. Why should that
> > care about mmu notifier range? I see it may be convenient but it doesn't look
> > like a good API to me.
> 
> Saddly i do not see a way around that one this is because of fs/dax.c
> which does the mmu_notifier_invalidate_range_end while follow_pte_pmd
> do the mmu_notifier_invalidate_range_start

I see so this is really a preexisting problem with follow_pte_pmd() having
ugly interface. After some thoughts I think your patch actually slightly
improves the situation so OK.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
