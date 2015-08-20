Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 0DB476B0253
	for <linux-mm@kvack.org>; Thu, 20 Aug 2015 08:31:12 -0400 (EDT)
Received: by wicja10 with SMTP id ja10so34914244wic.1
        for <linux-mm@kvack.org>; Thu, 20 Aug 2015 05:31:11 -0700 (PDT)
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com. [209.85.212.169])
        by mx.google.com with ESMTPS id jf3si8169506wjb.131.2015.08.20.05.31.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Aug 2015 05:31:10 -0700 (PDT)
Received: by wicja10 with SMTP id ja10so144302172wic.1
        for <linux-mm@kvack.org>; Thu, 20 Aug 2015 05:31:10 -0700 (PDT)
Date: Thu, 20 Aug 2015 15:31:07 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv3 0/5] Fix compound_head() race
Message-ID: <20150820123107.GA31768@node.dhcp.inet.fi>
References: <1439976106-137226-1-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="6TrnltStXW4iwmi0"
Content-Disposition: inline
In-Reply-To: <1439976106-137226-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org


--6TrnltStXW4iwmi0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Aug 19, 2015 at 12:21:41PM +0300, Kirill A. Shutemov wrote:
> Here's my attempt on fixing recently discovered race in compound_head().
> It should make compound_head() reliable in all contexts.
> 
> The patchset is against Linus' tree. Let me know if it need to be rebased
> onto different baseline.
> 
> It's expected to have conflicts with my page-flags patchset and probably
> should be applied before it.
> 
> v3:
>    - Fix build without hugetlb;
>    - Drop page->first_page;
>    - Update comment for free_compound_page();
>    - Use 'unsigned int' for page order;
> 
> v2: Per Hugh's suggestion page->compound_head is moved into third double
>     word. This way we can avoid memory overhead which v1 had in some
>     cases.
> 
>     This place in struct page is rather overloaded. More testing is
>     required to make sure we don't collide with anyone.

Andrew, can we have the patchset applied, if nobody has objections?

It applies cleanly into your patchstack just before my page-flags
patchset.

As expected, it causes few conflicts with patches:

 page-flags-introduce-page-flags-policies-wrt-compound-pages.patch
 mm-sanitize-page-mapping-for-tail-pages.patch
 include-linux-page-flagsh-rename-macros-to-avoid-collisions.patch

Updated patches with solved conflicts are attached.

Let me know if I need to do anything else about this.

Hugh, does it address your worry wrt page-flags?

Before you've mentioned races of whether the head page still agrees with
the tail. I don't think it's an issue: you can get this kind of race only
in very special environments like pfn scanner where you anyway need to
re-validate the page after stabilizing it.

Bloat from my page-flags is also reduced substantially. Size of your
page_is_locked() example in allnoconfig case reduced from 32 to 17 bytes.
With the patchset it look this way:

00003070 <page_is_locked>:
    3070:	8b 50 14             	mov    0x14(%eax),%edx
    3073:	f6 c2 01             	test   $0x1,%dl
    3076:	8d 4a ff             	lea    -0x1(%edx),%ecx
    3079:	0f 45 c1             	cmovne %ecx,%eax
    307c:	8b 00                	mov    (%eax),%eax
    307e:	24 01                	and    $0x1,%al
    3080:	c3                   	ret    

-- 
 Kirill A. Shutemov

--6TrnltStXW4iwmi0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="include-linux-page-flagsh-rename-macros-to-avoid-collisions.patch"


--6TrnltStXW4iwmi0--
