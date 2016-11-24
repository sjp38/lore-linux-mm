Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3E5176B0038
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 12:08:55 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id j65so85551458iof.1
        for <linux-mm@kvack.org>; Thu, 24 Nov 2016 09:08:55 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0057.hostedemail.com. [216.40.44.57])
        by mx.google.com with ESMTPS id k7si7378206itc.46.2016.11.24.09.08.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Nov 2016 09:08:54 -0800 (PST)
Message-ID: <1480007330.19726.11.camel@perches.com>
Subject: Re: [PATCH] z3fold: use %z modifier for format string
From: Joe Perches <joe@perches.com>
Date: Thu, 24 Nov 2016 09:08:50 -0800
In-Reply-To: <20161124163158.3939337-1-arnd@arndb.de>
References: <20161124163158.3939337-1-arnd@arndb.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>
Cc: Vitaly Wool <vitalywool@gmail.com>, Dan Streetman <ddstreet@ieee.org>, zhong jiang <zhongjiang@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 2016-11-24 at 17:31 +0100, Arnd Bergmann wrote:
> Printing a size_t requires the %zd format rather than %d:
> 
> mm/z3fold.c: In function a??init_z3folda??:
> include/linux/kern_levels.h:4:18: error: format a??%da?? expects argument of type a??inta??, but argument 2 has type a??long unsigned inta?? [-Werror=format=]
> 
> Fixes: 50a50d2676c4 ("z3fold: don't fail kernel build if z3fold_header is too big")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
>  mm/z3fold.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/z3fold.c b/mm/z3fold.c
> index e282ba073e77..66ac7a7dc934 100644
> --- a/mm/z3fold.c
> +++ b/mm/z3fold.c
> @@ -884,7 +884,7 @@ static int __init init_z3fold(void)
>  {
>  	/* Fail the initialization if z3fold header won't fit in one chunk */
>  	if (sizeof(struct z3fold_header) > ZHDR_SIZE_ALIGNED) {
> -		pr_err("z3fold: z3fold_header size (%d) is bigger than "
> +		pr_err("z3fold: z3fold_header size (%zd) is bigger than "
>  			"the chunk size (%d), can't proceed\n",
>  			sizeof(struct z3fold_header) , ZHDR_SIZE_ALIGNED);
>  		return -E2BIG;

The embedded "z3fold: " prefix here should be removed
as there's a pr_fmt that also adds it.

The test looks like it should be a BUILD_BUG_ON rather
than any runtime test too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
