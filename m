Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f180.google.com (mail-qc0-f180.google.com [209.85.216.180])
	by kanga.kvack.org (Postfix) with ESMTP id D158A6B0038
	for <linux-mm@kvack.org>; Fri,  8 May 2015 13:54:18 -0400 (EDT)
Received: by qcbgu10 with SMTP id gu10so40730617qcb.2
        for <linux-mm@kvack.org>; Fri, 08 May 2015 10:54:18 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id jf5si6019233qcb.8.2015.05.08.10.54.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 May 2015 10:54:18 -0700 (PDT)
Date: Fri, 8 May 2015 19:54:15 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] UserfaultFD: Fix stack corruption when zeroing uffd_msg
Message-ID: <20150508175415.GB16508@redhat.com>
References: <55425A74.3020604@parallels.com>
 <20150507134236.GB13098@redhat.com>
 <554B769E.1040000@parallels.com>
 <20150507143343.GG13098@redhat.com>
 <554B79C0.5060807@parallels.com>
 <20150507151136.GH13098@redhat.com>
 <554B82D4.4060809@parallels.com>
 <20150507170802.GI13098@redhat.com>
 <554CBC99.2050808@parallels.com>
 <554CC31F.9050509@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <554CC31F.9050509@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Emelyanov <xemul@parallels.com>
Cc: Linux MM <linux-mm@kvack.org>

On Fri, May 08, 2015 at 05:07:27PM +0300, Pavel Emelyanov wrote:
> 
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
> 
> ---
> 
> diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
> index 026ef99..c89e96f 100644
> --- a/fs/userfaultfd.c
> +++ b/fs/userfaultfd.c
> @@ -134,7 +134,7 @@ static inline void msg_init(struct uffd_msg *msg)
>  	 * Must use memset to zero out the paddings or kernel data is
>  	 * leaked to userland.
>  	 */
> -	memset(&msg, 0, sizeof(struct uffd_msg));
> +	memset(msg, 0, sizeof(struct uffd_msg));

Applied (folded). The memset was originally inline in userfault_msg,
when I introduced msg_init the compiler didn't warn of the & that had
to be removed as it's now called as:

	msg_init(&msg);

All right thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
