Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1AA826B027A
	for <linux-mm@kvack.org>; Fri, 28 Oct 2016 03:35:46 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id fl2so38700465pad.7
        for <linux-mm@kvack.org>; Fri, 28 Oct 2016 00:35:46 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id n67si12236568pga.91.2016.10.28.00.35.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Oct 2016 00:35:45 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9S7XsAf124804
	for <linux-mm@kvack.org>; Fri, 28 Oct 2016 03:35:44 -0400
Received: from e31.co.us.ibm.com (e31.co.us.ibm.com [32.97.110.149])
	by mx0b-001b2d01.pphosted.com with ESMTP id 26bvbygfjh-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 28 Oct 2016 03:35:44 -0400
Received: from localhost
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 28 Oct 2016 01:35:43 -0600
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [RFC 0/8] Define coherent device memory node
In-Reply-To: <20161026160721.GA13638@gmail.com>
References: <1477283517-2504-1-git-send-email-khandual@linux.vnet.ibm.com> <20161024170902.GA5521@gmail.com> <87a8dtawas.fsf@linux.vnet.ibm.com> <20161025151637.GA6072@gmail.com> <87y41bcqow.fsf@linux.vnet.ibm.com> <20161026160721.GA13638@gmail.com>
Date: Fri, 28 Oct 2016 10:59:52 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <878tt96nxr.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, js1304@gmail.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, akpm@linux-foundation.org, bsingharora@gmail.com

Jerome Glisse <j.glisse@gmail.com> writes:

> On Wed, Oct 26, 2016 at 04:39:19PM +0530, Aneesh Kumar K.V wrote:
>> Jerome Glisse <j.glisse@gmail.com> writes:
>> 
>> > On Tue, Oct 25, 2016 at 09:56:35AM +0530, Aneesh Kumar K.V wrote:
>> >> Jerome Glisse <j.glisse@gmail.com> writes:
>> >> 
>> >> > On Mon, Oct 24, 2016 at 10:01:49AM +0530, Anshuman Khandual wrote:
>> >> >
>> >> I looked at the hmm-v13 w.r.t migration and I guess some form of device
>> >> callback/acceleration during migration is something we should definitely
>> >> have. I still haven't figured out how non addressable and coherent device
>> >> memory can fit together there. I was waiting for the page cache
>> >> migration support to be pushed to the repository before I start looking
>> >> at this closely.
>> >> 
>> >
>> > The page cache migration does not touch the migrate code path. My issue with
>> > page cache is writeback. The only difference with existing migrate code is
>> > refcount check for ZONE_DEVICE page. Everything else is the same.
>> 
>> What about the radix tree ? does file system migrate_page callback handle
>> replacing normal page with ZONE_DEVICE page/exceptional entries ?
>> 
>
> It use the exact same existing code (from mm/migrate.c) so yes the radix tree
> is updated and buffer_head are migrated.
>

I looked at the the page cache migration patches shared and I find that
you are not using exceptional entries when we migrate a page cache page to
device memory. But I am now not sure how a read from page cache will
work with that.

ie, a file system read will now find the page in page cache. But we
cannot do a copy_to_user of that page because that is now backed by an
unaddressable memory right ?

do_generic_file_read() does
      page = find_get_page(mapping, index);
      ....
      ret = copy_page_to_iter(page, offset, nr, iter);

which does
	void *kaddr = kmap_atomic(page);
	size_t wanted = copy_to_iter(kaddr + offset, bytes, i);
	kunmap_atomic(kaddr);


-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
