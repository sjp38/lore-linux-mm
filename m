Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f176.google.com (mail-ve0-f176.google.com [209.85.128.176])
	by kanga.kvack.org (Postfix) with ESMTP id 319F66B0078
	for <linux-mm@kvack.org>; Thu, 26 Jun 2014 11:05:27 -0400 (EDT)
Received: by mail-ve0-f176.google.com with SMTP id db12so3830865veb.35
        for <linux-mm@kvack.org>; Thu, 26 Jun 2014 08:05:26 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id fa3si4555260vdc.63.2014.06.26.08.05.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jun 2014 08:05:26 -0700 (PDT)
Date: Thu, 26 Jun 2014 11:05:01 -0400
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: Re: [PATCH] x86: numa: setup_node_data(): drop dead code and rename
 function
Message-ID: <20140626110501.78bb611d@redhat.com>
In-Reply-To: <53AC335F.4010308@redhat.com>
References: <20140619222019.3db6ad7e@redhat.com>
	<53AC335F.4010308@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, isimatu.yasuaki@jp.fujitsu.com, yinghai@kernel.org, andi@firstfloor.org, akpm@linux-foundation.org, rientjes@google.com

On Thu, 26 Jun 2014 10:51:11 -0400
Rik van Riel <riel@redhat.com> wrote:

> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
> 
> On 06/19/2014 10:20 PM, Luiz Capitulino wrote:
> 
> > @@ -523,8 +508,17 @@ static int __init numa_register_memblks(struct
> > numa_meminfo *mi) end = max(mi->blk[i].end, end); }
> > 
> > -		if (start < end) -			setup_node_data(nid, start, end); +		if
> > (start >= end) +			continue; + +		/* +		 * Don't confuse VM with a
> > node that doesn't have the +		 * minimum amount of memory: +		 */ +
> > if (end && (end - start) < NODE_MIN_SIZE) +			continue; + +
> > alloc_node_data(nid); }
> 
> Minor nit.  If we skip a too-small node, should we remember that we
> did so, and add its memory to another node, assuming it is physically
> contiguous memory?

Interesting point. Honest question, please disregard if this doesn't
make sense: but won't this affect automatic numa performance? Because
the kernel won't know that that extra memory actually pertains to another
node and hence that extra memory will have a difference distance of the
node that's making use it of it.

If my thinking is wrong or if even then you believe this is a good feature,
I can work on it on a different patch, as this check is not being introduced
by this patch. Although I also wonder how many numa machines have such small
nodes...

> Other than that...
> 
> Acked-by: Rik van Riel <riel@redhat.com>

Thanks!

> 
> - -- 
> All rights reversed
> -----BEGIN PGP SIGNATURE-----
> Version: GnuPG v1
> Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/
> 
> iQEcBAEBAgAGBQJTrDNfAAoJEM553pKExN6DrNgH/j160OIey5moCEFMH51a1e3+
> D6iOIXxsVii5/wqabYuA1DCQ8Asgd/UK2BWdxxRZVZuTHXXn97iifq1IkIPEQxXc
> pjz25/ZFSpa3fgZk8iyUzOQjLukFfkiaO1mSopO7IWwUZoEa9fJ7bOBvwcnFU4oQ
> uZAV375RpxiPEXNh2qQZXX0kNrycZd8S81jUSuQv3OLPRI1EQo+txOg/u7ir0pOJ
> z1fkBK0hiSHziAzB/nyjR/RgSb23vpMlUlPoGMhwCMp08aJkL147bHZvsCtlg/w4
> kBqq/zy9te4ecSicUsX/l16o0SJ9a1JtvFAlqz0iqlGcKQGCEw2P+y0ZyrhfvaE=
> =NOgK
> -----END PGP SIGNATURE-----
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
