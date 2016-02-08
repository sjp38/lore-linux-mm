Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 20289828E4
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 14:05:52 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id g62so130143641wme.0
        for <linux-mm@kvack.org>; Mon, 08 Feb 2016 11:05:52 -0800 (PST)
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com. [195.75.94.111])
        by mx.google.com with ESMTPS id h70si18124778wmd.58.2016.02.08.11.05.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 08 Feb 2016 11:05:50 -0800 (PST)
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Mon, 8 Feb 2016 19:05:50 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id C20EF17D8062
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 19:06:01 +0000 (GMT)
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u18J5lMt9371752
	for <linux-mm@kvack.org>; Mon, 8 Feb 2016 19:05:47 GMT
Received: from d06av01.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u18J5k3p015733
	for <linux-mm@kvack.org>; Mon, 8 Feb 2016 12:05:47 -0700
Date: Mon, 8 Feb 2016 20:05:44 +0100
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: Re: [PATCH RFC 1/1] numa: fix /proc/<pid>/numa_maps for THP
Message-ID: <20160208200544.0442b453@thinkpad>
In-Reply-To: <20160205170317.4906cba3@thinkpad>
References: <1454686440-31218-1-git-send-email-gerald.schaefer@de.ibm.com>
	<1454686440-31218-2-git-send-email-gerald.schaefer@de.ibm.com>
	<56B4C1E1.6060408@intel.com>
	<20160205170317.4906cba3@thinkpad>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Michael Holzheu <holzheu@linux.vnet.ibm.com>

On Fri, 5 Feb 2016 17:03:17 +0100
Gerald Schaefer <gerald.schaefer@de.ibm.com> wrote:

> On Fri, 5 Feb 2016 07:38:09 -0800
> Dave Hansen <dave.hansen@intel.com> wrote:
> 
> > On 02/05/2016 07:34 AM, Gerald Schaefer wrote:
> > > +static struct page *can_gather_numa_stats_pmd(pmd_t pmd,
> > > +					      struct vm_area_struct *vma,
> > > +					      unsigned long addr)
> > > +{
> > 
> > Is there a way to do this without making a copy of most of
> > can_gather_numa_stats()?  Seems like the kind of thing where the pmd
> > version will bitrot.
> > 
> 
> Yes, that also gave me a little headache, even more with the vm_normal_page()
> code duplication, but I didn't see a much better way. Separate _pte/_pmd
> functions that largely do the same thing seem not so uncommon to me.
> 
> The best I could think of would be splitting the !HAVE_PTE_SPECIAL path
> in vm_normal_page() into a separate function, but I see not much room for
> improvement for can_gather_numa_stats(), other than maybe not having
> a _pmd version at all and doing all the work inside gather_pte_stats(),
> but that would probably just relocate the code duplication.

Nope, can't see any sane way to prevent the (trivial) code duplication in
can_gather_numa_stats_pmd(). Adding a "common" function for _pte and _pmd
handling (using void *) would be very ugly and given that the duplicated
code is just trivial sanity checks it also seems very disproportionate.
BTW, we also (should) have no "pmd version bitrot" in the countless other
places where we have separate _pte/_pmd versions.

So, any ideas or feedback on the vm_normal_page(_pmd) part?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
