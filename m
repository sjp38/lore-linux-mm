Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id B779B6B0033
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 09:54:25 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id l18so2982083wrc.23
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 06:54:25 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 4si1635558eds.41.2017.11.02.06.54.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 02 Nov 2017 06:54:24 -0700 (PDT)
Date: Thu, 2 Nov 2017 14:54:23 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v1 1/1] mm: buddy page accessed before initialized
Message-ID: <20171102135423.voxnzk2qkvfgu5l3@dhcp22.suse.cz>
References: <20171031155002.21691-1-pasha.tatashin@oracle.com>
 <20171031155002.21691-2-pasha.tatashin@oracle.com>
 <20171102133235.2vfmmut6w4of2y3j@dhcp22.suse.cz>
 <a9b637b0-2ff0-80e8-76a7-801c5c0820a8@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a9b637b0-2ff0-80e8-76a7-801c5c0820a8@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, akpm@linux-foundation.org, mgorman@techsingularity.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 02-11-17 09:39:58, Pavel Tatashin wrote:
[...]
> Hi Michal,
> 
> Previously as before my project? That is because memory for all struct pages
> was always zeroed in memblock, and in __free_one_page() page_is_buddy() was
> always returning false, thus we never tried to incorrectly remove it from
> the list:
> 
> 837			list_del(&buddy->lru);
> 
> Now, that memory is not zeroed, page_is_buddy() can return true after kexec
> when memory is dirty (unfortunately memset(1) with CONFIG_VM_DEBUG does not
> catch this case). And proceed further to incorrectly remove buddy from the
> list.

OK, I thought this was a regression from one of the recent patches. So
the problem is not new. Why don't we see the same problem during the
standard boot?

> This is why we must initialize the computed buddy page beforehand.

Ble, this is really ugly. I will think about it more.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
