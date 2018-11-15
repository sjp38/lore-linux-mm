Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6A4046B034F
	for <linux-mm@kvack.org>; Thu, 15 Nov 2018 09:25:40 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id v4so8059612edm.18
        for <linux-mm@kvack.org>; Thu, 15 Nov 2018 06:25:40 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a18-v6si1750284edj.47.2018.11.15.06.25.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Nov 2018 06:25:38 -0800 (PST)
Date: Thu, 15 Nov 2018 15:25:35 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Memory hotplug softlock issue
Message-ID: <20181115142535.GU23831@dhcp22.suse.cz>
References: <20181114090134.GG23419@dhcp22.suse.cz>
 <20181114145250.GE2653@MiWiFi-R3L-srv>
 <20181114150029.GY23419@dhcp22.suse.cz>
 <20181115051034.GK2653@MiWiFi-R3L-srv>
 <20181115073052.GA23831@dhcp22.suse.cz>
 <20181115075349.GL2653@MiWiFi-R3L-srv>
 <20181115083055.GD23831@dhcp22.suse.cz>
 <20181115131211.GP2653@MiWiFi-R3L-srv>
 <20181115131927.GT23831@dhcp22.suse.cz>
 <20181115132342.GQ2653@MiWiFi-R3L-srv>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181115132342.GQ2653@MiWiFi-R3L-srv>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baoquan He <bhe@redhat.com>
Cc: pifang@redhat.com, David Hildenbrand <david@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, aarcange@redhat.com

On Thu 15-11-18 21:23:42, Baoquan He wrote:
> On 11/15/18 at 02:19pm, Michal Hocko wrote:
> > On Thu 15-11-18 21:12:11, Baoquan He wrote:
> > > On 11/15/18 at 09:30am, Michal Hocko wrote:
> > [...]
> > > > It would be also good to find out whether this is fs specific. E.g. does
> > > > it make any difference if you use a different one for your stress
> > > > testing?
> > > 
> > > Created a ramdisk and put stress bin there, then run stress -m 200, now
> > > seems it's stuck in libc-2.28.so migrating. And it's still xfs. So now xfs
> > > is a big suspect. At bottom I paste numactl printing, you can see that it's
> > > the last 4G.
> > > 
> > > Seems it's trying to migrate libc-2.28.so, but stress program keeps trying to
> > > access and activate it.
> > 
> > Is this still with faultaround disabled? I have seen exactly same
> > pattern in the bug I am working on. It was ext4 though.
> 
> No, forgot disabling faultround after reboot. Do we need to disable it and
> retest?

No the faultaround is checked at the time of the fault. The reason why I
am suspecting this path is that it can elevate the reference count
before taking the lock. Normal page fault path should lock the page
first. And we hold the lock while trying to migrate that page.
-- 
Michal Hocko
SUSE Labs
