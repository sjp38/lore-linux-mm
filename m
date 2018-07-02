Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id A89476B0007
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 15:51:54 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id q21-v6so9127527pff.4
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 12:51:54 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id v187-v6si15033911pgv.678.2018.07.02.12.51.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 12:51:51 -0700 (PDT)
Date: Mon, 2 Jul 2018 12:51:50 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm: teach dump_page() to correctly output poisoned
 struct pages
Message-Id: <20180702125150.a7b69e852d9b7bd52f1f451d@linux-foundation.org>
In-Reply-To: <20180702180536.2552-1-pasha.tatashin@oracle.com>
References: <20180702180536.2552-1-pasha.tatashin@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, linux-kernel@vger.kernel.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, linux-mm@kvack.org, mgorman@techsingularity.net, gregkh@linuxfoundation.org

On Mon,  2 Jul 2018 14:05:36 -0400 Pavel Tatashin <pasha.tatashin@oracle.com> wrote:

> If struct page is poisoned, and uninitialized access is detected via
> PF_POISONED_CHECK(page) dump_page() is called to output the page. But,
> the dump_page() itself accesses struct page to determine how to print
> it, and therefore gets into a recursive loop.
> 
> For example:
> dump_page()
>  __dump_page()
>   PageSlab(page)
>    PF_POISONED_CHECK(page)
>     VM_BUG_ON_PGFLAGS(PagePoisoned(page), page)
>      dump_page() recursion loop.
> 
> Fixes: f165b378bbdf ("mm: uninitialized struct page poisoning sanity checking")
> 
> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
> Acked-by: Michal Hocko <mhocko@suse.com>

Thanks.  I added a cc:stable to make sure this gets into 4.17.x.
