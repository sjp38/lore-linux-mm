Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id C83C86B02B4
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 07:34:32 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id x64so674758wmg.11
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 04:34:32 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m63si4884058wma.185.2017.08.07.04.34.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 07 Aug 2017 04:34:31 -0700 (PDT)
Date: Mon, 7 Aug 2017 13:34:29 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC] Tagging of vmalloc pages for supporting the pmalloc
 allocator
Message-ID: <20170807113428.GF32434@dhcp22.suse.cz>
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
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7733852a-67c9-17a3-4031-cb08520b9ad2@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: Jerome Glisse <jglisse@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-security-module@vger.kernel.org, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Kees Cook <keescook@google.com>

On Mon 07-08-17 14:26:21, Igor Stoppa wrote:
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

Yes I would start that way and also look at some find_vm_area callers
and maybe they can be simplified. The most obvious one being
task_struct::stack_vm_area but I have to confess I haven't checked that
too deeply.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
