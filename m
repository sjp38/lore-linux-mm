Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id BFC636B025E
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 02:45:17 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id a2so2644818lfe.0
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 23:45:17 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id jp7si4087677wjb.155.2016.06.14.23.45.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jun 2016 23:45:16 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u5F6hl8Y104012
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 02:45:15 -0400
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com [202.81.31.143])
	by mx0b-001b2d01.pphosted.com with ESMTP id 23jggsxdcj-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 02:45:15 -0400
Received: from localhost
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 15 Jun 2016 16:45:12 +1000
Received: from d23relay06.au.ibm.com (d23relay06.au.ibm.com [9.185.63.219])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id A74F32CE8046
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 16:45:09 +1000 (EST)
Received: from d23av05.au.ibm.com (d23av05.au.ibm.com [9.190.234.119])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u5F6j9qQ10486032
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 16:45:09 +1000
Received: from d23av05.au.ibm.com (localhost [127.0.0.1])
	by d23av05.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u5F6j8ZI002428
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 16:45:09 +1000
Date: Wed, 15 Jun 2016 12:15:04 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6v3 02/12] mm: migrate: support non-lru movable page
 migration
References: <1463754225-31311-1-git-send-email-minchan@kernel.org> <1463754225-31311-3-git-send-email-minchan@kernel.org> <20160530013926.GB8683@bbox> <20160531000117.GB18314@bbox> <575E7F0B.8010201@linux.vnet.ibm.com> <20160615023249.GG17127@bbox>
In-Reply-To: <20160615023249.GG17127@bbox>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <5760F970.7060805@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rafael Aquini <aquini@redhat.com>, virtualization@lists.linux-foundation.org, Jonathan Corbet <corbet@lwn.net>, John Einar Reitan <john.reitan@foss.arm.com>, dri-devel@lists.freedesktop.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Gioh Kim <gi-oh.kim@profitbricks.com>

On 06/15/2016 08:02 AM, Minchan Kim wrote:
> Hi,
> 
> On Mon, Jun 13, 2016 at 03:08:19PM +0530, Anshuman Khandual wrote:
>> > On 05/31/2016 05:31 AM, Minchan Kim wrote:
>>> > > @@ -791,6 +921,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
>>> > >  	int rc = -EAGAIN;
>>> > >  	int page_was_mapped = 0;
>>> > >  	struct anon_vma *anon_vma = NULL;
>>> > > +	bool is_lru = !__PageMovable(page);
>>> > >  
>>> > >  	if (!trylock_page(page)) {
>>> > >  		if (!force || mode == MIGRATE_ASYNC)
>>> > > @@ -871,6 +1002,11 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
>>> > >  		goto out_unlock_both;
>>> > >  	}
>>> > >  
>>> > > +	if (unlikely(!is_lru)) {
>>> > > +		rc = move_to_new_page(newpage, page, mode);
>>> > > +		goto out_unlock_both;
>>> > > +	}
>>> > > +
>> > 
>> > Hello Minchan,
>> > 
>> > I might be missing something here but does this implementation support the
>> > scenario where these non LRU pages owned by the driver mapped as PTE into
>> > process page table ? Because the "goto out_unlock_both" statement above
>> > skips all the PTE unmap, putting a migration PTE and removing the migration
>> > PTE steps.
> You're right. Unfortunately, it doesn't support right now but surely,
> it's my TODO after landing this work.
> 
> Could you share your usecase?

Sure.

My driver has privately managed non LRU pages which gets mapped into user space
process page table through f_ops->mmap() and vmops->fault() which then updates
the file RMAP (page->mapping->i_mmap) through page_add_file_rmap(page). One thing
to note here is that the page->mapping eventually points to struct address_space
(file->f_mapping) which belongs to the character device file (created using mknod)
which we are using for establishing the mmap() regions in the user space.

Now as per this new framework, all the page's are to be made __SetPageMovable before
passing the list down to migrate_pages(). Now __SetPageMovable() takes *new* struct
address_space as an argument and replaces the existing page->mapping. Now thats the
problem, we have lost all our connection to the existing file RMAP information. This
stands as a problem when we try to migrate these non LRU pages which are PTE mapped.
The rmap_walk_file() never finds them in the VMA, skips all the migrate PTE steps and
then the migration eventually fails.

Seems like assigning a new struct address_space to the page through __SetPageMovable()
is the source of the problem. Can it take the existing (file->f_mapping) as an argument
in there ? Sure, but then can we override file system generic ->isolate(), ->putback(),
->migratepages() functions ? I dont think so. I am sure, there must be some work around
to fix this problem for the driver. But we need to rethink this framework from supporting
these mapped non LRU pages point of view.

I might be missing something here, feel free to point out.

- Anshuman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
