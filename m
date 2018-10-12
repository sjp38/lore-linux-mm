Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3511D6B0283
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 14:14:30 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id j60-v6so12786312qtb.8
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 11:14:30 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t63-v6si941803qkc.113.2018.10.12.11.14.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Oct 2018 11:14:29 -0700 (PDT)
Date: Fri, 12 Oct 2018 14:14:25 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH v7 0/7] mm: Merge hmm into devm_memremap_pages, mark
 GPL-only
Message-ID: <20181012181425.GF6593@redhat.com>
References: <153936657159.1198040.4489957977352276272.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <153936657159.1198040.4489957977352276272.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, stable@vger.kernel.org, Balbir Singh <bsingharora@gmail.com>, Logan Gunthorpe <logang@deltatee.com>, Christoph Hellwig <hch@lst.de>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Oct 12, 2018 at 10:49:31AM -0700, Dan Williams wrote:
> [ apologies for the resend, script error ]
> 
> Changes since v6 [1]:
> * Rebase on next-20181008 and fixup conflicts with the xarray conversion
>   and hotplug optimizations
> * It has soaked on a 0day visible branch for a few days without any
>   reports.
> 
> [1]: https://lkml.org/lkml/2018/9/13/104
> 
> ---
> 
> Hi Andrew,
> 
> Jerome has reviewed the cleanups, thanks Jerome. We still disagree on
> the EXPORT_SYMBOL_GPL status of the core HMM implementation, but Logan,
> Christoph and I continue to support marking all devm_memremap_pages()
> derivatives EXPORT_SYMBOL_GPL.
> 
> HMM has been upstream for over a year, with no in-tree users it is clear
> it was designed first and foremost for out of tree drivers. It takes
> advantage of a facility Christoph and I spearheaded to support
> persistent memory. It continues to see expanding use cases with no clear
> end date when it will stop attracting features / revisions. It is not
> suitable to export devm_memremap_pages() as a stable 3rd party driver
> api.
> 
> devm_memremap_pages() is a facility that can create struct page entries
> for any arbitrary range and give out-of-tree drivers the ability to
> subvert core aspects of page management. It, and anything derived from
> it (e.g. hmm, pcip2p, etc...), is a deep integration point into the core
> kernel, and an EXPORT_SYMBOL_GPL() interface. 
> 
> Commit 31c5bda3a656 "mm: fix exports that inadvertently make put_page()
> EXPORT_SYMBOL_GPL" was merged ahead of this series to relieve some of
> the pressure from innocent consumers of put_page(), but now we need this
> series to address *producers* of device pages.
> 
> More details and justification in the changelogs. The 0day
> infrastructure has reported success across 152 configs and this survives
> the libnvdimm unit test suite. Aside from the controversial bits the
> diffstat is compelling at:
> 
> 	7 files changed, 126 insertions(+), 323 deletions(-)
> 
> Note that the series has some minor collisions with Alex's recent series
> to improve devm_memremap_pages() scalability [2]. So, whichever you take
> first the other will need a minor rebase.
> 
> [2]: https://www.lkml.org/lkml/2018/9/11/10

I am fine with this patchset going in (i reviewed it and tested it with
HMM on nouveau), Dan and Christoph did author the original code around
devm_memremap_pages() and thus ultimately they are the one who should
decide over GPL export or not.

Cheers,
Jerome
