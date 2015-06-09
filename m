Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 26ED96B0071
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 18:28:40 -0400 (EDT)
Received: by pdjn11 with SMTP id n11so23439023pdj.0
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 15:28:39 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id wu3si10662917pbc.61.2015.06.09.15.28.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jun 2015 15:28:39 -0700 (PDT)
Date: Tue, 9 Jun 2015 15:28:38 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/5] ipc,shm: move BUG_ON check into shm_lock
Message-Id: <20150609152838.94774d7feafef3f7e6ccbd74@linux-foundation.org>
In-Reply-To: <1433597880-8571-2-git-send-email-dave@stgolabs.net>
References: <1433597880-8571-1-git-send-email-dave@stgolabs.net>
	<1433597880-8571-2-git-send-email-dave@stgolabs.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: Manfred Spraul <manfred@colorfullife.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Davidlohr Bueso <dbueso@suse.de>

On Sat,  6 Jun 2015 06:37:56 -0700 Davidlohr Bueso <dave@stgolabs.net> wrote:

> Upon every shm_lock call, we BUG_ON if an error was returned,
> indicating racing either in idr or in shm_destroy. Move this logic
> into the locking.
> 
> --- a/ipc/shm.c
> +++ b/ipc/shm.c
> @@ -155,8 +155,14 @@ static inline struct shmid_kernel *shm_lock(struct ipc_namespace *ns, int id)
>  {
>  	struct kern_ipc_perm *ipcp = ipc_lock(&shm_ids(ns), id);
>  
> -	if (IS_ERR(ipcp))
> +	if (IS_ERR(ipcp)) {
> +		/*
> +		 * We raced in the idr lookup or with shm_destroy(),
> +		 * either way, the ID is busted.
> +		 */
> +		BUG();
>  		return (struct shmid_kernel *)ipcp;
> +	}

Was there any particular reason to still do it this way?  It's a bit
klunky.

--- a/ipc/shm.c~ipcshm-move-bug_on-check-into-shm_lock-fix
+++ a/ipc/shm.c
@@ -155,14 +155,11 @@ static inline struct shmid_kernel *shm_l
 {
 	struct kern_ipc_perm *ipcp = ipc_lock(&shm_ids(ns), id);
 
-	if (IS_ERR(ipcp)) {
-		/*
-		 * We raced in the idr lookup or with shm_destroy(),
-		 * either way, the ID is busted.
-		 */
-		BUG();
-		return (struct shmid_kernel *)ipcp;
-	}
+	/*
+	 * We raced in the idr lookup or with shm_destroy().  Either way, the
+	 * ID is busted.
+	 */
+	BUG_ON(IS_ERR(ipcp));
 
 	return container_of(ipcp, struct shmid_kernel, shm_perm);
 }

One benefit of the code you sent is that the unreachable `return' will
prevent a compile warning when CONFIG_BUG=n, but CONFIG_BUG=n is silly
and I never worry about it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
