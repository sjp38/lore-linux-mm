Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id E4F976B0035
	for <linux-mm@kvack.org>; Mon,  3 Mar 2014 08:15:03 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id bj1so3684780pad.16
        for <linux-mm@kvack.org>; Mon, 03 Mar 2014 05:15:03 -0800 (PST)
Received: from out3-smtp.messagingengine.com (out3-smtp.messagingengine.com. [66.111.4.27])
        by mx.google.com with ESMTPS id u5si280313pbi.298.2014.03.03.05.15.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Mar 2014 05:15:02 -0800 (PST)
Received: from compute6.internal (compute6.nyi.mail.srv.osa [10.202.2.46])
	by gateway1.nyi.mail.srv.osa (Postfix) with ESMTP id C232020E29
	for <linux-mm@kvack.org>; Mon,  3 Mar 2014 08:14:57 -0500 (EST)
Message-ID: <5314804F.9090806@iki.fi>
Date: Mon, 03 Mar 2014 15:14:55 +0200
From: Pekka Enberg <penberg@iki.fi>
MIME-Version: 1.0
Subject: Re: [patch] x86, kmemcheck: Use kstrtoint() instead of sscanf()
References: <5304558F.9050605@huawei.com> <alpine.DEB.2.02.1402182344001.3551@chino.kir.corp.google.com> <alpine.DEB.2.02.1402191412300.31921@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1402191412300.31921@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Vegard Nossum <vegardno@ifi.uio.no>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>
Cc: Xishi Qiu <qiuxishi@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 02/20/2014 12:14 AM, David Rientjes wrote:
> Kmemcheck should use the preferred interface for parsing command line
> arguments, kstrto*(), rather than sscanf() itself.  Use it appropriately.
>
> Signed-off-by: David Rientjes <rientjes@google.com>

Acked-by: Pekka Enberg <penberg@kernel.org>

Andrew, can you pick this up?

> ---
>   arch/x86/mm/kmemcheck/kmemcheck.c | 8 +++++++-
>   1 file changed, 7 insertions(+), 1 deletion(-)
>
> diff --git a/arch/x86/mm/kmemcheck/kmemcheck.c b/arch/x86/mm/kmemcheck/kmemcheck.c
> --- a/arch/x86/mm/kmemcheck/kmemcheck.c
> +++ b/arch/x86/mm/kmemcheck/kmemcheck.c
> @@ -78,10 +78,16 @@ early_initcall(kmemcheck_init);
>    */
>   static int __init param_kmemcheck(char *str)
>   {
> +	int val;
> +	int ret;
> +
>   	if (!str)
>   		return -EINVAL;
>   
> -	sscanf(str, "%d", &kmemcheck_enabled);
> +	ret = kstrtoint(str, 0, &val);
> +	if (ret)
> +		return ret;
> +	kmemcheck_enabled = val;
>   	return 0;
>   }
>   

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
