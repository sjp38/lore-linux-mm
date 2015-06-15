Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id B1AF56B0038
	for <linux-mm@kvack.org>; Mon, 15 Jun 2015 16:36:53 -0400 (EDT)
Received: by pacgb13 with SMTP id gb13so42171814pac.1
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 13:36:53 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id kp7si19347728pbc.76.2015.06.15.13.36.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jun 2015 13:36:52 -0700 (PDT)
Date: Mon, 15 Jun 2015 13:36:45 -0700
From: Darren Hart <dvhart@infradead.org>
Subject: Re: Possible broken MM code in dell-laptop.c?
Message-ID: <20150615203645.GD83198@vmdeb7>
References: <201506141105.07171@pali>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <201506141105.07171@pali>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pali =?iso-8859-1?Q?Roh=E1r?= <pali.rohar@gmail.com>
Cc: Hans de Goede <hdegoede@redhat.com>, Ben Skeggs <bskeggs@redhat.com>, Stuart Hayes <stuart_hayes@dell.com>, Matthew Garrett <mjg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, platform-driver-x86@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, Jun 14, 2015 at 11:05:07AM +0200, Pali Rohar wrote:
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
> 	if (!bufferpage) {
> 		ret = -ENOMEM;
> 		goto fail_buffer;
> 	}
> 	buffer = page_address(bufferpage);
> 
> 	ret = dell_setup_rfkill();
> 
> 	if (ret) {
> 		pr_warn("Unable to setup rfkill\n");
> 		goto fail_rfkill;
> 	}
> ...
> fail_rfkill:
> 	free_page((unsigned long)bufferpage);
> fail_buffer:
> ...
> }
> 
> Then there is another part:
> 
> static void __exit dell_exit(void)
> {
> ...
> 	free_page((unsigned long)buffer);

I believe you are correct, and this should be bufferpage. Have you observed any
failures?

-- 
Darren Hart
Intel Open Source Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
