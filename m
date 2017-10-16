Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 802D86B0038
	for <linux-mm@kvack.org>; Mon, 16 Oct 2017 16:58:31 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id n89so9387609pfk.17
        for <linux-mm@kvack.org>; Mon, 16 Oct 2017 13:58:31 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h64si4512740pge.382.2017.10.16.13.58.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 16 Oct 2017 13:58:30 -0700 (PDT)
Date: Mon, 16 Oct 2017 22:58:22 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 3/3] mm/map_contig: Add mmap(MAP_CONTIG) support
Message-ID: <20171016205822.dgcp2klsosqq6a5f@dhcp22.suse.cz>
References: <alpine.DEB.2.20.1710131015420.3949@nuc-kabylake>
 <20171013152801.nbpk6nluotgbmfrs@dhcp22.suse.cz>
 <alpine.DEB.2.20.1710131040570.4247@nuc-kabylake>
 <20171013154747.2jv7rtfqyyagiodn@dhcp22.suse.cz>
 <alpine.DEB.2.20.1710131053450.4400@nuc-kabylake>
 <20171013161736.htumyr4cskfrjq64@dhcp22.suse.cz>
 <752b49eb-55c6-5a34-ab41-6e91dd93ea70@mellanox.com>
 <aff6b405-6a06-f84d-c9b1-c6fb166dff81@oracle.com>
 <20171016180749.2y2v4ucchb33xnde@dhcp22.suse.cz>
 <e8cf6227-003d-8a82-8b4d-07176b43810c@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e8cf6227-003d-8a82-8b4d-07176b43810c@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Guy Shattah <sguy@mellanox.com>, Christopher Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Laura Abbott <labbott@redhat.com>, Vlastimil Babka <vbabka@suse.cz>

On Mon 16-10-17 13:32:45, Mike Kravetz wrote:
> On 10/16/2017 11:07 AM, Michal Hocko wrote:
[...]
> > That depends on who is actually going to use the contiguous memory. If
> > we are talking about drivers to communication to the userspace then
> > using driver specific fd with its mmap implementation then we do not
> > need any special fs nor a seperate infrastructure. Well except for a
> > library function to handle the MM side of the thing.
> 
> If we embed this functionality into device specific mmap calls it will
> closely tie the usage to the devices.  However, don't we still have to
> worry about potential interaction with other parts of the mm as you mention
> below?  I guess that would be the library function and how it is used
> by drivers.

Yes, those problems with pinning the amount of contiguous memory are
simply inherent. You have to be really careful when allowing to reserve large
partions of the contiguous memory. Especially if this is going to be a
very dynamic allocator. The main advantage of the per
device mmap is that it has its access control by default via file
permissions. You can simply rule the untrusted user out of the game. You
can also implement the per device usage limits. So you have some tools to
keep the usage under leash and evaluate potential costs vs. benefits.
That sounds to me much more safer than a generic API which would have
a tricky accounting and access control restrictions.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
