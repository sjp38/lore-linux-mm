Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id CEB6A6B00A2
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 19:49:21 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id lf10so4467066pab.41
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 16:49:21 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id sg10si17605876pbb.249.2014.06.02.16.49.20
        for <linux-mm@kvack.org>;
        Mon, 02 Jun 2014 16:49:20 -0700 (PDT)
Message-ID: <538D0D7E.6000405@intel.com>
Date: Mon, 02 Jun 2014 16:49:18 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 01/11] pagewalk: update page table walker core
References: <1392068676-30627-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1392068676-30627-2-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1392068676-30627-2-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Cliff Wickman <cpw@sgi.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@parallels.com>, Rik van Riel <riel@redhat.com>, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org

On 02/10/2014 01:44 PM, Naoya Horiguchi wrote:
> When we try to use multiple callbacks in different levels, skip control is
> also important. For example we have thp enabled in normal configuration, and
> we are interested in doing some work for a thp. But sometimes we want to
> split it and handle as normal pages, and in another time user would handle
> both at pmd level and pte level.
> What we need is that when we've done pmd_entry() we want to decide whether
> to go down to pte level handling based on the pmd_entry()'s result. So this
> patch introduces a skip control flag in mm_walk.
> We can't use the returned value for this purpose, because we already
> defined the meaning of whole range of returned values (>0 is to terminate
> page table walk in caller's specific manner, =0 is to continue to walk,
> and <0 is to abort the walk in the general manner.)

This seems a bit complicated for a case which doesn't exist in practice
in the kernel today.  We don't even *have* a single ->pte_entry handler.
 Everybody just sets ->pmd_entry and does the splitting and handling of
individual pte entries in there.  The only reason it's needed is because
of the later patches in the series, which is kinda goofy.

I'm biased, but I think the abstraction here is done in the wrong place.

Naoya, could you take a looked at the new handler I proposed?  Would
that help make this simpler?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
