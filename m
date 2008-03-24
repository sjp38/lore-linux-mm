Date: Mon, 24 Mar 2008 14:52:09 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC/PATCH 02/15 v2] preparation: host memory management
 changes for s390 kvm
Message-Id: <20080324145209.23920166.akpm@linux-foundation.org>
In-Reply-To: <1206205359.7177.84.camel@cotte.boeblingen.de.ibm.com>
References: <1206030270.6690.51.camel@cotte.boeblingen.de.ibm.com>
	<1206203560.7177.45.camel@cotte.boeblingen.de.ibm.com>
	<1206205359.7177.84.camel@cotte.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Carsten Otte <cotte@de.ibm.com>
Cc: virtualization@lists.linux-foundation.org, kvm-devel@lists.sourceforge.net, avi@qumranet.com, npiggin@suse.de, hugh@veritas.com, linux-mm@kvack.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, os@de.ibm.com, borntraeger@de.ibm.com, hollisb@us.ibm.com, EHRHARDT@de.ibm.com, jeroney@us.ibm.com, aliguori@us.ibm.com, jblunck@suse.de, rvdheij@gmail.com, rusty@rustcorp.com.au, arnd@arndb.de, xiantao.zhang@intel.com
List-ID: <linux-mm.kvack.org>

On Sat, 22 Mar 2008 18:02:39 +0100
Carsten Otte <cotte@de.ibm.com> wrote:

> From: Heiko Carstens <heiko.carstens@de.ibm.com>
> From: Christian Borntraeger <borntraeger@de.ibm.com>
> 
> This patch changes the s390 memory management defintions to use the pgste field
> for dirty and reference bit tracking of host and guest code. Usually on s390, 
> dirty and referenced are tracked in storage keys, which belong to the physical
> page. This changes with virtualization: The guest and host dirty/reference bits
> are defined to be the logical OR of the values for the mapping and the physical
> page. This patch implements the necessary changes in pgtable.h for s390.
> 
> 
> There is a common code change in mm/rmap.c, the call to page_test_and_clear_young
> must be moved. This is a no-op for all architecture but s390. page_referenced
> checks the referenced bits for the physiscal page and for all mappings:
> o The physical page is checked with page_test_and_clear_young.
> o The mappings are checked with ptep_test_and_clear_young and friends.
> 
> Without pgstes (the current implementation on Linux s390) the physical page
> check is implemented but the mapping callbacks are no-ops because dirty 
> and referenced are not tracked in the s390 page tables. The pgstes introduces 
> guest and host dirty and reference bits for s390 in the host mapping. These
> mapping must be checked before page_test_and_clear_young resets the reference
> bit. 
>
> ...
>
> --- linux-host.orig/mm/rmap.c
> +++ linux-host/mm/rmap.c
> @@ -413,9 +413,6 @@ int page_referenced(struct page *page, i
>  {
>  	int referenced = 0;
>  
> -	if (page_test_and_clear_young(page))
> -		referenced++;
> -
>  	if (TestClearPageReferenced(page))
>  		referenced++;
>  
> @@ -433,6 +430,10 @@ int page_referenced(struct page *page, i
>  			unlock_page(page);
>  		}
>  	}
> +
> +	if (page_test_and_clear_young(page))
> +		referenced++;
> +
>  	return referenced;
>  }

ack.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
