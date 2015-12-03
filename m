Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 1A6056B0038
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 03:16:50 -0500 (EST)
Received: by wmec201 with SMTP id c201so14589387wme.0
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 00:16:49 -0800 (PST)
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com. [74.125.82.51])
        by mx.google.com with ESMTPS id f2si10675341wma.46.2015.12.03.00.16.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Dec 2015 00:16:49 -0800 (PST)
Received: by wmww144 with SMTP id w144so11206663wmw.0
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 00:16:49 -0800 (PST)
Date: Thu, 3 Dec 2015 09:16:47 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] Improve Atheros ethernet driver not to do order 4
 GFP_ATOMIC allocation
Message-ID: <20151203081646.GB9264@dhcp22.suse.cz>
References: <20151127082010.GA2500@dhcp22.suse.cz>
 <20151128145113.GB4135@amd>
 <20151130132129.GB21950@dhcp22.suse.cz>
 <20151201.153517.224543138214404348.davem@davemloft.net>
 <CAMXMK6u1vQ772SGv-J3cKvOmS6QRAjjQLYiSiWO2+T=HRTiK1A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAMXMK6u1vQ772SGv-J3cKvOmS6QRAjjQLYiSiWO2+T=HRTiK1A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Snook <chris.snook@gmail.com>
Cc: David Miller <davem@davemloft.net>, pavel@ucw.cz, akpm@osdl.org, linux-kernel@vger.kernel.org, jcliburn@gmail.com, netdev@vger.kernel.org, rjw@rjwysocki.net, linux-mm@kvack.org, nic-devel@qualcomm.com, ronangeles@gmail.com, ebiederm@xmission.com

On Wed 02-12-15 22:43:31, Chris Snook wrote:
> On Tue, Dec 1, 2015 at 12:35 PM David Miller <davem@davemloft.net> wrote:
> 
> > From: Michal Hocko <mhocko@kernel.org>
> > Date: Mon, 30 Nov 2015 14:21:29 +0100
> >
> > > On Sat 28-11-15 15:51:13, Pavel Machek wrote:
> > >>
> > >> atl1c driver is doing order-4 allocation with GFP_ATOMIC
> > >> priority. That often breaks  networking after resume. Switch to
> > >> GFP_KERNEL. Still not ideal, but should be significantly better.
> > >
> > > It is not clear why GFP_KERNEL can replace GFP_ATOMIC safely neither
> > > from the changelog nor from the patch context.
> >
> > Earlier in the function we do a GFP_KERNEL kmalloc so:
> >
> > A?\_(a??)_/A?
> >
> > It should be fine.
> >
> 
> AFAICT, the people who benefit from GFP_ATOMIC are the people running all
> their storage over NFS/iSCSI who are suspending their machines while
> they're so busy they don't have any clean order 4 pagecache to drop, and
> want the machine to panic rather than hang.

Why would GFP_KERNEL order-4 allocation hang? It will fail if there are
not >=4 order pages available even after reclaim and/or compaction.
GFP_ATOMIC allocations should be used only when an access to memory
reserves is really required. If the allocation just doesn't want to
invoke direct reclaim then GFP_NOWAIT is a more suitable alternative.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
