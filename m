Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id E1F056B0003
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 09:27:20 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id y13-v6so13468751ita.8
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 06:27:20 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id f5-v6si6623459itc.80.2018.07.16.06.27.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jul 2018 06:27:19 -0700 (PDT)
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w6GDNKh8189149
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 13:27:19 GMT
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by aserp2120.oracle.com with ESMTP id 2k7a33vd2c-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 13:27:18 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w6GDRINY028253
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 13:27:18 GMT
Received: from abhmp0012.oracle.com (abhmp0012.oracle.com [141.146.116.18])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w6GDRIKl001309
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 13:27:18 GMT
Received: by mail-oi0-f42.google.com with SMTP id r16-v6so74761551oie.3
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 06:27:17 -0700 (PDT)
MIME-Version: 1.0
References: <20180713165812.ec391548ffeead96725d044c@linux-foundation.org>
 <9b93d48c-b997-01f7-2fd6-6e35301ef263@oracle.com> <CA+55aFxFw2-1BD2UBf_QJ2=faQES_8q==yUjwj4mGJ6Ub4uX7w@mail.gmail.com>
 <5edf2d71-f548-98f9-16dd-b7fed29f4869@oracle.com> <CA+55aFwPAwczHS3XKkEnjY02PaDf2mWrcqx_hket4Ce3nScsSg@mail.gmail.com>
 <CAGM2rebeo3UUo2bL6kXCMGhuM36wjF5CfvqGG_3rpCfBs5S2wA@mail.gmail.com>
 <CA+55aFxetyCqX2EzFBDdHtriwt6UDYcm0chHGQUdPX20qNHb4Q@mail.gmail.com>
 <CAGM2reb2Zk6t=QJtJZPRGwovKKR9bdm+fzgmA_7CDVfDTjSgKA@mail.gmail.com>
 <20180716120642.GN17280@dhcp22.suse.cz> <fc5cfff3-0000-41da-e4d9-3e91ef9d0792@oracle.com>
 <20180716122918.GO17280@dhcp22.suse.cz>
In-Reply-To: <20180716122918.GO17280@dhcp22.suse.cz>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Mon, 16 Jul 2018 09:26:41 -0400
Message-ID: <CAGM2reaM1sCCj8QjkfSrKhTXrj=__DXAFgQkBV2ZN5chKgjzTQ@mail.gmail.com>
Subject: Re: Instability in current -git tree
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, tglx@linutronix.de, willy@infradead.org, mingo@redhat.com, axboe@kernel.dk, gregkh@linuxfoundation.org, davem@davemloft.net, viro@zeniv.linux.org.uk, Dave Airlie <airlied@gmail.com>, Tejun Heo <tj@kernel.org>, Theodore Tso <tytso@google.com>, snitzer@redhat.com, Linux Memory Management List <linux-mm@kvack.org>, neelx@redhat.com, mgorman@techsingularity.net

> Maybe a stupid question, but I do not see it from the code (this init
> code is just to complex to keep it cached in head so I always have to
> study the code again and again, sigh). So what exactly prevents
> memmap_init_zone to stumble over reserved regions? We do play some ugly
> games to find a first !reserved pfn in the node but I do not really see
> anything in the init path to properly skip over reserved holes inside
> the node.

Hi Michal,

This is not a stupid question. I figured out how this whole thing
became broken:  Revert "mm: page_alloc: skip over regions of invalid
pfns where possible" caused that.

Because, before that was reverted, memmap_init_zone() would use
memblock.memory to check that only pages that have physical backing
are initialized. But, now after that was reverted zer_resv_unavail()
scheme became totally broken.

The concept is quite easy: zero all the allocated memmap memory that
has not been initialized by memmap_init_zone(). So, I think I will
modify memmap_init_zone() to zero the skipped pfns that have memmap
backing. But, that requires more thinking.

Thank you,
Pavel
