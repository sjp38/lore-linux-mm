Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 341986B004A
	for <linux-mm@kvack.org>; Tue,  6 Mar 2012 19:08:35 -0500 (EST)
Date: Tue, 6 Mar 2012 16:08:33 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] mm, mempolicy: dummy slab_node return value for bugless
 kernels
Message-Id: <20120306160833.0e9bf50a.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1203041341340.9534@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1203041341340.9534@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org

On Sun, 4 Mar 2012 13:43:32 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> BUG() is a no-op when CONFIG_BUG is disabled, so slab_node() needs a
> dummy return value to avoid reaching the end of a non-void function.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  mm/mempolicy.c |    1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -1611,6 +1611,7 @@ unsigned slab_node(struct mempolicy *policy)
>  
>  	default:
>  		BUG();
> +		return numa_node_id();
>  	}
>  }

Wait.  If the above code generated a warning then surely we get a *lot*
of warnings!  I'd expect that a lot of code assumes that BUG() never
returns?

Can we fix this within the BUG() definition?  I can't think of a way,
unless gcc gives us a way of accessing the return type of the current
function, and I don't think it does that.


Also, does CONIG_BUG=n even make sense?  If we got here and we know
that the kernel has malfunctioned, what point is there in pretending
otherwise?  Odd.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
