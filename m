Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 97AD26B01F1
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 14:12:21 -0400 (EDT)
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e9.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o7VHs2IY003337
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 13:54:02 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o7VICFXc343882
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 14:12:15 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o7VICDip017473
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 15:12:15 -0300
Subject: Re: [PATCH 0/8] v5 De-couple sysfs memory directories from memory
 sections
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <4C694C60.6030207@austin.ibm.com>
References: <4C60407C.2080608@austin.ibm.com>
	 <20100812120816.e97d8b9e.akpm@linux-foundation.org>
	 <4C694C60.6030207@austin.ibm.com>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Tue, 31 Aug 2010 11:12:12 -0700
Message-ID: <1283278332.7023.11.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nathan Fontenot <nfont@austin.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Greg KH <greg@kroah.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2010-08-16 at 09:34 -0500, Nathan Fontenot wrote:
> > It's not an unresolvable issue, as this is a must-fix problem.  But you
> > should tell us what your proposal is to prevent breakage of existing
> > installations.  A Kconfig option would be good, but a boot-time kernel
> > command line option which selects the new format would be much better.
> 
> This shouldn't break existing installations, unless an architecture chooses
> to do so.  With my patch only the powerpc/pseries arch is updated such that
> what is seen in userspace is different. 

Even if an arch defines the override for the sysfs dir size, I still
don't think this breaks anything (it shouldn't).  We move _all_ of the
directories over, all at once, to a single, uniform size.  The only
apparent change to a user moving kernels would be a larger
block_size_bytes (which is certainly not changing the ABI) and a new
sysfs file for the end of the section.  The new sysfs file is
_completely_ redundant at this point.

The architecture is only supposed to bump up the directory size when it
*KNOWS* that all operations will be done at the larger section size,
such as if the specific hardware has physical DIMMs which are much
larger than SECTION_SIZE.

Let's say we have a system with 20MB of memory, SECTION_SIZE of 1MB and
a sysfs dir size of 4MB.  

Before the patch, we have 20 directories: one for each section.  After
this patch, we have 5 directories.  

The thing that I think is the next step, but that we _will_ probably
need eventually is this, take the 5 sysfs dirs in the above case:

	0->3, 4->7, 8->11, 12->15, 16->19

and turn that into a single one:

	0->19

*That* will require changing the ABI, but we could certainly have some
bloated and slow, but backward-compatible mode.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
