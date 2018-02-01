Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id F1E356B0006
	for <linux-mm@kvack.org>; Thu,  1 Feb 2018 09:19:41 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id w22so8412830otj.19
        for <linux-mm@kvack.org>; Thu, 01 Feb 2018 06:19:41 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 2si958699oil.280.2018.02.01.06.19.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Feb 2018 06:19:41 -0800 (PST)
Date: Thu, 1 Feb 2018 22:19:34 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: [PATCH 2/2] mm/sparse.c: Add nr_present_sections to change the
 mem_map allocation
Message-ID: <20180201141934.GC1770@localhost.localdomain>
References: <20180201071956.14365-1-bhe@redhat.com>
 <20180201071956.14365-3-bhe@redhat.com>
 <20180201101641.icoxv2sp6ckrjfxd@node.shutemov.name>
 <6def8374-2de2-a30c-69ff-2a49fb57dc9a@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6def8374-2de2-a30c-69ff-2a49fb57dc9a@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, tglx@linutronix.de, douly.fnst@cn.fujitsu.com

On 02/01/18 at 05:49am, Dave Hansen wrote:
> On 02/01/2018 02:16 AM, Kirill A. Shutemov wrote:
> > On Thu, Feb 01, 2018 at 03:19:56PM +0800, Baoquan He wrote:
> >> In sparse_init(), we allocate usemap_map and map_map which are pointer
> >> array with the size of NR_MEM_SECTIONS. The memory consumption can be
> >> ignorable in 4-level paging mode. While in 5-level paging, this costs
> >> much memory, 512M. Kdump kernel even can't boot up with a normal
> >> 'crashkernel=' setting.
> >>
> >> Here add a new variable to record the number of present sections. Let's
> >> allocate the usemap_map and map_map with the size of nr_present_sections.
> >> We only need to make sure that for the ith present section, usemap_map[i]
> >> and map_map[i] store its usemap and mem_map separately.
> >>
> >> This change can save much memory on most of systems. Anytime, we should
> >> avoid to define array or allocate memory with the size of NR_MEM_SECTIONS.
> > That's very desirable outcome. But I don't know much about sparsemem.
> 
> ... with the downside being that we can no longer hot-add memory that
> was not part of the original, present sections.
> 
> Is that OK?

Thanks for looking into this, Dave!

I suppose these functions changed here are only called during system
bootup, namely in paging_init(). Hot-add memory goes in a different
path, __add_section() -> sparse_add_one_section(), different called
functions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
