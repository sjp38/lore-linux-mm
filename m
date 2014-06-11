Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id B46626B0146
	for <linux-mm@kvack.org>; Wed, 11 Jun 2014 00:30:12 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id rq2so7019938pbb.3
        for <linux-mm@kvack.org>; Tue, 10 Jun 2014 21:30:12 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id bw8si5159093pad.133.2014.06.10.21.30.10
        for <linux-mm@kvack.org>;
        Tue, 10 Jun 2014 21:30:11 -0700 (PDT)
Date: Wed, 11 Jun 2014 13:34:04 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2] vmalloc: use rcu list iterator to reduce
 vmap_area_lock contention
Message-ID: <20140611043404.GA14728@js1304-P5Q-DELUXE>
References: <1402453146-10057-1-git-send-email-iamjoonsoo.kim@lge.com>
 <5397CDC3.1050809@hurleysoftware.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5397CDC3.1050809@hurleysoftware.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Hurley <peter@hurleysoftware.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Zhang Yanfei <zhangyanfei.yes@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Richard Yao <ryao@gentoo.org>, Eric Dumazet <eric.dumazet@gmail.com>

On Tue, Jun 10, 2014 at 11:32:19PM -0400, Peter Hurley wrote:
> PF: none (google.com: peter@hurleysoftware.com does not designate permitted sender hosts) client-ip=216.70.64.70;
> Received: from h96-61-95-138.cntcnh.dsl.dynamic.tds.net ([96.61.95.138]:55986 helo=[192.168.1.139])
> 	by n23.mail01.mtsvc.net with esmtpsa (TLSv1:AES128-SHA:128)
> 	(Exim 4.72)
> 	(envelope-from <peter@hurleysoftware.com>)
> 	id 1WuZGw-00064f-2L; Tue, 10 Jun 2014 23:32:22 -0400
> Message-ID: <5397CDC3.1050809@hurleysoftware.com>
> Date: Tue, 10 Jun 2014 23:32:19 -0400
> From: Peter Hurley <peter@hurleysoftware.com>
> User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:24.0) Gecko/20100101 Thunderbird/24.5.0
> MIME-Version: 1.0
> To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton
> <akpm@linux-foundation.org>
> CC: Zhang Yanfei <zhangyanfei.yes@gmail.com>, Johannes Weiner
> <hannes@cmpxchg.org>,
> Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org,
> linux-kernel@vger.kernel.org, Richard Yao <ryao@gentoo.org>, Eric
> Dumazet <eric.dumazet@gmail.com>
> Subject: Re: [PATCH v2] vmalloc: use rcu list iterator to reduce vmap_area_lock
> contention
> References: <1402453146-10057-1-git-send-email-iamjoonsoo.kim@lge.com>
> In-Reply-To: <1402453146-10057-1-git-send-email-iamjoonsoo.kim@lge.com>
> Content-Type: text/plain; charset=UTF-8; format=flowed
> Content-Transfer-Encoding: 7bit
> X-Authenticated-User: 990527 peter@hurleysoftware.com
> X-MT-ID: 8FA290C2A27252AACF65DBC4A42F3CE3735FB2A4
> X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
> Sender: owner-linux-mm@kvack.org
> Precedence: bulk
> X-Loop: owner-majordomo@kvack.org
> List-ID: <linux-mm.kvack.org>
> Status: O
> Content-Length: 3338
> Lines: 96
> 
> On 06/10/2014 10:19 PM, Joonsoo Kim wrote:
> >Richard Yao reported a month ago that his system have a trouble
> >with vmap_area_lock contention during performance analysis
> >by /proc/meminfo. Andrew asked why his analysis checks /proc/meminfo
> >stressfully, but he didn't answer it.
> >
> >https://lkml.org/lkml/2014/4/10/416
> >
> >Although I'm not sure that this is right usage or not, there is a solution
> >reducing vmap_area_lock contention with no side-effect. That is just
> >to use rcu list iterator in get_vmalloc_info().
> >
> >rcu can be used in this function because all RCU protocol is already
> >respected by writers, since Nick Piggin commit db64fe02258f1507e13fe5
> >("mm: rewrite vmap layer") back in linux-2.6.28
> 
> While rcu list traversal over the vmap_area_list is safe, this may
> arrive at different results than the spinlocked version. The rcu list
> traversal version will not be a 'snapshot' of a single, valid instant
> of the entire vmap_area_list, but rather a potential amalgam of
> different list states.

Hello,

Yes, you are right, but I don't think that we should be strict here.
Meminfo is already not a 'snapshot' at specific time. While we try to
get certain stats, the other stats can change.
And, although we may arrive at different results than the spinlocked
version, the difference would not be large and would not make serious
side-effect.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
