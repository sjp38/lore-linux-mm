Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6FFDD6B02FA
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 12:17:38 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id k126so88079677oia.7
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 09:17:38 -0700 (PDT)
Received: from mail-oi0-x22d.google.com (mail-oi0-x22d.google.com. [2607:f8b0:4003:c06::22d])
        by mx.google.com with ESMTPS id a41si2728423ota.14.2017.06.20.09.17.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Jun 2017 09:17:37 -0700 (PDT)
Received: by mail-oi0-x22d.google.com with SMTP id p187so17172650oif.3
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 09:17:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170620084924.GA9752@lst.de>
References: <149766213493.22552.4057048843646200083.stgit@dwillia2-desk3.amr.corp.intel.com>
 <CALCETrU1Hg=q4cdQDex--3nVBfwRC1o=9pC6Ss77Z8Lxg7ZJLg@mail.gmail.com>
 <CAPcyv4j4UEegViDJcLZjVv5AFGC18-DcvHFnhZatB0hH3BY85g@mail.gmail.com>
 <CALCETrUfv26pvmyQ1gOkKbzfSXK2DnmeBG6VmSWjFy1WBhknTw@mail.gmail.com>
 <CAPcyv4iPb69e+rE3fJUzm9U_P_dLfhantU9mvYmV-R0oQee4rA@mail.gmail.com>
 <CALCETrVY38h2ajpod2U_2pdHSp8zO4mG2p19h=OnnHmhGTairw@mail.gmail.com>
 <20170619132107.GG11993@dastard> <CALCETrUe0igzK0RZTSSondkCY3ApYQti89tOh00f0j_APrf_dQ@mail.gmail.com>
 <20170620004653.GI17542@dastard> <CALCETrVuoPDRuuhc9X8eVCYiFUzWLSTRkcjbD6jas_2J2GixNQ@mail.gmail.com>
 <20170620084924.GA9752@lst.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 20 Jun 2017 09:17:36 -0700
Message-ID: <CAPcyv4jkH6iwDoG4NnCaTNXozwYgVXiJDe2iFSONcE63KvGQoA@mail.gmail.com>
Subject: Re: [RFC PATCH 2/2] mm, fs: daxfile, an interface for
 byte-addressable updates to pmem
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Andy Lutomirski <luto@kernel.org>, Dave Chinner <david@fromorbit.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Rudoff, Andy" <andy.rudoff@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, linux-nvdimm <linux-nvdimm@lists.01.org>, Linux API <linux-api@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, Linux FS Devel <linux-fsdevel@vger.kernel.org>

On Tue, Jun 20, 2017 at 1:49 AM, Christoph Hellwig <hch@lst.de> wrote:
> [stripped giant fullquotes]
>
> On Mon, Jun 19, 2017 at 10:53:12PM -0700, Andy Lutomirski wrote:
>> But that's my whole point.  The kernel doesn't really need to prevent
>> all these background maintenance operations -- it just needs to block
>> .page_mkwrite until they are synced.  I think that whatever new
>> mechanism we add for this should be sticky, but I see no reason why
>> the filesystem should have to block reflink on a DAX file entirely.
>
> Agreed - IFF we want to support write through semantics this is the
> only somewhat feasible way.  It still has massive downsides of forcing
> the full sync machinery to run from the page fauly handler, which
> I'm rather scared off, but that's still better than creating a magic
> special case that isn't managable at all.

An immutable-extent DAX-file and a reflink-capable DAX-file are not
mutually exclusive, and I have yet to hear a need for reflink support
without fsync/msync. Instead I have heard the need for an immutable
file for RDMA purposes, especially for hardware that can't trigger an
mmu fault. The special management of an immutable file is acceptable
to get these capabilities.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
