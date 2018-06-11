Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id BA8FA6B0005
	for <linux-mm@kvack.org>; Mon, 11 Jun 2018 19:35:24 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id 18-v6so14180167oix.4
        for <linux-mm@kvack.org>; Mon, 11 Jun 2018 16:35:24 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 31-v6sor28892992otf.157.2018.06.11.16.35.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Jun 2018 16:35:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180611145809.c05f215b9b2e7dab9e808304@linux-foundation.org>
References: <152669369110.34337.14271778212195820353.stgit@dwillia2-desk3.amr.corp.intel.com>
 <152669370864.34337.13815113039455146564.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20180611145809.c05f215b9b2e7dab9e808304@linux-foundation.org>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 11 Jun 2018 16:35:22 -0700
Message-ID: <CAPcyv4gziGh7Xih_W2-5nxpHRLnUwi1nDtwsC7bbQousuibsQg@mail.gmail.com>
Subject: Re: [PATCH v11 3/7] mm: fix __gup_device_huge vs unmap
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-nvdimm <linux-nvdimm@lists.01.org>, stable <stable@vger.kernel.org>, Jan Kara <jack@suse.cz>, david <david@fromorbit.com>, Christoph Hellwig <hch@lst.de>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On Mon, Jun 11, 2018 at 2:58 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Fri, 18 May 2018 18:35:08 -0700 Dan Williams <dan.j.williams@intel.com> wrote:
>
>> get_user_pages_fast() for device pages is missing the typical validation
>> that all page references have been taken while the mapping was valid.
>> Without this validation truncate operations can not reliably coordinate
>> against new page reference events like O_DIRECT.
>>
>> Cc: <stable@vger.kernel.org>
>
> I'm not seeing anything in the changelog which justifies a -stable
> backport.  ie: a description of the end-user-visible effects of the
> bug?
>

Without this change get_user_pages_fast() could race truncate. The
ordering of page_cache_add_speculative() before re-validating the
mapping allows truncate and page freeing to synchronize against
get_user_pages_fast().

Specifically, a get_user_pages_fast() thread could continue allowing a
page to be mapped and accessed via the kernel mapping after it was
meant to be torn down. This could cause unexpected data corruption or
access to the physical page after it has been invalidated from process
page tables.

Ideally I think we would go further than this patch and backport the
full fix for the filesystem-dax-vs-truncate problem. I was planning to
spin up a 4.14 backport with the full set of the pieces that went into
4.17 and 4.18.
