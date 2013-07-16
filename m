Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 85CB06B0032
	for <linux-mm@kvack.org>; Tue, 16 Jul 2013 08:16:56 -0400 (EDT)
Received: by mail-vc0-f170.google.com with SMTP id hf12so395883vcb.15
        for <linux-mm@kvack.org>; Tue, 16 Jul 2013 05:16:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130715145653.GA7275@medulla.variantweb.net>
References: <CAA_GA1fiEJYxqAZ1c0BneuftB5g8d+2_mYBj=4iE=1EcYaTx7w@mail.gmail.com>
	<20130715145653.GA7275@medulla.variantweb.net>
Date: Tue, 16 Jul 2013 20:16:55 +0800
Message-ID: <CAA_GA1f6=ojtGPOFSECwkvduZo42UmO6hh8S8OiQyayDE__mQA@mail.gmail.com>
Subject: Re: Testing results of zswap
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Nitin Gupta <ngupta@vflare.org>, bob.liu@oracle.com, Mel Gorman <mgorman@suse.de>

Hi Seth,

On Mon, Jul 15, 2013 at 10:56 PM, Seth Jennings
<sjenning@linux.vnet.ibm.com> wrote:
> On Mon, Jul 15, 2013 at 10:56:17AM +0800, Bob Liu wrote:
>> As my test results showed in this thread.
>> 1. Zswap only useful when total ram size is large else the performance
>> was worse than disabled it!
>
> I have not observed this.  In my kernbench runs, I was using VMs with ~512MB
> of RAM and saw significant improvement from zswap.
>

Could you confirm the results?  Since zswap changed a lot from the beginning.
I tried with 1G of RAM based on kernel v3.10 with you zswap patches,
but there isn't performance improvement.
I have no idea what's the problem might be.

Using make -j4:

kernbench
                               base1              frontswa
                              base1G             frontswap
User    min        1025.27 (  0.00%)     1024.79 (  0.05%)
User    mean       1025.27 (  0.00%)     1024.79 (  0.05%)
User    stddev        0.00 (  0.00%)        0.00 (  0.00%)
User    max        1025.27 (  0.00%)     1024.79 (  0.05%)
System  min          52.07 (  0.00%)       52.56 ( -0.94%)
System  mean         52.07 (  0.00%)       52.56 ( -0.94%)
System  stddev        0.00 (  0.00%)        0.00 (  0.00%)
System  max          52.07 (  0.00%)       52.56 ( -0.94%)
Elapsed min         374.21 (  0.00%)      370.52 (  0.99%)
Elapsed mean        374.21 (  0.00%)      370.52 (  0.99%)
Elapsed stddev        0.00 (  0.00%)        0.00 (  0.00%)
Elapsed max         374.21 (  0.00%)      370.52 (  0.99%)
CPU     min         287.00 (  0.00%)      290.00 ( -1.05%)
CPU     mean        287.00 (  0.00%)      290.00 ( -1.05%)
CPU     stddev        0.00 (  0.00%)        0.00 (  0.00%)
CPU     max         287.00 (  0.00%)      290.00 ( -1.05%)

               base1    frontswa
              base1G   frontswap
User         1027.02     1026.44
System         52.90       53.49
Elapsed       401.51      404.19

                                  base1    frontswa
                                 base1G   frontswap
Page Ins                        1526804     1531812
Page Outs                       2230280     2229688
Swap Ins                            440           0
Swap Outs                          2743           2
---------------------------------------------
You can see that the swapins/swapouts reduced significantly. But the
run time didn't reduced accordingly.

The same result by using make -j16:
kernbench
                               base1              frontsw1
                              base16             frontsw16
User    min        1071.42 (  0.00%)     1067.70 (  0.35%)
User    mean       1071.42 (  0.00%)     1067.70 (  0.35%)
User    stddev        0.00 (  0.00%)        0.00 (  0.00%)
User    max        1071.42 (  0.00%)     1067.70 (  0.35%)
System  min          56.29 (  0.00%)       57.06 ( -1.37%)
System  mean         56.29 (  0.00%)       57.06 ( -1.37%)
System  stddev        0.00 (  0.00%)        0.00 (  0.00%)
System  max          56.29 (  0.00%)       57.06 ( -1.37%)
Elapsed min         360.41 (  0.00%)      357.24 (  0.88%)
Elapsed mean        360.41 (  0.00%)      357.24 (  0.88%)
Elapsed stddev        0.00 (  0.00%)        0.00 (  0.00%)
Elapsed max         360.41 (  0.00%)      357.24 (  0.88%)
CPU     min         312.00 (  0.00%)      314.00 ( -0.64%)
CPU     mean        312.00 (  0.00%)      314.00 ( -0.64%)
CPU     stddev        0.00 (  0.00%)        0.00 (  0.00%)
CPU     max         312.00 (  0.00%)      314.00 ( -0.64%)

               base1    frontsw1
              base16   frontsw16
User         1073.24     1069.44
System         57.14       57.91
Elapsed       387.61      389.91

                                  base1    frontsw1
                                 base16   frontsw16
Page Ins                        1783848     1774536
Page Outs                       2241616     2238868
Swap Ins                            612          22
Swap Outs                          2569          40

--
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
