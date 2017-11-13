Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id C45F56B0253
	for <linux-mm@kvack.org>; Mon, 13 Nov 2017 17:46:29 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id c123so8381430pga.17
        for <linux-mm@kvack.org>; Mon, 13 Nov 2017 14:46:29 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id p4si6142277pgc.477.2017.11.13.14.46.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Nov 2017 14:46:28 -0800 (PST)
Subject: Re: [PATCH v6 03/11] mm, x86: Add support for eXclusive Page Frame
 Ownership (XPFO)
From: Dave Hansen <dave.hansen@intel.com>
References: <20170907173609.22696-1-tycho@docker.com>
 <20170907173609.22696-4-tycho@docker.com>
 <34454a32-72c2-c62e-546c-1837e05327e1@intel.com>
 <20170920223452.vam3egenc533rcta@smitten>
 <97475308-1f3d-ea91-5647-39231f3b40e5@intel.com>
 <20170921000901.v7zo4g5edhqqfabm@docker>
 <d1a35583-8225-2ab3-d9fa-273482615d09@intel.com>
 <20171110010907.qfkqhrbtdkt5y3hy@smitten>
 <7237ae6d-f8aa-085e-c144-9ed5583ec06b@intel.com>
Message-ID: <2aa64bf6-fead-08cc-f4fe-bd353008ca59@intel.com>
Date: Mon, 13 Nov 2017 14:46:25 -0800
MIME-Version: 1.0
In-Reply-To: <7237ae6d-f8aa-085e-c144-9ed5583ec06b@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tycho Andersen <tycho@docker.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, x86@kernel.org

On 11/13/2017 02:20 PM, Dave Hansen wrote:
> On 11/09/2017 05:09 PM, Tycho Andersen wrote:
>> which I guess is from the additional flags in grow_dev_page() somewhere down
>> the stack. Anyway... it seems this is a kernel allocation that's using
>> MIGRATE_MOVABLE, so perhaps we need some more fine tuned heuristic than just
>> all MOVABLE allocations are un-mapped via xpfo, and all the others are mapped.
>>
>> Do you have any ideas?
> 
> It still has to do a kmap() or kmap_atomic() to be able to access it.  I
> thought you hooked into that.  Why isn't that path getting hit for these?

Oh, this looks to be accessing data mapped by a buffer_head.  It
(rudely) accesses data via:

void set_bh_page(struct buffer_head *bh,
...
	bh->b_data = page_address(page) + offset;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
