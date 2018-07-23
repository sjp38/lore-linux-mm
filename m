Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id C91606B0003
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 19:14:05 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id e93-v6so1406234plb.5
        for <linux-mm@kvack.org>; Mon, 23 Jul 2018 16:14:05 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id az8-v6sor2833442plb.7.2018.07.23.16.14.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 23 Jul 2018 16:14:04 -0700 (PDT)
Date: Mon, 23 Jul 2018 16:14:02 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: thp: remove use_zero_page sysfs knob
In-Reply-To: <91caed46-6437-a137-0dbc-dadd113f8d58@linux.alibaba.com>
Message-ID: <alpine.DEB.2.21.1807231610260.196032@chino.kir.corp.google.com>
References: <1532110430-115278-1-git-send-email-yang.shi@linux.alibaba.com> <20180720210626.5bnyddmn4avp2l3x@kshutemo-mobl1> <3118b646-681e-a2aa-dc7b-71d4821fa50f@linux.alibaba.com> <alpine.DEB.2.21.1807231329080.105582@chino.kir.corp.google.com>
 <91caed46-6437-a137-0dbc-dadd113f8d58@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, hughd@google.com, aaron.lu@intel.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 23 Jul 2018, Yang Shi wrote:

> > > I agree to keep it for a while to let that security bug cool down,
> > > however, if
> > > there is no user anymore, it sounds pointless to still keep a dead knob.
> > > 
> > It's not a dead knob.  We use it, and for reasons other than
> > CVE-2017-1000405.  To mitigate the cost of constantly compacting memory to
> > allocate it after it has been freed due to memry pressure, we can either
> > continue to disable it, allow it to be persistently available, or use a
> > new value for use_zero_page to specify it should be persistently
> > available.
> 
> My understanding is the cost of memory compaction is *not* unique for huge
> zero page, right? It is expected when memory pressure is met, even though huge
> zero page is disabled.
> 

It's caused by fragmentation, not necessarily memory pressure.  We've 
disabled it because compacting for tens of thousands of huge zero pages in 
the background has a noticeable impact on cpu.  Additionally, if the hzp 
cannot be allocated at runtime it increases the rss of applications that 
map it, making it unpredictable.  Making it persistent, as I've been 
suggesting, fixes these issues.
