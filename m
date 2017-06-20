Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3798B6B0365
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 12:27:22 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id j65so88556739oib.1
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 09:27:22 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id e27si4204666oth.210.2017.06.20.09.27.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Jun 2017 09:27:21 -0700 (PDT)
Received: from mail-ua0-f181.google.com (mail-ua0-f181.google.com [209.85.217.181])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id BD490239F5
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 16:27:20 +0000 (UTC)
Received: by mail-ua0-f181.google.com with SMTP id j53so73188571uaa.2
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 09:27:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAPcyv4jkH6iwDoG4NnCaTNXozwYgVXiJDe2iFSONcE63KvGQoA@mail.gmail.com>
References: <149766213493.22552.4057048843646200083.stgit@dwillia2-desk3.amr.corp.intel.com>
 <CALCETrU1Hg=q4cdQDex--3nVBfwRC1o=9pC6Ss77Z8Lxg7ZJLg@mail.gmail.com>
 <CAPcyv4j4UEegViDJcLZjVv5AFGC18-DcvHFnhZatB0hH3BY85g@mail.gmail.com>
 <CALCETrUfv26pvmyQ1gOkKbzfSXK2DnmeBG6VmSWjFy1WBhknTw@mail.gmail.com>
 <CAPcyv4iPb69e+rE3fJUzm9U_P_dLfhantU9mvYmV-R0oQee4rA@mail.gmail.com>
 <CALCETrVY38h2ajpod2U_2pdHSp8zO4mG2p19h=OnnHmhGTairw@mail.gmail.com>
 <20170619132107.GG11993@dastard> <CALCETrUe0igzK0RZTSSondkCY3ApYQti89tOh00f0j_APrf_dQ@mail.gmail.com>
 <20170620004653.GI17542@dastard> <CALCETrVuoPDRuuhc9X8eVCYiFUzWLSTRkcjbD6jas_2J2GixNQ@mail.gmail.com>
 <20170620084924.GA9752@lst.de> <CAPcyv4jkH6iwDoG4NnCaTNXozwYgVXiJDe2iFSONcE63KvGQoA@mail.gmail.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Tue, 20 Jun 2017 09:26:59 -0700
Message-ID: <CALCETrVdOLTp1YYVwpsvWbZam2tgHnAxqERUP9c2CsbPGj+ARg@mail.gmail.com>
Subject: Re: [RFC PATCH 2/2] mm, fs: daxfile, an interface for
 byte-addressable updates to pmem
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Christoph Hellwig <hch@lst.de>, Andy Lutomirski <luto@kernel.org>, Dave Chinner <david@fromorbit.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Rudoff, Andy" <andy.rudoff@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, linux-nvdimm <linux-nvdimm@lists.01.org>, Linux API <linux-api@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, Linux FS Devel <linux-fsdevel@vger.kernel.org>

On Tue, Jun 20, 2017 at 9:17 AM, Dan Williams <dan.j.williams@intel.com> wrote:
> On Tue, Jun 20, 2017 at 1:49 AM, Christoph Hellwig <hch@lst.de> wrote:
>> [stripped giant fullquotes]
>>
>> On Mon, Jun 19, 2017 at 10:53:12PM -0700, Andy Lutomirski wrote:
>>> But that's my whole point.  The kernel doesn't really need to prevent
>>> all these background maintenance operations -- it just needs to block
>>> .page_mkwrite until they are synced.  I think that whatever new
>>> mechanism we add for this should be sticky, but I see no reason why
>>> the filesystem should have to block reflink on a DAX file entirely.
>>
>> Agreed - IFF we want to support write through semantics this is the
>> only somewhat feasible way.  It still has massive downsides of forcing
>> the full sync machinery to run from the page fauly handler, which
>> I'm rather scared off, but that's still better than creating a magic
>> special case that isn't managable at all.
>
> An immutable-extent DAX-file and a reflink-capable DAX-file are not
> mutually exclusive, and I have yet to hear a need for reflink support
> without fsync/msync. Instead I have heard the need for an immutable
> file for RDMA purposes, especially for hardware that can't trigger an
> mmu fault. The special management of an immutable file is acceptable
> to get these capabilities.

I guess this applies to any user of get_user_pages() on a DAX-mapped file.  Hmm.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
