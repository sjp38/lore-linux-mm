Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5D9AF6B0279
	for <linux-mm@kvack.org>; Thu, 15 Jun 2017 18:16:41 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id x23so5218751wrb.6
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 15:16:41 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id m143si404308wmg.179.2017.06.15.15.16.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Jun 2017 15:16:40 -0700 (PDT)
Date: Thu, 15 Jun 2017 15:16:37 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v5] mm: huge-vmap: fail gracefully on unexpected huge
 vmap mappings
Message-Id: <20170615151637.77babb9a1b65c878f4235f65@linux-foundation.org>
In-Reply-To: <BE70CA51-B790-456E-B31C-399632B4DCD1@linaro.org>
References: <20170609082226.26152-1-ard.biesheuvel@linaro.org>
	<20170615142439.7a431065465c5b4691aed1cc@linux-foundation.org>
	<BE70CA51-B790-456E-B31C-399632B4DCD1@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: linux-mm@kvack.org, mhocko@suse.com, zhongjiang@huawei.com, labbott@fedoraproject.org, mark.rutland@arm.com, linux-arm-kernel@lists.infradead.org, dave.hansen@intel.com

On Fri, 16 Jun 2017 00:11:53 +0200 Ard Biesheuvel <ard.biesheuvel@linaro.org> wrote:

> 
> 
> > On 15 Jun 2017, at 23:24, Andrew Morton <akpm@linux-foundation.org> wrote:
> > 
> >> On Fri,  9 Jun 2017 08:22:26 +0000 Ard Biesheuvel <ard.biesheuvel@linaro.org> wrote:
> >> 
> >> Existing code that uses vmalloc_to_page() may assume that any
> >> address for which is_vmalloc_addr() returns true may be passed
> >> into vmalloc_to_page() to retrieve the associated struct page.
> >> 
> >> This is not un unreasonable assumption to make, but on architectures
> >> that have CONFIG_HAVE_ARCH_HUGE_VMAP=y, it no longer holds, and we
> >> need to ensure that vmalloc_to_page() does not go off into the weeds
> >> trying to dereference huge PUDs or PMDs as table entries.
> >> 
> >> Given that vmalloc() and vmap() themselves never create huge
> >> mappings or deal with compound pages at all, there is no correct
> >> answer in this case, so return NULL instead, and issue a warning.
> > 
> > Is this patch known to fix any current user-visible problem?
> 
> Yes. When reading /proc/kcore on arm64, you will hit an oops as soon as you hit the huge mappings used for the various segments that make up the mapping of vmlinux. With this patch applied, you will no longer hit the oops, but the kcore contents willl be incorrect (these regions will be zeroed out)
> 
> We are fixing this for kcore specifically, so it avoids vread() for  those regions. At least one other problematic user exists, i.e., /dev/kmem, but that is currently broken on arm64 for other reasons.
> 

Do you have any suggestions regarding which kernel version(s) should
get this patch?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
