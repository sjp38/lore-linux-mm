Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 8A2574403D8
	for <linux-mm@kvack.org>; Fri,  5 Feb 2016 11:03:29 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id p63so32937031wmp.1
        for <linux-mm@kvack.org>; Fri, 05 Feb 2016 08:03:29 -0800 (PST)
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com. [195.75.94.109])
        by mx.google.com with ESMTPS id u187si15512353wmu.82.2016.02.05.08.03.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 05 Feb 2016 08:03:28 -0800 (PST)
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Fri, 5 Feb 2016 16:03:27 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id E011817D805F
	for <linux-mm@kvack.org>; Fri,  5 Feb 2016 16:03:36 +0000 (GMT)
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u15G3O4L41418968
	for <linux-mm@kvack.org>; Fri, 5 Feb 2016 16:03:24 GMT
Received: from d06av01.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u15G3Ngj021129
	for <linux-mm@kvack.org>; Fri, 5 Feb 2016 09:03:23 -0700
Date: Fri, 5 Feb 2016 17:03:17 +0100
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: Re: [PATCH RFC 1/1] numa: fix /proc/<pid>/numa_maps for THP
Message-ID: <20160205170317.4906cba3@thinkpad>
In-Reply-To: <56B4C1E1.6060408@intel.com>
References: <1454686440-31218-1-git-send-email-gerald.schaefer@de.ibm.com>
	<1454686440-31218-2-git-send-email-gerald.schaefer@de.ibm.com>
	<56B4C1E1.6060408@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Michael Holzheu <holzheu@linux.vnet.ibm.com>

On Fri, 5 Feb 2016 07:38:09 -0800
Dave Hansen <dave.hansen@intel.com> wrote:

> On 02/05/2016 07:34 AM, Gerald Schaefer wrote:
> > +static struct page *can_gather_numa_stats_pmd(pmd_t pmd,
> > +					      struct vm_area_struct *vma,
> > +					      unsigned long addr)
> > +{
> 
> Is there a way to do this without making a copy of most of
> can_gather_numa_stats()?  Seems like the kind of thing where the pmd
> version will bitrot.
> 

Yes, that also gave me a little headache, even more with the vm_normal_page()
code duplication, but I didn't see a much better way. Separate _pte/_pmd
functions that largely do the same thing seem not so uncommon to me.

The best I could think of would be splitting the !HAVE_PTE_SPECIAL path
in vm_normal_page() into a separate function, but I see not much room for
improvement for can_gather_numa_stats(), other than maybe not having
a _pmd version at all and doing all the work inside gather_pte_stats(),
but that would probably just relocate the code duplication.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
