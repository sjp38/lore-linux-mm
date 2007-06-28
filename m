From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH/RFC 0/11] Shared Policy Overview
Date: Fri, 29 Jun 2007 00:02:11 +0200
References: <20070625195224.21210.89898.sendpatchset@localhost> <200706280001.16383.ak@suse.de> <1183038137.5697.16.camel@localhost>
In-Reply-To: <1183038137.5697.16.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200706290002.12113.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Christoph Lameter <clameter@sgi.com>, "Paul E. McKenney" <paulmck@us.ibm.com>, linux-mm@kvack.org, akpm@linux-foundation.org, nacc@us.ibm.com
List-ID: <linux-mm.kvack.org>


> -	return __alloc_pages(gfp, 0, zonelist_policy(gfp, pol));
> +	page =  __alloc_pages(gfp, 0, zonelist_policy(gfp, pol));
> +	if (pol != &default_policy && pol != current->mempolicy)
> +		__mpol_free(pol);

That destroyed the tail call in the fast path. I would prefer if it
was preserved at least for the default_policy case. This means handling
this in a separated if path.

Other than that it looks reasonable and we probably want something
like this for .22.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
