Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 6109A6B006C
	for <linux-mm@kvack.org>; Mon,  1 Dec 2014 13:00:31 -0500 (EST)
Received: by mail-wg0-f42.google.com with SMTP id z12so14897438wgg.1
        for <linux-mm@kvack.org>; Mon, 01 Dec 2014 10:00:31 -0800 (PST)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.227])
        by mx.google.com with ESMTP id it9si6300634wid.96.2014.12.01.10.00.30
        for <linux-mm@kvack.org>;
        Mon, 01 Dec 2014 10:00:30 -0800 (PST)
Date: Mon, 1 Dec 2014 20:00:23 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v1 0/4] Refactor do_wp_page, no functional change
Message-ID: <20141201180023.GB16334@node.dhcp.inet.fi>
References: <1417452977-11337-1-git-send-email-raindel@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1417452977-11337-1-git-send-email-raindel@mellanox.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shachar Raindel <raindel@mellanox.com>
Cc: linux-mm@kvack.org, kirill.shutemov@linux.intel.com, mgorman@suse.de, riel@redhat.com, ak@linux.intel.com, matthew.r.wilcox@intel.com, dave.hansen@linux.intel.com, n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org, torvalds@linux-foundation.org, haggaie@mellanox.com, aarcange@redhat.com, pfeiner@google.com, hannes@cmpxchg.org, sagig@mellanox.com, walken@google.com

On Mon, Dec 01, 2014 at 06:56:13PM +0200, Shachar Raindel wrote:
> Currently do_wp_page contains 265 code lines. It also contains 9 goto
> statements, of which 5 are targeting labels which are not cleanup
> related. This makes the function extremely difficult to
> understand. The following patches are an attempt at breaking the
> function to its basic components, and making it easier to understand.
> 
> The patches are straight forward function extractions from
> do_wp_page. As we extract functions, we remove unneeded parameters and
> simplify the code as much as possible. However, the functionality is
> supposed to remain completely unchanged. The patches also attempt to
> document the functionality of each extracted function. In patch 2, we
> split the unlock logic to the contain logic relevant to specific needs
> of each use case, instead of having huge number of conditional
> decisions in a single unlock flow.
> 
> 
> Change log:
> 
> v0 -> v1:
> - Minor renaming of argument in patch 1
> - Instead of having a complex unlock function, unlock the needed parts
>   in the relevant call sites. Simplify code accordingly.
> - Avoid calling wp_page_copy with the ptl held.
> - Rename wp_page_shared_vma to wp_page_shared, flip the logic of a
>   check there to goto the end of the function if no function, instead
>   of having a large conditional block.
> 
> Shachar Raindel (4):
>   mm: Refactor do_wp_page, extract the reuse case
>   mm: Refactor do_wp_page - rewrite the unlock flow
>   mm: refactor do_wp_page, extract the page copy flow
>   mm: Refactor do_wp_page handling of shared vma into a function
> 
>  mm/memory.c | 397 +++++++++++++++++++++++++++++++++++-------------------------
>  1 file changed, 231 insertions(+), 166 deletions(-)

See few nitpicks in 4/4, but looks like a good cleanup. Thanks.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
