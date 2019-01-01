Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 271B88E0002
	for <linux-mm@kvack.org>; Tue,  1 Jan 2019 05:15:41 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id d31so36622350qtc.4
        for <linux-mm@kvack.org>; Tue, 01 Jan 2019 02:15:41 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id v6si5886666qte.364.2019.01.01.02.15.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Jan 2019 02:15:40 -0800 (PST)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id x01ADvkF009699
	for <linux-mm@kvack.org>; Tue, 1 Jan 2019 05:15:40 -0500
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2pr417vnna-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 01 Jan 2019 05:15:39 -0500
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Tue, 1 Jan 2019 10:15:38 -0000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: Re: [PATCH] mm: Introduce page_size()
In-Reply-To: <20190101063031.GD6310@bombadil.infradead.org>
References: <20181231134223.20765-1-willy@infradead.org> <87y385awg6.fsf@linux.ibm.com> <20190101063031.GD6310@bombadil.infradead.org>
Date: Tue, 01 Jan 2019 15:45:22 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87imz87kg5.fsf@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

Matthew Wilcox <willy@infradead.org> writes:

> On Tue, Jan 01, 2019 at 08:57:53AM +0530, Aneesh Kumar K.V wrote:
>> Matthew Wilcox <willy@infradead.org> writes:
>> > +/* Returns the number of bytes in this potentially compound page. */
>> > +static inline unsigned long page_size(struct page *page)
>> > +{
>> > +	return (unsigned long)PAGE_SIZE << compound_order(page);
>> > +}
>> > +
>> 
>> How about compound_page_size() to make it clear this is for
>> compound_pages? Should we make it work with Tail pages by doing
>> compound_head(page)?
>
> I think that's a terrible idea.  Actually, I think the whole way we handle
> compound pages is terrible; we should only ever see head pages.  Doing
> page cache lookups should only give us head pages.  Calling pfn_to_page()
> should give us the head page.  We should only put head pages into SG lists.
> Everywhere you see a struct page should only be a head page.
>
> I know we're far from that today, and there's lots of work to be done
> to get there.  But the current state of handling compound pages is awful
> and confusing.

One exception is THP compound pages which can also be mapped as regular
pages in some page tables?

-aneesh
