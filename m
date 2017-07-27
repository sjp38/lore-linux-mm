Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id E8F776B025F
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 04:23:01 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 185so7090094wmk.12
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 01:23:01 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f126si10451093wmg.81.2017.07.27.01.23.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 27 Jul 2017 01:23:00 -0700 (PDT)
Date: Thu, 27 Jul 2017 10:22:58 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: gigantic hugepages vs. movable zones
Message-ID: <20170727082258.GL20970@dhcp22.suse.cz>
References: <20170726105004.GI2981@dhcp22.suse.cz>
 <87inie1uwf.fsf@linux.vnet.ibm.com>
 <20170727072857.GI20970@dhcp22.suse.cz>
 <1529e986-5f28-35dd-c82e-a4b5801b4afd@linux.vnet.ibm.com>
 <20170727081236.GK20970@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170727081236.GK20970@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Luiz Capitulino <lcapitulino@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Vlastimil Babka <vbabka@suse.cz>

[CC for real]

On Thu 27-07-17 10:12:36, Michal Hocko wrote:
> On Thu 27-07-17 13:30:31, Aneesh Kumar K.V wrote:
> > 
> > 
> > On 07/27/2017 12:58 PM, Michal Hocko wrote:
> > >On Thu 27-07-17 07:52:08, Aneesh Kumar K.V wrote:
> > >>Michal Hocko <mhocko@kernel.org> writes:
> > >>
> > >>>Hi,
> > >>>I've just noticed that alloc_gigantic_page ignores movability of the
> > >>>gigantic page and it uses any existing zone. Considering that
> > >>>hugepage_migration_supported only supports 2MB and pgd level hugepages
> > >>>then 1GB pages are not migratable and as such allocating them from a
> > >>>movable zone will break the basic expectation of this zone. Standard
> > >>>hugetlb allocations try to avoid that by using htlb_alloc_mask and I
> > >>>believe we should do the same for gigantic pages as well.
> > >>>
> > >>>I suspect this behavior is not intentional. What do you think about the
> > >>>following untested patch?
> > >>
> > >>
> > >>I also noticed an unrelated issue with the usage of
> > >>start_isolate_page_range. On error we set the migrate type to
> > >>MIGRATE_MOVABLE.
> > >
> > >Why that should be a problem? I think it is perfectly OK to have
> > >MIGRATE_MOVABLE pageblocks inside kernel zones.
> > >
> > 
> > we can pick pages with migrate type movable and if we fail to isolate won't
> > we set the migrate type of that pages to MOVABLE ?
> 
> I do not see an immediate problem. GFP_KERNEL allocations can fallback
> to movable migrate pageblocks AFAIR. But I am not very much familiar
> with migratetypes. Vlastimil, could you have a look please?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
