From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199908011823.LAA32354@google.engr.sgi.com>
Subject: Re: [PATCH] bugfix for drivers/char/mem.c
Date: Sun, 1 Aug 1999 11:23:30 -0700 (PDT)
In-Reply-To: <E11AtH4-0003sP-00@heaton.cl.cam.ac.uk> from "Steven Hand" at Aug 1, 99 11:55:09 am
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Steven Hand <Steven.Hand@cl.cam.ac.uk>
Cc: Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> There is a bug in the function read_kmem() in drivers/char/mem.c  -
> the file position is incorrectly updated after a read() from /dev/kmem.
> This means that successive reads from /dev/kmem without an intervening
> seek will return incorrect data. 
> 
> The bug has been around for quite a while, and is present in all the
> 2.2.x kernels.  The following patch (against v.2.3.12) fixes it.
> 
> 
> S.
> 
> --- v2.3.12/linux/drivers/char/mem.c	Sun Aug  1 11:09:11 1999
> +++ linux/drivers/char/mem.c	Sun Aug  1 11:25:07 1999
> @@ -245,11 +245,14 @@
>  		count -= read;
>  	}
>  
> -	virtr = vread(buf, (char *)p, count);
> -	if (virtr < 0)
> -		return virtr;
> -	*ppos += p + virtr;
> -	return virtr + read;
> +	if(count) {
> +		if((virtr = vread(buf, (char *)p, count)) < 0)
> +			return virtr;
> +		read += virtr;
> +	}
> +
> +	*ppos += read;
> +	return read;
>  }
>  
>  /*
>

I see the problem. Can I suggest a simpler fix, based on the fact that
vread() returns 0 when count == 0?

-	*ppos += p + virtr;
+	*ppos += read + virtr;

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
