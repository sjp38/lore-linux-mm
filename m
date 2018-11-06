Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9F7076B039C
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 15:51:58 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id d8-v6so10591239wmb.5
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 12:51:58 -0800 (PST)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50077.outbound.protection.outlook.com. [40.107.5.77])
        by mx.google.com with ESMTPS id x65-v6si2519551wme.127.2018.11.06.12.51.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 06 Nov 2018 12:51:57 -0800 (PST)
From: Jason Gunthorpe <jgg@mellanox.com>
Subject: Re: [RFC PATCH v4 01/13] ktask: add documentation
Date: Tue, 6 Nov 2018 20:51:54 +0000
Message-ID: <20181106205146.GB30490@mellanox.com>
References: <20181105165558.11698-1-daniel.m.jordan@oracle.com>
 <20181105165558.11698-2-daniel.m.jordan@oracle.com>
 <20181106084911.GA22504@hirez.programming.kicks-ass.net>
 <20181106203411.pdce6tgs7dncwflh@ca-dmjordan1.us.oracle.com>
In-Reply-To: <20181106203411.pdce6tgs7dncwflh@ca-dmjordan1.us.oracle.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <5D06AA0EB35F9848AAEE468B33AEEB0F@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Peter Zijlstra <peterz@infradead.org>, "rjw@rjwysocki.net" <rjw@rjwysocki.net>, "linux-pm@vger.kernel.org" <linux-pm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "aarcange@redhat.com" <aarcange@redhat.com>, "aaron.lu@intel.com" <aaron.lu@intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "alex.williamson@redhat.com" <alex.williamson@redhat.com>, "bsd@redhat.com" <bsd@redhat.com>, "darrick.wong@oracle.com" <darrick.wong@oracle.com>, "dave.hansen@linux.intel.com" <dave.hansen@linux.intel.com>, "jwadams@google.com" <jwadams@google.com>, "jiangshanlai@gmail.com" <jiangshanlai@gmail.com>, "mhocko@kernel.org" <mhocko@kernel.org>, "mike.kravetz@oracle.com" <mike.kravetz@oracle.com>, "Pavel.Tatashin@microsoft.com" <Pavel.Tatashin@microsoft.com>, "prasad.singamsetty@oracle.com" <prasad.singamsetty@oracle.com>, "rdunlap@infradead.org" <rdunlap@infradead.org>, "steven.sistare@oracle.com" <steven.sistare@oracle.com>, "tim.c.chen@intel.com" <tim.c.chen@intel.com>, "tj@kernel.org" <tj@kernel.org>, "vbabka@suse.cz" <vbabka@suse.cz>

On Tue, Nov 06, 2018 at 12:34:11PM -0800, Daniel Jordan wrote:

> > What isn't clear is if this calling thread is waiting or not. Only do
> > this inheritance trick if it is actually waiting on the work. If it is
> > not, nobody cares.
>=20
> The calling thread waits.  Even if it didn't though, the inheritance tric=
k
> would still be desirable for timely completion of the job.

Can you make lockdep aware that this is synchronous?

ie if I do

  mutex_lock()
  ktask_run()
  mutex_lock()

Can lockdep know that all the workers are running under that lock?

I'm thinking particularly about rtnl_lock as a possible case, but
there could also make some sense to hold the read side of the mm_sem
or similar like the above.

Jason
