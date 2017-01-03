Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id E27506B0069
	for <linux-mm@kvack.org>; Tue,  3 Jan 2017 03:44:22 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id l2so52028281wml.5
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 00:44:22 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id sd16si76303218wjb.290.2017.01.03.00.44.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 03 Jan 2017 00:44:21 -0800 (PST)
Date: Tue, 3 Jan 2017 09:44:19 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC] nodemask: Consider MAX_NUMNODES inside node_isset
Message-ID: <20170103084418.GC30111@dhcp22.suse.cz>
References: <20170103082753.25758-1-khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170103082753.25758-1-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, vbabka@suse.cz, akpm@linux-foundation.org

On Tue 03-01-17 13:57:53, Anshuman Khandual wrote:
> node_isset can give incorrect result if the node number is beyond the
> bitmask size (MAX_NUMNODES in this case) which is not checked inside
> test_bit. Hence check for the bit limits (MAX_NUMNODES) inside the
> node_isset function before calling test_bit.

Could you be more specific when such a thing might happen? Have you seen
any in-kernel user who would give such a bogus node?

> Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
> ---
>  include/linux/nodemask.h | 8 +++++++-
>  1 file changed, 7 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/nodemask.h b/include/linux/nodemask.h
> index 6e66cfd..0aee588b 100644
> --- a/include/linux/nodemask.h
> +++ b/include/linux/nodemask.h
> @@ -139,7 +139,13 @@ static inline void __nodes_clear(nodemask_t *dstp, unsigned int nbits)
>  }
>  
>  /* No static inline type checking - see Subtlety (1) above. */
> -#define node_isset(node, nodemask) test_bit((node), (nodemask).bits)
> +#define node_isset(node, nodemask) node_test_bit(node, nodemask, MAX_NUMNODES)
> +static inline int node_test_bit(int node, nodemask_t nodemask, int maxnodes)
> +{
> +	if (node >= maxnodes)
> +		return 0;
> +	return test_bit((node), (nodemask).bits);
> +}
>  
>  #define node_test_and_set(node, nodemask) \
>  			__node_test_and_set((node), &(nodemask))
> -- 
> 1.8.3.1
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
