Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id E63206B02F3
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 09:31:11 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id o124so1848825qke.9
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 06:31:11 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u41si7434187qth.202.2017.08.07.06.31.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Aug 2017 06:31:11 -0700 (PDT)
Date: Mon, 7 Aug 2017 09:31:07 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [RFC] Tagging of vmalloc pages for supporting the pmalloc
 allocator
Message-ID: <20170807133107.GA16616@redhat.com>
References: <8e82639c-40db-02ce-096a-d114b0436d3c@huawei.com>
 <20170803114844.GO12521@dhcp22.suse.cz>
 <c3a250a6-ad4d-d24d-d0bf-4c43c467ebe6@huawei.com>
 <20170803135549.GW12521@dhcp22.suse.cz>
 <20170803144746.GA9501@redhat.com>
 <ab4809cd-0efc-a79d-6852-4bd2349a2b3f@huawei.com>
 <20170803151550.GX12521@dhcp22.suse.cz>
 <abe0c086-8c5a-d6fb-63c4-bf75528d0ec5@huawei.com>
 <20170804081240.GF26029@dhcp22.suse.cz>
 <7733852a-67c9-17a3-4031-cb08520b9ad2@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <7733852a-67c9-17a3-4031-cb08520b9ad2@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-security-module@vger.kernel.org, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Kees Cook <keescook@google.com>

On Mon, Aug 07, 2017 at 02:26:21PM +0300, Igor Stoppa wrote:
> On 04/08/17 11:12, Michal Hocko wrote:
> > On Fri 04-08-17 11:02:46, Igor Stoppa wrote:
> 
> [...]
> 
> >> struct page {
> >>   /* First double word block */
> >>   unsigned long flags;		/* Atomic flags, some possibly
> >> 				 * updated asynchronously */
> >> union {
> >> 	struct address_space *mapping;	/* If low bit clear, points to
> >> 					 * inode address_space, or NULL.
> >> 					 * If page mapped as anonymous
> >> 					 * memory, low bit is set, and
> >> 					 * it points to anon_vma object:
> >> 					 * see PAGE_MAPPING_ANON below.
> >> 					 */
> >> ...
> >> }
> >>
> >> mapping seems to be used exclusively in 2 ways, based on the value of
> >> its lower bit.
> > 
> > Not really. The above applies to LRU pages. Please note that Slab pages
> > use s_mem and huge pages use compound_mapcount. If vmalloc pages are
> > using none of those already you can add a new field there.
> 
> Yes, both from reading the code and some experimentation, it seems that
> vmalloc is not using either field.
> 
> I'll add a vm_area field as you advised.
> 
> Is this something I could send as standalone patch?

Note that vmalloc() is not the only thing that use vmalloc address
space. There is also vmap() and i know one set of drivers that use
vmap() and also use the mapping field of struct page namely GPU
drivers.

So like i said previously i would store a flag inside vm_struct to
know if page you are looking at are pmalloc or not. Again do you
need to store something per page ? Would storing it per vm_struct
not be enough ?

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
