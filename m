Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 36A096B20E6
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 12:04:03 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id m123-v6so3446741ite.6
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 09:04:03 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id a206-v6si27534032itd.51.2018.11.20.09.04.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Nov 2018 09:04:01 -0800 (PST)
Date: Tue, 20 Nov 2018 09:03:21 -0800
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: Re: [RFC PATCH v4 05/13] workqueue, ktask: renice helper threads to
 prevent starvation
Message-ID: <20181120170320.2qvlwnpohzxow4bm@ca-dmjordan1.us.oracle.com>
References: <20181105165558.11698-1-daniel.m.jordan@oracle.com>
 <20181105165558.11698-6-daniel.m.jordan@oracle.com>
 <20181113163400.GK2509588@devbig004.ftw2.facebook.com>
 <20181119164554.axobolrufu26kfah@ca-dmjordan1.us.oracle.com>
 <20181120163319.GW2509588@devbig004.ftw2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181120163319.GW2509588@devbig004.ftw2.facebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, linux-mm@kvack.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, aaron.lu@intel.com, akpm@linux-foundation.org, alex.williamson@redhat.com, bsd@redhat.com, darrick.wong@oracle.com, dave.hansen@linux.intel.com, jgg@mellanox.com, jwadams@google.com, jiangshanlai@gmail.com, mhocko@kernel.org, mike.kravetz@oracle.com, Pavel.Tatashin@microsoft.com, prasad.singamsetty@oracle.com, rdunlap@infradead.org, steven.sistare@oracle.com, tim.c.chen@intel.com, vbabka@suse.cz

On Tue, Nov 20, 2018 at 08:33:19AM -0800, Tejun Heo wrote:
> On Mon, Nov 19, 2018 at 08:45:54AM -0800, Daniel Jordan wrote:
> > So instead of flush_work_at_nice, how about this?:
> > 
> > void renice_work_sync(work_struct *work, long nice);
> 
> Wouldn't renice_or_cancel make more sense?

I guess you mean, for renicing if the work is started and canceling if it
hasn't?

Then yes, it would in this case, since if a ktask work hasn't start, there's no
point in running it--there are no more chunks for it to work on.

Was attempting to generalize for other cases when the work did need to be run,
but designing for the future can be dicey, and I'm fine either way.  So absent
other opinions, I'll do renice_or_cancel.
