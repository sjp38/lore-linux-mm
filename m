Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id DA6906B0292
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 11:43:21 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id j29so9383264wre.1
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 08:43:21 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v187si1879617wmf.101.2017.08.30.08.43.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 30 Aug 2017 08:43:19 -0700 (PDT)
Date: Wed, 30 Aug 2017 17:43:15 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: possible circular locking dependency
 mmap_sem/cpu_hotplug_lock.rw_sem
Message-ID: <20170830154315.sa57wasw64rvnuhe@dhcp22.suse.cz>
References: <20170807140947.nhfz2gel6wytl6ia@shodan.usersys.redhat.com>
 <alpine.DEB.2.20.1708161605050.1987@nanos>
 <20170830141543.qhipikpog6mkqe5b@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170830141543.qhipikpog6mkqe5b@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Artem Savkov <asavkov@redhat.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org

The previous patch is insufficient. drain_all_stock can still race with
the memory offline callback and the underlying memcg disappear. So we
need to be more careful and pin the css on the memcg. This patch
instead...
---
