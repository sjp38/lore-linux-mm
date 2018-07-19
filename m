Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 28B686B0003
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 10:28:25 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id l5-v6so6068688ioh.4
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 07:28:25 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id x131-v6si3419978itf.134.2018.07.19.07.28.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jul 2018 07:28:24 -0700 (PDT)
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w6JENtdZ048877
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 14:28:23 GMT
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by userp2120.oracle.com with ESMTP id 2k9yjx7c4f-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 14:28:23 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w6JESLLa022839
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 14:28:21 GMT
Received: from abhmp0006.oracle.com (abhmp0006.oracle.com [141.146.116.12])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w6JESLnt024643
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 14:28:21 GMT
Received: by mail-it0-f50.google.com with SMTP id q20-v6so9977323ith.0
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 07:28:21 -0700 (PDT)
MIME-Version: 1.0
References: <20180719132740.32743-1-osalvador@techadventures.net>
 <20180719132740.32743-6-osalvador@techadventures.net> <20180719134622.GE7193@dhcp22.suse.cz>
 <20180719135859.GA10988@techadventures.net> <20180719140308.GG7193@dhcp22.suse.cz>
In-Reply-To: <20180719140308.GG7193@dhcp22.suse.cz>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Thu, 19 Jul 2018 10:27:44 -0400
Message-ID: <CAGM2reZ-+njLtZSnNpry11frg85KmMk4WWxGdaqk1o4BUJVO1w@mail.gmail.com>
Subject: Re: [PATCH v2 5/5] mm/page_alloc: Only call pgdat_set_deferred_range
 when the system boots
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: osalvador@techadventures.net, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, osalvador@suse.de

On Thu, Jul 19, 2018 at 10:03 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Thu 19-07-18 15:58:59, Oscar Salvador wrote:
> > On Thu, Jul 19, 2018 at 03:46:22PM +0200, Michal Hocko wrote:
> > > On Thu 19-07-18 15:27:40, osalvador@techadventures.net wrote:
> > > > From: Oscar Salvador <osalvador@suse.de>
> > > >
> > > > We should only care about deferred initialization when booting.
> > >
> > > Again why is this worth doing?
> >
> > Well, it is not a big win if that is what you meant.
> >
> > Those two fields are only being used when dealing with deferred pages,
> > which only happens at boot time.
> >
> > If later on, free_area_init_node gets called from memhotplug code,
> > we will also set the fields, although they will not be used.
> >
> > Is this a problem? No, but I think it is more clear from the code if we
> > see when this is called.
> > So I would say it was only for code consistency.
>
> Then put it to the changelog.
>
> > If you think this this is not worth, I am ok with dropping it.
>
> I am not really sure. I am not a big fan of SYSTEM_BOOTING global
> thingy so I would rather not spread its usage.

I agree, I do not think this patch is necessary. Calling
pgdat_set_deferred_range() does not hurt in hotplug context, and it is
cheap too. SYSTEM_BOOTING sometimes useful, but it is better to use it
only where necessary, where without this "if" we will encounter some
bugs.

Thank you,
Pavel
