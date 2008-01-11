Subject: Re: [patch 05/19] split LRU lists into anon & file sets
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20080111143627.FD64.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080108205939.323955454@redhat.com>
	 <20080108210002.638347207@redhat.com>
	 <20080111143627.FD64.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Content-Type: text/plain
Date: Fri, 11 Jan 2008 10:50:09 -0500
Message-Id: <1200066610.5304.11.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2008-01-11 at 15:24 +0900, KOSAKI Motohiro wrote:
> Hi Rik
> 
> > +static inline int is_file_lru(enum lru_list l)
> > +{
> > +	BUILD_BUG_ON(LRU_INACTIVE_FILE != 2 || LRU_ACTIVE_FILE != 3);
> > +	return (l/2 == 1);
> > +}
> 
> below patch is a bit cleanup proposal.
> i think LRU_FILE is more clarify than "/2".
> 
> What do you think it?
> 
> 
> 
> Index: linux-2.6.24-rc6-mm1-rvr/include/linux/mmzone.h
> ===================================================================
> --- linux-2.6.24-rc6-mm1-rvr.orig/include/linux/mmzone.h        2008-01-11 11:10:30.000000000 +0900
> +++ linux-2.6.24-rc6-mm1-rvr/include/linux/mmzone.h     2008-01-11 14:40:31.000000000 +0900
> @@ -147,7 +147,7 @@
>  static inline int is_file_lru(enum lru_list l)
>  {
>         BUILD_BUG_ON(LRU_INACTIVE_FILE != 2 || LRU_ACTIVE_FILE != 3);
> -       return (l/2 == 1);
> +       return !!(l & LRU_FILE);
>  }
> 
>  struct per_cpu_pages {
> 

Kosaki-san:

Again, my doing.  I agree that the calculation is a bit strange, but I
wanted to "future-proof" this function in case we ever get to a value of
'6' for the lru_list enum.  In that case, the AND will evaluate to
non-zero for what may not be a file LRU.  Between the build time
assertion and the division [which could just be a 'l >> 1', I suppose]
we should be safe.

Thanks,
Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
