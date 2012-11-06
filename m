Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id A894F6B0044
	for <linux-mm@kvack.org>; Tue,  6 Nov 2012 16:49:40 -0500 (EST)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Tue, 6 Nov 2012 16:49:38 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 64C0B38C8045
	for <linux-mm@kvack.org>; Tue,  6 Nov 2012 16:49:25 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qA6LnOqL271622
	for <linux-mm@kvack.org>; Tue, 6 Nov 2012 16:49:24 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qA6LnO0n009093
	for <linux-mm@kvack.org>; Tue, 6 Nov 2012 19:49:24 -0200
Message-ID: <509985DE.8000508@linux.vnet.ibm.com>
Date: Tue, 06 Nov 2012 13:49:18 -0800
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 6/8] mm: Demarcate and maintain pageblocks in region-order
 in the zones' freelists
References: <20121106195026.6941.24662.stgit@srivatsabhat.in.ibm.com> <20121106195342.6941.94892.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20121106195342.6941.94892.stgit@srivatsabhat.in.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, mjg59@srcf.ucam.org, paulmck@linux.vnet.ibm.com, maxime.coquelin@stericsson.com, loic.pallardy@stericsson.com, arjan@linux.intel.com, kmpark@infradead.org, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl, gargankita@gmail.com, amit.kachhap@linaro.org, svaidy@linux.vnet.ibm.com, thomas.abraham@linaro.org, santosh.shilimkar@ti.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 11/06/2012 11:53 AM, Srivatsa S. Bhat wrote:
> This is the main change - we keep the pageblocks in region-sorted order,
> where pageblocks belonging to region-0 come first, followed by those belonging
> to region-1 and so on. But the pageblocks within a given region need *not* be
> sorted, since we need them to be only region-sorted and not fully
> address-sorted.
> 
> This sorting is performed when adding pages back to the freelists, thus
> avoiding any region-related overhead in the critical page allocation
> paths.

It's probably _better_ to do it at free time than alloc, but it's still
pretty bad to be doing a linear walk over a potentially 256-entry array
holding the zone lock.  The overhead is going to show up somewhere.  How
does this do with a kernel compile?  Looks like exit() when a process
has a bunch of memory might get painful.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
