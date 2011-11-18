Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id BDB4B6B002D
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 15:00:13 -0500 (EST)
Date: Fri, 18 Nov 2011 11:59:55 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/1] mm/vmalloc.c: eliminate extra loop in
 pcpu_get_vm_areas error path
Message-Id: <20111118115955.410af035.akpm@linux-foundation.org>
In-Reply-To: <1321616630-28281-1-git-send-email-consul.kautuk@gmail.com>
References: <1321616630-28281-1-git-send-email-consul.kautuk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kautuk Consul <consul.kautuk@gmail.com>
Cc: Joe Perches <joe@perches.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 18 Nov 2011 17:13:50 +0530
Kautuk Consul <consul.kautuk@gmail.com> wrote:

> If either of the vas or vms arrays are not properly kzalloced,
> then the code jumps to the err_free label.
> 
> The err_free label runs a loop to check and free each of the array
> members of the vas and vms arrays which is not required for this
> situation as none of the array members have been allocated till this
> point.
> 
> Eliminate the extra loop we have to go through by introducing a new
> label err_free2 and then jumping to it.
> 
> Signed-off-by: Kautuk Consul <consul.kautuk@gmail.com>
> ---
>  mm/vmalloc.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index b669aa6..1a0d4e2 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -2352,7 +2352,7 @@ struct vm_struct **pcpu_get_vm_areas(const unsigned long *offsets,
>  	vms = kzalloc(sizeof(vms[0]) * nr_vms, GFP_KERNEL);
>  	vas = kzalloc(sizeof(vas[0]) * nr_vms, GFP_KERNEL);
>  	if (!vas || !vms)
> -		goto err_free;
> +		goto err_free2;
>  
>  	for (area = 0; area < nr_vms; area++) {
>  		vas[area] = kzalloc(sizeof(struct vmap_area), GFP_KERNEL);
> @@ -2455,6 +2455,7 @@ err_free:
>  		if (vms)
>  			kfree(vms[area]);
>  	}
> +err_free2:
>  	kfree(vas);
>  	kfree(vms);
>  	return NULL;

Which means we can also do the below, yes?  (please check my homework!)

--- a/mm/vmalloc.c~mm-vmallocc-eliminate-extra-loop-in-pcpu_get_vm_areas-error-path-fix
+++ a/mm/vmalloc.c
@@ -2449,10 +2449,8 @@ found:
 
 err_free:
 	for (area = 0; area < nr_vms; area++) {
-		if (vas)
-			kfree(vas[area]);
-		if (vms)
-			kfree(vms[area]);
+		kfree(vas[area]);
+		kfree(vms[area]);
 	}
 err_free2:
 	kfree(vas);
_


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
