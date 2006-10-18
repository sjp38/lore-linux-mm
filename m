Subject: Re: [PATCH] memory page_alloc zonelist caching speedup aligncache
From: Rohit Seth <rohitseth@google.com>
Reply-To: rohitseth@google.com
In-Reply-To: <20061018081440.18477.10664.sendpatchset@sam.engr.sgi.com>
References: <20061018081440.18477.10664.sendpatchset@sam.engr.sgi.com>
Content-Type: text/plain
Date: Wed, 18 Oct 2006 08:35:37 -0700
Message-Id: <1161185737.582.326.camel@galaxy.corp.google.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: akpm@osdl.org, nickpiggin@yahoo.com.au, ak@suse.de, linux-mm@kvack.org, holt@sgi.com, mbligh@google.com, rientjes@google.com, menage@google.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

On Wed, 2006-10-18 at 01:14 -0700, Paul Jackson wrote:
> From: Paul Jackson <pj@sgi.com>
> 
> Avoid frequent writes to the zonelist zones[] array, which are
> read-only after initial setup, by putting the zonelist_cache on
> a separate cacheline.
> 
> Signed-off-by: Paul Jackson <pj@sgi.com>
> 
> ---
> 
>  include/linux/mmzone.h |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletion(-)
> 
> --- 2.6.19-rc2-mm1.orig/include/linux/mmzone.h	2006-10-17 17:19:22.000000000 -0700
> +++ 2.6.19-rc2-mm1/include/linux/mmzone.h	2006-10-17 17:31:31.000000000 -0700
> @@ -396,7 +396,8 @@ struct zonelist {
>  	struct zonelist_cache *zlcache_ptr;		     // NULL or &zlcache
>  	struct zone *zones[MAX_ZONES_PER_ZONELIST + 1];      // NULL delimited
>  #ifdef CONFIG_NUMA
> -	struct zonelist_cache zlcache;			     // optional ...
> +	/* Keep written zonelist_cache off read-only zones[] cache lines */
> +	struct zonelist_cache zlcache ____cacheline_aligned; // optional ...
>  #endif
>  };
>  
> 

Wouldn't it be better to have the read mostly field z_to_n defined first
in zonelist_cache (and define the BITMAP at the end).

-rohit

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
