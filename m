Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id AAA1E6B0006
	for <linux-mm@kvack.org>; Fri, 19 Oct 2018 00:33:07 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b34-v6so19829573ede.5
        for <linux-mm@kvack.org>; Thu, 18 Oct 2018 21:33:07 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m17-v6sor7494431eje.24.2018.10.18.21.33.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 18 Oct 2018 21:33:05 -0700 (PDT)
Date: Fri, 19 Oct 2018 04:33:03 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [RFC] put page to pcp->lists[] tail if it is not on the same node
Message-ID: <20181019043303.s5axhjfb2v2lzsr3@master>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: willy@infradead.org, mhocko@suse.com, mgorman@techsingularity.net
Cc: richard.weiyang@gmail.com, linux-mm@kvack.org, akpm@linux-foundation.org

node
Reply-To: Wei Yang <richard.weiyang@gmail.com>

Masters,

During the code reading, I pop up this idea.

    In case we put some intelegence of NUMA node to pcp->lists[], we may
    get a better performance.

The idea is simple:

    Put page on other nodes to the tail of pcp->lists[], because we
    allocate from head and free from tail.

Since my desktop just has one numa node, I couldn't test the effect. I
just run a kernel build test to see if it would degrade current kernel.
The result looks not bad.

                    make -j4 bzImage
           base-line:
           
           real    6m15.947s        
           user    21m14.481s       
           sys     2m34.407s        
           
           real    6m16.089s        
           user    21m18.295s       
           sys     2m35.551s        
           
           real    6m16.239s        
           user    21m17.590s       
           sys     2m35.252s        
           
           patched:
           
           real    6m14.558s
           user    21m18.374s
           sys     2m33.143s
           
           real    6m14.606s
           user    21m14.969s
           sys     2m32.039s
           
           real    6m15.264s
           user    21m16.698s
           sys     2m33.024s

Sorry for sending this without a real justification. Hope this will not
make you uncomfortable. I would be very glad if you suggest some
verifications that I could do.

Below is my testing patch, look forward your comments.
