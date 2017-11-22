Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8A8056B0038
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 04:43:44 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id r37so12848420qtj.0
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 01:43:44 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id x65si935267qkg.19.2017.11.22.01.43.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 01:43:43 -0800 (PST)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vAM9h2Xh047712
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 04:43:42 -0500
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2ed61ytsxh-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 04:43:42 -0500
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ar@linux.vnet.ibm.com>;
	Wed, 22 Nov 2017 09:43:39 -0000
Date: Wed, 22 Nov 2017 09:43:34 +0000
From: Andrea Reale <ar@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm: migrate: fix an incorrect call of
 prep_transhuge_page()
References: <20171121021855.50525-1-zi.yan@sent.com>
 <20171121141213.89db86bfbd75c22fc0209990@linux-foundation.org>
 <73A54AD9-33E0-4C82-8C9F-6E1786ED6132@cs.rutgers.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <73A54AD9-33E0-4C82-8C9F-6E1786ED6132@cs.rutgers.edu>
Message-Id: <20171122094333.GA24826@samekh>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, =?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, stable@vger.kernel.org

On Tue 21 Nov 2017, 17:35, Zi Yan wrote:
> On 21 Nov 2017, at 17:12, Andrew Morton wrote:
> 
> > On Mon, 20 Nov 2017 21:18:55 -0500 Zi Yan <zi.yan@sent.com> wrote:
> >
> >> This patch fixes it by only calling prep_transhuge_page() when we are
> >> certain that the target page is THP.
> >
> > What are the user-visible effects of the bug?
> 
> By inspecting the code, if called on a non-THP, prep_transhuge_page() will
> 1) change the value of the mapping of (page + 2), since it is used for THP deferred list;
> 2) change the lru value of (page + 1), since it is used for THPa??s dtor.
> 
> Both can lead to data corruption of these two pages.

Pragmatically and from the point of view of the memory_hotplug subsys,
the effect is a kernel crash when pages are being migrated during a memory
hot remove offline and migration target pages are found in a bad state.

Best,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
