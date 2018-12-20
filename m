Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 543BD8E0002
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 06:35:53 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id l45so2082577edb.1
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 03:35:53 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x55si2048937eda.76.2018.12.20.03.35.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Dec 2018 03:35:51 -0800 (PST)
Date: Thu, 20 Dec 2018 12:35:47 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCHv2 2/3] mm/numa: build zonelist when alloc for device on
 offline node
Message-ID: <20181220113547.GC9104@dhcp22.suse.cz>
References: <1545299439-31370-1-git-send-email-kernelfans@gmail.com>
 <1545299439-31370-3-git-send-email-kernelfans@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1545299439-31370-3-git-send-email-kernelfans@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pingfan Liu <kernelfans@gmail.com>
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Bjorn Helgaas <bhelgaas@google.com>, Jonathan Cameron <Jonathan.Cameron@huawei.com>, David Rientjes <rientjes@google.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>

On Thu 20-12-18 17:50:38, Pingfan Liu wrote:
[...]
> @@ -453,7 +456,12 @@ static inline int gfp_zonelist(gfp_t flags)
>   */
>  static inline struct zonelist *node_zonelist(int nid, gfp_t flags)
>  {
> -	return NODE_DATA(nid)->node_zonelists + gfp_zonelist(flags);
> +	if (unlikely(!possible_zonelists[nid])) {
> +		WARN_ONCE(1, "alloc from offline node: %d\n", nid);
> +		if (unlikely(build_fallback_zonelists(nid)))
> +			nid = first_online_node;
> +	}
> +	return possible_zonelists[nid] + gfp_zonelist(flags);
>  }

No, please don't do this. We do not want to make things work magically
and we definitely do not want to put something like that into the hot
path. We definitely need zonelists to be build transparently for all
possible nodes during the init time.
-- 
Michal Hocko
SUSE Labs
