Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id A1B1B6B1B2E
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 11:02:29 -0500 (EST)
Received: by mail-yb1-f198.google.com with SMTP id y125-v6so14038526ybe.22
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 08:02:29 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id 184-v6si16300806ybt.182.2018.11.19.08.02.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 08:02:27 -0800 (PST)
Date: Mon, 19 Nov 2018 08:01:38 -0800
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: Re: [RFC PATCH v4 11/13] mm: parallelize deferred struct page
 initialization within each node
Message-ID: <20181119160137.72zha7dbsr3adkfs@ca-dmjordan1.us.oracle.com>
References: <20181105165558.11698-1-daniel.m.jordan@oracle.com>
 <20181105165558.11698-12-daniel.m.jordan@oracle.com>
 <AT5PR8401MB1169798EBEF1EE5EBA3ABFFFABC70@AT5PR8401MB1169.NAMPRD84.PROD.OUTLOOK.COM>
 <20181112165412.vizeiv6oimsuxkbk@ca-dmjordan1.us.oracle.com>
 <AT5PR8401MB1169B05F889BCF8EF113E053ABC10@AT5PR8401MB1169.NAMPRD84.PROD.OUTLOOK.COM>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AT5PR8401MB1169B05F889BCF8EF113E053ABC10@AT5PR8401MB1169.NAMPRD84.PROD.OUTLOOK.COM>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Elliott, Robert (Persistent Memory)" <elliott@hpe.com>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "aarcange@redhat.com" <aarcange@redhat.com>, "aaron.lu@intel.com" <aaron.lu@intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "alex.williamson@redhat.com" <alex.williamson@redhat.com>, "bsd@redhat.com" <bsd@redhat.com>, "darrick.wong@oracle.com" <darrick.wong@oracle.com>, "dave.hansen@linux.intel.com" <dave.hansen@linux.intel.com>, "jgg@mellanox.com" <jgg@mellanox.com>, "jwadams@google.com" <jwadams@google.com>, "jiangshanlai@gmail.com" <jiangshanlai@gmail.com>, "mhocko@kernel.org" <mhocko@kernel.org>, "mike.kravetz@oracle.com" <mike.kravetz@oracle.com>, "Pavel.Tatashin@microsoft.com" <Pavel.Tatashin@microsoft.com>, "prasad.singamsetty@oracle.com" <prasad.singamsetty@oracle.com>, "rdunlap@infradead.org" <rdunlap@infradead.org>, "steven.sistare@oracle.com" <steven.sistare@oracle.com>, "tim.c.chen@intel.com" <tim.c.chen@intel.com>, "tj@kernel.org" <tj@kernel.org>, "vbabka@suse.cz" <vbabka@suse.cz>

On Mon, Nov 12, 2018 at 10:15:46PM +0000, Elliott, Robert (Persistent Memory) wrote:
> 
> 
> > -----Original Message-----
> > From: Daniel Jordan <daniel.m.jordan@oracle.com>
> > Sent: Monday, November 12, 2018 11:54 AM
> > To: Elliott, Robert (Persistent Memory) <elliott@hpe.com>
> > Cc: Daniel Jordan <daniel.m.jordan@oracle.com>; linux-mm@kvack.org;
> > kvm@vger.kernel.org; linux-kernel@vger.kernel.org; aarcange@redhat.com;
> > aaron.lu@intel.com; akpm@linux-foundation.org; alex.williamson@redhat.com;
> > bsd@redhat.com; darrick.wong@oracle.com; dave.hansen@linux.intel.com;
> > jgg@mellanox.com; jwadams@google.com; jiangshanlai@gmail.com;
> > mhocko@kernel.org; mike.kravetz@oracle.com; Pavel.Tatashin@microsoft.com;
> > prasad.singamsetty@oracle.com; rdunlap@infradead.org;
> > steven.sistare@oracle.com; tim.c.chen@intel.com; tj@kernel.org;
> > vbabka@suse.cz
> > Subject: Re: [RFC PATCH v4 11/13] mm: parallelize deferred struct page
> > initialization within each node
> > 
> > On Sat, Nov 10, 2018 at 03:48:14AM +0000, Elliott, Robert (Persistent
> > Memory) wrote:
> > > > -----Original Message-----
> > > > From: linux-kernel-owner@vger.kernel.org <linux-kernel-
> > > > owner@vger.kernel.org> On Behalf Of Daniel Jordan
> > > > Sent: Monday, November 05, 2018 10:56 AM
> > > > Subject: [RFC PATCH v4 11/13] mm: parallelize deferred struct page
> > > > initialization within each node
> > > >
> ...
> > > > In testing, a reasonable value turned out to be about a quarter of the
> > > > CPUs on the node.
> > > ...
> > > > +	/*
> > > > +	 * We'd like to know the memory bandwidth of the chip to
> > > >         calculate the
> > > > +	 * most efficient number of threads to start, but we can't.
> > > > +	 * In testing, a good value for a variety of systems was a
> > > >         quarter of the CPUs on the node.
> > > > +	 */
> > > > +	nr_node_cpus = DIV_ROUND_UP(cpumask_weight(cpumask), 4);
> > >
> > >
> > > You might want to base that calculation on and limit the threads to
> > > physical cores, not hyperthreaded cores.
> > 
> > Why?  Hyperthreads can be beneficial when waiting on memory.  That said, I
> > don't have data that shows that in this case.
> 
> I think that's only if there are some register-based calculations to do while
> waiting. If both threads are just doing memory accesses, they'll both stall, and
> there doesn't seem to be any benefit in having two contexts generate the IOs
> rather than one (at least on the systems I've used). I think it takes longer
> to switch contexts than to just turnaround the next IO.

(Sorry for the delay, Plumbers is over now...)

I guess we're both just waving our hands without data.  I've only got x86, so
using a quarter of the CPUs rules out HT on my end.  Do you have a system that
you can test this on, where using a quarter of the CPUs will involve HT?

Thanks,
Daniel
