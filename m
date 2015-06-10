Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 761766B0070
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 20:13:20 -0400 (EDT)
Received: by wiwd19 with SMTP id d19so32042109wiw.0
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 17:13:20 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bv2si14302976wjc.100.2015.06.09.17.13.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 09 Jun 2015 17:13:18 -0700 (PDT)
Message-ID: <1433895192.3165.67.camel@stgolabs.net>
Subject: Re: [PATCH 1/5] ipc,shm: move BUG_ON check into shm_lock
From: Davidlohr Bueso <dave@stgolabs.net>
Date: Tue, 09 Jun 2015 17:13:12 -0700
In-Reply-To: <20150609152838.94774d7feafef3f7e6ccbd74@linux-foundation.org>
References: <1433597880-8571-1-git-send-email-dave@stgolabs.net>
	 <1433597880-8571-2-git-send-email-dave@stgolabs.net>
	 <20150609152838.94774d7feafef3f7e6ccbd74@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Manfred Spraul <manfred@colorfullife.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 2015-06-09 at 15:28 -0700, Andrew Morton wrote:
> --- a/ipc/shm.c~ipcshm-move-bug_on-check-into-shm_lock-fix
> +++ a/ipc/shm.c
> @@ -155,14 +155,11 @@ static inline struct shmid_kernel *shm_l
>  {
>  	struct kern_ipc_perm *ipcp = ipc_lock(&shm_ids(ns), id);
>  
> -	if (IS_ERR(ipcp)) {
> -		/*
> -		 * We raced in the idr lookup or with shm_destroy(),
> -		 * either way, the ID is busted.
> -		 */
> -		BUG();
> -		return (struct shmid_kernel *)ipcp;
> -	}
> +	/*
> +	 * We raced in the idr lookup or with shm_destroy().  Either way, the
> +	 * ID is busted.
> +	 */
> +	BUG_ON(IS_ERR(ipcp));
>  
>  	return container_of(ipcp, struct shmid_kernel, shm_perm);
>  }
> 
> One benefit of the code you sent is that the unreachable `return' will
> prevent a compile warning when CONFIG_BUG=n, but CONFIG_BUG=n is silly
> and I never worry about it.

I took a closer look and the above looks Ok, and I don't care either way
about CONFIG_BUG=n.

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
