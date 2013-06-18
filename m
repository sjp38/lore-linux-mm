Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 95A4F6B0032
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 08:29:23 -0400 (EDT)
Received: by mail-vc0-f182.google.com with SMTP id id13so2820057vcb.41
        for <linux-mm@kvack.org>; Tue, 18 Jun 2013 05:29:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130617160200.27bb5d82df09a26adb8efce5@linux-foundation.org>
References: <1370291585-26102-1-git-send-email-sjenning@linux.vnet.ibm.com>
	<1370291585-26102-4-git-send-email-sjenning@linux.vnet.ibm.com>
	<CAA_GA1eWFYDxp3gEdWzajVP4jMpmJbt=oWBZYqZEQjndU=s_Qg@mail.gmail.com>
	<20130617160200.27bb5d82df09a26adb8efce5@linux-foundation.org>
Date: Tue, 18 Jun 2013 20:29:22 +0800
Message-ID: <CAA_GA1cLD7-AW45VkU9Tx9os7Pu5jaW3UkrVaQu--ecQ2x9j_g@mail.gmail.com>
Subject: Re: [PATCHv13 3/4] zswap: add to mm/
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@sr71.net>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Hugh Dickens <hughd@google.com>, Paul Mackerras <paulus@samba.org>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>

>
> I'm not sure how representative this is of real workloads, but it does
> look rather fatal for zswap.  The differences are so large, I wonder if
> it's just some silly bug or config issue.
>

In my observation, zswap_pool_pages always close to zswap_stored_pages
in this testing.
I think it means that the fragmentation of zswap is heavy.
Since in idea state number of zswap pool pages should be half of stored pages.

The reason may be this workload is not suitable for compression.
The data of it can't be compressed to a low percent.
It can only compressed to around 70% percent(not exactly but at least
above 50%).

I made a simple patch to limit the fragment of zswap to 70%.
The result can be better but still not positive.
                                         v3.10-rc4                   v3.10-rc4
                               2G-parallio-nozswap     2G-parallio-zswapdefrag
Ops memcachetest-0M              1041.00 (  0.00%)           1058.00 (  1.63%)
Ops memcachetest-198M             973.00 (  0.00%)           1019.00 (  4.73%)
Ops memcachetest-430M             892.00 (  0.00%)            831.00 ( -6.84%)
Ops memcachetest-661M             819.00 (  0.00%)            850.00 (  3.79%)
Ops memcachetest-893M             775.00 (  0.00%)            784.00 (  1.16%)
Ops memcachetest-1125M            764.00 (  0.00%)            766.00 (  0.26%)
Ops memcachetest-1356M            749.00 (  0.00%)            782.00 (  4.41%)
Ops io-duration-0M                  0.00 (  0.00%)              0.00 (  0.00%)
Ops io-duration-198M               21.00 (  0.00%)             28.00 (-33.33%)
Ops io-duration-430M               29.00 (  0.00%)             32.00 (-10.34%)
Ops io-duration-661M               34.00 (  0.00%)             34.00 (  0.00%)
Ops io-duration-893M               36.00 (  0.00%)             42.00 (-16.67%)
Ops io-duration-1125M              43.00 (  0.00%)             47.00 ( -9.30%)
Ops io-duration-1356M              50.00 (  0.00%)             49.00 (  2.00%)
Ops swaptotal-0M               469193.00 (  0.00%)         461146.00 (  1.72%)
Ops swaptotal-198M             496201.00 (  0.00%)         495692.00 (  0.10%)
Ops swaptotal-430M             520400.00 (  0.00%)         520252.00 (  0.03%)
Ops swaptotal-661M             538872.00 (  0.00%)         513541.00 (  4.70%)
Ops swaptotal-893M             522590.00 (  0.00%)         532311.00 ( -1.86%)
Ops swaptotal-1125M            526934.00 (  0.00%)         527089.00 ( -0.03%)
Ops swaptotal-1356M            525241.00 (  0.00%)         525747.00 ( -0.10%)
Ops swapin-0M                  251226.00 (  0.00%)         248426.00 (  1.11%)
Ops swapin-198M                236126.00 (  0.00%)         239031.00 ( -1.23%)
Ops swapin-430M                265193.00 (  0.00%)         266174.00 ( -0.37%)
Ops swapin-661M                280281.00 (  0.00%)         263151.00 (  6.11%)
Ops swapin-893M                263004.00 (  0.00%)         268473.00 ( -2.08%)
Ops swapin-1125M               261962.00 (  0.00%)         264925.00 ( -1.13%)
Ops swapin-1356M               262571.00 (  0.00%)         266695.00 ( -1.57%)
Ops minorfaults-0M             625759.00 (  0.00%)         620448.00 (  0.85%)
Ops minorfaults-198M           769752.00 (  0.00%)         703458.00 (  8.61%)
Ops minorfaults-430M           678590.00 (  0.00%)         686257.00 ( -1.13%)
Ops minorfaults-661M           669308.00 (  0.00%)         668845.00 (  0.07%)
Ops minorfaults-893M           656343.00 (  0.00%)         680286.00 ( -3.65%)
Ops minorfaults-1125M          657954.00 (  0.00%)         655280.00 (  0.41%)
Ops minorfaults-1356M          672035.00 (  0.00%)         659861.00 (  1.81%)
Ops majorfaults-0M              39395.00 (  0.00%)          38828.00 (  1.44%)
Ops majorfaults-198M            38758.00 (  0.00%)          42876.00 (-10.62%)
Ops majorfaults-430M            39819.00 (  0.00%)          38668.00 (  2.89%)
Ops majorfaults-661M            40171.00 (  0.00%)          38443.00 (  4.30%)
Ops majorfaults-893M            37576.00 (  0.00%)          37664.00 ( -0.23%)
Ops majorfaults-1125M           36891.00 (  0.00%)          37527.00 ( -1.72%)
Ops majorfaults-1356M           37123.00 (  0.00%)          37779.00 ( -1.77%)

--
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
