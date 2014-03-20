Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 393AC6B01AA
	for <linux-mm@kvack.org>; Thu, 20 Mar 2014 06:04:58 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id kp14so714062pab.19
        for <linux-mm@kvack.org>; Thu, 20 Mar 2014 03:04:57 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id uk5si1100614pab.314.2014.03.20.03.04.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 20 Mar 2014 03:04:57 -0700 (PDT)
Message-ID: <532ABD0D.8020607@oracle.com>
Date: Thu, 20 Mar 2014 18:03:57 +0800
From: Bob Liu <bob.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: performance regression due to commit e82e0561("mm: vmscan: obey
 proportional scanning requirements for kswapd")
References: <20140218080122.GO26593@yliu-dev.sh.intel.com>
In-Reply-To: <20140218080122.GO26593@yliu-dev.sh.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yuanhan Liu <yuanhan.liu@linux.intel.com>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 02/18/2014 04:01 PM, Yuanhan Liu wrote:
> Hi,
> 
> Commit e82e0561("mm: vmscan: obey proportional scanning requirements for
> kswapd") caused a big performance regression(73%) for vm-scalability/
> lru-file-readonce testcase on a system with 256G memory without swap.
> 
> That testcase simply looks like this:
>      truncate -s 1T /tmp/vm-scalability.img
>      mkfs.xfs -q /tmp/vm-scalability.img
>      mount -o loop /tmp/vm-scalability.img /tmp/vm-scalability
> 
>      SPARESE_FILE="/tmp/vm-scalability/sparse-lru-file-readonce"
>      for i in `seq 1 120`; do
>          truncate $SPARESE_FILE-$i -s 36G
>          timeout --foreground -s INT 300 dd bs=4k if=$SPARESE_FILE-$i of=/dev/null
>      done
> 
>      wait
> 
> Actually, it's not the newlly added code(obey proportional scanning)
> in that commit caused the regression. But instead, it's the following
> change:
> +
> +               if (nr_reclaimed < nr_to_reclaim || scan_adjusted)
> +                       continue;
> +
> 
> 
> -               if (nr_reclaimed >= nr_to_reclaim &&
> -                   sc->priority < DEF_PRIORITY)
> +               if (global_reclaim(sc) && !current_is_kswapd())
>                         break;
> 
> The difference is that we might reclaim more than requested before
> in the first round reclaimming(sc->priority == DEF_PRIORITY).
> 

>From my understanding, I also think we used to reclaim more memory if
sc->priority==DEF_PRIORITY. See the while loop:

while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
                                       nr[LRU_INACTIVE_FILE]) {

For kswapd, the loop will continue until nr[LRU_INACTIVE_ANON],
nr[LRU_ACTIVE_FILE] and nr[LRU_INACTIVE_FILE] become zero.

But in commit e82e0561("mm: vmscan: obey proportional scanning
requirements for kswapd"), nr[lru] was set to 0.

/* Stop scanning the smaller of the LRU */
nr[lru] = 0;
nr[lru + LRU_ACTIVE] = 0;

And the other LRU scan count was also recalculated, as a result the
total scan count in this round may less than original code.

So I think this change is reasonable which make the behaviour the same
as before(also no performance drop).

-- 
Regards,
-Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
