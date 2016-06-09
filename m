Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f199.google.com (mail-ig0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2C8C46B0005
	for <linux-mm@kvack.org>; Thu,  9 Jun 2016 11:41:53 -0400 (EDT)
Received: by mail-ig0-f199.google.com with SMTP id i11so59176636igh.0
        for <linux-mm@kvack.org>; Thu, 09 Jun 2016 08:41:53 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id to3si8145368pac.1.2016.06.09.08.41.51
        for <linux-mm@kvack.org>;
        Thu, 09 Jun 2016 08:41:51 -0700 (PDT)
Subject: Re: [PATCH 1/1] mm/swap.c: flush lru_add pvecs on compound page
 arrival
References: <1465396537-17277-1-git-send-email-lukasz.odzioba@intel.com>
 <57583A49.30809@intel.com>
 <D6EDEBF1F91015459DB866AC4EE162CC023F8EBE@IRSMSX103.ger.corp.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <57598E3E.3010705@intel.com>
Date: Thu, 9 Jun 2016 08:41:50 -0700
MIME-Version: 1.0
In-Reply-To: <D6EDEBF1F91015459DB866AC4EE162CC023F8EBE@IRSMSX103.ger.corp.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Odzioba, Lukasz" <lukasz.odzioba@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "mhocko@suse.com" <mhocko@suse.com>, "aarcange@redhat.com" <aarcange@redhat.com>, "vdavydov@parallels.com" <vdavydov@parallels.com>, "mingli199x@qq.com" <mingli199x@qq.com>, "minchan@kernel.org" <minchan@kernel.org>
Cc: "Anaczkowski, Lukasz" <lukasz.anaczkowski@intel.com>

On 06/09/2016 01:50 AM, Odzioba, Lukasz wrote:
> On 08-06-16 17:31:00, Dave Hansen wrote:
>> Do we have any statistics that tell us how many pages are sitting the
>> lru pvecs?  Although this helps the problem overall, don't we still have
>> a problem with memory being held in such an opaque place?
> 
>>From what I observed the problem is mainly with lru_add_pvec, the
> rest is near empty for most of the time. I added debug code to
>  lru_add_drain_all(), to see sizes of the lru pvecs when I debugged this.
> 
> Among lru_add_pvec, lru_rotate_pvecs, lru_deactivate_file_pvecs, 
> lru_deactivate_pvecs, activate_page_pvecs almost all (3-4GB) of the 
> missing memory was in lru_add_pvec, the rest was almost always empty.

Does your workload put large pages in and out of those pvecs, though?
If your system doesn't have any activity, then all we've shown is that
they're not a problem when not in use.  But what about when we use them?

Have you, for instance, tried this on a system with memory pressure?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
