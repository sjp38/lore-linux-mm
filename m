Subject: Re: [PATCH][RFC] slub: increasing order reduces memory usage of
	some key caches
From: Richard Kennedy <richard@rsk.demon.co.uk>
In-Reply-To: <487E1ACF.3030603@linux-foundation.org>
References: <1216211371.3122.46.camel@castor.localdomain>
	 <487E1ACF.3030603@linux-foundation.org>
Content-Type: text/plain
Date: Thu, 17 Jul 2008 11:09:08 +0100
Message-Id: <1216289348.3061.16.camel@castor.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: penberg@cs.helsinki.fi, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2008-07-16 at 10:59 -0500, Christoph Lameter wrote:
> Patch to do this the right way in slub:
> 
> Index: linux-2.6/mm/slub.c
> ===================================================================
> --- linux-2.6.orig/mm/slub.c	2008-07-16 10:42:07.000000000 -0500
> +++ linux-2.6/mm/slub.c	2008-07-16 10:53:36.000000000 -0500
> @@ -1860,6 +1860,10 @@
>  
>  		rem = slab_size % size;
>  
> +		/* Never waste more than half of the size of an object*/
> +		if (rem > size / 2)
> +			continue;
> +
>  		if (rem <= slab_size / fract_leftover)
>  			break;

Thanks, I'll give that a try.

Do we need to limit the number of times this applies though?

for example, 216 byte structures will give

order:objs/slab:waste
0 :  18 :208
1 :  37 :200
2 :  75 :184
3 : 151 :152
4 : 303 : 88

I'm not sure where the balance point between efficient memory usage &
fragmentation pressure lies, but my gut feeling is that order 4 is just
too big for a structure this small.  

Richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
