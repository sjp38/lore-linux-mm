Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id A9FB36B02C3
	for <linux-mm@kvack.org>; Fri,  7 Jul 2017 06:23:28 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id l34so6863653wrc.12
        for <linux-mm@kvack.org>; Fri, 07 Jul 2017 03:23:28 -0700 (PDT)
Received: from mail-wr0-x242.google.com (mail-wr0-x242.google.com. [2a00:1450:400c:c0c::242])
        by mx.google.com with ESMTPS id e12si1966790wra.216.2017.07.07.03.23.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jul 2017 03:23:26 -0700 (PDT)
Received: by mail-wr0-x242.google.com with SMTP id z45so6678665wrb.2
        for <linux-mm@kvack.org>; Fri, 07 Jul 2017 03:23:26 -0700 (PDT)
Date: Fri, 7 Jul 2017 13:23:24 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC PATCH 1/1] mm/mremap: add MREMAP_MIRROR flag for existing
 mirroring functionality
Message-ID: <20170707102324.kfihkf72sjcrtn5b@node.shutemov.name>
References: <1499357846-7481-1-git-send-email-mike.kravetz@oracle.com>
 <1499357846-7481-2-git-send-email-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1499357846-7481-2-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Aaron Lu <aaron.lu@intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

On Thu, Jul 06, 2017 at 09:17:26AM -0700, Mike Kravetz wrote:
> The mremap system call has the ability to 'mirror' parts of an existing
> mapping.  To do so, it creates a new mapping that maps the same pages as
> the original mapping, just at a different virtual address.  This
> functionality has existed since at least the 2.6 kernel.
> 
> This patch simply adds a new flag to mremap which will make this
> functionality part of the API.  It maintains backward compatibility with
> the existing way of requesting mirroring (old_size == 0).
> 
> If this new MREMAP_MIRROR flag is specified, then new_size must equal
> old_size.  In addition, the MREMAP_MAYMOVE flag must be specified.

The patch breaks important invariant that anon page can be mapped into a
process only once.

What is going to happen to mirrored after CoW for instance?

In my opinion, it shouldn't be allowed for anon/private mappings at least.
And with this limitation, I don't see much sense in the new interface --
just create mirror by mmap()ing the file again.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
