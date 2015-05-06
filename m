Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 810C06B006E
	for <linux-mm@kvack.org>; Wed,  6 May 2015 06:46:45 -0400 (EDT)
Received: by wgyo15 with SMTP id o15so6935862wgy.2
        for <linux-mm@kvack.org>; Wed, 06 May 2015 03:46:45 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o2si1571780wic.59.2015.05.06.03.46.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 06 May 2015 03:46:44 -0700 (PDT)
Message-ID: <5549F112.1000405@suse.cz>
Date: Wed, 06 May 2015 12:46:42 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 3/9] media: omap_vout: Convert omap_vout_uservirt_to_phys()
 to use get_vaddr_pfns()
References: <1430897296-5469-1-git-send-email-jack@suse.cz> <1430897296-5469-4-git-send-email-jack@suse.cz>
In-Reply-To: <1430897296-5469-4-git-send-email-jack@suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>, linux-mm@kvack.org
Cc: linux-media@vger.kernel.org, Hans Verkuil <hverkuil@xs4all.nl>, dri-devel@lists.freedesktop.org, Pawel Osciak <pawel@osciak.com>, Mauro Carvalho Chehab <mchehab@osg.samsung.com>, mgorman@suse.de, Marek Szyprowski <m.szyprowski@samsung.com>, linux-samsung-soc@vger.kernel.org

On 05/06/2015 09:28 AM, Jan Kara wrote:
> Convert omap_vout_uservirt_to_phys() to use get_vaddr_pfns() instead of
> hand made mapping of virtual address to physical address. Also the
> function leaked page reference from get_user_pages() so fix that by
> properly release the reference when omap_vout_buffer_release() is
> called.
>
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---
>   drivers/media/platform/omap/omap_vout.c | 67 +++++++++++++++------------------
>   1 file changed, 31 insertions(+), 36 deletions(-)
>

...

> +	vec = frame_vector_create(1);
> +	if (!vec)
> +		return -ENOMEM;
>
> -		if (res == nr_pages) {
> -			physp =  __pa(page_address(&pages[0]) +
> -					(virtp & ~PAGE_MASK));
> -		} else {
> -			printk(KERN_WARNING VOUT_NAME
> -					"get_user_pages failed\n");
> -			return 0;
> -		}
> +	ret = get_vaddr_frames(virtp, 1, 1, 0, vec);

Use true/false where appropriate.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
