Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m98FcXnj012498
	for <linux-mm@kvack.org>; Wed, 8 Oct 2008 11:38:33 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m98FZpp8273294
	for <linux-mm@kvack.org>; Wed, 8 Oct 2008 11:35:51 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m98FZmqo025489
	for <linux-mm@kvack.org>; Wed, 8 Oct 2008 11:35:50 -0400
Subject: Re: [RFC v6][PATCH 5/9] Restore memory address space
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <1223461197-11513-6-git-send-email-orenl@cs.columbia.edu>
References: <1223461197-11513-1-git-send-email-orenl@cs.columbia.edu>
	 <1223461197-11513-6-git-send-email-orenl@cs.columbia.edu>
Content-Type: text/plain
Date: Wed, 08 Oct 2008 08:35:45 -0700
Message-Id: <1223480145.11830.3.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: jeremy@goop.org, arnd@arndb.de, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Wed, 2008-10-08 at 06:19 -0400, Oren Laadan wrote:
> 
> +static int cr_read_private_vma_contents(struct cr_ctx *ctx)
> +{
> +       struct cr_hdr_pgarr *hh;
> +       unsigned long nr_pages;
> +       int parent, ret = 0;
> +
> +       while (1) {
> +               hh = cr_hbuf_get(ctx, sizeof(*hh));
> +               parent = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_PGARR);
> +               if (parent != 0) {
> +                       if (parent < 0)
> +                               ret = parent;
> +                       else
> +                               ret = -EINVAL;
> +                       cr_hbuf_put(ctx, sizeof(*hh));
> +                       break;
> +               }
> +
> +               cr_debug("nr_pages %ld\n", (unsigned long) hh->nr_pages);
> +
> +               nr_pages = hh->nr_pages;
> +               cr_hbuf_put(ctx, sizeof(*hh));
> +
> +               if (!nr_pages)
> +                       break;
> +
> +               ret = cr_read_pages_vaddrs(ctx, nr_pages);
> +               if (ret < 0)
> +                       break;
> +               ret = cr_read_pages_contents(ctx);
> +               if (ret < 0)
> +                       break;
> +               cr_pgarr_reset_all(ctx);
> +       }
> +
> +       return ret;
> +}

This basically just uses a while(1) loop with 'break' instead of an
'out_err:' label and some gotos.  That's kinda odd for the kernel.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
