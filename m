Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 797436B0002
	for <linux-mm@kvack.org>; Mon, 20 May 2013 18:24:56 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id fb10so50821pad.23
        for <linux-mm@kvack.org>; Mon, 20 May 2013 15:24:55 -0700 (PDT)
Date: Mon, 20 May 2013 15:24:53 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: vmscan: add BUG_ON on illegal return values from
 scan_objects
In-Reply-To: <1369041267-26424-1-git-send-email-oskar.andero@sonymobile.com>
Message-ID: <alpine.DEB.2.02.1305201523230.12790@chino.kir.corp.google.com>
References: <1369041267-26424-1-git-send-email-oskar.andero@sonymobile.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oskar Andero <oskar.andero@sonymobile.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Radovan Lekanovic <radovan.lekanovic@sonymobile.com>, Glauber Costa <glommer@openvz.org>, Dave Chinner <dchinner@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On Mon, 20 May 2013, Oskar Andero wrote:

> Add a BUG_ON to catch any illegal value from the shrinkers. This fixes a
> potential bug if scan_objects returns a negative other than -1, which
> would lead to undefined behaviour.
> 
> Cc: Glauber Costa <glommer@openvz.org>
> Cc: Dave Chinner <dchinner@redhat.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Signed-off-by: Oskar Andero <oskar.andero@sonymobile.com>
> ---
>  mm/vmscan.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 6bac41e..fbe6742 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -293,6 +293,7 @@ shrink_slab_one(struct shrinker *shrinker, struct shrink_control *shrinkctl,
>  		ret = shrinker->scan_objects(shrinker, shrinkctl);
>  		if (ret == -1)
>  			break;
> +		BUG_ON(ret < -1);
>  		freed += ret;
>  
>  		count_vm_events(SLABS_SCANNED, nr_to_scan);

Nack, this doesn't fix anything.  I can see the intention, and for that it 
might make sense to turn this into VM_BUG_ON() so that anybody debugging 
an issue related to this with CONFIG_DEBUG_VM would get the indication, 
but I don't think we need to enforce the API with BUG_ON().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
