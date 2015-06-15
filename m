Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 7AC246B0038
	for <linux-mm@kvack.org>; Mon, 15 Jun 2015 17:18:21 -0400 (EDT)
Received: by wifx6 with SMTP id x6so964022wif.0
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 14:18:20 -0700 (PDT)
Received: from mail-wg0-x22e.google.com (mail-wg0-x22e.google.com. [2a00:1450:400c:c00::22e])
        by mx.google.com with ESMTPS id u7si20320619wiw.120.2015.06.15.14.18.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jun 2015 14:18:19 -0700 (PDT)
Received: by wgv5 with SMTP id 5so78647602wgv.1
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 14:18:19 -0700 (PDT)
Date: Mon, 15 Jun 2015 23:18:16 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: Possible broken MM code in dell-laptop.c?
Message-ID: <20150615211816.GC16138@dhcp22.suse.cz>
References: <201506141105.07171@pali>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <201506141105.07171@pali>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pali =?iso-8859-1?Q?Roh=E1r?= <pali.rohar@gmail.com>
Cc: Hans de Goede <hdegoede@redhat.com>, Darren Hart <dvhart@infradead.org>, Ben Skeggs <bskeggs@redhat.com>, Stuart Hayes <stuart_hayes@dell.com>, Matthew Garrett <mjg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, platform-driver-x86@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun 14-06-15 11:05:07, Pali Rohar wrote:
> Hello,
> 
> in drivers/platform/x86/dell-laptop.c is this part of code:
> 
> static int __init dell_init(void)
> {
> ...
> 	/*
> 	 * Allocate buffer below 4GB for SMI data--only 32-bit physical addr
> 	 * is passed to SMI handler.
> 	 */
> 	bufferpage = alloc_page(GFP_KERNEL | GFP_DMA32);
[...]
> 	buffer = page_address(bufferpage);
[...]
> fail_rfkill:
> 	free_page((unsigned long)bufferpage);

This one should be __free_page because it consumes struct page* and it
is the proper counter part for alloc_page. free_page, just to make it
confusing, consumes an address which has to be translated to a struct
page.

I have no idea why the API has been done this way and yeah, it is really
confusing.

[...]
> static void __exit dell_exit(void)
> {
> ...
> 	free_page((unsigned long)buffer);


-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
