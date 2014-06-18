Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f175.google.com (mail-ie0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id 9568D6B0031
	for <linux-mm@kvack.org>; Wed, 18 Jun 2014 16:16:52 -0400 (EDT)
Received: by mail-ie0-f175.google.com with SMTP id tp5so1198770ieb.20
        for <linux-mm@kvack.org>; Wed, 18 Jun 2014 13:16:52 -0700 (PDT)
Received: from mail-ig0-x236.google.com (mail-ig0-x236.google.com [2607:f8b0:4001:c05::236])
        by mx.google.com with ESMTPS id d18si5232066ics.56.2014.06.18.13.16.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 18 Jun 2014 13:16:51 -0700 (PDT)
Received: by mail-ig0-f182.google.com with SMTP id l13so96132iga.9
        for <linux-mm@kvack.org>; Wed, 18 Jun 2014 13:16:51 -0700 (PDT)
Date: Wed, 18 Jun 2014 13:16:49 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH RESEND] slub: return correct error on slab_sysfs_init
In-Reply-To: <53A0EB84.7030308@oracle.com>
Message-ID: <alpine.DEB.2.02.1406181314290.10339@chino.kir.corp.google.com>
References: <53A0EB84.7030308@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Liu <jeff.liu@oracle.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Christoph Lameter <cl@gentwo.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>

On Wed, 18 Jun 2014, Jeff Liu wrote:

> From: Jie Liu <jeff.liu@oracle.com>
> 
> Return -ENOMEM than -ENOSYS if kset_create_and_add() failed
> 

Why?  kset_create_and_add() can fail for a few other reasons other than 
memory constraints and given that this is only done at bootstrap, it 
actually seems like a duplicate name would be a bigger concern than low on 
memory if another init call actually registered it.

> Signed-off-by: Jie Liu <jeff.liu@oracle.com>
> ---
>  mm/slub.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/slub.c b/mm/slub.c
> index b2b0473..e10f60f 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -5301,7 +5301,7 @@ static int __init slab_sysfs_init(void)
>  	if (!slab_kset) {
>  		mutex_unlock(&slab_mutex);
>  		pr_err("Cannot register slab subsystem.\n");
> -		return -ENOSYS;
> +		return -ENOMEM;
>  	}
>  
>  	slab_state = FULL;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
