Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id CE2086B0038
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 22:49:49 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id z37so3737092qtz.16
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 19:49:49 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id k6si3450282qta.161.2017.11.29.19.49.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Nov 2017 19:49:49 -0800 (PST)
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id vAU3nlrV023467
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 03:49:47 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id vAU3nkbP002497
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 03:49:46 GMT
Received: from abhmp0014.oracle.com (abhmp0014.oracle.com [141.146.116.20])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id vAU3nkvk003350
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 03:49:46 GMT
Received: by mail-oi0-f51.google.com with SMTP id t81so3952927oih.13
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 19:49:46 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171120170429.315726fb004905314ced614e@linux-foundation.org>
References: <20171115085556.fla7upm3nkydlflp@techsingularity.net>
 <20171115115559.rjb5hy6d6332jgjj@dhcp22.suse.cz> <20171115141329.ieoqvyoavmv6gnea@techsingularity.net>
 <20171115142816.zxdgkad3ch2bih6d@dhcp22.suse.cz> <20171115144314.xwdi2sbcn6m6lqdo@techsingularity.net>
 <20171115145716.w34jaez5ljb3fssn@dhcp22.suse.cz> <06a33f82-7f83-7721-50ec-87bf1370c3d4@gmail.com>
 <20171116085433.qmz4w3y3ra42j2ih@dhcp22.suse.cz> <20171116100633.moui6zu33ctzpjsf@techsingularity.net>
 <CAOAebxt8ZjfCXND=1=UJQETbjVUGPJVcqKFuwGsrwyM2Mq1dhQ@mail.gmail.com> <20171120170429.315726fb004905314ced614e@linux-foundation.org>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Wed, 29 Nov 2017 22:49:45 -0500
Message-ID: <CAOAebxsg=fM1B0sxKFenwShWTK1D2Xkcaw3qGD9dy6Lzw_iMLA@mail.gmail.com>
Subject: Re: [PATCH] mm, meminit: Serially initialise deferred memory if
 trace_buf_size is specified
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, koki.sanagi@us.fujitsu.com, Steve Sistare <steven.sistare@oracle.com>

>> Hi Mel,
>>
>> The forth approach is the best as it is seamless for admins and
>> engineers, it will also work on any system configuration with any
>> parameters without any special involvement.
>
> Apart from what-mel-said, I'd be concerned that this failsafe would
> almost never get tested.  We should find some way to ensure that this
> code gets exercised in some people's kernels on a permanent basis and
> I'm not sure how to do that.
>
> One option might be to ask Fengguang to add the occasional
> test_pavels_stuff=1 to the kernel boot commandline.  That's better
> than nothing but 0-day only runs on a small number of machine types.
>

Hi Andrew,

Excellent point about testing. I think, that if I implement it the way
I proposed in the previous e-mail:

1. initialize very few struct pages initially
2. initialize more as kernel needs them in every node
3. finally initialize all the rest when other cpus are started

We will have coverage for my code every time machine boots (and
deferred page init feature configured), as the the initial very few
struct pages is not going to be enough on any machine. Potentially, we
will also see some small boot time improvement because we will
initialize serially only as many pages as needed, and not do upper
bound guessing about how many pages is needed beforehand.

Thank you,
Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
