Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 65B2E8E00E5
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 01:16:47 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id c34so7842108edb.8
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 22:16:47 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d19si1867631edy.436.2018.12.11.22.16.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Dec 2018 22:16:46 -0800 (PST)
Message-ID: <1544595387.3125.2.camel@suse.de>
Subject: Re: [PATCH v2] mm, memory_hotplug: Don't bail out in
 do_migrate_range prematurely
From: Oscar Salvador <osalvador@suse.de>
Date: Wed, 12 Dec 2018 07:16:27 +0100
In-Reply-To: <20181212033506.tyj747b7kzyvsp4c@master>
References: <20181211135312.27034-1-osalvador@suse.de>
	 <20181212033506.tyj747b7kzyvsp4c@master>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, david@redhat.com, pasha.tatashin@soleen.com, dan.j.williams@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 2018-12-12 at 03:35 +0000, Wei Yang wrote:
> I see the above code is wrapped with CONFIG_DEBUG_VM on current Linus
> tree.
> This is removed by someone else?

Yes, e8abbd69957288 ("mm, memory_hotplug: be more verbose for memory
offline failures") got rid of the CONFIG_DEBUG_VM.
This commit is sitting in the -mmotm tree.

> 
> > -			put_page(page);
> > -			/* Because we don't have big zone->lock.
> > we should
> > -			   check this again here. */
> > -			if (page_count(page)) {
> > -				not_managed++;
> > -				ret = -EBUSY;
> > -				break;
> > -			}
> > 		}
> > +		put_page(page);
> > 	}
> > 	if (!list_empty(&source)) {
> > -		if (not_managed) {
> > -			putback_movable_pages(&source);
> > -			goto out;
> > -		}
> > -
> > 		/* Allocate a new page from the nearest neighbor node
> > */
> > 		ret = migrate_pages(&source, new_node_page, NULL, 0,
> > 					MIGRATE_SYNC,
> > MR_MEMORY_HOTPLUG);
> > @@ -1426,7 +1412,7 @@ do_migrate_range(unsigned long start_pfn,
> > unsigned long end_pfn)
> > 			putback_movable_pages(&source);
> > 		}
> > 	}
> > -out:
> > +
> > 	return ret;
> > }
> > 
> > -- 
> > 2.13.7
> 
> 
-- 
Oscar Salvador
SUSE L3
