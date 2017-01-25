Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 41F876B0253
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 11:56:35 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id y143so277540676pfb.6
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 08:56:35 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id k186si23938849pgd.113.2017.01.25.08.56.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jan 2017 08:56:34 -0800 (PST)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0PGrhmU072275
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 11:56:33 -0500
Received: from e23smtp03.au.ibm.com (e23smtp03.au.ibm.com [202.81.31.145])
	by mx0b-001b2d01.pphosted.com with ESMTP id 286tr66e11-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 11:56:33 -0500
Received: from localhost
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Thu, 26 Jan 2017 02:56:30 +1000
Received: from d23relay10.au.ibm.com (d23relay10.au.ibm.com [9.190.26.77])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id F2F163578056
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 03:56:27 +1100 (EST)
Received: from d23av06.au.ibm.com (d23av06.au.ibm.com [9.190.235.151])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v0PGuJXV35651676
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 03:56:27 +1100
Received: from d23av06.au.ibm.com (localhost [127.0.0.1])
	by d23av06.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v0PGttmE014284
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 03:55:55 +1100
Date: Wed, 25 Jan 2017 08:55:22 -0800
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH 01/12] uprobes: split THPs before trying replace them
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20170124162824.91275-1-kirill.shutemov@linux.intel.com>
 <20170124162824.91275-2-kirill.shutemov@linux.intel.com>
 <20170124132849.73135e8c6e9572be00dbbe79@linux-foundation.org>
 <20170124222217.GB19920@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20170124222217.GB19920@node.shutemov.name>
Message-Id: <20170125165522.GA11569@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>

> > 
> > > For THPs page_check_address() always fails. It's better to split them
> > > first before trying to replace.
> > 
> > So what does this mean.  uprobes simply fails to work when trying to
> > place a probe into a THP memory region?
> 
> Looks like we can end up with endless retry loop in uprobe_write_opcode().
> 
> > How come nobody noticed (and reported) this when using the feature?
> 
> I guess it's not often used for anon memory.
> 

The first time the breakpoint is hit on a page, it replaces the text
page with anon page.  Now lets assume we insert breakpoints in all the
pages in a range. Here each page is individually replaced by a non THP
anonpage. (since we dont have bulk breakpoint insertion support,
breakpoint insertion happens one at a time). Now the only interesting
case may be when each of these replaced pages happen to be physically
contiguous so that THP kicks in to replace all of these pages with one
THP page. Can happen in practice?

Are there any other cases that I have missed?

-- 
Thanks and Regards
Srikar Dronamraju

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
